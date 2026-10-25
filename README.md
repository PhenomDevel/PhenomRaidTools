# PhenomRaidTools

<img src="docs/logo.png" alt="PhenomRaidTools logo" width="96" align="right">

[![CI](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml)
[![Release](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml)
[![Version](https://img.shields.io/github/v/release/PhenomDevel/PhenomRaidTools?label=version)](https://github.com/PhenomDevel/PhenomRaidTools/releases/latest)
[![CurseForge](https://img.shields.io/curseforge/dt/381654?label=CurseForge)](https://www.curseforge.com/projects/381654)
[![License](https://img.shields.io/github/license/PhenomDevel/PhenomRaidTools)](LICENSE)
[![Discord](https://img.shields.io/discord/596662921753526275?label=discord)](https://discord.gg/GAYDjBF)

**Plan per boss which player sees which message when; the raid lead syncs the plan before the pull.**

PhenomRaidTools is used next to the usual raid addons like
[WeakAuras2](https://github.com/WeakAuras/WeakAuras2),
[DeadlyBossMods](https://github.com/DeadlyBossMods/DeadlyBossMods) and
[BigWigs](https://github.com/BigWigsMods/BigWigs). The raid lead plans each
boss ahead, the plan goes to the group before the pull, and every player runs
it locally and sees only the messages meant for them.

- **Plan on a timeline.** Click where something should happen. An assignment shows once, repeating or at several times, for the players, roles, groups or classes you pick, on the difficulties you pick.
- **Cooldowns made easy.** Pick a raid or utility cooldown and it shows with icon and spell name (or your text) on the matching overlay. Text to speech can read any message aloud.
- **See it before the pull.** A preview beside the window plays the assignment or overlay you are editing.
- **Overlays your way.** Text, icons or bars, growing in any direction. New profiles start with messages at the top, healing cooldowns on the left and utility cooldowns on the right.
- **One window.** Overview with the sync status of every player, encounters grouped by instance with boss portraits, templates, overlays, settings and profiles, all searchable.

> **Rebuilt for Midnight.** Midnight (12.0, also WoW: Forever) took the combat
> log, boss health and power and in-encounter addon messages away from addons,
> and PhenomRaidTools 3 is rebuilt around that. **Before updating from 2.x,
> back up** `WTF/Account/<account>/SavedVariables/PhenomRaidTools.lua`: the
> update removes what can't run anymore (rotations, health and power
> percentages, timers on combat log events, raid warnings and markers,
> placeholders, `/prtm`, encounter versions – the active one stays – and timer
> groups, whose difficulties move to the assignments). Details in
> [Midnight addon restrictions](#midnight-addon-restrictions) and the
> [changelog](CHANGELOG.md).

## Installation

1. Install it with the CurseForge or Wago app, or download the zip from
   [GitHub releases](https://github.com/PhenomDevel/PhenomRaidTools/releases).
2. For a manual install, extract `PhenomRaidTools` into the game client's
   `Interface/AddOns/` folder (`_retail_` or your WoW: Forever installation).
3. Log in and type `/prt`. On the first start a short guide asks for your role
   (raid lead, player or both) and lets you place the message overlays.

Changes per version: [CHANGELOG.md](CHANGELOG.md).

## Supported clients

| Client | Interface |
| --- | --- |
| WoW: Forever | 16001 |
| Retail | 120105 (12.1.5) and 120107 (12.1.7 PTR) |

Classic Era, Wrath Classic and other clients are not supported anymore.

### Midnight addon restrictions
Since 12.0 (also on WoW: Forever) addons can't read the combat log, unit health or unit power during encounters, and addon messages are blocked while an encounter is in progress. PhenomRaidTools therefore distributes the plans before the pull and every player runs them locally:

- In sender mode, the group leader or an assistant sends the plans of all enabled encounters on ready check (only what changed or isn't confirmed yet) or with `/prt sync`.
- Players in receiver mode keep the last plan per encounter (only from the leader or an assistant) and run it on `ENCOUNTER_START`, showing the messages meant for them.
- Assignments count from the pull. Everything that can't run anymore was removed, and the update deletes it from existing profiles: rotations, health and power percentages, timers on combat log events, stop conditions, raid warnings, raid markers, placeholders (`$tank1`, custom and encounter placeholders), the combat event recorder and `/prtm`.

## Usage

Open the window with `/prt` or the minimap icon. Everything lives in one window with a search field:

- **Overview:** lead/player mode, sending plans to the group with the confirmation of every member, the plans you received.
- **Encounters:** one plan per boss, listed by instance, with a timeline of all assignments after the pull, import/export and the MethodRaidTools note. *New encounter* lists the bosses of the current raids from the Encounter Journal; any other boss is created by its encounter ID. An import replaces the plan of its encounter.
- **Templates:** messages you reuse; load them in any message.
- **Overlays:** the message overlays, your next assignments during an encounter and the lead status.
- **Settings** and **Profiles** (including a profile per specialization and profile export/import).

For a brief introduction read the [PhenomRaidTools Beginner Guide](docs/PhenomRaidTools_Beginner_Guide.pdf).

### Commands

| Command | |
| --- | --- |
| `/prt` | Open the window |
| `/prt sync` | Send your plans to the group (also happens on every ready check) |
| `/prt versions` | Print the PRT versions in your group |
| `/prt news` | Show what's new |
| `/prt profile` | Open the profiles |
| `/prt minimap` | Show the minimap icon again |

## Features

### Lead & player
The raid lead (sender mode) builds the plans and sends them to the group before the pull. Players (receiver mode) run the received plans on the pull and see only the messages meant for them. Plans are accepted from the group leader and assistants only.

### Assignments
Click into an encounter's timeline to add an assignment at that time; the timeline shows each assignment's spell icon (a note for plain text) and on hover its text and who sees it. While you edit an assignment or an overlay, a preview panel beside the window shows it as your players see it.

Every assignment shows one message: once (e.g. at `1:30`), repeating (e.g. every `0:30` from `0:15` to `3:00`) or at several times (`0:30, 1:15, 90`). It is edited as one sentence: type (message or cooldown), targets (roles, players, raid groups, classes), overlay, duration and sound or text to speech. A cooldown shows the spell's name unless you give it your own text. It runs on the difficulties selected for it (Normal, Heroic, Mythic); with none selected it is off. *Text to speech* reads the text aloud with the voice of the game's text to speech settings instead of playing a sound.

Encounter versions and groups were removed: updating keeps the version that was active and moves each group's difficulties (or its off state) to its assignments.

### Overlays
New profiles start with three overlays: *Messages* at the top, *Healing cooldowns* on the left and *Utility cooldowns* on the right. A cooldown chosen from the list goes on the overlay for its kind. *Default overlays → Restore* brings them back. Each message shows on one of your overlays. Every overlay has its own style (text, icons or bars), grows up, down, left or right from its anchor or centered on it, and has its own font, sound and number of messages at once. Unlock an overlay to drag it; *Show on screen* shows sample messages where it is.

*Your next assignments* lists what's next for you during an encounter with a countdown, read from the plan. The *lead status* shows the time to the lead's next assignment.

### MethodRaidTools note
The encounter page writes the cooldown assignments of the encounter (a line per time: icon and players) into your MethodRaidTools note, either the whole note or only between `{prtstart}` and `{prtend}`. Send it with MRT as usual.

## Feedback & support

- Questions: [Discord](https://discord.gg/GAYDjBF). Post your encounter strings there so others can profit.
- Bugs and ideas: [GitHub issues](https://github.com/PhenomDevel/PhenomRaidTools/issues).
- If you like the addon, star it on GitHub. To support its development with money, tip any amount on [Streamlabs](https://streamlabs.com/phenomgamestv/tip).

## Development

- Libraries, local setup and checks: [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)
- Release (same process in all PhenomDevel addons): [`docs/RELEASE.md`](docs/RELEASE.md)
- API documentation (work in progress): [phenomdevel.github.io/PhenomRaidTools](https://phenomdevel.github.io/PhenomRaidTools/api/index.html)

## License

[GPL-2.0](LICENSE)

---

Developed with the help of AI ([Claude](https://claude.ai) by Anthropic).
Every change is reviewed by a professional software developer before it is
merged.
