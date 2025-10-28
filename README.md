# SpamBlock
A Windower 4 addon to make yell chat usable. Originally "[FuckOff](https://github.com/Chiaia/Windower-4-Addons/blob/main/fuckoff/fuckoff.lua)" by Chiaia.

## Latest Major Version Changes: 1.4
* The auto-updating code has been improved, no longer triggering on Windower events and now running on a configurable timer. The overhead on updates has also been reduced, as checks now only grab the start of the file to see if there is a new version instead of the entire thing. I've tried my best to make sure the auto-update is as lightweight as possible so please do make an issue if you find any problems.
* A custom blacklist and word filter have been added, which can be added to or removed with addon commands.
* The addon finally has addon commands, please type //sbl help in game with the addon loaded, or see below for a list of these. 

## How to Use
The addon is designed to be set-and-forget, with the option to finetune via addon commands as needed. Filters are manually updated by me and currently designed for use on the Bahamut World to prevent the sea of spam we've been getting recently related to RMT and mercing. You may set your own blacklisted characters and phrases to compliment the filters I maintain if you wish using the commands listed below.

**This addon will auto-update as new versions are released, and the filters are updated. You may turn this off with the command listed below.**

## Commands
All commands use **//sbl** or **//spamblock**.
* **help**
  * Displays a briefer version of these command descriptions.
* **blist** <*player*>
  * Adds named player to your custom blacklist. This functions the same as the in-game blacklist (just better), and will remove that player's chat from any channel.
* **unblist** <*player*>
  * Remove player from your custom blacklist.
* **addword** <*word*>
  * Adds phrase/word to your custom filter list. This only functions in shout and yell, and is designed for strings I have somehow missed, or use for the addon outside of the Bahamut world.
* **delword** <*word*>
  * Removes phrase/word from your custom filter list.
* **list**
  * Prints your current custom blacklist and filter list to the chatlog.
* **autoupdate**
  * Toggles auto-updates on/off. Please keep in mind that turning off auto-updates will mean you will be required to maintain your own blacklist and filters, and you will not receive any updates from this repo until you re-enable it.
* **update**
  * Manually checks for updates.
* **forceupdate**
  * Forces the addon to download the latest version from this repo, regardless of what version number it is. This should be used in cases something has gone wrong.
* **interval** <*min*>
  * Changes how often SpamBlock runs a check for updates, minimum of 5 minutes, the default is 15 minutes. You can use this command to finetune how often you want the game to check for updates, if the preset time is too often or not often enough for your preference.

## Settings File
The settings file allows you to enable or disable which modules of the addon are used;
* **blist** - Turns the manually maintained blacklist and your custom blacklist on or off, this blocks ALL chat from players added to these lists. (*Default: True*)
* **rmt** - Turns the RMT filtering and your custom filters for selected strings in yell and shout messages on or off. (*Default: True*)
* **books** - Turns off spam caused by players using skill-up books, suppressing their chat entries. (*Default: True*)

## To Do
* Apart from bug fixes and filter updates, I consider this addon basically feature complete. I welcome PRs and suggestions for improvements though!

## Known Issues
* After an extended period of time in the same zone, SpamBlock will cease functioning.
  * This is an issue with Windower itself, after about 6 hours in a zone, the packet handler falls over and dies, only fix I'm currently aware of is to restart your game.

## Credits
* Chiaia for [FuckOff](https://github.com/Chiaia/Windower-4-Addons/blob/main/fuckoff/fuckoff.lua), the code this addon is based on.
* Lili for the basis of the auto-updating code, found in [Readable](https://github.com/lili-ffxi/FFXI-Addons/blob/master/readable/readable.lua).
