[![CI](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml) [![Release](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml) [![Discord General](https://img.shields.io/discord/596662921753526275?label=discord)](https://discord.com/invite/GAYDjBF)
# PhenomRaidTools

## Quickstart
Open the addon with `/prt` or the minimap icon. On the first start a short guide asks for your role (raid lead, player or both) and lets you place the message overlays. If you seek help visit the discord server and feel free to ask :)

Everything lives in one window with a search field:

- **Overview:** lead/player mode, sending plans to the group with the confirmation of every member, the plans you received.
- **Encounters:** one plan per boss with versions, a timeline of all messages after the pull, timers, rotations, encounter placeholders, import/export and the MethodRaidTools note.
- **Players & groups:** raid roster (`$tank1`, `$heal1`, `$dd1`, ...), custom placeholders with a preview of who they resolve to in your group, import and export of placeholders.
- **Templates:** messages you reuse; load them in any message.
- **Overlays:** the message overlays, your next assignments during an encounter and the lead status.
- **Settings** and **Profiles** (including a profile per specialization and profile export/import).

Messages are edited as one sentence with a live preview: type (message, cooldown, raid warning, raid marker), targets (roles, roster, placeholders, groups, classes), delay, duration and sound. *Try it* shows the message on your own overlay.

### Commands
| Command | |
| --- | --- |
| `/prt` | Open the window |
| `/prt sync` | Send your plans to the group (also happens on every ready check) |
| `/prt versions` | Print the PRT versions in your group |
| `/prt news` | Show what's new |
| `/prt profile` | Open the profiles |
| `/prt minimap` | Show the minimap icon again |
| `/prtm <text>` | Show a message to everyone (during encounters only to you) |

## About
PhenomRaidTools is an addon to use next to the usual raid utility addons like [WeakAuras2](https://github.com/WeakAuras/WeakAuras2), [DeadlyBossMods](https://github.com/DeadlyBossMods/DeadlyBossMods), and [BigWigs](https://github.com/BigWigsMods/BigWigs). With PhenomRaidTools you'll be able to configure your own timers, rotations and other triggers to show messages on the screen. You can choose when and how the messages should be displayed as well as who in the raid team should see the messages.

## Supported clients
| Client | Interface |
| --- | --- |
| WoW: Forever | 16001 |
| Retail | 120105 (12.1.5) and 120107 (12.1.7 PTR) |

Classic Era, Wrath Classic and other clients are not supported anymore.

### Midnight addon restrictions
Since 12.0 (also on WoW: Forever) addons can't read the combat log, unit health or unit power during encounters, and addon messages are blocked while an encounter is in progress. PhenomRaidTools therefore distributes the plans before the pull and every player runs them locally:

- In sender mode, the group leader or an assistant sends the plans of all enabled encounters on ready check (only what changed or isn't confirmed yet) or with `/prt sync`.
- Players in receiver mode keep the last plan per encounter (only from the leader or an assistant) and run it on `ENCOUNTER_START`, showing the messages meant for them. Raid warnings and raid markers stay with the lead. Placeholders and the raid roster (`$tank1`, ...) resolve with the lead's data, which is sent along.
- Triggers can only react to encounter start/end and combat start/end. Health and power percentages and timers or rotations using combat log events (or a spell, source or target in a condition) don't trigger. They are kept, listed per encounter under *Can't fire anymore*, counted in the What's new window after updating, and not sent with the plan.
- The combat event recorder and the `$target`/`$source` message placeholders are gone; both depended on the combat log.

## Guide
For a brief introduction into the addon please read: [PhenomRaidTools Beginner Guide](https://github.com/PhenomDevel/PhenomRaidTools/blob/master/docs/PhenomRaidTools_Beginner_Guide.pdf)

## Lead & player
The raid lead (sender mode) builds the plans and sends them to the group before the pull. Players (receiver mode) run the received plans on the pull and see only the messages meant for them. The message filter decides whose direct messages (e.g. `/prtm`) you accept; plans are always accepted from the group leader and assistants.

## Triggers
### Timer
Starts on the pull (or combat start) and shows the messages of each timing, e.g. `0:30, 1:15, 90` seconds after the start. Timings can have an offset to warn earlier. Use them for healing cooldowns, soaks or positioning.

### Rotation
Shows the next entry each time its event happens and can start over after the last entry. Since Midnight only pull, combat and encounter start or end are left as events.

### Health and power percentage
Need boss health or power, which addons don't get anymore since Midnight. Existing ones are kept for reference.

## Overlays
Each message shows on one of your overlays. Every overlay has its own style (text, icons or bars), grows up, down, left or right from its anchor or centered on it, and has its own font, sound and number of messages at once. Unlock an overlay to drag it, *Test* shows sample messages.

*Your next assignments* lists what's next for you during an encounter with a countdown, read from the plan. The *lead status* shows the lead's timers and rotations.

## MethodRaidTools note
The encounter page writes the cooldown messages of all enabled timers and rotations into your MethodRaidTools note, either the whole note or only between `{prtstart}` and `{prtend}`. Send it with MRT as usual.

## API
> WORK IN PROGRESS

You can find the API documentation at [API](https://phenomdevel.github.io/PhenomRaidTools/api/index.html)

## Setup

### Easymode
Just install the addon through the Twitch desktop app or any other third party app for managing your addons

### Manual
- Download the latest release of the addon: [Releases](https://github.com/PhenomDevel/PhenomRaidTools/releases)
- Unpack the zip folder
- Copy the folder `PhenomRaidTools` to your World of Warcraft addon folder `path\to\World of Warcraft\_retail_\Interface\AddOns` (or the AddOns folder of your WoW: Forever installation)

### Development
The libraries are not part of the repository (the packager fetches them from `.pkgmeta` on release). To run a git checkout in game:

```sh
scripts/setup-dev.sh "/path/to/World of Warcraft/_retail_/Interface/AddOns"
```

This puts the libraries into `PhenomRaidTools/Libs` (gitignored): Ace3 from GitHub at a pinned tag, the others from the latest release zip. With the AddOns folder as argument it also links the addon folder there, so `git pull` + `/reload` is enough. Needs `git`, `curl` and `unzip`. Run it again to update the libraries.

On Windows run it in Git Bash without argument and create the link as a directory junction (no admin rights required):

```powershell
New-Item -ItemType Junction `
  -Path "D:\Games\World of Warcraft\_retail_\Interface\AddOns\PhenomRaidTools" `
  -Target "D:\Dev\PhenomRaidTools\PhenomRaidTools"
```

## Help
I have set up a discord server up and running for every kind of question. Feel free to enter and ask what you have trouble with. [Discord](https://discord.gg/GAYDjBF)

## Support
If you like the addon and want to support it's development you can simply do so with one of the following

- Leave feedback, suggestions or bug reports
- Star the project on github
- Post your encounter strings in discord so others can profit
- If you really have too much money and want to support me just donate any amount you feel comfortable with on https://streamlabs.com/phenomgamestv/tip

Thank you very much.