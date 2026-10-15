---
name: miaa-bibtex-scholar
description: Add Google Scholar citation counts to entries, or verify titles against publisher records. Use when the user wants citation counts on a batch or a tree, or wants entry titles checked against CrossRef, arXiv, and Semantic Scholar. Citation counts are added only on demand. Runs when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Scholar: citation counts and title checks

Load `miaa-bibtex-core` first. Two small aims, both optional and on demand.

## Citation counts

```bash
bibcc scholar cite bib/<file>.bib -i
```

The human types each Google Scholar count into a `citation` field. Where it goes and when to
add it: `$CORE/references/miaa-conventions.md` sections 2 and 3.

## Verify titles

```bash
bibcc scholar titles bib/<file>.bib
```

Reports entries whose title disagrees with CrossRef, arXiv, or Semantic Scholar. A mismatch
usually means the wrong paper: hand it to `miaa-bibtex-verify`, which owns the `mismatch` row.

## Output

`citation` fields filled when asked; a title report reviewed or handed over.
