---
name: miaa-bibtex-decide
description: Decide and set the content the agent must judge: citation keys, title case, brace protection, and taxonomy placement. Use to decide or rename a citation key, fix title case, brace protected terms such as acronyms and method names, or choose which taxonomy file an entry belongs in. Scope is tunable by the request, for example only check quotation or only keys. Applies to any .bib file or folder, whether or not bibcc created it. Runs under any composer or when the user names this stage. Loads miaa-bibtex-core.
metadata:
  author: MIAA lab
  version: "1.0"
---

# Decide: author keys, titles, and placement

Load `miaa-bibtex-core` first. One aim: set the content that needs judgment. Keys, title
case, braces, and taxonomy. The rules are in `$CORE/references/miaa-conventions.md` sections
1, 4, and 8. The vocabulary is the survey's project terms file (`.bibcc-terms.txt`, seeded
from the lab's shared list in preflight) and the user terms file; `bibcc terms list` shows
both.

Scope is tunable. The request may narrow this skill to one concern, for example only check
quotation, or only decide keys. Default to all four concerns when nothing is narrowed.

## Citation key

`Method_FirstAuthorSurname_VenueYear`. Read the title and abstract, the PDF if ambiguous, for
METHOD: the paper's own name for its method or system, casing kept, else the first two content
words. Year is the edition year. `add` builds the key from the manifest and guesses the rest;
confirm or rename it.

```bash
bibcc check keys bib/<file>.bib
```

`check keys` validates the format and the author surname; it does not rename. **Keys are
final after this step**; PDFs are named by them.

## Title case and protection

APA Title Case. Decide which terms get braces, one pair per term (`{CLIP}`, `{ImageNet}`,
`{CODA-Prompt}: ...`), never the whole title. To brace the vocabulary wherever it appears
with the same case, then see what else bibcc suggests:

```bash
bibcc check quote bib/<file>.bib --apply
bibcc check title bib/<file>.bib
```

`quote --apply` braces only the listed terms and splits compounds braced as a whole
(`{CLIP-Based}` becomes `{CLIP}-Based`); the other suggestions are hints to judge. An
`Over-Braced` row is a judgment call: bibcc cannot tell a method name from a description,
because `{CIP-Net}` and `{CLIP-Based}` have the same shape. For a method name, record it
without braces in the project terms file, then rerun the `--apply` command:

```bash
bibcc terms add CIP-Net --scope project   # commit .bibcc-terms.txt
```

Otherwise the split is right and `--apply` makes it. Never re-brace compounds by hand, and
never edit a terms file by hand. Terms worth having lab-wide go upstream into BibCC's
`examples/terms/miaa.txt` by pull request.

## Taxonomy

Infer the survey's taxonomy from `bib/` (folder and file names) and the section `.tex` files
that cite them. Choose the file from the paper's setting and method family; the input's side
information helps. Move the entry out of `added.bib`. For a new file, add it to the repo's
`\bibliography{...}` list or `\addbibresource` lines.

## Rows this skill owns

From the master table in `miaa-bibtex-core`: `title_case.txt` suggestions, and
`smart_protection.txt` rows (`Over-Braced` and the rest).

## Output

Entries with final keys, correct title case, and braces; entries placed in the taxonomy.
Report any key you renamed so downstream PDF naming uses it.
