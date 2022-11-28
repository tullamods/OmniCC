# OmniCC Changelog

## 10.0.2

* Update TOCs for 10.0.2
* NOTE: OmniCC's options menu is now no longer a part of the main options menu,
  to avoid issues introduced with Dragonflight's UI changes. To bring up the
  options menu, use either the /omnicc or /occ slash commands.

## 10.0.1

* Tagging as release

## 10.0.0

* Update TOCs for 10.0.0

## 9.2.1

* Updated TOCs for 9.2.5, 3.4.0, 2.5.4, and 1.14.3.

## 9.2.0

* Updated TOCs for 9.2.0, 2.5.3, and 1.14.2

## 9.1.6

* Whoops, I forgot that 9.1.5 introduced a new Maximum Cooldown Duration setting (thanks Lyrex)
* Setting the maximum duration slider to 0 will enable cooldowns of any duration
* Adjusted default for max duration to be 0 instead of 600

## 9.1.5

* TOC updates for 1.14.1 and 9.1.5

## 9.1.0

* TOC updates for WoW 9.1.0

## 9.0.10

* Update TOCs for Burning Crusade Classic

## 9.0.9

* Update TOCs for 1.13.7

## 9.0.8

* The cooldown opacity setting is now only applied when set at an opacity value under 100%
* Update TOCs values for 9.0.5

## 9.0.7

* Updated Korean translation (thanks, WetU)
* Updated Russian translation (thanks mone-ennen)
* Fixed an issue when upgrading from OmniCC versions prior to 8.1 or so
* Added a setting to disable auto disabling of blizzard cooldown text `/run OmniCC.db.global.disableBlizzardCooldownText = false; ReloadUI()`

## 9.0.6

* Replaced the Draw Cooldown Swipes with a Cooldown Opacity slider
* Updated Russian Localization (thanks, Artur91425)

## 9.0.5

* Update TOCs for 1.13.6
* Add a nil check when deciding to hide cooldown spirals or not
* Build process updates

## 9.0.4

* Updated TOCs for 9.0.2

## 9.0.3

* Fix cases where cooldowns may not properly refresh

## 9.0.2

* Fixed an error for when OmniCC attempts to display configuration for rules with missing id values

## 9.0.1

* Apply default rulesets only when a profile is first created. This fixes an issue with deleting the defaults.

## 9.0.0

* Finish effects will now trigger immediately for cooldowns that are soon to complete, but were overridden by the GCD.
* Added a new setting, Timer Offset, to adjust the end point for timers to account for things like spell queue windows and latency.
* Added predefined rules for Action Bars, nameplates, and auras
* Updated TOCs for the Shadowlands pre-patch

## 8.3.6

* Deferred loading of OmniCC_Config until you either use /omnicc or click on it in interface options
* Updated Ace3 packages for compatibility with World of Warcraft Shadowlands
