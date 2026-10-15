---
name: miaa-bibtex-doctor
description: Maintain the miaa-bibtex skill set against the installed bibcc. Use when bibcc has been updated or a new version is released, or when the user asks to check the set for drift. It reads bibcc surface, the machine-readable command surface, and diffs it against what miaa-bibtex-core documents, flags changed commands, options, report files, and status words, and checks that every skill loads core and restates no rule.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Doctor: keep the set in sync with bibcc

Load `miaa-bibtex-core` first: it sets `$CORE` and holds the master table this skill checks.
One aim: keep the miaa-bibtex skill set true to the installed bibcc and internally
consistent. The version gate is defined in core's preflight; this skill checks that it still
holds.

## Read the installed surface

```bash
bibcc surface                 # JSON: commands, options, reports, status words, version
bibcc surface --format text   # the same, for a quick human read
bibcc --version
```

`bibcc surface` is the machine-readable command surface: every command and subcommand with
its options, the report files BibCC writes, the status and `next` words its reports use,
and the `issue_type` words of the check reports, by report file. Read the fields you need,
for example `bibcc surface | jq .status.next` or `bibcc surface | jq .issues`, instead of
parsing the help pages.

The version gate: the set needs BibCC 0.8.0 or later, the same gate as `miaa-bibtex-core`
(`bibcc check quote -h` lists `--scope`). If `bibcc surface` is unknown, the install
predates 0.7.0: fall back to reading `bibcc --help` and `bibcc COMMAND -h`, and note in the
report that the install is too old for the set.

## Diff against the documented surface

Compare the JSON with `$CORE/references/bibcc-workflow.md` and the command and option names
used across the set. Flag every difference:

- A command or subcommand added or removed, from `.commands[].name` and
  `.commands[].subcommands[].name`.
- An option added or removed, or its default or choices changed, from `.commands[].options`.
- A report file added or removed, from `.reports`, checked against the workflow sheet and the
  master report-to-action table in core.
- A status or `next` word changed, from `.status`, checked against the master table in core.
- An `issue_type` word added or removed, from `.issues`, checked against the master table in
  core and the report columns in the workflow sheet.

## Check internal consistency

- Every skill directory name equals its `name:` frontmatter.
- Every stage skill and composer loads `miaa-bibtex-core` and names no rule of its own.
- No skill explains a bibcc option outside `miaa-bibtex-core` and
  `references/bibcc-workflow.md`. Stage skills name the options of the commands they run,
  and the sheet says what each option does.
- Every report file and status word in the set appears in the master report-to-action table
  in core, and every row there names an owning skill.

## Report drift

Write a short report: the installed version (`bibcc surface | jq .bibcc`), each difference
found, the file and line that documents it, and the proposed edit. Patch the set only when
the user approves; never touch the bibcc install.

## Output

A drift report; approved edits to the set.
