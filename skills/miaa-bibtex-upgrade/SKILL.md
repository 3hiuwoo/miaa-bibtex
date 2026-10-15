---
name: miaa-bibtex-upgrade
description: Promote interim and preprint entries to their published official BibTeX when a venue's proceedings or issue appear. Use when a new proceeding or journal issue publishes, or periodically to sweep an existing .bib tree for entries that are now published, replacing arXiv, CVF, and OpenReview stand-ins while keeping keys. Runs under the miaa-bibtex-refresh composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Upgrade: promote stand-ins when proceedings publish

Load `miaa-bibtex-core` first. One aim: replace interim or preprint entries with the official
BibTeX of their published version, keeping keys. Different from acquire: acquire gets BibTeX
for papers you do not have; upgrade replaces BibTeX you already have.

## Sweep

```bash
bibcc upgrade --report-only bib/            # what is now published; downloads nothing
bibcc upgrade bib/<file>.bib --in-place     # replace, keeping keys; then delete the marker
```

`--report-only` takes a directory; `--in-place` takes one file. In `.bibcc/bib/published.txt`
and `upgrade.txt`, the `next` column says what to do: `upgrade` means upgrade can replace the
entry now; `by hand` means published but its BibTeX must be fetched; `wait` means not out yet;
`retry` means a lookup failed; `check` means fix the identifier.

The replaced entry carries only the official BibTeX's fields, plus venue fields and
`citation`: upgrade drops the interim `url`, `eprint`, `archiveprefix`, and `primaryclass` on
purpose, so do not restore them. Upgrade also replaces entries built from metadata
(`% BibCC: not the official BibTeX`) once official or interim BibTeX can be downloaded, and
removes their comment. After a successful replacement, delete the
`% TODO: switch to official bibtex` line above the entry. A non-downloadable published
version is kept with a manual URL; hand it over.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: the `upgrade.txt` and `published.txt` rows with
`next` = `upgrade`, `by hand`, `retry`, `wait`, or `check`; the `add.txt` rows with
`next` = `wait` and status `metadata`; and the `official_unchecked.txt` rows with
`next` = `wait` or `retry`. Fetch `by hand` items by the ladder into `WORK/exports/` and
re-run.

## Output

The affected `.bib` files with published entries in place and markers removed; the
`published.txt` and `upgrade.txt` rows resolved or handed over.
