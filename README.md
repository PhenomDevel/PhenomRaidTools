# PhenomRaidTools – Raid Assignments & Reminders

<img src="https://raw.githubusercontent.com/PhenomDevel/PhenomRaidTools/master/docs/logo/logo.png" alt="PhenomRaidTools logo" width="96" align="right">

[![Version](https://img.shields.io/github/v/release/PhenomDevel/PhenomRaidTools?label=version)](https://github.com/PhenomDevel/PhenomRaidTools/releases/latest)
[![CurseForge](https://img.shields.io/curseforge/dt/381654?label=CurseForge)](https://www.curseforge.com/projects/381654)
[![License](https://img.shields.io/github/license/PhenomDevel/PhenomRaidTools)](https://github.com/PhenomDevel/PhenomRaidTools/blob/master/LICENSE)

**Plan per boss which player sees which message when; the raid lead syncs the plan before the pull.**

The raid lead plans each boss on a timeline. Before the pull the plan goes to
the group, and every player runs it locally and sees only the messages meant
for them. Since Midnight (also WoW: Forever) addons get no combat log, no boss
health or power and can't message the group during encounters, so everything
counts from the pull. Use it next to your boss mod (DBM, BigWigs).

## Supported versions

| Client | Interface |
| --- | --- |
| WoW: Forever | 16001 |
| Retail | 120105 (12.1.5) and 120107 (12.1.7 PTR) |

Classic Era, Wrath Classic and other clients are not supported.

## Installation

1. Install it with the [CurseForge](https://www.curseforge.com/projects/381654)
   or [Wago](https://addons.wago.io/addons/nQN57KBw) app, or download the zip
   from [GitHub releases](https://github.com/PhenomDevel/PhenomRaidTools/releases/latest).
2. Manual install: extract `PhenomRaidTools` into
   `World of Warcraft/<client>/Interface/AddOns/`.
3. Log in and type `/prt`. A short guide asks for your role (raid lead,
   player or both) and lets you place the message overlays.

**Updating from 2.x:** back up
`WTF/Account/<account>/SavedVariables/PhenomRaidTools.lua` first. The update
removes what Midnight no longer allows: rotations, health and power
percentages, timers on combat log events, raid warnings and markers,
placeholders and `/prtm`.

What changed: [CHANGELOG.md](https://github.com/PhenomDevel/PhenomRaidTools/blob/master/CHANGELOG.md)

## Features

- **Timeline:** each boss is one large timeline with a lane per target. Click
  where an assignment belongs and edit it below as one sentence; drag a marker
  to move it (with Alt to copy it), middle-click it to delete it, zoom with the
  mouse wheel (up to 20 minutes). An assignment shows once, repeating (every *n* seconds
  from–to) or at several times, for the players, roles, raid groups or classes
  you pick, on the difficulties you pick.
- **Demo playback:** play the plan on your overlays in real time or four times as
  fast, for everyone or as a role or player sees it.
- **Cooldowns:** pick a raid or utility cooldown; it shows with icon and spell
  name (or your text). Text to speech can read any message aloud.
- **Sync before the pull:** the lead sends the plans on every ready check or
  with `/prt sync`; the overview shows who has them. Plans are accepted from
  the group leader and assistants only.
- **Overlays:** messages at the top, healing cooldowns on the left, utility
  cooldowns on the right. Each overlay shows text, icons or bars and grows in
  any direction, with its own font, size, outline and shadow. A preview
  beside the window shows what you are editing.
- **Your next assignments** during an encounter with a countdown.
- **Demo:** *Overlays → Demo* or `/prt demo` plays a short sample fight with
  every kind of message for you, so you see your overlays in action.
- **One window with search:** overview with the settings, encounters with the
  bosses of each instance as tiles and import/export, templates, overlays and
  profiles (also per specialization).
- **MethodRaidTools note:** writes the cooldown assignments of a boss into
  your MRT note.

### Commands

| Command | |
| --- | --- |
| `/prt` | Open the window |
| `/prt sync` | Send your plans to the group (also happens on every ready check) |
| `/prt versions` | Print the PRT versions in your group |
| `/prt news` | Show what's new |
| `/prt demo` | Play a sample fight with every kind of message for you |
| `/prt profile` | Open the profiles |
| `/prt minimap` | Show the minimap icon again |

## Support

- Questions: [Discord](https://discord.gg/GAYDjBF)
- Bugs and ideas: [GitHub issues](https://github.com/PhenomDevel/PhenomRaidTools/issues)
- If you like the addon, star it on GitHub or leave a tip on
  [Streamlabs](https://streamlabs.com/phenombutbetter/tip).

---

Developed with the help of AI ([Claude](https://claude.ai) by Anthropic).
Every change is reviewed by a professional software developer before it is
merged.
