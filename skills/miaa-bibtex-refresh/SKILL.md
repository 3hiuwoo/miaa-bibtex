---
name: miaa-bibtex-refresh
description: Periodic upkeep of an existing tree, composing upgrade, library, and verify. Use when a new proceeding or journal issue publishes, or on a schedule, to promote now-published stand-ins, audit the venue library, and re-verify the tree. Loads miaa-bibtex-core and runs the stage skills in order.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Refresh: periodic upkeep

Load `miaa-bibtex-core` first, then run these stage skills in order. Use when the tree already
exists and the trigger is time or a publication announcement, not a new batch.

| Step | Skill | Aim | Stop when |
|---|---|---|---|
| 1 | `miaa-bibtex-upgrade` | Promote interim and preprint entries | Every `upgrade` row is applied; `by hand` rows are listed |
| 2 | `miaa-bibtex-library` | Audit and complete the venue library | Records are filled and reconciled |
| 3 | `miaa-bibtex-verify` | Re-verify the tree | Every gate passes |
| 4 | Write the run report | Core format | The report is shown to the user |

Run `bibcc upgrade --report-only bib/` first, to see what is now published, before any
replacement. Then `bibcc format bib/ --check` to see which files moved.

## Output

Published entries in place with markers removed; the venue library updated; the tree
re-verified; the run report.
