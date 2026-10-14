# miaa-bibtex skill set

MIAA lab's BibTeX and PDF curation, split into one shared core, eight atomic stage skills,
three composers, and a meta skill. The set is portable: plain `SKILL.md` directories that any
agent reading the Agent Skills format can load.

## Layout

```
miaa-bibtex/
├── README.md
├── install.sh              # installs or removes the skills in the agent skill roots
└── skills/
    ├── miaa-bibtex-core/   # invariants, conventions, ladder, report format
    ├── miaa-bibtex-acquire/ ... etc.
```

## The set

| Tier | Skill | One aim |
|---|---|---|
| 0 | `miaa-bibtex-core` | The invariants every stage obeys |
| 1 | `miaa-bibtex-acquire` | Official BibTeX for new papers |
| 1 | `miaa-bibtex-upgrade` | Promote interim and preprint entries when proceedings publish |
| 1 | `miaa-bibtex-complete` | Fill missing entry values by search |
| 1 | `miaa-bibtex-decide` | Author keys, title case, braces, taxonomy |
| 1 | `miaa-bibtex-verify` | Audit entry structure and investigate reports |
| 1 | `miaa-bibtex-library` | Audit and complete the venue library |
| 1 | `miaa-bibtex-pdfs` | Download PDFs by citation key |
| 1 | `miaa-bibtex-scholar` | Citation counts and title checks |
| 2 | `miaa-bibtex-curate` | Compose acquire, complete, decide, verify for a new batch |
| 2 | `miaa-bibtex-review` | Compose verify and complete on an existing tree |
| 2 | `miaa-bibtex-refresh` | Compose upgrade, library, verify for periodic upkeep |
| 3 | `miaa-bibtex-doctor` | Keep the set in sync with bibcc and with itself |

## Rules live in one place

`miaa-bibtex-core` holds every rule: the official-BibTeX hard rule, the bibcc-command-line-only
rule, the work-directory and run-report conventions, the retrieval ladder, the dependency
preflight, the master report-to-action table, the MIAA hard rules, and rule precedence. No
stage skill restates a rule; each names its commands and its scope, then defers to core. When
a rule changes, change it in core only.

## Install and remove

```bash
./install.sh              # symlink every skill into ~/.agents/skills, then mirror into ~/.claude and ~/.gemini
./install.sh --check      # validate frontmatter and consistency, change nothing
./install.sh --uninstall  # remove the skill links from every root (a real directory needs --force)
```

The canonical root is `~/.agents/skills`; `~/.claude/skills` and `~/.gemini/skills` link to
it. Set `AGENTS_SKILLS_DIR` to install elsewhere. Add `CODEX_SKILLS_DIR` to also mirror into a
Codex root. `--uninstall` removes only the symlinks this installer created; it leaves a real
directory in place unless you pass `--force`, so a checked-out copy is never deleted by
accident.

## Maintain

After a bibcc release, run the `miaa-bibtex-doctor` skill. It reads `bibcc surface`, the
machine-readable command surface that bibcc prints as JSON, and diffs it against what
`skills/miaa-bibtex-core/references/bibcc-workflow.md` documents. It flags any command,
option, report file, or status word that changed, and checks that the set is internally
consistent.
