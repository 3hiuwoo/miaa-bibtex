---
name: miaa-bibtex-pdfs
description: Download each entry's PDF and save it as CITATION_KEY.pdf, then verify the library. Use when the user wants the PDFs for a batch or tree fetched and named by citation key, when aligning a PDF folder with a .bib, or when renaming reference-manager exports. Keys must be final first. Runs under the miaa-bibtex-curate composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# PDFs: fetch and name by citation key

Load `miaa-bibtex-core` first. One aim: give every entry its PDF, named
`<citation key>.pdf`. Only for papers in the `.bib`, with keys final. Rules:
`$CORE/references/miaa-conventions.md` section 7.

**Destination**: the folder the user names; if none is named, create a new folder for this
batch, for example `pdfs/<batch-name>/`, named after the ids file or the date, and state its
path in the report.

## Find

Climb the retrieval ladder in core for each source in the order of conventions section 7;
when the retry budget of one source is spent, move to the next; then the human list. IEEE
Xplore, SpringerLink, ACM, and Elsevier may need the user's institutional access through
rung 3. Per-source PDF locations: `$CORE/references/retrieval-playbook.md`. Harvest the PDF
URL from the paper page, or from the `pdf` field some exports carry.

## Save

Save or rename directly to `<key>.pdf`, since the key is known. For a folder exported from a
reference manager (`Author - Year - Title.pdf`), use the title matcher:

```bash
bibcc librarian rename bib/<file>.bib <pdf folder> --dry-run   # preview
bibcc librarian rename bib/<file>.bib <pdf folder>             # apply
```

It takes the text after the last ` - ` as the title. Ambiguous titles (conference and journal
versions) are reported, not renamed.

## Verify

```bash
bibcc librarian missing bib/ <pdf folder> --skip-empty   # exit 1 lists entries without a PDF
bibcc librarian extra   bib/ <pdf folder>                # PDFs without an entry
```

`--skip-empty` leaves out empty entries, whose BibTeX is still missing. The report goes next
to the first path. Unresolved PDFs go in the run report's To do now list, one line each with
the URL and the target `<folder>/<key>.pdf`.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: the `missing_pdfs.txt` entries.

## Output

PDFs saved as `<key>.pdf`; the missing and extra lists reviewed; unresolved items handed over.
