---
name: miaa-bibtex-verify
description: Audit the structure and syntax of entries against the rules and bibcc's reports, and investigate what bibcc could not compare. Use to run the check suite (missing fields, field typos and bad values, keys, duplicates, empty entries), the format gate, and the PDF-library gate; to re-check existing entries against their official BibTeX; or to investigate mismatch and unchecked rows. Scope is tunable by the request, for example only check quotation or only one file. Applies to any .bib file or folder, whether or not bibcc created it. Runs under any composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Verify: audit structure and investigate reports

Load `miaa-bibtex-core` first. One aim: find and fix structural and syntactic problems in
entries, and investigate what bibcc could not compare. This is the review entry point and the
final gate before delivery. It audits content it did not author, so it works on any existing
tree.

Scope is tunable. The request may narrow this skill to one check or one file. Default to the
full gate when nothing is narrowed.

## The check suite and gates

`check` takes one file at a time; `format` and `upgrade --report-only` take directories.

```bash
bibcc format bib/ --in-place
for f in $(find bib -name '*.bib' -not -path '*/.bibcc/*'); do
  bibcc check missing "$f" --strict                 || echo "FAIL missing: $f"
  bibcc check fields  "$f" --against bib/ --strict  || echo "FAIL fields: $f"
  bibcc check keys    "$f" --strict                 || echo "FAIL keys: $f"
  bibcc check editions "$f" --against bib/ --strict || echo "FAIL editions: $f"
  bibcc check title "$f"                            # hints
  bibcc check quote "$f"                            # hints; reads the terms files
done
bibcc format bib/ --check              # must exit 0
```

Every gate line must pass; fix what it reports, in `bib/.bibcc/<file>.bib/`. `missing` exempts
venues whose record says `month: none` and fields outside the venue's schema. `editions` fails
only on entries that lack a field of their venue's schema; its schema proposals
(`edition_schemas.txt`) go to `miaa-bibtex-library`. Title-case and brace findings are hints,
not failures; hand them to `miaa-bibtex-decide`.

## Re-check existing entries against the official BibTeX

For entries that came from elsewhere (a colleague, Google Scholar, an older run), compare them
with their official BibTeX again, one file at a time:

```bash
bibcc check official bib/<file>.bib --delay 2 --learn --scope project   # entries: official_fields.txt; venues and schemas: official_venues.txt
bibcc check official bib/<file>.bib --local .bibcc/work/<batch>/exports/ --offline   # AAAI, ACM, Elsevier
bibcc check editions bib/<file>.bib --against bib/   # entries against the schemas just learned
bibcc check venues                                   # library records one edition has and another lacks
```

`check official --strict` fails on `upstream_only`, `differs`, and `type` findings; run it on
the files this batch touched, not the whole tree, because it downloads every entry again (a
rerun within 30 days reads the disk cache; `--refresh` downloads again). The
`--apply` step that adds back missing official fields belongs to `miaa-bibtex-complete`; this
skill runs the comparison and investigates the rows it owns.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: the `official_unchecked.txt` rows with
`mismatch`, and the `official_unchecked.txt` rows with `next` = `by hand` when you are
auditing existing entries rather than acquiring new ones. The `check venues` log rows belong
to `miaa-bibtex-library`.

## The PDF-library gate

```bash
bibcc librarian missing bib/ <pdf folder> --skip-empty   # exit 1 lists entries without a PDF
bibcc librarian extra   bib/ <pdf folder>                # PDFs without an entry
```

`--skip-empty` leaves out empty entries, whose BibTeX is still missing. Missing PDFs go to
`miaa-bibtex-pdfs`.

## Output

A pass or fail per gate with exit statuses; the reports reviewed; the rows you resolved or
handed over. Name any decision only the human can make.
