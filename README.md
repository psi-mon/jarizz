# jarizz

jarizz is a lightweight native macOS menubar app built with Swift and SwiftUI. It provides one unified UI for talking to multiple AI backends — local CLI agents (claude, copilot, codex, gemini-cli) and web AI services embedded in-app via WKWebView (for example Gemini). A configurable global hotkey pops up the interface from a small menubar icon.

Development is orchestrated by [SwarmForge](https://github.com/unclebob/swarm-forge) (four-pack workflow). Project rules live in `swarmforge/constitution/`. The first feature slice is the app shell: menubar icon, global hotkey, and empty popover.

## Getting started

1. Review `swarmforge/constitution/project.prompt`.
2. Run `./swarm`.
3. In the **Specifier** terminal (first window), send:

   > Implement feature slice 1 from the constitution: menubar icon, configurable global hotkey (default Control+Option+Space), and empty popover. Follow the MVP in scope and out of scope sections.

4. Answer specifier questions, approve the Gherkin spec, then let the swarm run the four-pack loop.
