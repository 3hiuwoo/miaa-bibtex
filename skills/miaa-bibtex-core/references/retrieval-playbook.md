# Retrieval playbook: where the official BibTeX and PDF live

Rung 2 and 3 of the retrieval ladder. For each source: what counts as official, where the
BibTeX export and PDF are, whether bibcc reaches it, and what a human would click.
Locators (CrossRef, Semantic Scholar, dblp, OpenAlex, Google Scholar) only help find the
official page; their BibTeX is never used.

## Behave like a polite human

- One request per second; send a normal browser `User-Agent` and a `Referer` of the paper
  page when calling an export endpoint.
- A 403, captcha, or "access denied" means stop automating that site and move to the
  browser rung or the human; do not retry in a loop or route around the block.
- Use institutional access only through the user's own logged-in browser session.
- PDFs: official host first, then the arXiv version (same content, accepted for any
  paper). Never unofficial mirrors. If neither exists, list it for the human.
- Retry budget: two attempts per rung per item; then the item is unresolved and goes in
  the run report with handoff instructions.

## Cite buttons are endpoints (turn rung 3 into rung 2)

Most "Cite" / "Export citation" buttons are links or form posts to a plain export
endpoint. Before handing an item to rung 3, fetch the article page (a scrape connector
that renders JavaScript helps), find the BibTeX link in the Cite menu, and GET it with the
article page as `Referer`:

- AAAI OJS: the Cite dropdown links to paths like
  `…/citationstylelanguage/download/bibtex?submissionId=<id>`. The export is `@article`
  with `journal = {Proceedings of the AAAI …}` and the issue month; save it unchanged:
  `bibcc add DIR/` turns it into `@inproceedings` and keeps the month.
- ScienceDirect and ACM DL: the export link is injected by script; a connector with click
  actions (for example Firecrawl `actions`) can press it, or read the request the button
  makes once in a browser's network tab and reuse the pattern.

What truly needs rung 3: anything behind the user's institutional login (paywalled PDFs on
IEEE Xplore, SpringerLink, ACM, ScienceDirect) and sites whose bot protection rejects every
server-side fetcher. A local browser that carries the user's logins covers both. Cloud
connectors never can: they run on their own servers with no access to the user's session.

## Rung 3 recipe (agent-browser, the lab standard)

One-time: `agent-browser install`, then `agent-browser --headed --profile ~/.miaa-browser
open <library proxy login URL>` and let the user log in. Every later run:

```bash
agent-browser --profile ~/.miaa-browser --download-path <pdf folder> open <article URL>
agent-browser snapshot -i            # interactive elements with @eN refs: find Cite / Export / PDF
agent-browser click @eN              # open the Cite menu, then click its BibTeX item
agent-browser get text @eM           # copy the BibTeX text; save it to .bibcc/work/<batch>/exports/<key>.bib
agent-browser click @eP              # "PDF": the file lands in the download path; rename it to <key>.pdf
agent-browser close
```

Save every BibTeX you get this way (or by a rung-2 fetch) to
`.bibcc/work/<batch>/exports/<key>.bib`, with a `% source: <URL>` line just above the
entry, then `bibcc add .bibcc/work/<batch>/exports/ --against bib/ --output added.bib`
fills the matching empty entries, keeping their keys. A `.bib` download from the browser
goes to the same directory.

A 403 or a login wall inside the browser means the user's session lacks access: stop and
list the item for the human. Alternatives if already connected: Claude in Chrome
(`claude --chrome`, drives the user's real Chrome), Chrome DevTools MCP (`--autoConnect`
attaches to the running Chrome), Playwright MCP (`--extension`, or its own persistent
profile logged in once). Same steps, different tool names.

## Sources

| Source | Official for | BibTeX | PDF | bibcc |
|---|---|---|---|---|
| **IEEE Xplore** (`10.1109`) | CVPR/ICCV/WACV once indexed, IEEE journals | "Cite This" → BibTeX on `ieeexplore.ieee.org/document/<n>`; export endpoint `…/rest/search/citation/format?recordIds=<n>&download-format=download-bibtex&lite=true` (needs Referer) | `…/stamp/stamp.jsp?arnumber=<n>`, usually institutional; for CVPR/ICCV/WACV the CVF PDF is the same camera-ready | yes |
| **CVF Open Access** `openaccess.thecvf.com` | CVPR/ICCV/WACV and workshops until Xplore has them (interim) | BibTeX block on the paper's `html/…html` page | `…/papers/…_paper.pdf` link on the same page | yes, interim |
| **Springer / Nature** (`10.1007`, `10.1038`) | ECCV (LNCS), Springer and Nature journals | "Cite this" → "Download citation" → BibTeX; endpoint `citation-needed.springer.com/v2/references/<doi>?format=bibtex&flavour=citation` | `link.springer.com/content/pdf/<doi>.pdf`, usually institutional | yes |
| **ECVA** `ecva.net/papers.php` | ECCV PDFs before SpringerLink | none (use arXiv as interim, upgrade when LNCS is out) | open, listed per year on `papers.php` | empty entry |
| **PMLR** `proceedings.mlr.press` | ICML, CoLLAs, AISTATS, CoRL, UAI, … | BibTeX block on `v<vol>/<id>.html` | `v<vol>/<id>/<id>.pdf` (also the `pdf` field of the export) | yes |
| **NeurIPS proceedings** `proceedings.neurips.cc` | NeurIPS | "Bibtex" button on `paper_files/paper/<year>/hash/<hash>-Abstract-Conference.html` | `…/file/<hash>-Paper-Conference.pdf` | yes (legacy `nips.cc` hosts are rewritten) |
| **ICLR proceedings** `proceedings.iclr.cc` (2024 on) | ICLR 2024+ | same pattern as NeurIPS | same pattern | yes |
| **OpenReview** `openreview.net` | ICLR ≤ 2023 (final); NeurIPS/ICLR/ICML before the proceedings (interim) | "BibTeX" expander on `forum?id=<id>`; API `api2.openreview.net/notes?forum=<id>` → `content._bibtex` | `openreview.net/pdf?id=<id>` | by title only |
| **ACL Anthology** (`10.18653`) | ACL, EMNLP, NAACL, EACL, COLING, Findings | `aclanthology.org/<id>.bib` (exports carry `address`; keep it) | `aclanthology.org/<id>.pdf` | yes |
| **IJCAI** (`10.24963`) | IJCAI | `ijcai.org/proceedings/<year>/bibtex/<nnnn>` | `ijcai.org/proceedings/<year>/<nnnn>.pdf` | yes |
| **AAAI OJS** `ojs.aaai.org` (`10.1609`) | AAAI | article page → "Cite" → BibTeX (automation is blocked; browser works) | "PDF" button → `…/article/download/<id>/<file>` (open) | empty entry |
| **ACM DL** `dl.acm.org` (`10.1145`) | ACM MM, KDD, WWW, TOMM, … | "Export Citation" → BibTeX (blocked for bots) | `dl.acm.org/doi/pdf/<doi>`, often institutional | empty entry |
| **Elsevier / ScienceDirect** (`10.1016`) | PR, Neurocomputing, ESWA, KBS, … | "Cite" → "Export citation to BibTeX" (blocked for bots) | institutional | empty entry |
| **arXiv** | BibTeX: preprints and interim stand-ins only. PDF: accepted fallback for any paper | `arxiv.org/bibtex/<id>` | `arxiv.org/pdf/<id>` | yes |

Early-access journal papers (IEEE "Early Access", Springer "Online First") are official
but incomplete (no volume/pages): mark them and upgrade later.

## Listing pages (useful when building a batch; outside the MIAA rules)

- CVF: `openaccess.thecvf.com/<CONF><YEAR>?day=all`
- PMLR: `proceedings.mlr.press/v<vol>/` (volume index at `proceedings.mlr.press/`)
- NeurIPS / ICLR: `proceedings.neurips.cc/paper_files/paper/<year>`,
  `proceedings.iclr.cc/paper_files/paper/<year>`
- ACL Anthology: `aclanthology.org/events/<venue>-<year>/`
- OpenReview: `openreview.net/group?id=<Venue>/<Year>/Conference`

## Handing the rest to the human (rung 4)

Start from the `empty` and `failed` rows of `.bibcc/<output>/add.txt`, which already carry the key, title, and `get it:` URL. List one line per item: citation
key, official URL, what to click ("Cite → BibTeX", "PDF"), and where to put the result (the
empty entry under that key, or `<key>.pdf` in the PDF folder). Keep bibcc's empty entries
in place so the keys are reserved. The human can save BibTeX files anywhere and run
`bibcc add FILE.bib --output added.bib` to fill them. Never fill a gap with `add --fallback`: a metadata entry
is not official.
