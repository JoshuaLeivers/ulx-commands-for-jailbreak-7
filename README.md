[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) ![Version: v3.1 Alpha](https://img.shields.io/badge/version-v3.1%20alpha-red)


# ULX Commands for Jail Break 7
Garry's Mod Addon that adds [ULX](https://github.com/TeamUlysses/ulx) commands for [Excl's Jail Break 7](https://github.com/kurt-stolle/jailbreak).

## Warning
This version is untested and incomplete, and is subject to change at any time. Do not use this version on live servers.

## Requirements
ULX Commands for Jail Break 7 requires the following addons:

* [ULib](https://github.com/TeamUlysses/ulib)
* [ULX](https://github.com/TeamUlysses/ulx)
* [Jail Break 7](https://github.com/kurt-stolle/jailbreak)

## Installation
To install this addon, extract the files from the downloaded archive to your server's `garrysmod/addons/` folder.

## Usage
The commands added by this plugin are as follows:

| Command                                     | Module | Chat Command(s)                                    | Description                                         |
| ------------------------------------------- | ------ | -------------------------------------------------- | --------------------------------------------------- |
| `ulx opencells`                             | Maps   | `!opencells`                                       | Opens all cell doors.                               |
| `ulx closecells`                            | Maps   | `!closecells`                                      | Closes all cell doors.                              |
| `ulx startheli`                             | Maps   | `!startheli` <br> `!starthelicopter`               | Starts the helicopter on new_summer based maps.     |
| `ulx stopheli`                              | Maps   | `!stopheli` <br> `!stophelicopter`                 | Stops the helicopter on new_summer based maps.      |
| `ulx mancannon`                             | Maps   | `!mancannon` <br> `!mc`                            | Opens the mancannon door on jail_summer jail maps.  |
| `ulx forceguard <player(s)>`                | Teams  | `!forceguard` <br> `!fguard`                       | Forces target(s) to guard team.                     |
| `ulx forceprisoner <player(s)>`             | Teams  | `!forceprisoner` <br> `!fprisoner`                 | Forces target(s) to prisoner team.                  |
| `ulx forcespectator <player(s)>`            | Teams  | `!forcespectator` <br> `!fspectator` <br> `!fspec` | Forces target(s) to spectator team.                 |
| `ulx forcewarden <player>`                  | Teams  | `!forcewarden` <br> `!fwarden`                     | Forces target to warden role.                       |
| `ulx demotewarden`                          | Teams  | `!demotewarden` <br> `!dwarden` <br> `!dw`         | Removes the warden status from the current warden.  |
| `ulx rebel <player(s)>`                     | Teams  | `!rebel`                                           | Declare prisoner(s) as rebels.                      |
| `ulx pardon <player(s)>`                    | Teams  | `!pardon`                                          | Pardon rebel prisoner(s).                           |
| `ulx guardban <player> [minutes] [reason]`  | Bans   | `!guardban`                                        | Bans target from guard team.                        |
| `ulx wardenban <player> [minutes] [reason]` | Bans   | `!wardenban`                                       | Bans target from warden status.                     |
| `ulx unguardban <player>`                   | Bans   | `!unguardban`                                      | Unbans target from guard team.                      |
| `ulx unwardenban <player>`                  | Bans   | `!unwardenban`                                     | Unbans target from warden status.                   |
| ``

## Suggestions & Issues
If you have any new ideas, suggestions or issues, please feel free to create a new issue.
This includes requests for new commands, new maps to be added to opencells, and any commands not working as intended.

## License
	ULX Commands for Jailbreak 7
	Copyright (C) 2016-2017  Ian Murray
	Copyright (C) 2018-2019 Joshua Leivers

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	---

	ULX Commands for Jailbreak 7 - Bans Module
	Copyright (C) Team Ulysses
	Copyright (C) Joshua Leivers

	This work is licensed under the Creative Commons
	Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	To view a copy of this license, visit
	<http://creativecommons.org/licenses/by-nc-sa/3.0/> or send a letter
	to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

	This module is an adapted version of ULib and ULX's handling of server
	bans to fit guardbans and wardenbans. All credit is to Team Ulysses,
	who created the majority of this code and provided the source code
	under this license on GitHub.
