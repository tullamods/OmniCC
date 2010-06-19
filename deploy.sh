#!/bin/sh

rm -rf "/Applications/World of Warcraft/Interface/AddOns/OmniCC"
rm -rf "/Applications/World of Warcraft/Interface/AddOns/OmniCC_Config"

cp -r OmniCC "/Applications/World of Warcraft/Interface/AddOns/"
cp -r OmniCC_Config "/Applications/World of Warcraft/Interface/Addons/"

cp LICENSE "/Applications/World of Warcraft/Interface/AddOns/OmniCC/"
cp README  "/Applications/World of Warcraft/Interface/AddOns/OmniCC/"
cp LICENSE "/Applications/World of Warcraft/Interface/AddOns/OmniCC_Config"