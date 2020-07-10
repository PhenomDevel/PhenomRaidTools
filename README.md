[![PhenomRaidTools on Discord](https://img.shields.io/badge/discord-PhenomRaidTools-738bd7.svg)](https://discord.gg/GAYDjBF)

# PhenomRaidTools
## Quick Start

To get started just type `/prt` into your chat or click the minimap icon and PhenomRaidTools will open. If you need any help to set up an encounter please see [#Help](https://github.com/PhenomDevel/PhenomRaidTools#help)

## About
Send messages to everyone in the raid team based on four different trigger types

 - Timer
 - Rotation
 - Health percentage
 - Power percentage
 
You can configure almost everything about when and how the messages should be displayed for your raid team.

### Timer
You can configure a lot of different things for a timer

 - Start condition on which the timer should start e.g. spell cast of an encounter so you know it is phase 2
 - Stop condition on which the timer will stop e.g. spell cast of an encounter so you know phase 2 ended and boss is back into phase 1
 - Timings on which messages should be displayed for the raid team

### Rotation
You can configure a lot of different things for a rotation

 - Trigger condition on which the counter for the rotation should increment e.g. spell cast of encounter
 - Should the rotation restart - so if all your rotation entries are successfully processed the rotation will start over again e.g. kick rotation
 - Ignore after activation - you can ignore the trigger condition for a set amount of time so the trigger won't activate e.g. if there are a lot of the same events happening at the given time and you only care about it once every 30 seconds
 - Ignore duration - sets the duration for how long the trigger condition should be ignored

### Health percentage
You can configure a lot of different things for a health rotation

 - Unit id for which the check should be performed
 - Ignore after activation - you can ignore the health check for a set amount of time so the messages will not be sent multiple times because the boss is at a given percentage for a long duration
 - Ignore duration - sets the duration for how long the health check
 - Operator (greater than, less than, and equals) e.g. you care about the boss hp when it is less than 50%
 - Health percentages - integer values of the unit health on which the messages should be sent to the raid team

### Power percentage
Same as health percentage but with the power values of the given unit.

### Messages
For each trigger type you can send multiple messages. You have the ability to define more than one target.
Message consists of the following

 - targets: A comma separated list of targets e.g. `ALL, HEALER, Phenom`
 - delay: The delay after which the message should be sent once the trigger condition is met
 - duration: The duration for how long a message should be shown
 - message: The message which will be displayed for the targets
   - `%s` will be interpolated to the remaining time of the display e.g. `Big DMG inc in %s`
   - `$source` will be interpolated with the source of the occurring event e.g. `source has just cast XY`
   - `$target` will be interpolated with the target of the occurring event e.g. `XY cast on $target`
   - `{spell:$ID}` will be interpolated with the texture of spell $ID
   - `{rt1-8}` will be interpolated with the texture of the raidmarker rt1 - rt8

## Setup
### Easymode
 - Just install the addon through the Twitch desktop app

### Manual
 - Download the latest release of the addon: [Releases](https://github.com/PhenomDevel/PhenomRaidTools/releases)
 - Unpack the zip folder
 - Copy the folder `PhenomRaidTools` to your World of Warcraft addon folder `path\to\World of Warcraft\_retail_\Interface\AddOns`

(!) If you want to use [WeakAuras2](https://github.com/WeakAuras/WeakAuras2/releases) to receive messages do the next steps aswell. You can use the addon to receive message but you won't have as many visual options as in [WeakAuras2](https://github.com/WeakAuras/WeakAuras2/releases).

 - You will have to install [WeakAuras2](https://github.com/WeakAuras/WeakAuras2/releases) if you haven't yet
 - Install the receiver weakaura which is used to receive messages that PhenomRaidTools will send to the given players [PhenomRaidTools: Receiver](https://wago.io/HyieicnAz)

## Help
I have set up a discord server up and running for every kind of question. Feel free to enter and ask what you have trouble with. [Discord](https://discord.gg/GAYDjBF)

## Feature Requests (Planned, Backlog, Questionable)
 - [Questionable] Add trigger for `DBM` / `BW`
 - [Backlog] Be able to configure multiple conditions for each trigger. Like trigger on `ENCOUNTER_START` *or* `SPELL_CAST_SUCCESS/123`
 - [Backlog] Sync function to sync all encounters with someone else at once
 - [Backlog] Add "global" encounter which will always be merged with the current encounter for e.g. seconds pots or something
 - [Backlog] Be able to set a start condition for rotations so it does not start counting the first time a condition is met. It would only start counting after the start condition was met once
 - [Backlog] Have multiple overlays for messages like Important, normal and unimportant or something which alle can be positioned differently. The sender can configure the positions for the messages and those will be send to the receiver. The receiver can overwrite these positions if wanted.

## TODOs
 - Translate error messages and debug messages