# OmniCC Changelog

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
