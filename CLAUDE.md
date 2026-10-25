# PhenomRaidTools – notes for Claude

World of Warcraft raid addon: the raid lead plans per boss which player sees
which message when and syncs the plan to the group before the pull. The `.toc`
targets **WoW: Forever** (Interface 16001) and **Retail** (120105 live, 120107
PTR), both on the modern mainline API including the Midnight addon
restrictions (no combat log, unit health/power or addon messages during
encounters). Do not assume the old Classic Era API.

## Layout
- Dev setup and checks: `docs/DEVELOPMENT.md`. Release and shared
  conventions: see *Shared with the other PhenomDevel addons* below.
- `PhenomRaidTools/` is the addon folder that gets installed; everything else
  stays in the repo only (see `.pkgmeta`).
- Default branch is `master`, not `main`.

## Checks
- `luacheck .` must pass before committing.
- Kevin verifies every change in-game. In the PR description, list what he
  should check in-game.

## Shared with the other PhenomDevel addons
PhenomRaidTools, BlizzHUDTweaks, Quality-of-Life-Forever and
Guild-Finder-Forever follow the same conventions below; this section is
identical in their `CLAUDE.md`. A change to a shared file or rule goes to all
four (one PR per repository).

- Release process: `docs/RELEASE.md`. `.github/workflows/release.yml`,
  `.github/workflows/ci.yml` and `docs/RELEASE.md` are identical in all four,
  except the `env` block of `release.yml` and the "This repository" section
  of `RELEASE.md`.
- Tags: `vX.Y.Z`, test releases `vX.Y.Z-alphaN` / `-betaN`. Releases are
  started by Kevin (*Actions → Release → Run workflow*); never push tags or
  start the release workflow without being asked.
- Every user-facing PR adds a line under `## Unreleased` in `CHANGELOG.md`
  (written for players). A release PR renames it to `## vX.Y.Z (YYYY-MM-DD)`
  and adds the "What's new" entry where the addon has one.
- Repository layout, the same in all four (only the folders an addon needs):
  - `<Addon>/<Addon>.toc` lists everything (libraries too, no `embeds.xml`),
    paths with backslashes, sections `Libs`, `Locales`, `Core`, `UI`,
    `Modules`.
  - `<Addon>/Libs/`, `Locales/` (enUS first), `Media/` (addon icon
    `Logo.tga`/`Logo.blp`, other assets in subfolders), `Core/` (setup in
    `Core/Init.lua`, logic, data, events), `UI/` (windows, widgets, option
    pages, minimap button, toasts, What's new), `Modules/` (self-contained
    features).
  - `docs/` (`DEVELOPMENT.md` with the layout tree, `RELEASE.md`,
    `logo/logo.svg` + `logo/logo.png`), `tools/` (dev scripts),
    `.github/workflows/` (`ci.yml`, `release.yml`) and
    `.github/ISSUE_TEMPLATE/` (`bug-report.md`, `feature-request.md`,
    identical in all four).
  - Root: `.editorconfig`, `.gitignore` (same base, repo-specific part
    below it), `.luacheckrc`, `.pkgmeta` (ignore `README.md`, `CLAUDE.md`,
    `docs`, `tools`), `CHANGELOG.md`, `CLAUDE.md`, `LICENSE` (MIT),
    `README.md`.
- READMEs are for players only, outline in this order:
  1. `# Name`, logo (`<img … width="96" align="right">` with an absolute
     `https://raw.githubusercontent.com/…` URL, so it also renders on
     CurseForge/Wago), badges: Version, CurseForge, License (same set in all
     four)
  2. summary: bold one-line tagline and a short abstract
  3. `## Supported versions`: table `Client | Interface`, matching the `.toc`
  4. `## Installation`: CurseForge/Wago app or GitHub releases, manual
     install folder, first command; then a link to `CHANGELOG.md`
  5. `## Features`, ending with `### Commands` (table)
  6. `## Support`: common issues, GitHub issues, Discord where the addon has
     one, tip link `https://streamlabs.com/phenombutbetter/tip`
  7. footer "Developed with the help of AI …"
- No developer, API, release or guide content in the README; that belongs in
  `docs/` (e.g. `docs/DEVELOPMENT.md`, `docs/RELEASE.md`).
- Every link and image in the README is absolute
  (`https://github.com/PhenomDevel/<repo>/blob/<branch>/…`, images via
  `https://raw.githubusercontent.com/…`), so it also works where the README
  is shown outside GitHub (CurseForge, Wago).
