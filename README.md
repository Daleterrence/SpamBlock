# SpamBlock



A Windower 4 addon to make yell chat usable. Originally "[FuckOff](https://github.com/Chiaia/Windower-4-Addons/blob/main/fuckoff/fuckoff.lua)" by Chiaia.



#### How to Use

The addon is designed to be set-and-forget. Filters are manually updated by me and currently designed for use on the Bahamut World to prevent the sea of spam we've been getting recently related to RMT and mercing.


**This addon will auto-update as new versions are released, and the filters are updated.**

The settings file allows you to enable or disable which modules of the addon are used;

* rmt - Turns the RMT filtering for selected strings in yell and shout messages on or off. (Default: True)
* books - Turns off spam caused by players using skill-up books, suppressing their chat entries. (Default: True)
* autoupdate - Turns the auto-updating function of the addon on or off. If disabled, you will need to maintain your filters yourself. (Default: True)
* blist - Turns the blacklist portion of the addon on or off, this blocks ALL chat from players added to this list, normally used as a fall-back against endlessly spamming characters. (Default: True)



#### To Do

* Add commands to turn settings on or off. They can be enabled or disabled in the settings.xml file the addon generates for now.
* Add a custom blacklist to allow people to add their own names to be filtered.
* Buy milk and bread.



### Known Issues



* After an extended period of time in the same zone, SpamBlock will cease functioning.

  * This is an issue with Windower itself, after about 6 hours in a zone, the packet handler falls over and dies, only fix I'm currently aware of is to reload the addon.

### Credits

- Chiaia for [FuckOff](https://github.com/Chiaia/Windower-4-Addons/blob/main/fuckoff/fuckoff.lua), the addon this code is based on.
- Lili for the auto-updating code, found in [Readable](https://github.com/lili-ffxi/FFXI-Addons/blob/master/readable/readable.lua).
