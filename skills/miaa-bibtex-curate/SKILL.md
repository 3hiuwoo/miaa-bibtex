---
name: miaa-bibtex-curate
description: The full from-scratch flow for a batch of papers, composing acquire, complete, decide, and verify. Use when the user hands over a batch of papers to add to a survey's .bib tree and wants the whole job done: official BibTeX fetched, fields completed, keys and titles decided, entries placed, and everything verified. Loads miaa-bibtex-core and runs the stage skills in order.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Curate: the full from-scratch flow

Load `miaa-bibtex-core` first, then run these stage skills in order. Each stage loads core
itself; do not restate its rules here. Run the dependency preflight in core before anything
else, and resolve the batch into `WORK/papers.csv` if the caller has not already.

| Step | Skill | Aim | Stop when |
|---|---|---|---|
| 1 | `miaa-bibtex-acquire` | Official BibTeX for new papers, staged and marked | Totals show `0 empty`, or what is left is listed for handover |
| 2 | `miaa-bibtex-complete` | Fill missing field values | No `upstream_only` or `conflict` row remains that a source can satisfy |
| 3 | `miaa-bibtex-verify` | Structure, gates, official re-check | Structural gates pass; key and title findings are handed to `miaa-bibtex-decide` |
| 4 | `miaa-bibtex-decide` | Keys, title case, braces, taxonomy | Keys are final, titles and braces decided, entries placed |
| 5 | Write the run report | Core format | The report is shown to the user |

Order matters: keys become final in step 4, before any PDF is named. Structure is settled
(step 3) before content, so `decide` sets keys and titles on a clean tree. `miaa-bibtex-pdfs` and
`miaa-bibtex-scholar` are side flows the user runs after; PDFs need final keys. Handover
points, from the master table in core, are the rows each stage cannot finish; they seed the
run report's checklists.

## Output

The batch's `.bib` entries, complete, keyed, placed, and verified; the run report.
