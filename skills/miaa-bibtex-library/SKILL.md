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
bibcc venues import miaa --scope project   # only if preflight's config profile didn't seed it
bibcc venues import .bibcc-venues.yaml --dry-run   # preview merging a project library into the user library
bibcc venues examples               # list the shared libraries in BibCC's examples/venues/
```

Preflight's `bibcc config profile miaa --scope project` normally seeds the project library,
together with the survey's config and terms file. The project library (`.bibcc-venues.yaml`, committed)
pools records through git for every coauthor. The user library is personal and cross-survey.

## Audit and fill

```bash
bibcc check venues                  # records one edition has and another lacks; shared values
bibcc check venues --scope project --apply   # move the values every edition shares into family records
bibcc venues providers              # where each conference's official BibTeX comes from
bibcc check official bib/<file>.bib --learn --scope project   # learn each venue's schema
bibcc check editions bib/<file>.bib --against bib/   # schemas proposed for venues without one
```

Fill the blanks in `.bibcc/<file>/missing_venues.yaml` from the official conference or journal
page. ISBN and ISSN, month, and location are on the proceedings front matter or the venue's
site. Month rules: `$CORE/references/miaa-conventions.md` section 2, and the blank-`month` row
of the master table. Then apply:

```bash
bibcc complete bib/<file>.bib --in-place --update-venues --scope project
```

## Reconcile and promote

When `official_venues.txt` reports `library_lacks` or `library_differs`, fix the record, then
overwrite the entries that copied it:
`bibcc complete bib/<file>.bib --in-place --resolve library --fields F1,F2`. When `check
venues` reports a cross-edition gap, fill the record from the official page of that edition.
When it lists fields that every edition shares, run `bibcc check venues --scope project
--apply`: it moves them into the conference's family record, creating it when missing, and
deletes them from the editions without changing any edition's fields. Never move them by
hand. The family records also carry where a conference's official BibTeX comes from;
`bibcc venues providers` prints the table that applies, built in or set by a family record.

## Venue schemas

A schema (`entry_fields`) lists the per-paper fields a venue's official BibTeX has; `check
editions` checks entries against it and `check missing` skips fields outside it. bibcc learns
them: `check official --learn` from the downloaded BibTeX, and `check editions --learn` from
the entries alone. For `schema_lacks` and `schema_differs` rows, follow the
master table in `miaa-bibtex-core`.
To reuse a survey's venues elsewhere, merge its project library into the user library once the
user agrees (it only adds; differing values are kept and reported):
`bibcc venues import .bibcc-venues.yaml`, then without `--dry-run`. Venues worth having
lab-wide go upstream into BibCC's `examples/venues/miaa.yaml` by pull request, and lab-wide
layout settings into `examples/config/miaa.yaml`.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: `official_venues.txt` (`library_lacks`,
`library_differs`, `schema_lacks`, `schema_differs`), `edition_schemas.txt`
(`schema_lacks`, `schema_differs`), the `check venues` cross-edition gaps and shared values, and the
`missing_venues.yaml` blank values and blank `month`.

## Output

Library records filled, fixed, and promoted; the entries that copied a fixed record updated;
the `miaa.yaml` upstream proposal named when relevant.
