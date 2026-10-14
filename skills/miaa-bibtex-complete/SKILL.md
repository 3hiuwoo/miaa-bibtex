---
name: miaa-bibtex-complete
description: Fill the missing field values of entries, from the venue library and the official pages, and reconcile entries with their official BibTeX. Use when entries are incomplete (missing month, pages, doi, isbn, and so on), when bibcc reports upstream_only, differs, or local_only fields, when an entry needs the fields its venue's other entries have, or when interim fields must be removed. Runs under any composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Complete: fill entry values

Load `miaa-bibtex-core` first. One aim: make each entry's field values correct and complete.
This is entry-driven work: the trigger is "this entry is wrong or incomplete". Asset-driven
work on the venue library belongs to `miaa-bibtex-library`. The required set per type and the
month rules are in `$CORE/references/miaa-conventions.md` section 2.

## Venue-shared fields

publisher, isbn, issn, month, location, address, series, editor. Never type them into
entries. Run `bibcc complete`, fill the blanks in `.bibcc/<file>/missing_venues.yaml` from the
official conference or journal page, then apply through the library:

```bash
bibcc complete bib/<file>.bib --online
bibcc complete bib/<file>.bib --in-place --update-venues --scope project
```

The month rules matter here: an event across two months, or a non-monthly journal, gets
`month: none`, never a guess. The project library (`.bibcc-venues.yaml`, committed) learns
the venue once for every coauthor. When a library record turns out wrong, fix the record,
then overwrite the entries that copied it:
`bibcc complete bib/<file>.bib --in-place --resolve library --fields F1,F2`. Filling the YAML
blanks and fixing records is the boundary with `miaa-bibtex-library`: when the work is driven
by a wrong entry, do the small in-flow record write here; when it is driven by the library
itself, hand it to `miaa-bibtex-library`.

## Entry-specific fields

pages, volume, number, doi, url, articleno, day. The official export normally has them. Let
bibcc compare first:

```bash
bibcc check official bib/<file>.bib                     # downloads each entry's official BibTeX again
bibcc check official bib/<file>.bib --apply pages,doi   # add official values the entries lack
bibcc check editions bib/<file>.bib --against bib/      # fields the venue's other entries have
```

For AAAI, ACM, and Elsevier, bibcc cannot download: fetch the official BibTeX by the ladder
into `WORK/exports/<key>.bib` (with the `% source: <URL>` line) and compare with
`--local .bibcc/work/<batch>/exports/ --offline`. Only for a field no export has, read it off
the official paper page of the same source as the BibTeX and patch the entry by hand, keeping
every official value as exported. `url` is never patched: if the official export has none,
the entry has none.

## Interim leftovers

Fields that only the interim or preprint version has belong to that version. Upgrade drops
them; remove any that remain:

```bash
bibcc check fields bib/<file>.bib --apply
```

Never copy them back from the input list, the old entry, or WORK, and never use the CVF page
as a `url` for IEEE Xplore BibTeX. `check fields` also reports AAAI-style `@article` entries
as `conference_article`; `bibcc complete FILE --in-place` retypes them.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: `official_fields.txt` (`upstream_only`,
`differs`, `local_only`), `edition_fields.txt` (`same_year`, `other_years`),
`conflicts.txt`, and `field_issues.txt`. The `official_venues.txt` rows and the
`missing_venues.yaml` blanks belong to `miaa-bibtex-library`.

## Output

Entries with their field values filled or reconciled; a diff or in-place edit; the venue
library updated in flow when a record was the source.
