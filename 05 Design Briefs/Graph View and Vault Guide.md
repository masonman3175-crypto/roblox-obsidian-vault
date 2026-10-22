---
research_pack: slop-lab-v2
kind: guide
status: navigation
created: 2026-10-17
tags: [roblox, obsidian, guide]
---

# Graph View and Vault Guide

## The requested graph
![[Assets/graph-target.png]]

This image is a reference for a dense linked knowledge graph, not a requirement to duplicate exact node positions. Obsidian's force layout changes as it settles, resizes, and is zoomed. Every new node in this pack corresponds to a nonempty note, and the connections are actual internal links.

## Open it
Open the vault folder already used in this project, then use the left-ribbon **Open graph view** control or the command palette's graph command. No community plugin, theme, or add-on is required. Start reading at [[START HERE - Slop Game Lab]].

## Color organization
- Gold: source/reference records.
- Green: knowledge and decision notes.
- Purple: maps of content and the start page.
- Blue: reusable coding prompts.
- Orange: dependency-ordered build cards.
- Pink: original concepts.

The built-in graph settings file contains these groups and hides the inherited baseline placeholder/Welcome example from the research view. It also hides unresolved placeholder nodes. This is a display filter, not deletion of existing notes. No workspace JSON is replaced by the generator. The existing vault is opened in Graph view for visual verification.

## How to navigate
Use a map of content for a subject, then follow related decisions to dependencies and tests. Source records link to the notes that use them. Use Local Graph at a shallow depth when the global graph is too dense. A source leaf is expected; an unresolved or empty placeholder node is not.

## Evidence versus decoration
The audit counts actual Markdown notes, resolvable wikilinks, unique undirected edges, source records, and connected components. It separately preserves the pre-existing Welcome note's example unresolved link. Tests do not pretend the generated notes are a working game.

## Upkeep
Keep one stable note per decision. Update it when evidence changes instead of appending contradictory copies. Mark stale sources and untested ideas. Make a build card complete only after naming the build and test evidence. Use the transactional backup for this expansion if a restoration is needed; later edits are protected by hash checks.

Source: [[REF - Obsidian Graph view]] · Related: [[Research Methods and Evidence Ledger]] · [[Reference Library]]
