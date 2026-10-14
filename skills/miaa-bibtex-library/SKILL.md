---
name: miaa-bibtex-library
description: Audit and complete the venue library, the shared asset behind complete. Use to seed or import a venue library, fill missing venue records from official pages, reconcile records across editions and venues, promote a survey's project library to the user library, or hand a lab-wide venue upstream. This is asset-driven work on the library itself, not on a single entry. Runs under the miaa-bibtex-refresh composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Library: audit and complete the venue library

Load `miaa-bibtex-core` first. One aim: make the venue library correct and complete. The
discriminator against `miaa-bibtex-complete`: entry-driven work is complete; asset-driven work
on the library itself is here. The schema and the month rules are in
`$CORE/references/miaa-conventions.md` and `$CORE/references/bibcc-workflow.md`.

## Where and seed

```bash
bibcc venues where                  # which libraries apply, their sizes, what the project overrides
bibcc venues init --scope project   # empty project library (./.bibcc-venues.yaml)
bibcc venues import miaa --scope project   # seed from the lab's shared library, once, then commit
bibcc venues import .bibcc-venues.yaml --dry-run   # preview merging a project library into the user library
bibcc venues examples               # list the shared libraries in BibCC's examples/venues/
```

The project library (`.bibcc-venues.yaml`, committed) pools records through git for every
coauthor. The user library is personal and cross-survey.

## Audit and fill

```bash
bibcc check venues                  # records one edition has and another lacks
bibcc check editions bib/<file>.bib --against bib/   # fields the venue's other entries have
```

Fill the blanks in `.bibcc/<file>/missing_venues.yaml` from the official conference or journal
page. ISBN and ISSN, month, and location are on the proceedings front matter or the venue's
site. Month rules: one month means that month; an event across two months, or a non-monthly
journal, gets `none`; a journal record leaves month blank because each issue has its own.
Never copy the previous edition's month. Then apply:

```bash
bibcc complete bib/<file>.bib --in-place --update-venues --scope project
```

## Reconcile and promote

When `official_venues.txt` reports `library_lacks` or `library_differs`, fix the record, then
overwrite the entries that copied it:
`bibcc complete bib/<file>.bib --in-place --resolve library --fields F1,F2`. When `check
venues` reports a cross-edition gap, fill the record from the official page of that edition.
To reuse a survey's venues elsewhere, merge its project library into the user library once the
user agrees (it only adds; differing values are kept and reported):
`bibcc venues import .bibcc-venues.yaml`, then without `--dry-run`. Venues worth having
lab-wide go upstream into BibCC's `examples/venues/miaa.yaml` by pull request.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: `official_venues.txt` (`library_lacks`,
`library_differs`), the `check venues` cross-edition gaps, and the `missing_venues.yaml` blank
values and blank `month`.

## Output

Library records filled, fixed, and promoted; the entries that copied a fixed record updated;
the `miaa.yaml` upstream proposal named when relevant.
