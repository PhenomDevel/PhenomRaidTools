# Development

## Layout

```
PhenomRaidTools/             addon folder (the only thing that gets installed)
  PhenomRaidTools.toc        load order, interface version, SavedVariables
  Libs/                      libraries (git-ignored except LibDeflate, see below)
  Locales/                   enUS (base), deDE
  Media/                     Logo.blp (addon icon), Sounds/
  Core/                      addon setup (Init.lua), plan sync, triggers, overlays, API
  UI/                        window, widgets, pages, What's new
docs/                        developer docs, release process, API docs (GitHub Pages),
                             logo/ (README logo)
tools/                       fetch-libs.sh (libraries for local development),
                             ldoc/ (API doc generator config)
.pkgmeta                     packaging config (BigWigs packager)
```

Settings are stored in `PhenomRaidToolsDB` (AceDB profiles).

## Libraries

Release builds get Ace3, LibSharedMedia, LibDBIcon and LibDataBroker from the
`.pkgmeta` externals; LibDeflate is committed. To run a git checkout in game:

```sh
tools/fetch-libs.sh "/path/to/World of Warcraft/_retail_/Interface/AddOns"
```

This puts the libraries into `PhenomRaidTools/Libs` (git-ignored): Ace3 from
GitHub at a pinned tag, the others from the latest release zip. With the
AddOns folder as argument it also links the addon folder there. Needs `git`,
`curl` and `unzip`. Run it again to update the libraries.

## Local setup

Link the addon folder into the client so `git pull` + `/reload` is enough. The
folder name must match the `.toc` name. On Windows run `fetch-libs.sh` in Git
Bash without argument and create the link as a directory junction (no admin
rights required):

```powershell
New-Item -ItemType Junction `
  -Path "D:\Games\World of Warcraft\_retail_\Interface\AddOns\PhenomRaidTools" `
  -Target "D:\Dev\PhenomRaidTools\PhenomRaidTools"
```

New files or `.toc` changes require a client restart instead of `/reload`.

## API

Public API for other addons (work in progress), generated with `ldoc`:
[phenomdevel.github.io/PhenomRaidTools](https://phenomdevel.github.io/PhenomRaidTools/api/index.html)

## Checks

Lint: `luacheck .` (also runs in CI on every push). Functionality is verified
in-game.

## Release

Rename `## Unreleased` in `CHANGELOG.md` to `## vX.Y.Z (YYYY-MM-DD)`, merge
it, then run *Actions → Release → Run workflow* on `master` with the version
(`v3.1.0`, or `v3.1.0-beta1` / `-alpha1` for test releases). The workflow
tags the commit and uploads to CurseForge, Wago and GitHub. Details, including
the "What's new" notes and the local test build: [`RELEASE.md`](RELEASE.md)
(same process in all PhenomDevel addons).

## Interface version

The `.toc` lists `16001` (WoW: Forever) and the retail builds (`120105`,
`120107`). If a client shows the addon as out of date, read its value via
`/dump select(4, GetBuildInfo())` and add it to the comma-separated list.
