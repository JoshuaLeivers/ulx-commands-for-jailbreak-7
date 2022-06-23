[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) ![Version: v4.0.0 Alpha](https://img.shields.io/badge/version-v4.0.0%20alpha-red)


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
This should result in a file structure structure like `garrysmod/addons/ulx-jb7/lua/`.

## Usage
The commands added by this plugin are as follows:

| Command                                     | Module | Chat Command(s)                                    | Description                                         |
| ------------------------------------------- | ------ | -------------------------------------------------- | --------------------------------------------------- |
| `ulx opencells`                             | Maps   | `!opencells` <br>                                  | Opens all cell doors.                               |
| `ulx closecells`                            | Maps   | `!closecells` <br>                                 | Closes all cell doors.                              |
| `ulx cellsstatus`                           | Maps   | `!cellsstatus` <br> `!cells`                       | Returns whether the cell doors are currently open.  |
| `ulx startheli`                             | Maps   | `!startheli`                                       | Starts the helicopter on new_summer based maps.     |
| `ulx stopheli`                              | Maps   | `!stopheli`                                        | Stops the helicopter on new_summer based maps.      |
| `ulx mancannon`                             | Maps   | `!mancannon`                                       | Opens the mancannon door on jail_summer jail maps.  |
|---------------------------------------------|--------|----------------------------------------------------|-----------------------------------------------------|
| `ulx forceguard <player(s)>`                | Teams  | `!forceguard` <br> `!fguard`                       | Forces target(s) to guard team.                     |
| `ulx forceprisoner <player(s)>`             | Teams  | `!forceprisoner` <br> `!fprisoner`                 | Forces target(s) to prisoner team.                  |
| `ulx forcespectator <player(s)>`            | Teams  | `!forcespectator` <br> `!fspectator` <br> `!fspec` | Forces target(s) to spectator team.                 |
| `ulx forcewarden <player>`                  | Teams  | `!forcewarden` <br> `!fwarden`                     | Forces target to warden role.                       |
| `ulx demotewarden`                          | Teams  | `!demotewarden` <br> `!dwarden` <br> `!dw`         | Removes the warden status from the current warden.  |
| `ulx rebel <player(s)>`                     | Teams  | `!rebel`                                           | Declare prisoner(s) as rebels.                      |
| `ulx pardon <player(s)>`                    | Teams  | `!pardon`                                          | Pardon rebel prisoner(s).                           |
|---------------------------------------------|--------|----------------------------------------------------|-----------------------------------------------------|
| `ulx guardban <player> [time] [reason]`     | Bans   | `!guardban`                                        | Bans target from guard team.                        |
| `ulx wardenban <player> [time] [reason]`    | Bans   | `!wardenban`                                       | Bans target from warden status.                     |
| `ulx unguardban <player>`                   | Bans   | `!unguardban`                                      | Unbans target from guard team.                      |
| `ulx unwardenban <player>`                  | Bans   | `!unwardenban`                                     | Unbans target from warden status.                   |
| `ulx guardbaninfo [player]`                 | Bans   | `!guardbaninfo`                                    | Views guard ban info for self/target.               |
| `ulx wardenbaninfo [player]`                | Bans   | `!wardenbaninfo`                                   | Views warden ban info for self/target               |

## Suggestions & Issues
If you have any new ideas, suggestions or issues, please feel free to create a new issue.
This includes requests for new commands, new maps to be added to opencells, and any commands not working as intended.

## License
	ULX Commands for Jailbreak 7
	Copyright (C) 2016-2017  Ian Murray
	Copyright (C) 2018-2022  VulpusMaximus

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

### Declaration of Changes
The GNU GPL v3 licence requires that any significant changes to the source be disclosed.
This version of this software includes several new commands/functionality, and most existing code has had significant changes (i.e. the code has changed, but the functionality hasn't by much - it should just be clearer and ideally "better" as much as possible).
