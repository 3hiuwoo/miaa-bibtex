---
name: miaa-bibtex-core
description: The shared invariants for MIAA survey BibTeX and PDF work. Load this before running any other miaa-bibtex skill. It holds the official-BibTeX hard rule, the bibcc-command-line-only rule, the work-directory and run-report conventions, the retrieval ladder, the dependency preflight, the master report-to-action table, the MIAA hard rules, and rule precedence. It performs no task on its own.
metadata:
  author: MIAA lab
  version: "1.0"
---

# MIAA BibTeX core: the invariants

Every miaa-bibtex stage obeys the rules in this skill. This skill does no work by itself.
Load it before `miaa-bibtex-acquire`, `miaa-bibtex-upgrade`, `miaa-bibtex-complete`,
`miaa-bibtex-decide`, `miaa-bibtex-verify`, `miaa-bibtex-library`, `miaa-bibtex-pdfs`,
`miaa-bibtex-scholar`, or any composer (`miaa-bibtex-curate`, `miaa-bibtex-review`,
`miaa-bibtex-refresh`).

Set `CORE` to this skill's directory, `~/.agents/skills/miaa-bibtex-core` in the canonical
install. Adjust the path if the set is installed elsewhere. The reference files:

| File | Holds |
|---|---|
| `$CORE/references/miaa-conventions.md` | Keys, entry types and fields, field order, title style, the marker, layout, PDFs |
| `$CORE/references/bibcc-workflow.md` | The bibcc command cheat sheet and the output-file map |
| `$CORE/references/retrieval-playbook.md` | Per-source endpoints, the rung-3 recipe, polite retrieval |

Every stage skill is thin on purpose: it names its commands and its scope, then defers to
this file for the rules. Never restate a rule in a stage skill. When a rule changes, change
it here only.

## The hard rule

**Every final entry begins from the official BibTeX**: the publisher's or proceedings' own
export (IEEE Xplore, Springer, PMLR, NeurIPS/ICLR proceedings, ACL Anthology, IJCAI, AAAI,
ACM, Elsevier, CVF, OpenReview). Never hand-write an entry, never build one from API
metadata. CrossRef, Semantic Scholar, dblp, and Google Scholar are locators, not sources.
Never leave a tool's guess as the final record. Whatever the official site offers, copyable
text or a downloadable `.bib`, is the source of truth. Fields, key, markers, and formatting
are layered on top of it.

Corollary: a field the official export provides is kept as exported. `location` from the
ACL Anthology stays `location`. Lab default names apply only when the export has no such
field. Preprints (arXiv) and interim entries (CVF Open Access, OpenReview before the
proceedings) are temporary stand-ins and must be marked.

## bibcc through its command line only

Drive bibcc only through the `bibcc` command. Never import bibcc or any of its modules,
never run Python against its internals, and never read its source to script around it.
Internals have no stable interface, they skip the command's verification and reports, and
they differ between installs. Helper scripts are fine when they only call `bibcc` and touch
files in the work directory.

When a step has no command, make the edit in the `.bib` file by hand, let `bibcc format`
and `bibcc check` re-verify it, and name the missing feature in the run report. Never work
around a missing bibcc feature in bulk.

## Work directory

Keep every scratch file of a run in `.bibcc/work/<batch>/` at the survey repo root (`WORK`
below; `<batch>` is a short name such as the ids file or the date): the manifest, notes,
helper scripts, and `exports/` for official BibTeX you fetch yourself, one `.bib` per paper.
Keep `.bib` files that bibcc edits (`added.bib`, `bib/...`) outside `.bibcc/`. bibcc writes
its own reports to `.bibcc/<file>/` next to each file it reads. At the end, after the run
report is written, delete WORK (`rm -rf .bibcc/work/<batch>; rmdir .bibcc/work 2>/dev/null`)
and say so in the report.

## Preflight: detect every dependency, then ask once

Run this at the start of every run, before any retrieval. Detect everything first, then ask
the user **one** question listing what is missing and what skipping each would cost. Ask as
an interactive question if the harness has one, otherwise in chat. Never install silently.
Record the answers in the run report. If everything is present, say so in one line and
continue.

| Dependency | Needed for | Detect | Install, only after a yes |
|---|---|---|---|
| `uv` (Python 3.10 or later) | Installing and running bibcc | `command -v uv` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `bibcc` | Every deterministic step | `command -v bibcc`, then `bibcc check quote -h \| grep -q -- --scope` | `uv tool install git+https://github.com/3hiuwoo/BibCC` (no tag: `main` holds only releases). Too old: the same command with `--force` |
| lab profile: config, venue library, protected terms | `format`, `complete`, `check quote` | `bibcc config where` in the survey repo (lists the config, venue libraries, and terms files that apply) | bibcc ships none. Seed the survey once: `bibcc config profile miaa --scope project` at the repo root, then commit `.bibcc.yaml`, `.bibcc-venues.yaml`, and `.bibcc-terms.txt` |
| web fetch and search | Retrieval rung 2 | The harness's fetch or search tools exist | none; use what is there |
| rung-3 browser | Login-gated and bot-blocked sites | `command -v agent-browser`, or a connected browser MCP | lab standard agent-browser, below |
| optional | Large title batches, tidy repo | `S2_API_KEY` set; `.bibcc/` in `.gitignore` | mention only |

The `bibcc check quote -h | grep -q -- --scope` check is the version gate: an install
without it is older than 0.8.0 and lacks the protected-terms files (`bibcc terms`, read by
`check quote`), the lab-profile import (`bibcc config profile`), `check venues --apply`, venue schemas (`check official --learn`), family
records, and `bibcc surface`. If the check still fails after a forced reinstall, stop and
tell the user this set needs BibCC 0.8.0 or later. Any version that passes works, including a
maintainer's editable `dev` checkout.

Consequences to state in the question:

- **uv or bibcc declined**: the flows cannot run. Produce the manifest only (`papers.csv`,
  kept at the repo root, outside WORK), write the run report, stop.
- **browser declined**: run every flow; rung 3 is skipped; login-gated items go to the run
  report's To do now list.

Install block, run only for the items the user approved:

```bash
CORE=~/.agents/skills/miaa-bibtex-core                        # adjust if installed elsewhere
command -v uv    >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
command -v bibcc >/dev/null || uv tool install git+https://github.com/3hiuwoo/BibCC
bibcc check quote -h | grep -q -- --scope ||                        # older than 0.8.0:
  uv tool install --force git+https://github.com/3hiuwoo/BibCC        #   move to the latest release
bibcc check quote -h | grep -q -- --scope || echo 'needs BibCC 0.8.0 or later: stop here'
bibcc --version && bibcc config where                               # record the version and files in the run report
bibcc config profile miaa --scope project   # survey repo root; adds only what is missing; commit the three files
grep -qs '^\.bibcc/' .gitignore || echo '.bibcc/' >> .gitignore    # in the survey repo
# rung-3 browser, lab standard:
brew install agent-browser 2>/dev/null || npm install -g agent-browser
agent-browser install                                               # one-time Chrome for Testing download
agent-browser --headed --profile ~/.miaa-browser open https://<library-proxy-login>   # user logs in once
```

Why agent-browser: a CLI driven from the shell, so it works in every agent harness and with
every model provider; it keeps a persistent login profile (later runs pass
`--profile ~/.miaa-browser` headless), saves downloads, and reads pages as compact
accessibility snapshots. Alternatives, used if already present: Claude in Chrome, Chrome
DevTools MCP, Playwright MCP. Same steps, different tool names.

## Retrieval ladder

Stop at the first rung that yields the official artifact. Never skip to synthesis.

1. **bibcc** (`add`, `upgrade`): IEEE Xplore, Springer/Nature, PMLR, NeurIPS and ICLR
   proceedings, ACL Anthology, IJCAI, CVF (interim), OpenReview (by title), arXiv.
2. **Direct fetch** of the official page or its export endpoint with the agent's web fetch
   tool, curl, and **every fetch or scrape connector that is connected**. Try each before
   moving on; a connector that renders pages may succeed where a plain fetch is refused.
   Endpoints per source: `$CORE/references/retrieval-playbook.md`.
3. **Browser automation** with the rung-3 tool found in preflight (lab standard:
   agent-browser with the `~/.miaa-browser` profile). Open the official page, take an
   interactive snapshot, click "Cite" or "Export BibTeX" and read the text, or click "PDF"
   with `--download-path` set to the PDF folder. This reuses the user's logins, so paywalled
   PDFs work through institutional access. Recipe in the playbook. No browser tool, or the
   user declined one: skip this rung.
4. **Human**: hand over an exact list of what remains, each with its official URL and what
   to click. Keep the empty entries bibcc wrote; the human saves each result to
   `WORK/exports/` or pastes it into the empty entry, keeping the key.

Rate limits and bot blocks mean slow down or move a rung, never fabricate. Use only official
hosts, plus arXiv for PDFs, and access the user legitimately has. No unofficial mirrors.
**Retry budget**: two attempts per rung per item, one second apart, longer after a rate
limit. After that the item is *unresolved* and goes in the run report with handoff
instructions. Do not keep looping.

## Who does what

| bibcc (deterministic, verified edits) | agent (judgment, browsing, files) |
|---|---|
| Locate papers, download official BibTeX, dedupe against `bib/` (`add`) | Resolve the batch from any input; pick the best identifier per paper |
| Replace interim or preprint entries once published (`upgrade`) | Retrieve BibTeX and PDFs from blocked or unsupported sites via the ladder |
| Add venue-shared fields from the venue library; propose unknown venues (`complete`) | Research missing values on official pages; fill the missing-venues YAML |
| Compare entries with their official BibTeX (`check official`); learn each venue's schema into the library (`--learn`); check entries against it (`check editions`) | Fetch the official BibTeX bibcc cannot download; judge `differs` and `local_only` findings, and schemas proposed from entries alone |
| Validate keys, title case, braces, field typos, interim leftovers, duplicates (`check`) | Decide the citation key, the braces, and the taxonomy file |
| Whole-file layout (`format`); align a PDF library, rename reference-manager exports (`librarian`) | Download PDFs and save them as `<key>.pdf`; write the run report |

## Master report-to-action table

Each row is something bibcc found but cannot finish. Act only on rows whose **Owner** is the
skill you are running. The rows carry the report file, the row marker, and the agent action.

| Report | Row | Owner | Agent action |
|---|---|---|---|
| `add.txt`, `upgrade.txt`, `published.txt` | `next` = `by hand` | acquire, upgrade | Ladder rungs 2 to 4 with the row's URL; save to `WORK/exports/<key>.bib`; `bibcc add WORK/exports/` |
| `add.txt`, `upgrade.txt`, `published.txt` | `next` = `retry` | acquire, upgrade | Run the same command again after a pause with a larger `--delay`; then the ladder |
| `add.txt`, `upgrade.txt`, `published.txt` | `next` = `wait` | upgrade | Nothing now: the entry is interim; `upgrade` later |
| `official_unchecked.txt` | `next` = `by hand` (AAAI, ACM, Elsevier) | acquire, verify | Fetch the official BibTeX by the ladder into `WORK/exports/<key>.bib`; `bibcc check official FILE --local WORK/exports/ --offline` |
| `official_unchecked.txt` | `mismatch` | verify | The entry's DOI or title points at another paper: open the URL, fix the entry's `doi` or identity, check again |
| `official_unchecked.txt` | `next` = `wait` | upgrade | Nothing now: the entry is interim; `upgrade` later |
| `official_fields.txt` | `upstream_only` | complete | `bibcc check official FILE --apply F1,F2`, or `all`; never by hand |
| `official_fields.txt` | `differs` | complete | The official value wins (precedence 1); edit the entry by hand, unless the difference is a MIAA layer (key, title braces) |
| `official_fields.txt` | `local_only` | complete | Keep `venue`, `citation`, and library fields; remove interim leftovers with `check fields --apply`; for others, check the official page, then keep or remove |
| `official_venues.txt` | `library_lacks`, `library_differs` | library | Fix the venue library record, then `complete --in-place --resolve library --fields F` |
| `official_venues.txt` | `schema_lacks` | library | `bibcc check official FILE --learn --scope project`; never write `entry_fields` by hand |
| `official_venues.txt` | `schema_differs` | library | Confirm on the official page that the venue changed its export (a new year), then `check official FILE --learn --scope project`; if not, the downloaded BibTeX is odd: leave the schema |
| `edition_schemas.txt` | `schema_lacks` | library | Proposed from entries alone (AAAI, ACM, Elsevier venues). Fetch one paper's official BibTeX by the ladder into `WORK/exports/` and `check official FILE --local WORK/exports/ --offline --learn --scope project`; only when no export is reachable, `check editions FILE --against bib/ --learn --scope project` |
| `edition_fields.txt` | `missing` | complete | `check official FILE --apply F` for that entry; if no export has it, read it off the official page |
| `check venues` log | cross-edition gaps | library | Fill the record from the official page of that edition |
| `check venues` log | `Fields that every edition shares` | library | `bibcc check venues --scope project --apply` moves them into the family record; never by hand. `check venues` again |
| `add`, `upgrade` log | `month: the official BibTeX gives '...', a period across two months` | acquire, upgrade | Nothing to fix: the entry correctly has no month. Name the entry under Status in the run report |
| `conflicts.txt` (`complete`) | `month` with library = `none` | complete | Unless the month came from the official BibTeX (then the record is wrong: fix it), `complete --in-place --resolve library --fields month` removes it |
| `missing_venues.yaml` | blank values | library | Read the official proceedings or journal page; fill in; `complete --update-venues --scope project` |
| `missing_venues.yaml` | blank `month` | library | Official dates page: one month means that month; across two months means `none`. Journal record: leave blank (each issue has its own month); non-monthly journal means `none` |
| `field_issues.txt` | `conference_article` | complete | `bibcc complete FILE --in-place` retypes it to `@inproceedings`; never by hand |
| `title_case.txt` | suggestions | decide | Judge each one |
| `smart_protection.txt` | `Over-Braced: use ...` | decide | A method name stays whole: `bibcc terms add NAME --scope project` (without braces), then rerun `check quote --apply`. Otherwise the split is right and `--apply` makes it |
| `smart_protection.txt` | other rows | decide | Judge each one |

## Run report (always, at the end)

Write `.bibcc/<batch>.run-report.md` at the survey repo root, outside WORK, so it survives
the cleanup, and show it to the user. The human reads the top and stops, so what they must
do comes first, as checkboxes; the record of what was done comes after.

1. **Title and summary.** `# Run report: <file>, <date>`, then one bold **For you:**
   paragraph: how many papers need the human now, how many are waiting on a publisher
   (nothing to do yet), and one clause saying everything else is done.
2. **`## To do now (N)`**: one checkbox per unresolved paper, PDF, or field a person can
   finish today, seeded from `.bibcc/<file>/add.txt`, `upgrade.txt`, `published.txt`,
   `official_unchecked.txt`, and `missing_pdfs.txt`.
   - Open with one sentence saying how to finish any item: where to paste (over the entry,
     **keeping the key**), delete its `% TODO: switch to official bibtex` line, and tick
     the box.
   - Group the boxes in `###` subsections by source and action. State the clicks
     ("Cite then BibTeX", "PDF") and where the result goes once per group, not per line.
   - One line per box: `` - [ ] `KEY`: URL ``. Add a few words only when that item differs
     from its group.
   - Add `### Retry later (N)` and `### Check the identifier (N)` as their own groups, with
     boxes, only when they have items.
   - End with `### When you're done`: the exact commands to run afterwards, in order
     (`bibcc format ... --in-place`, the `check --strict` loop, `bibcc librarian missing ...`),
     with a comment saying what result to expect.
3. **`## Waiting on the publisher (N): nothing to do now`**: one checkbox per entry with a
   stand-in (`wait`, every interim or preprint entry, and empty entries whose proceedings
   are not out). One sentence first: what the stand-in is, where the official version will
   appear, and the command that picks it up.
4. **`## Status`**: the gates and their exit statuses, that the `.bib` files carry only TODO
   markers, venue records added and whether to promote them
   (`bibcc venues import .bibcc-venues.yaml`), any decision only the human can make, any
   batch step bibcc had no command for, and whether WORK was removed.
5. **`## Done`**: preflight answers and the bibcc version; entries added (key to file,
   official or interim); fields patched (field, value, source URL); PDFs saved (key to path,
   official or arXiv).
6. **`## Appendix: retrieval attempts`**: per unresolved item, the rungs tried and why each
   failed.

Every unresolved paper appears in exactly one checkbox list, and each heading's count equals
its boxes. When an item is resolved later, tick it (`[x]`) and say how in Status instead of
deleting it.

## MIAA hard rules

1. Official BibTeX first; never fabricate or leave a non-official record as final. `add`
   stays at `--fallback none`; a metadata-built entry is not done.
2. bibcc through its command line only, and bibcc first: the agent does by hand only what a
   bibcc report hands over. Scratch files in `.bibcc/work/<batch>/`, removed at the end.
3. Official field names are kept as exported; `venue` (location, `City, ST, USA` or
   `City, Country`) is added only when the export has none.
4. Key is `Method_Author_VenueYear`, year is the edition year; preprints `_arXiv<year>`
   until accepted, then the accepting venue. Keys are final before any PDF is named.
5. Interim, preprint, and empty entries carry `% TODO: switch to official bibtex` directly
   above; no other comments in delivered `.bib` files (run notes go to WORK or the run
   report).
6. APA Title Case; one brace pair per protected term; never the whole title.
7. Required fields per type, title-first field order, `citation` last; every official field
   kept, including `abstract` and `keywords`.
8. `{}` values, `--` page ranges, lowercase month macros, two-space aligned layout. Month:
   official first; else the single event month or the journal issue month; none for
   cross-month events, cross-month official periods, and non-monthly journals. AAAI's
   `@article` export becomes `@inproceedings`.
9. PDFs: one per entry, `<citation key>.pdf`; official host first, arXiv version acceptable;
   the user's folder or a new per-batch folder.

## Rule precedence

1. Official BibTeX values, as exported.
2. Fields added from the venue library or official pages (never overwrite 1).
3. MIAA conventions (key, defaults for absent fields, order, marker, PDF name).
4. `bibcc format` layout.

## References

- `$CORE/references/miaa-conventions.md`: rules and tables.
- `$CORE/references/retrieval-playbook.md`: per-source endpoints, the rung-3 recipe.
- `$CORE/references/bibcc-workflow.md`: the command cheat sheet.
