---
name: miaa-bibtex-review
description: Audit and repair a .bib file or tree that already exists, composing verify, complete, and decide. Use when the user wants existing entries reviewed, re-checked against their official BibTeX, or fixed, whether or not bibcc created them. Loads miaa-bibtex-core and runs the stage skills in order.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Review: audit and repair an existing tree

Load `miaa-bibtex-core` first, then run these stage skills in order. Use when entries already
exist and the user wants them audited or repaired, not acquired.

| Step | Skill | Aim | Stop when |
|---|---|---|---|
| 1 | `miaa-bibtex-verify` | Structure, gates, official re-check | Every gate passes; mismatches investigated |
| 2 | `miaa-bibtex-complete` | Fill values the audit found missing | No `upstream_only` or `conflict` row remains that a source can satisfy |
| 3 | `miaa-bibtex-decide` | Keys, title case, braces, taxonomy, as needed | The narrowed scope is done |
| 4 | Write the run report | Core format | The report is shown to the user |

Narrow the scope by request: a review may be one check, one file, or one concern such as
quotation. Skip a stage when the request excludes it.

## Output

The audited `.bib` files, repaired where a source could supply a fix; the run report naming
what the human must finish.
