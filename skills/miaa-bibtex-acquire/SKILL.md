---
name: miaa-bibtex-acquire
description: Acquire official BibTeX for new papers that are not yet in the survey's .bib tree. Use when the user hands over a batch of papers to add (a list, CSV, pasted text, DOIs, arXiv IDs, URLs, or titles) and wants their official BibTeX fetched and staged. Runs under the miaa-bibtex-curate composer or when the user names this stage. Loads miaa-bibtex-core for all rules.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Acquire: official BibTeX for new papers

Load `miaa-bibtex-core` first. One aim: get the official BibTeX for papers that are not yet
in the tree, and stage it. This skill does not complete fields, decide keys, or place
entries. Use it when a batch of papers is known. Choosing the papers, from a list, CSV,
pasted text, or the agent's own search, is the caller's job.

## Input

Produce the manifest `WORK/papers.csv` with the header `identifier,method,venue,year,key`
and one row per paper. `identifier` is the best available: DOI, else official paper-page
URL, else arXiv ID, else the exact title (quote it in CSV if it has a comma). Fill `method`
(the paper's own name for its method), `venue` (key abbreviation such as `CVPR`), and `year`
(edition year) when the input or a glance at the paper gives them; leave a cell empty to let
bibcc guess. Use `key` only to force a whole key. A plain `ids.txt`, one identifier per
line, also works, but then every key part is a guess.

- OpenReview forum URLs and ECVA pages cannot be read by bibcc: use the title.
- Titles must match exactly, ignoring case and punctuation: resolve paraphrased or truncated
  titles to the exact one first.
- Keep the other side information the input carried (setting, topic) in WORK: it feeds the
  taxonomy decision in `miaa-bibtex-decide`.
- Dedupe is automatic with `--against bib/`; a paper already present is reported, not
  re-added. A published paper whose preprint is already in the tree is flagged too.

## Retrieve

```bash
cd <survey repo>
bibcc add --from .bibcc/work/<batch>/papers.csv --against bib/ --output added.bib
bibcc upgrade added.bib --in-place   # interim CVF/OpenReview becomes proceedings BibTeX where already out
```

Keep `add` at its default `--fallback` (hard rule 1). The last lines of the run give the totals and group
the papers left to do by what to do next. Then read `.bibcc/added.bib/add.txt`: one row per
paper with a status and a `next` value.

By status:

- `official`: done. `interim` (CVF or OpenReview): mark it, below.
- `empty` and `failed` with `next` = `by hand` or `retry`: climb the retrieval ladder in
  core with the row's URL (`retry`: run `--retry` once first). `wait`: leave the empty
  entry; nobody can get its BibTeX yet. `check`: correct the identifier in the manifest.
  Save each official BibTeX you get as `WORK/exports/<key>.bib`, with a `% source: <URL>`
  line just above the entry, then import them all at once:

  ```bash
  bibcc add .bibcc/work/<batch>/exports/ --against bib/ --output added.bib
  ```

  A paper that matches an empty entry fills it in place and keeps its key; the row's status
  becomes `official`. For `failed` rows, `bibcc add --retry --output added.bib` tries every
  empty entry and failed paper again; run it after a pause, not in a loop. Move on when the
  totals show `0 empty`, or list what is left in the run report.
- `duplicate` and `metadata`: follow their rows in the master table.

The unresolved rows, sorted by `next`, seed the run report's checklists.

## Mark interim entries

Mark every interim, preprint, and empty entry as core requires (hard rule 5; conventions
section 5), and key an accepted-but-unpublished paper by its accepting venue now (hard
rule 4), so its key doesn't change at upgrade time.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: the `add.txt` rows with `next` = `by hand`,
`retry`, or `check`, and with status `interim`, `duplicate`, or `metadata`; the
`official_unchecked.txt` rows with `next` = `by hand` or `retry`; and the `add` log's
cross-month `month` note.

## Output

`added.bib` with official or interim entries, marked; `WORK/exports/` with any BibTeX you
fetched yourself; the `add.txt` rows you resolved or handed over. Hand keys to
`miaa-bibtex-decide` before any PDF is named.
