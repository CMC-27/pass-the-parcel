# docs/ — Generated Wiki Visualizer

This directory holds a **generated** artifact, not authored documentation.

| File | Source |
|---|---|
| `wiki-graph.md` | `python scripts/wiki_visualize.py` |

## Regenerate

```
python scripts/wiki_visualize.py
```

The script walks `.wiki/`, emits a mermaid hub-and-spoke graph plus a linked catalog, and refuses to write if any emitted link does not resolve. Commit the refreshed `wiki-graph.md` whenever the wiki structure changes.

## Not Hosted

This is a static Markdown export only. No GitHub Pages, no MkDocs, no build step. Hosting can be added later without changing the export.
