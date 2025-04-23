-- code to drive the addon
local AddonName, Addon = ...
local CONFIG_ADDON = AddonName .. '_Config'
local L = LibStub('AceLocale-3.0'):GetLocale(AddonName)

EventUtil.ContinueOnAddOnLoaded(AddonName, function(addonName)
    Addon:InitializeDB()
    Addon.Cooldown:SetupHooks()

    -- setup addon compartment button
	if AddonCompartmentFrame then
		AddonCompartmentFrame:RegisterAddon{
			text = C_AddOns.GetAddOnMetadata(addonName, "Title"),
			icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture"),
			func = function() Addon:ShowOptionsFrame() end,
		}
	end

    -- setup slash commands
    SlashCmdList[AddonName] = function(cmd, ...)
        if cmd == 'version' then
            print(L.Version:format(Addon.db.global.addonVersion))
        elseif cmd == 'blizzard' then
            if Addon.db.global.disableBlizzardCooldownText then
                Addon.db.global.disableBlizzardCooldownText = false
            else
                Addon.db.global.disableBlizzardCooldownText = true
            end
            C_UI.Reload()
        elseif cmd == 'config' then
            Addon:ShowOptionsFrame()
        else
            Addon:ShowOptionsFrame()
        end
    end

    SLASH_OmniCC1 = '/omnicc'
    SLASH_OmniCC2 = '/occ'

    -- watch for subsequent events
    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Addon.PLAYER_ENTERING_WORLD, Addon)
end)

function Addon:PLAYER_ENTERING_WORLD()
    self.Timer:ForActive('Update')
end

-- utility methods
function Addon:ShowOptionsFrame()
    if C_AddOns.LoadAddOn(CONFIG_ADDON) then
        local dialog = LibStub('AceConfigDialog-3.0')

        dialog:Open(AddonName)
        dialog:SelectGroup(AddonName, "themes", DEFAULT)

        return true
    end

    return false
end

function Addon:CreateHiddenFrame(...)
    local f = CreateFrame(...)

    f:Hide()

    return f
end

function Addon:GetButtonIcon(frame)
    if frame then
        local icon = frame.icon
        if type(icon) == 'table' and icon.GetTexture then
            return icon
        end

        local name = frame:GetName()
        if name then
            icon = _G[name .. 'Icon'] or _G[name .. 'IconTexture']

            if type(icon) == 'table' and icon.GetTexture then
                return icon
            end
        end
    end
end

-- exports
_G[AddonName] = Addon