#!/bin/sh

rm -rf "${WOW_ADDON_DIR}OmniCC"
rm -rf "${WOW_ADDON_DIR}OmniCC_Config"

cp -r OmniCC "${WOW_ADDON_DIR}"
cp -r OmniCC_Config "${WOW_ADDON_DIR}"

cp LICENSE "${WOW_ADDON_DIR}OmniCC"
cp README  "${WOW_ADDON_DIR}OmniCC"
cp LICENSE "${WOW_ADDON_DIR}OmniCC_Config"