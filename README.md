[![PhenomRaidTools on Discord](https://img.shields.io/badge/discord-PhenomRaidTools-738bd7.svg)](https://discord.gg/j5yGbK)
# PhenomRaidTools
## Quick Start
To get started just type `/prt` into your chat and PhenomRaidTools will open up. If you need any help setting up an encounter please see [#Help](https://github.com/PhenomDevel/PhenomRaidTools#help)
## About
Send messages to everyone in the raidteam based on four different trigger types:
- Timer
- Rotation
- Health percentage
- Power percentage

You can configure almost everything about when and how the messages should be displayed for your raidteam.
### Timer
You can configure a lot of different things for a timer:
- Start condition on which the timer should start e.g. spell cast of an encounter so you know it is phase 2
- Stop condition on which the timer will stop e.g. spell cast of an encounter so you know phase 2 ended and boss is back into phase 1
- Timings on which messages should be displayed for the raidteam
### Rotation
You can configure a lot of different things for a rotation:
- Trigger condition on which the counter for the rotation should increment e.g. spell cast of encounter
- Should the rotation restart - so if all you rotation entries are succesfully processed the rotation will start over again e.g. kick rotation
- Ignore after activation - you can ignore the trigger condition for a set amount of time so the trigger won't activate e.g. if there are a lot of the same events happening at the given time and you only care about it once every 30 seconds
- Ignore duration - sets the duration for how long the trigger condition should be ignored
### Health percentage
You can configure a lot of different things for a health rotation:
- Unit id for which the check should be performed
- Ignore after activation - you can ignore the health check for a set amount of time so the messages will not be send multiple times because the boss is at a given percentage for a long duration
- Ignore duration - sets the duration for how long the health check
- Operator (greater than, less than, and equals) e.g. you care about the boss hp when it is less than 50%
- Health percentages - interger values of the unit health on which the messages should be send to the raidteam
### Power percentage
Same as health percentage but with the power values of the given unit.
## Setup
1. Download the latest release of the addon: [Releases](https://github.com/PhenomDevel/PhenomRaidTools/releases)
2. Unpack the zip folder and place it into your normal addon folder
3. You will have to install [WeakAuras2](https://github.com/WeakAuras/WeakAuras2/releases) if you haven't yet
4. Install the receiver weakaura which is used to receive messages that PhenomRaidTools will send to the given players [PhenomRaidTools: Receiver](https://wago.io/HyieicnAz)
## Help
I have setup a discord server up and running for every kind of question. Feel free to enter and ask what you have trouble with. [Discord](https://discord.gg/j5yGbK)
## TODOs
- Add placeholders for interpolating event information (%target = target of the spell cast as target for the message etc.)
  %target
  %source
- Add condition met counter for timers (after X conditon mets it shoulkd trigger not ion first alwys)
- Add trigger for DBM / BW - On hold
- Be able to configure multiple conditions for each trigger
  Like trigger on ENCOUNTER_START *or* SPELL_CAST_SUCCESS/123
  Each conditon 