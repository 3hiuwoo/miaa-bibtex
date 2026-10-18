# bibcc command cheat sheet

Install once: install `uv` if missing (`curl -LsSf https://astral.sh/uv/install.sh | sh`),
then `uv tool install git+https://github.com/3hiuwoo/BibCC`. With no tag this is the
latest release (`main` holds only releases; development is on `dev`). This sheet follows
BibCC 0.8.0; if `bibcc check quote -h` doesn't list `--scope`, the install is too
old: rerun the install with `--force`. BibCC maintainers instead run
`uv sync && uv tool install --editable .` in a checkout of `dev`. Run `bibcc <cmd> -h` for
full options; it is the authority when it disagrees with this sheet.

bibcc ships no venue library. It reads the **user library** (`~/.config/bibcc/venues.yaml`,
or `$BIBCC_VENUES`) merged with the survey's **project library** (`.bibcc-venues.yaml`, the
nearest one above the `.bib` file; its values win). For a survey, seed the project files
once with `bibcc config profile miaa --scope project` at the repo root (the lab's config,
venue library, and terms file; it adds only what is missing) and commit them, so coauthors
pool venue records and terms through git. `bibcc config where` shows every file that
applies; `bibcc venues where` shows only the libraries. To
reuse a survey's venues elsewhere, merge its project library into the user library (adds
only; differing values are kept and reported): `bibcc venues import .bibcc-venues.yaml
[--dry-run]` (default `--scope user`).

Protected terms live in the same two scopes: the **user terms file**
(`~/.config/bibcc/terms.txt`, or `$BIBCC_TERMS`) and the survey's **project terms file**
(`.bibcc-terms.txt`, the nearest one above the `.bib` file). `check quote` reads both, and
still reads `.bibcc/<file>/vocab.txt`, where releases before 0.8.0 saved the compounds
kept whole.
The profile seeds the project file; `bibcc terms add NAME --scope project` adds one term.

The config holds the `format` settings in the same two scopes: the **user config**
(`~/.config/bibcc/config.yaml`, or `$BIBCC_CONFIG`) and the survey's **project config**
(`.bibcc.yaml`, the nearest one above the `.bib` file; its values win, and a command-line
option wins over both). The profile seeds the project config, so `bibcc format` gives every
coauthor the lab layout without options.

Reports about `FILE.bib` go to `.bibcc/FILE.bib/` next to it; logs to
`.bibcc/FILE.bib/logs/`. A file that is itself inside `.bibcc/` gets `reports/FILE.bib/`
beside it, so keep the `.bib` files bibcc edits outside `.bibcc/`. Reports with nothing to
say are removed. Add `.bibcc/` to `.gitignore`. `complete`, `upgrade`, and `format` are
**dry-run unless** you pass `--output` or `--in-place` (dry runs write a diff). `add` only
appends to its staging file and fills in its empty entries.

**Command line only.** Use `bibcc` as a command; never import its modules or script
against its source. Batches: `add --from FILE.csv`, `add DIR/` (local `.bib` files),
`add --retry`, `format DIR`, `upgrade --report-only DIR`, `check CHECK FILE --strict` per
file, `check official FILE --apply FIELDS`, `librarian missing DIR… PDF_DIR`; the `next`
column of `add.txt`, `upgrade.txt`, `published.txt`, and `official_unchecked.txt` sorts
the papers left to do. bibcc does every step it can; the agent does only what a report
hands over, and a missing batch feature belongs in bibcc, not in a workaround.

Env: `BIBCC_CONFIG`, `BIBCC_VENUES`, `BIBCC_TERMS` (user config, venue library, and terms
file paths; normally unset, so the defaults in `~/.config/bibcc/` apply), `S2_API_KEY`
(higher Semantic Scholar limits), `BIBCC_CACHE` (downloaded official BibTeX, kept 30 days;
default `~/.cache/bibcc`; `off` turns it off).

## Map to the SOP steps

| Step | Command |
|------|---------|
| 1–2 collect | `bibcc add <doi\|arxiv\|url\|"title"\|FILE.bib\|DIR> … --against bib/ [--from papers.csv\|ids.txt] [--retry] [--preprint] [--dry-run]` |
| 3 place | (no command — move entries from `added.bib` into the topic file; wire new files into `bib/all_bibs.tex`) |
| 4 interim | automatic in `add`/`upgrade`; add the `% TODO:` comment by hand; later `bibcc upgrade --report-only bib/` then `bibcc upgrade bib/x.bib --in-place` |
| 5 patch fields | `bibcc complete bib/x.bib [--in-place\|--output out.bib] [--update-venues --scope project] [--online] [--resolve library --fields F]` · `bibcc check official bib/x.bib [--apply F1,F2\|all] [--local DIR [--offline]] [--learn --scope project]` · `bibcc check editions bib/x.bib [--against bib/ [--learn --scope project]]` · `bibcc check fields bib/x.bib --apply` |
| 6 keys/titles | `bibcc check keys bib/x.bib` · `bibcc check title bib/x.bib [--apply\|--interactive]` · `bibcc check quote bib/x.bib [--apply\|--interactive [--scope project]] [--terms A,B]` · `bibcc terms add TERM --scope project` |
| 7 format | `bibcc format bib/ --in-place` (or `--check` in CI) |
| 8 citations | `bibcc scholar cite bib/x.bib -i` (or `--open`) |
| verify | `bibcc scholar titles bib/x.bib` · per file: `bibcc check missing\|fields\|keys bib/x.bib --strict` (`fields` with `--against bib/`; `check` takes one file and one check; loop over `find bib -name '*.bib'`) · touched files: `bibcc check official bib/x.bib --strict` |
| deliver | `bibcc compose compose bib/ references.bib` · `bibcc librarian missing bib/ PDF_DIR --skip-empty` |

## Command reference

**`check CHECK INPUT`** — one check per run (`bibcc check CHECK -h` for its options).
Writes only with the `--apply` options listed. Lists the empty entries it skips.
`--strict` on any file check: exit 1 if it finds something or the file has empty entries.
- `missing [--fields month] [--entry-types T] [--venues FILE]` — entries that lack
  required fields (default `month`). Entries whose venue record says `month: none` are
  exempt from the month check and listed in the log.
- `title [--apply|--interactive] [--style apa] [--extra-stopwords W]` — suggests APA title
  case; `--apply` and `--interactive` rewrite titles only.
- `quote [--terms A,B] [--vocab-file FILE] [--no-default] [--min-length N] [--apply|--interactive [--scope S]]` —
  **suggests** `{braces}` for acronyms and terms, and reports compounds braced as a whole
  when only some parts need braces (`{CLIP-Based}` → `{CLIP}-Based`). Reads the user and
  project terms files (logged) on top of `--terms`/`--vocab-file`. `--apply` braces those
  terms in titles (same case only, verified edit) and splits the over-braced compounds,
  then reports the rest. Never applies the built-in vocabulary or the heuristic
  suggestions. `--interactive` reviews each compound split one at a time (split, skip,
  edit, or keep whole); a compound kept whole goes to the user terms file, or with
  `--scope project` to the project's. To feed the decision in without prompting,
  `bibcc terms add CIP-Net --scope project`, so a method name stays whole for good.
- `keys` — validates `METHOD_AUTHOR_VENUEYEAR`; reports format, author (first author's
  surname; compound and accent-free forms accepted), venue, and year issues. Suggests
  canonical venue casing. Does **not** rename.
- `fields [--known-fields F] [--against PATH] [--apply]` — unknown field names (typos),
  bad values (empty, non-4-digit year, single-hyphen pages, URL-style DOI, non-macro month,
  malformed ISSN, schemeless URL), interim fields left in a published entry
  (`interim_field`: CVF, OpenReview, or arXiv `url`, `eprint`, `archiveprefix`,
  `primaryclass`, arXiv notes), conference papers typed `@article` with a
  `journal = {Proceedings of … Conference …}` (`conference_article`; `complete` fixes
  them), and duplicates (same DOI/arXiv ID/title, or duplicate key)
  in the file and in `--against`. `--apply` removes the interim fields and the empty fields only.
- `editions [--against PATH] [--ignore-fields F] [--include-fields F] [--learn [--scope S]] [--venues FILE]` —
  checks each entry against its venue's schema (`entry_fields` in the library: the
  per-paper fields the venue's official BibTeX has). `missing`: the entry lacks a field of
  the schema (counts for `--strict`); the evidence names the schema and its `learned_from`.
  `default_missing`: the venue has no schema, and the entry lacks a field of its
  publisher's default schema (what most of the library's schemas of the same publisher
  and kind share): a guess, never written by `--learn`, not counted by `--strict`.
  A journal article with no `volume` isn't expected to have `volume`, `number`, `pages`.
  For a venue without a schema it compares the venue's entries (the file and `--against`)
  and only proposes one (3 or more entries of a journal or a conference year);
  `--learn` writes the proposals and checks against them; a proposal for a journal or an
  edition that the library has no record of goes into `.bibcc/<in>/missing_venues.yaml`,
  with the record. Ignores the fields every entry has
  (`title`, `author`, `year`, `booktitle`, `journal`), `citation`, exporter bookkeeping,
  and library fields. Reports `edition_fields.txt` (`entry_id venue year field issue_type
  evidence`) and `edition_schemas.txt` (`venue year level issue_type entries fields detail`;
  level `journal`, `family`, `edition`; `schema_lacks`, or `schema_differs` when the
  library already holds a different schema for that venue; the detail lists the entries
  that lack a proposed field).
- `official [--apply F1,F2|all] [--ids KEYS] [--local PATH] [--offline]
  [--ignore-fields F] [--delay S] [--refresh] [--learn [--scope S]] [--venues FILE]` — downloads each entry's official
  BibTeX again (like `add`) and compares field by field: `upstream_only` (official has
  it, entry lacks it), `differs`, `local_only` (entry has it, official lacks it; not
  `citation` or library fields), `type`. Titles aren't compared, braces/case/accents/month
  spellings don't count. `--apply` adds the official values of the named fields to
  entries that lack them (`all`: every `upstream_only` field, `abstract` and `keywords` included);
  never changes a value. `--local PATH` (repeatable): BibTeX you fetched yourself, matched
  by key, file name, DOI, or title; `--offline`: only those. Skips preprints, interim
  entries, and metadata entries. `--strict` counts `upstream_only`, `differs`, and `type`.
  Reports: `official_fields.txt` (`entry_id field issue_type bib official source`),
  `official_venues.txt` (`venue year field issue_type checked lacking detail`;
  `entries_lack`, `export_lacks` (every checked entry has a field no official BibTeX has),
  `library_lacks`, `library_differs`, `books_lack` (the entries of one book of a
  proceedings agree on a `volume` or `part` the record's `books:` table lacks), and
  `schema_lacks` or
  `schema_differs` with field `entry_fields`: the venue's schema versus the downloaded
  BibTeX; `--learn` writes the schemas and the book fields into the library, and a schema
  whose journal or edition record is missing goes into `.bibcc/<in>/missing_venues.yaml`,
  with the record), `official_unchecked.txt` (`entry_id status detail url next`; status
  `no_bibtex`, `failed`, `mismatch`; `next` `by hand`, `retry`, `wait`, `check`).
- `venues [PATH] [--venues FILE | --scope S] [--apply] [--journal-fields F] [--proceedings-fields F]` — audit
  the user and project venue libraries, each on its own (`--venues FILE`: only that file,
  a `missing_venues.yaml` works too; `--scope`: only that library), including fields one
  edition of a conference has and another lacks, values every published edition shares,
  and the family records with their editions and schemas. `--apply` moves the shared
  values into the family record (created when missing) and saves the library; no
  edition's effective fields change.

**`complete`** — add fields an entry lacks, **from the venue library only**; existing values
never overwritten (conflicts reported). Dry-run default.
- `--output FILE` / `--in-place` (mutually exclusive) / `--log-dir` / `--venues` /
  `--delay S` (with `--online`: seconds between CrossRef requests).
- `--update-venues` — merge the filled `.bibcc/<in>/missing_venues.yaml` into one library
  first: the user library, or with `--scope project` the project's `.bibcc-venues.yaml`
  (which must exist). The log names the file written. `--venues FILE` reads and writes
  only that file. `--update-venues-only` merges and stops without completing the file.
  `--online` — CrossRef pre-fills the YAML and writes `venue_check.txt` (report only).
- `--resolve library` — overwrite entry fields that differ from the library with the
  library's values (after you fix a record); `--fields F` and `--ids KEYS` narrow it.
- Interim booktitles get only `venue` + `month` and are listed for `upgrade`.
- First retypes AAAI-style `@article` (journal `Proceedings of … Conference …`) to
  `@inproceedings` (`journal` → `booktitle`, other fields kept); logged with 🔁.
- A record with `month: none` never adds a month; an entry of that venue with a month is
  a conflict, and `--resolve library` removes its `month` and `day`.
- The missing-venues YAML never guesses a month: CrossRef pre-fills it only for a
  one-month event; journals get none (the issue month belongs to the entry).
- `add` and `upgrade` drop an official month that spans two months (`29 Jul--01 Aug`)
  with its `day`, and log it; they also retype AAAI `@article` exports.

**`add`** — locate + download official BibTeX into a staging file (`added.bib` default).
- `IDENTIFIER` may also be a `.bib` file or a directory of them: each entry is taken as
  official BibTeX you fetched yourself (no lookup); a `% source: URL` line just above an
  entry is recorded in the report.
- `--from FILE`: one id per line, or a `.csv`/`.tsv` manifest with an `identifier` column
  and optional `method`, `venue`, `year`, `key` columns that set the key (`venue` also
  helps find the official source). A manifest key already in use is an error.
- `--retry` — look up again the staging file's empty entries and the `failed` rows of its
  last `add.txt` (no identifiers needed).
- A paper matching an empty entry of the staging file (DOI, arXiv ID, title, or key) fills
  it in place, keeping the key; an empty entry in an `--against` file counts as present.
- `--against PATH` (repeatable), `--output`, `--venues`, `--preprint` (keep arXiv),
  `--keep-title`, `--dry-run`, `--delay`, `--log-dir`.
- The run ends with `FILE: N entries (M with fields, K empty)`.
- Blocked publishers (AAAI/ACM/Elsevier) and ECCV-not-on-Springer → empty entry with a
  `% BibCC: no official BibTeX …` comment and a `get it:` URL. Failed lookups exit 1.
- The end of the run lists what is left to do (empty entries, failed papers, each with
  title and `get it:` URL), grouped by what to do next, and counts the interim entries.
  `.bibcc/<output>/add.txt` has one tab-separated row per paper (`identifier status key
  title detail url next`; status `official`, `interim`, `metadata`, `empty`, `failed`,
  `duplicate`). `next`: `by hand` (official BibTeX exists, not downloadable: fetch it from
  the URL, browser for AAAI/ACM/Elsevier, save it to `.bibcc/work/<batch>/exports/`, and
  `bibcc add` that directory), `retry` (site unreachable or rate-limited: `add --retry`
  later), `check` (not found, or the manifest key is taken: fix the identifier), `wait`
  (proceedings not out, and every `interim` row: `upgrade` or `--retry` later), empty
  (done).
- `--fallback none|missing|all` builds entries from CrossRef/S2/OpenReview/arXiv
  metadata instead, marked `% BibCC: not the official BibTeX …`. **MIAA surveys pin
  official BibTeX: keep the default `none`.** If a metadata entry turns up anyway, treat it
  as not done: get the official BibTeX, or let `bibcc upgrade` replace it.

**`upgrade`** — replace preprints/interim entries (and entries `add --fallback` built from
metadata) with the published official BibTeX.
- `PATH` (one file unless `--report-only`), `--output` / `--in-place`, `--ids KEYS`,
  `--venues`, `--delay`, `--log-dir`.
- `--report-only PATH …` — list now-published candidates + source URL, downloads nothing.
- Keeps the key, keeps a matching hand-made title, keeps custom fields, drops preprint
  fields. Non-downloadable published versions are kept with a manual URL.
- `upgrade.txt` (`entry_id status detail next`; status `upgraded`, `unchanged`, `failed`)
  and `published.txt` (`file entry_id status venue source url next`; status `published`,
  `interim`, `official BibTeX available`) end with the same `next` column: `upgrade`
  (replace now with `upgrade --in-place`), `by hand`, `wait`, `retry`, or `check`.

**`format`** — rewrite layout of whole files. `PATH …` (recursive; `.bibcc/` skipped).
- `--in-place` / `-o/--output` (single file) / `--check` (exit 1 if unformatted).
- `--sort-fields` + `--field-order` (comma-separated; `*` marks where unlisted fields go),
  `--sort-entries`, `--keep-quotes`, `--keep-outer-braces`, `--keep-months`, `--keep-pages`,
  `--align`, `--indent N|tab`, `--blank-lines N`, `--trailing-comma`, `--drop-empty`,
  `--log-dir`. Each yes-or-no option has a `--no-` form that turns off a config value.
- Settings come from the `format:` section of the user and project configs (`.bibcc.yaml`);
  `--config FILE` reads only that file, `--no-config` none. In a MIAA survey the profile's
  `.bibcc.yaml` sets the lab layout, so run `format` without style options.

**`librarian`** — PDF library vs `.bib`; it never downloads PDFs. Subcommands
`missing BIB… LIBRARY [--skip-empty]` and `extra BIB… LIBRARY`: any number of `.bib`
files and directories (recursive, `.bibcc/` skipped), then LIBRARY = a PDF directory
(recursive) or a listing file (one PDF name per line). `missing` exits 1 when PDFs are
missing, 2 when a path does not exist; `--skip-empty` leaves out empty entries. Reports
next to the first BIB. `rename BIB PDF_FOLDER [--dry-run]` (title → `<key>.pdf`; the
title is the text after the last ` - ` in the filename, i.e. reference-manager exports).

**`scholar`** — `cite BIB [-i|--open] [--include-filled] [--batch-size N] [-o FILE] [--log-dir DIR]`
(builds Scholar URLs; interactive fill of `citation`); `titles BIB [--delay] [--quiet]
[--retry-errors REPORT] [--ids]` (verify titles vs CrossRef/arXiv/Semantic Scholar).

**`compose`** — `compose INPUT_DIR OUTPUT.bib [--no-dup-warning]`; merges with
`% === source: … ===` markers, preserves comments, warns on duplicate keys.

**`venues`** — manage the venue libraries. `where [PATH]` (libraries that apply, sizes,
fields the project overrides, which one is written); `init [--scope user|project]`
(empty library; project = `./.bibcc-venues.yaml`); `import SOURCE [--scope user|project |
--venues FILE] [--overwrite] [--dry-run]` (SOURCE = file, URL, or shared name like `miaa`;
only adds, keeps your values where they differ unless `--overwrite`); `examples` (list
the shared libraries in BibCC's `examples/venues/`); `providers [PATH] [--venues FILE]
[--format text|json]` (where each conference's official BibTeX comes from, and whether the
row is built in or set by a family record).

**`terms`** — manage the protected-terms files. `where [PATH]`; `list [PATH]`; `add TERM…
[--scope user|project | --terms FILE]` (adds the terms the file lacks, ignoring case);
`import SOURCE [--scope user|project | --terms FILE] [--dry-run]` (SOURCE = file, URL, or shared name like `miaa`);
`examples` (the shared lists in BibCC's `examples/terms/`).

**`config`** — manage the config files. `where [PATH]` (every file that applies: configs,
venue libraries, terms files, the provider table, and each setting with where it comes
from); `init [--scope user|project]` (a config listing every setting, commented out);
`import SOURCE [--scope user|project | --config FILE] [--overwrite] [--dry-run]` (adds the
settings the file lacks, keeps your values where they differ unless `--overwrite`, and
changes only those lines, so comments stay); `profile NAME [--scope user|project]
[--overwrite] [--dry-run]` (`config import`, `venues import`, and `terms import` of one
shared name, such as `miaa`); `examples` (the shared configs in BibCC's `examples/config/`).

**`surface [--format json|text]`** — the machine-readable command surface: commands,
options, report files, and status, `next`, and `issue_type` words. `miaa-bibtex-doctor`
reads it to find drift.

## Output files

All in `.bibcc/<file>/` next to the input (`--log-dir DIR`: `DIR/<file>/`); logs in its
`logs/`. Scratch files of a run go in `.bibcc/work/<batch>/`, deleted at the end.

| Command | Reports |
|---------|---------|
| `check` | `missing_fields.txt`, `title_case.txt`, `smart_protection.txt`, `citation_keys.txt`, `field_issues.txt`, `edition_fields.txt`, `edition_schemas.txt`, `official_fields.txt`, `official_venues.txt`, `official_unchecked.txt`, `missing_venues.yaml` (`editions` and `official` with `--learn`) |
| `complete` | `complete.diff`, `missing_venues.yaml`, `missing_venues.txt`, `conflicts.txt`, `incomplete_entries.txt`, `venue_check.txt` (online) |
| `add` | staging `.bib`, `add.txt`, `missing_venues.yaml` |
| `upgrade` | `upgrade.txt`, `upgrade.diff`, `missing_venues.yaml`, `published.txt` (report-only, next to the first PATH) |
| `format` | `format.diff` |
| `scholar cite` | `scholar_urls.txt` · `scholar titles` → `title_report.txt` |
| `librarian` | `missing_pdfs.txt`, `extra_pdfs.txt`, `rename_report.txt` |

## Venue library

Where: user library + project library, merged (above); the lab's shared one is
`examples/venues/miaa.yaml` in the BibCC repo. Schema: `journals:` (year-agnostic; fields `publisher`, `issn`,
`address`) and `proceedings:` (one record per publication year; fields `venue`, `month`,
`publisher`, `isbn`, `issn`, `editor`, `series`, `address`, `day`). `month: none` (either
kind) means the venue has no month: a cross-month event or a non-monthly journal (TMLR).
The previous edition's month is never copied. Proceedings records may
carry `interim:` booktitles (sources `cvf` / `openreview`) linking the pre-proceedings name
to the published one. Proceedings published as several books (the LNCS volumes of ECCV or
MICCAI, whose Springer chapter exports lack the `volume` and `part`) may carry `books:`,
mapping each book's ISBN, as it appears in its chapters' DOIs (`10.1007/978-…_13`), to its
`volume` and `part`; `complete` fills them into an entry by its DOI, and `check official`
learns them with `--learn` instead of reporting them as `local_only`. Matching ignores braces/case/`\&`/extra spaces; journals also match by
ISSN; proceedings by name+year or interim booktitle. A third list, `families:` (`name`,
`acronym`, `aliases`, `fields`, `entry_fields`, `learned_from`), describes a conference
across its editions: its `fields` apply to every edition (the edition's value wins), and
it may set where the official BibTeX comes from (`provider`, `interim`, `site`, and so
on; bibcc ships the defaults). Any record may carry `entry_fields` (the venue's schema)
and `learned_from`; only `check official --learn` and `check editions --learn` write them.
`check missing` skips a field outside the schema.

Add a venue: run `complete` (or `add`/`upgrade`) to generate
`.bibcc/<in>/missing_venues.yaml`, fill the blanks (pre-filled from `# from bib`,
`# from official BibTeX`, `# from <year> edition`, `# from CrossRef`, `# auto-guessed`;
lines commented `# from family NAME` stay commented: the family supplies them), then
`bibcc complete <in> --update-venues --scope project`. See `missing_venues.example.yaml` in
the BibCC repo.

## What the tool will NOT do (so you must)

- Rename existing keys (`upgrade` keeps them; `add` only suggests).
- Apply `{braces}` from `check quote` (it only suggests; `--apply` applies only the terms you list).
- Tell a method-name compound (`{CIP-Net}`) from a descriptive one (`{CLIP-Based}`): the
  over-braced report hands that over. Answer with `bibcc terms add NAME --scope project`,
  then rerun `--apply`.
- Query Google Scholar or DBLP (Scholar is browser-only; DBLP is behind a bot challenge).
- Download from AAAI / ACM / Elsevier (blocked) — writes empty entries instead; import the
  BibTeX you fetch with `bibcc add FILE.bib` to fill them, or compare existing entries
  with it through `check official --local DIR --offline`.
- Overwrite a differing field: `complete` reports a conflict (`--resolve library` takes
  the library's value), and `check official` reports `differs`; fix the entry by hand.
- Pick which taxonomy file an entry belongs to, or fill fields no source knows.
