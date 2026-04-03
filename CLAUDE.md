# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment

This is a **TOTVS/Protheus ERP** development workspace using **AdvPL** (Advanced Business Programming Language). Development requires:
- VS Code with the **TOTVS Developer Studio** extension (TOTVS Language Server)
- Access to TOTVS SmartClient for running/debugging programs
- Protheus include files (referenced from an external path in `settings.json`)

## Debug / Run

Debugging is configured in `.vscode/launch.json`:
- Configuration name: **"TOTVS Language Debug"**
- Prompts for a program name at launch
- Connects to SmartClient at `../totvs/bin/smartclient/smartclient.exe`
- Multi-session and table sync are enabled

There are no standalone build/test CLI commands — compilation and execution happen through the TOTVS Language Server extension within VS Code.

## Architecture

### Binary Library Stubs (`.vscode/.advpl/`)

These files are compiled binary definitions (not editable source) that expose the available TOTVS framework API:

- **`_binary_class.prw`** — Object-oriented components:
  - `brgetddb`: Advanced grid for displaying multi-column DB records
  - `msbrgetdbase`: Base browse control (`TCBrowse` subclass) with navigation methods (`goup`, `godown`, `goleft`, `goright`) and data management (`recadd`)
  - `mscalend`: Calendar control with restriction management and color customization
  - All components use codeblock-based event handlers (`bchange`, `bldblclick`, `brclick`, `bwhen`, `bvalid`)

- **`_binary_functions.prw`** — Procedural utilities:
  - DB operations: `changequery`, `dbapp`, `dbcopy`, `dbdelim`, `dblocate1`
  - Data migration/transformation helpers
  - SQL query compatibility/conversion functions

### Includes Path

Protheus framework includes (`.ch` header files) are located at the path configured in `settings.json` — a Google Drive-synced folder from the user's laptop. Ensure this path is accessible when using the language server.
