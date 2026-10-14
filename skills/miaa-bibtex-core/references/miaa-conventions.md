# MIAA BibTeX and PDF conventions

Lab-wide rules for survey bibliographies. Per-survey details (taxonomy files, LaTeX
wiring, PDF folder) are read from each repo.

Precedence: official BibTeX values as exported → fields added from the bibcc venue
library or the official paper page (never overwrite official ones) → these conventions →
`bibcc format` layout.

## 1. Citation keys

- Grammar: `Method_FirstAuthorSurname_VenueYear`.
- Method: the paper's own method/system name, casing and punctuation preserved
  (`CODA-Prompt`, `HiDe-PET`, `PASS++`); otherwise the first two content words of the
  title. Decide it from the title and abstract; open the paper if ambiguous.
- Author: first author's surname only, ASCII-folded, name particles joined (`vandeVen`,
  `Gomez-Villa`, `McDonnell`).
- Venue: uppercase abbreviation (`CVPR`, `ICCV`, `ECCV`, `NeurIPS`, `ICLR`, `ICML`, `AAAI`,
  `WACV`, `TPAMI`, `IJCV`, `TNNLS`, `PR`, `CoLLAs`…); workshops `CVPRW`, `ICCVW`.
- Year: the **edition year**, appended without a delimiter. It may differ from `year`:
  ECCV 2024 papers are `_ECCV2024` with `year = {2025}`; an accepted preprint is keyed by
  the accepting venue (`_AAAI2026` with `year = {2025}`).
- Preprints with no accepted venue: `_arXiv<year>`.
- **Finality**: the key is fixed at Flow A step A4, before any PDF is named. Changing a
  key afterwards means renaming its PDF and every `\cite` in the same change.
- Examples: `CPP_Li_WACV2024`, `L2P_Wang_CVPR2022`, `RCS-Prompt_Yang_ECCV2024`,
  `EWC_Kirkpatrick_PNAS2017`, `PASS++_Zhu_TPAMI2025`, `CLTypes_vandeVen_arXiv2018`.

## 2. Entry types and fields

| Type | Required | Keep if the official export provides |
|------|----------|--------------------------------------|
| `@inproceedings` | title, author, year, month (see Month), booktitle, publisher, pages, doi, isbn, issn, location | address, series, volume, number, editor, part, numpages, url, abstract, keywords, any other field |
| `@article` | title, author, year, month (see Month), journal, publisher, volume, number, pages, doi, issn | url, articleno, abstract, keywords, any other field |
| `@misc` (arXiv interim only) | title, author, year, url, eprint, archiveprefix, primaryclass | |
| `@incollection` / `@inbook` | title, author, year, booktitle or series, publisher, pages, isbn or issn, doi | editor, volume, address, url, any other field |

- **Location.** Official field names stay exactly as exported (`location` from the ACL
  Anthology / ARR, `address` from Springer). Only when the official BibTeX provides no
  location does the lab add it under the default name **`venue`**, as `City, ST, USA` or
  `City, Country` (`Vancouver, BC, Canada`, `Milan, Italy`). `venue = {Online}` for
  virtual events is optional.
- **Month.** A lowercase macro (`jun`). The official BibTeX wins, as exported, even when
  it isn't the event month (AAAI gives its issue month; Springer journals give month and
  `day`). When the official BibTeX has no month:
  - *Proceedings*: the event month from the venue library, only when the whole event
    falls within one month. An event across two months (NeurIPS 2022, Nov 28–Dec 9)
    gets **no month**: its record says `month: none`. A multi-site event uses the main
    venue's dates (NeurIPS 2025 → San Diego, `dec`).
  - *Journals*: the month of the volume or issue the paper appears in, never the
    online-first date. A journal that doesn't publish by month (TMLR) gets no month
    (`month: none` in its record).
  - An official month that gives a period across two months (PMLR's `29 Jul--01 Aug`)
    is dropped with its `day`; `add` and `upgrade` report it, and the run report must
    name each such entry.
  So `month` is required only where one of these rules yields one; an entry whose
  venue record says `month: none` is complete without it.
- **Conference papers exported as `@article`.** AAAI's export is `@article` with
  `journal = {Proceedings of the AAAI Conference on Artificial Intelligence}`. The entry
  must be `@inproceedings` with that name as `booktitle`; every other official field
  (including the issue month) stays. `add` and `upgrade` retype it; `bibcc complete`
  retypes any left over, and `bibcc check fields` reports `conference_article`.
- **Two kinds of missing fields.** *Venue-shared* fields (publisher, isbn, issn, month,
  location, address, series, editor) are entered once, through the missing-venues YAML,
  into the survey's project library (`.bibcc-venues.yaml`, committed; `--scope project`)
  and applied by `bibcc complete`; venues of lab-wide value go upstream into the shared
  `miaa` library in BibCC's `examples/venues/`. *Entry-specific* fields (pages,
  volume, number, doi, url, articleno) come from the official export or, failing that, the
  official paper page of the same source as the BibTeX, patched directly into the
  entry. `url` only as exported: none when the official export has none.
- **No interim leftovers.** An interim or preprint entry's own fields (CVF Open Access,
  OpenReview, or arXiv `url`; `eprint`, `archiveprefix`, `primaryclass`; arXiv `note`)
  go away with it when the official BibTeX replaces it. An IEEE Xplore entry with a CVF
  `url` mixes two sources, and `bibcc upgrade` would take it for interim again.
- **Citation counts.** Field `citation`, bare integer from Google Scholar, last field,
  present only when counts were demanded.

## 3. Field order

```
title, author, year, month, booktitle | journal, publisher, address, series, volume,
number, pages, doi, isbn, issn, url, editor, part, venue, citation
```

Publisher-specific extras keep the publisher's sub-order (Springer LNCS: `series,
volume, …, editor, part`; ACM: `numpages` after `url`; PMLR: `editor, pdf`). `citation`
is always last.

## 4. Title style and protected terms

- APA Title Case (default target; `bibcc check title`).
- Protect acronyms, mixed-case names, proper nouns, and method names with **a single pair
  of braces per term**: `{CLIP}`, `{BERT}`, `{ImageNet}`, `{ResNet}`, `{3D}`,
  `{CODA-Prompt}: COntinual Decomposed …`. Never wrap the whole title in braces.
- Same in `booktitle` / `journal`: `2023 {IEEE/CVF} Conference on … ({CVPR})`,
  `{IEEE} Transactions on …`.
- The agent decides the braces when it curates the entry; `bibcc check quote` with the
  lab vocabulary (`--vocab-file assets/protected_terms.txt`) is the safety net. Add
  recurring terms to that file; pass one-off survey terms with `--terms A,B`, or list
  them in the file's `.bibcc/<file>.bib/vocab.txt` (one per line, always read). A
  hyphenated method name braced whole (`{CODA-Prompt}`, `{CIP-Net}`) must be in one of
  them, or `check quote` reports it as over-braced and `--apply` splits it.

## 5. Interim / preprint marker

- One wording, on the line directly above the entry:
  `% TODO: switch to official bibtex`
- Applies to arXiv `@misc` stand-ins, CVF Open Access and OpenReview interim entries, and
  journal early-access records. Remove the line once `bibcc upgrade` has replaced the
  entry with the official BibTeX.

## 6. Layout

Produced by `bibcc format`: two-space indent, `=` aligned to the longest field name,
all values in `{}`, lowercase month macros, `--` page ranges, one blank line between
entries, no trailing comma after the last field, one final newline.

## 7. PDFs

- One PDF per entry, named exactly `<citation key>.pdf`, in the folder the user names;
  if none is named, a new folder for the batch (its path is stated in the run report).
- Only papers that are in the `.bib` get a PDF; the key must be final first.
- Source order: the official host of the same source as the BibTeX (CVF, PMLR,
  proceedings sites, ACL Anthology, IJCAI, ECVA, AAAI OJS; publisher sites through the
  user's institutional access), then the **arXiv version**, which is acceptable for any
  paper because the content is equivalent (the official-provenance rule applies to
  BibTeX, not PDFs). Never unofficial mirrors.
- Library alignment is checked with `bibcc librarian missing` / `extra`; reference-manager
  exports are renamed with `bibcc librarian rename`.

## 8. Per-survey items (read from the repo)

- Taxonomy: one `.bib` per topic under `bib/`, grouped in subfolders by survey section;
  files may be empty while the survey is in progress. The section `.tex` files show which
  topics cite which file.
- LaTeX wiring: a `\bibliography{…}` list or `\addbibresource` lines; add new files
  there.
- PDF folder: the one the user names; otherwise a new per-batch folder, reported.
- Build style: the lab's survey templates use `bibtex` `.bst` styles (e.g. Springer
  Nature's `sn-apacite.bst`) that down-case titles, which is why protected terms must be
  braced.
