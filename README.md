# PhenomRaidTools

## Setup
1. Download the latest release of the addon: [Releases](https://github.com/PhenomDevel/PhenomRaidTools/releases)
2. Unpack the zip folder and place it into your normal addon folder
3. You will have to install WeakAuras2 if you haven't yet
- Either through the twitch desktop app or from [WeakAuras2](https://github.com/WeakAuras/WeakAuras2/releases)
4. Install the receiver weakaura which is used to receive messages that PhenomRaidTools will send to the given players [PhenomRaidTools: Receiver](https://wago.io/HyieicnAz)

## TODOs
- Add placeholders for interpolating event information (%target = target of the spell cast as target for the message etc.)
-- %target
-- %source
- Add condition met counter for timers (after X conditon mets it shoulkd trigger not ion first alwys)
- Add trigger for DBM / BW
- Add dropdown for events so you don't have to know each event (needs to be adjustable in the options)
- Add ability to enable/disable difficulties in which the addon should start combatlogging

## Features
- You can configure triggers for as many encounters as you want
- Four different triggers which can be used to send messages to the receivers
  - Timers
    - Start Condition
      - Set event, spellID, target of the spell and source of the spell to get the timer rolling
    - Stop Condition
      - Set event, spellID, target of the spell and source of the spell to stop the timer
    - Multiple timings
      - Multiple messages per timing
  - Rotations
  - Health Percentages
  - Power Percentages

## Quick Start
To get started just type `/prt` into your chat and PhenomRaidTools will open up. If you need any help setting up an encounter please see [#Docs](https://github.com/PhenomDevel/PhenomRaidTools#docs)

## Docs
TODO

## Help
We have discord for every kind of questions. Feel free to enter and ask what you have trouble with. [Discord](https://discord.gg/j5yGbK)