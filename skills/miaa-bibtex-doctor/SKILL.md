---
name: miaa-bibtex-doctor
description: Maintain the miaa-bibtex skill set against the installed bibcc. Use when bibcc has been updated or a new version is released, or when the user asks to check the set for drift. It reads bibcc surface, the machine-readable command surface, and diffs it against what miaa-bibtex-core documents, flags changed commands, options, report files, and status words, and checks that every skill loads core and restates no rule.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Doctor: keep the set in sync with bibcc

One aim: keep the miaa-bibtex skill set true to the installed bibcc and internally
consistent. This is the only place the bibcc version pin lives.

## Read the installed surface

```bash
bibcc surface                 # JSON: commands, options, reports, status words, version
bibcc surface --format text   # the same, for a quick human read
bibcc --version
```

`bibcc surface` is the machine-readable command surface: every command and subcommand with
its options, the report files BibCC writes, and the status and `next` words its reports use.
Read the fields you need, for example `bibcc surface | jq .status.next`, instead of parsing
the help pages.

The version gate: the set needs BibCC 0.6.0 or later. `bibcc surface` exists in 0.6.0 and
later; if the command is unknown, the install is older and the set cannot run. Report that
and stop.

## Diff against the documented surface

Compare the JSON with `$CORE/references/bibcc-workflow.md` and the command and option names
used across the set. Flag every difference:

- A command or subcommand added or removed, from `.commands[].name` and
  `.commands[].subcommands[].name`.
- An option added or removed, or its default or choices changed, from `.commands[].options`.
- A report file added or removed, from `.reports`, checked against the workflow sheet and the
  master report-to-action table in core.
- A status or `next` word changed, from `.status`, checked against the master table in core.

## Check internal consistency

- Every skill directory name equals its `name:` frontmatter.
- Every stage skill and composer loads `miaa-bibtex-core` and names no rule of its own.
- No skill names a bibcc option inline outside `miaa-bibtex-core` and
  `references/bibcc-workflow.md`.
- Every report file and status word in the set appears in the master report-to-action table
  in core, and every row there names an owning skill.

## Report drift

Write a short report: the installed version (`bibcc surface | jq .bibcc`), each difference
found, the file and line that documents it, and the proposed edit. Patch the set only when
the user approves; never touch the bibcc install.

## Output

A drift report; approved edits to the set.
