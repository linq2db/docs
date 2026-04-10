# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Documentation site for all LinqToDB projects, hosted at [linq2db.github.io](https://linq2db.github.io). Built with a **custom DocFX binary** (`docfx/docfx`) — not the standard NuGet/dotnet tool version. The custom build adds `globalPrefix` support to handle namespace conflicts across EF Core versions (dotnet/docfx#8966).

## Build Commands

```bash
# Update submodules to latest release (required before first build)
./submodules.cmd          # runs: git submodule update --remote --merge

# Local build — generates static site in _site/
./local.cmd               # runs build.ps1 with deploy=$false

# Manual build
powershell ./build.ps1 -deploy $false    # build only
powershell ./build.ps1 -deploy $true     # build + deploy (needs GITHUB_PAT env var)
```

Requires **.NET SDK 10.0** (see `global.json`). The build pre-compiles `LinqToDB.FSharp` as a DocFX workaround before running `./docfx/docfx source/docfx.json`.

## Documentation Structure

- **`source/index.md`** — Landing page with hero, interactive SQL demo, navigation cards
- **`source/documentation/`** — Structured guides (Markdown + `toc.yml` per section)
  - `get-started/` — Installation and setup guides
  - `general/` — Core concepts (connections, interceptors, metrics, database support)
  - `sql/` — SQL features (bulk copy, CTEs, MERGE, joins, window functions)
  - `how-to/` — Task-oriented guides
  - `project/` — Contributing, issue reporting
- **`source/articles/`** — Blog/news content (release notes)
- **`source/api/`** — Auto-generated API docs (output of DocFX metadata extraction, not hand-edited)
- **`source/templates/custom/`** — CSS/JS overrides for DocFX modern template
- **`_site/`** — Generated static HTML output (gitignored)

## Landing Page SQL Demo

The landing page has a tabbed demo showing C# LINQ → generated SQL. See **`tools/sql-demo/README.md`** for full maintenance guide. Key points:

- SQL is pre-generated using `ToSqlQuery()` from the linq2db library
- Test file: `tools/sql-demo/SqlDemoGenerator.cs` — copy to `linq2db/Tests/Tests.Playground/` to run
- Tabs are pure CSS (radio inputs + `:checked` selectors), no JavaScript
- Use `&#10;` instead of blank lines inside `<pre>` blocks (DocFX wraps blank lines in `<p>` tags)

## Key Configuration Files

- **`source/docfx.json`** — Main DocFX config: 17 metadata sources (API namespaces) + build settings
- **`source/toc.yml`** — Top-level navigation (Documentation, Articles, API)
- **`source/filter.yml`** — API filtering rules

## Submodules

Source code for API documentation lives in `submodules/`:
- **`linq2db`** (release branch) — Main ORM library, F# extensions, tools, scaffold, remote packages
- **`LinqToDB.Identity`** (master) — ASP.NET Identity provider
- **`linq2db.EntityFrameworkCore`** — EF Core 3/8/9/10 integration
- **`IdentityServer4.LinqToDB`** — IdentityServer4 integration

Run `./submodules.cmd` after cloning or when API docs need updating.

## CI/CD (Azure Pipelines)

- **`azure-pipelines.yml`** — Triggers on master push: builds and deploys to linq2db.github.io
- **`azure-pipelines.build.yml`** — Triggers on PRs: build-only validation

Both use Windows 2022 VM with .NET SDK 10.x.

## Editor Conventions

Per `.editorconfig`: tab indentation (size 4), CRLF line endings, final newline required.
