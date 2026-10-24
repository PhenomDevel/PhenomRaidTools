[![CI](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/ci.yml) [![Release](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml/badge.svg)](https://github.com/PhenomDevel/PhenomRaidTools/actions/workflows/release.yml) [![Discord General](https://img.shields.io/discord/596662921753526275?label=discord)](https://discord.com/invite/GAYDjBF)
# PhenomRaidTools

## Quickstart
If you want to access the addon just use `/prt` or the minimap icon in game and the addon will open. If you seek help visit the discord server and feel free to ask for help :)

A new configuration window is being built page by page. Preview it with `/prt ui`; until it is complete, `/prt` keeps opening the current window.

Pages available in the new window so far:

- **Players & groups:** raid roster (`$tank1`, `$heal1`, `$dd1`, ...), custom placeholders with a preview of who they resolve to in your group, import and export of placeholders.

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
- Timers started by `ENCOUNTER_START` work. Rotations, health and power percentages and timers started or stopped by combat log events don't trigger. They are kept, marked as *Unsupported* in the configuration, listed once in chat after updating, and not sent with the plan.

## Guide
For a brief introduction into the addon please read: [PhenomRaidTools Beginner Guide](https://github.com/PhenomDevel/PhenomRaidTools/blob/master/docs/PhenomRaidTools_Beginner_Guide.pdf)

## Sender & Receiver
PhenomRaidTools supports two run modes. Sender mode and receiver mode. As sender all your configured triggers which send messages which will be executed and send messages through an addon channel. Every player who matches your configured targets within messages will get a message displayed.
As receiver you'll only get messages displayed when you are a valid message target of the received messages. You can alos filter messages so you won't get spammed.

## Trigger
There are four different types of triggers which will send the configured messages based on different condition which all can be configured.

### Timer
You can configure your own timers for a fight. Those can be used for e.g. healing cooldowns or strategic positioning.
You can setup a start condition for when the timer should start counting and a stop condition which can be used for restarting timers. This can be useful if you have a timer for an encounter phase which repeats itself.

### Rotation
Rotations have a trigger condition for when to count up. Everytime the trigger condition is met a certain action will be executed if there is one for the given index.
Like for timers you can configure start and stop conditions. This can be helpful if you only want a rotation to count in a certain phase or to restart it on certain events.

### Health Percentage
With health percentages you can query specific units for their health value and check if it less, equal or greater than a configured value and send messages based on this condition.

### Power Percentage
Same as health percentage but with power values.

## Spell Database
The spell database is an easy way to search for a specific spell in game by its name without having to browse the web. You have to explicitly activate the spell database since it will build up in the background and might take a while.
It is processed in a very CPU saving way and will stop once you start combat. So you shouldn't be able to notice any performance issues with the spell database activated.

## ExRT Note Export
You can export `Timers` into a ExRT note. This will generate a nicely formatted note based on your `Timers`.
Please note that this will only work for messages with type `cooldown` since the note is presented in a certain way and can be used for e.g. heal cooldown assignments.

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