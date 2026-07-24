#!/usr/bin/env python3
"""Compute the "house shape" of a repo from a local mirror of its PR JSON.

This is the receipt behind the match-the-house-shape skill: rather than assert what
a house merges, it computes it. Point it at a directory of PR JSON files (one per PR,
each with a top-level `pr` object carrying additions/deletions/changed_files/title/
created_at/merged_at, and an optional top-level `files` list of {filename}) and it
prints the median shape of the MERGED subset.

The corpus itself is not shipped (it's large and repo-specific). To reproduce the
numbers in the skill's RECEIPT, mirror the PRs first, e.g. with the GitHub CLI:

    for n in $(gh pr list --repo apache/solr --state merged --limit 5000 \
                  --json number --jq '.[].number'); do
      gh pr view "$n" --repo apache/solr \
        --json number,title,additions,deletions,changedFiles,createdAt,mergedAt,state,files \
        > "corpus/pr-$n.json"
    done

then:  python3 tools/house-shape.py corpus/

Usage: house-shape.py <corpus-dir>   (dir of *.json PR files)
"""
import json, glob, re, sys, statistics as st
from collections import Counter
from datetime import datetime


def load_merged(corpus_dir):
    merged = []
    for fp in glob.glob(f"{corpus_dir}/*.json"):
        try:
            d = json.load(open(fp))
        except Exception:
            continue
        pr = d.get("pr", d)  # accept {pr:{...}} or a flat PR object
        if not isinstance(pr, dict) or not pr.get("merged_at"):
            continue
        adds, dels, cf = pr.get("additions"), pr.get("deletions"), pr.get("changed_files")
        if adds is None or dels is None or cf is None:
            continue
        fnames = [x.get("filename", "") for x in d.get("files", []) if isinstance(x, dict)]
        test_touch = any("test" in fn.lower() for fn in fnames) if fnames else None
        title = pr.get("title", "") or ""
        has_key = bool(re.match(r"\s*[A-Z]+-\d+", title))
        ttm = None
        try:
            c = datetime.fromisoformat(pr["created_at"].replace("Z", "+00:00"))
            m = datetime.fromisoformat(pr["merged_at"].replace("Z", "+00:00"))
            ttm = (m - c).total_seconds() / 86400.0
        except Exception:
            pass
        merged.append(dict(adds=adds, dels=dels, churn=adds + dels, cf=cf,
                           test_touch=test_touch, has_key=has_key, ttm=ttm))
    return merged


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    merged = load_merged(sys.argv[1])
    n = len(merged)
    if not n:
        sys.exit("No merged PRs found — check the corpus dir and JSON shape.")

    def med(key):
        xs = [m[key] for m in merged if m.get(key) is not None]
        return st.median(xs) if xs else None

    tt = [m["test_touch"] for m in merged if m["test_touch"] is not None]
    print(f"MERGED PRs in corpus: {n}")
    print(f"median additions:  +{med('adds'):.0f}")
    print(f"median deletions:  -{med('dels'):.0f}")
    print(f"median churn:       {med('churn'):.0f}")
    print(f"median changed_files: {med('cf'):.0f}")
    if tt:
        print(f"test-file-touch rate: {100.0 * sum(tt) / len(tt):.1f}% (n={len(tt)} with file lists)")
    print(f"title starts with a tracker key: {100.0 * sum(m['has_key'] for m in merged) / n:.1f}%")
    ttms = [m["ttm"] for m in merged if m["ttm"] is not None]
    if ttms:
        print(f"median days-to-merge: {st.median(ttms):.1f}")
    buckets = Counter()
    for m in merged:
        c = m["churn"]
        buckets["<=10" if c <= 10 else "11-50" if c <= 50 else "51-200" if c <= 200
                else "201-1000" if c <= 1000 else "1000+"] += 1
    print("churn buckets:", dict(buckets))


if __name__ == "__main__":
    main()
