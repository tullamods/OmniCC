--[[
	mainPanel.lua
		the main container panel for omnicc
		provides ways of switching between tabs & groups
--]]

--[[ utility functions of champions ]]--

local function map(t, f)
	local newtbl = {}
	for i, v in pairs(t) do
		newtbl[i] = f(v)
	end
	return newtbl
end

local function copyDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			tbl[k] = copyDefaults(tbl[k] or {}, v)
		elseif tbl[k] == nil then
			tbl[k] = v
		end
	end
	return tbl
end


--[[
	OmniCC settings retrieval
--]]

local groupSets_Get, groupSets_ClearCache, groupSets_Cleanup
do
	local groupSets = {}

	--this code is a bit wacky, because I want to retrieve settings + defaults
	--so that its easier to work with
	groupSets_Get = function(groupId)
		local sets = groupSets[groupId]
		if not sets then
			if groupId == 'base' then
				sets = OmniCC.db.groupSettings[groupId]
			else
				sets = copyDefaults(OmniCC.db.groupSettings[groupId], OmniCC.db.groupSettings['base'])
			end
			groupSets[groupId] = sets
		end
		return sets
	end

	--reset our settings cache
	--cleared when we switch panels
	--so that we can account for things like adjustments to base settings
	groupSets_ClearCache = function()
		groupSets = {}
	end

	--reset the cache, and cleanup omnicc's defaults
	--a step to remove any defaults we injected into the saved settings to preserve memory a bit
	groupSets_Cleanup = function()
		groupSets_ClearCache()
		OmniCC:RemoveDefaults()
	end
end


--[[
	group settings selector
--]]

local function groupSelector_Create(parent, size)
	local dd = OmniCCOptions.Dropdown:New('Group', parent, size)
	dd.titleText:Hide()

	dd.Initialize = function(self)
		self:AddItem('Base', 'base')

		local groups = map(OmniCC.db.groups, function(g) return {g.name, g.id} end)
		print(table.sort(groups, function(a, b) return a[1] < b[1] end))

		for i, g in ipairs(groups) do
			self:AddItem(unpack(g))
		end
	end

	dd.SetSavedValue = function(self, value)
		parent.selectedGroup = value or 'base'

		groupSets_ClearCache()

		--force the current panel to refresh
		local panel = parent:GetCurrentPanel()
		panel:Hide()
		panel:Show()
	end

	dd.GetSavedValue = function(self)
		return parent.selectedGroup or 'base'
	end

	dd:SetPoint('TOPRIGHT', 4, -8)
	dd:OnShow()

	return dd
end

--[[
	title portion of the main frame
--]]

local function title_Create(parent, text, subtext, icon)
	local title = parent:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	title:SetPoint('TOPLEFT', 16, -16)

	if icon then
		title:SetFormattedText('|T%s:%d|t %s', icon, 32, name)
	else
		title:SetText(text)
	end

	if subtext then
		local subTitle = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		subTitle:SetPoint('LEFT', title, 'RIGHT', 2, 0)
		subTitle:SetTextColor(0.8, 0.8, 0.8)
		subTitle:SetText(subtext)
	end
end

--[[
	main frame tabs
--]]

local tab_Create, tab_OnClick
do
	tab_Create = function(parent, name, panel)
		parent.tabs = parent.tabs or {}

		local t = CreateFrame('Button', parent:GetName() .. 'Tab' .. (#parent.tabs + 1), parent, 'OptionsFrameTabButtonTemplate')
		table.insert(parent.tabs, t)

		t.panel = panel
		t:SetText(name)
		t:SetScript('OnClick', tab_OnClick)

		--this is the texture that makes up the top border around the main panel area
		--its here because each tab needs one to create the illusion of the tab popping out in front of the player
		t.sl = t:CreateTexture(nil, 'BACKGROUND')
		t.sl:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
		t.sl:SetPoint('BOTTOMRIGHT', t, 'BOTTOMLEFT', 11, -6)
		t.sl:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 16, -(34 + t:GetHeight() + 7))

		t.sr = t:CreateTexture(nil, 'BACKGROUND')
		t.sr:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
		t.sr:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', -11, -6)
		t.sr:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', -16, -(34 + t:GetHeight() + 10))

		--place the new tab
		--if its the first tab, anchor to the main frame
		--if not, anchor to the right of the last tab
		local numTabs = #parent.tabs
		if numTabs > 1 then
			t:SetPoint('TOPLEFT', parent.tabs[numTabs - 1], 'TOPRIGHT', -8, 0)
			t.sl:Hide()
			t.sr:Hide()
		else
			t:SetPoint('TOPLEFT', parent, 'TOPLEFT', 12, -34)
			t.sl:Show()
			t.sr:Show()
		end
		t:SetID(numTabs)

		--adjust tab sizes and other blizzy required things
		PanelTemplates_TabResize(t, 0)
		PanelTemplates_SetNumTabs(parent, numTabs)

		--display the first tab, if its not already displayed
		if numTabs == 1 then
			PanelTemplates_SetTab(parent, 1)
		end

		--place the panel associated with the tab
		parent.panelArea:Add(panel)

		return t
	end

	tab_OnClick = function(self)
		local parent = self:GetParent()

		--update tab selection
		PanelTemplates_Tab_OnClick(self, parent)
		PanelTemplates_UpdateTabs(parent)

		--hide any visible panels/tabs
		for i, tab in pairs(parent.tabs) do
			if tab ~= self then
				tab.panel:Hide()
				tab.sl:Hide()
				tab.sr:Hide()
			end
		end

		--show the top of the panel texture from our tab
		self.sl:Show()
		self.sr:Show()

		--show selected tab's panel
		self.panel:Show()
	end
end

--[[
	main frame content area
--]]

local panelArea_Create, panelArea_Add
do
	panelArea_Create = function(parent)
		local f = CreateFrame('Frame', parent:GetName() .. '_PanelArea', parent, 'OmniCC_TabPanelTemplate')
		f:SetPoint('TOPLEFT', 4, -56)
		f:SetPoint('BOTTOMRIGHT', -4, 4)
		f.Add = panelArea_Add

		parent.panelArea = f
		return f
	end

	panelArea_Add = function(self, panel)
		panel:SetParent(self)
		panel:SetAllPoints(self)

		if self:GetParent():GetCurrentPanel() == panel then
			panel:Show()
		else
			panel:Hide()
		end
	end
end

--[[
	the main frame
--]]

local optionsPanel_Create, optionsPanel_OnShow, optionsPanel_OnHide, optionsPanel_GetCurrentPanel
do
	optionsPanel_Create = function(title, subtitle)
		local f = CreateFrame('Frame', 'OmniCCOptionsPanel')
		f.name = title
		f:SetScript('OnShow', optionsPanel_OnShow)
		f:SetScript('OnHide', optionsPanel_OnHide)
		f.GetCurrentPanel = optionsPanel_GetCurrentPanel

		title_Create(f, title, subtitle)
		groupSelector_Create(f, 130)
		panelArea_Create(f)

		InterfaceOptions_AddCategory(f, title)
		return f
	end

	optionsPanel_OnShow = function(self)
		self:SetScript('OnShow', nil)

		for i, k in ipairs{'Style', 'Rules', 'Groups', 'About'} do
			local f = CreateFrame('Frame')
			local t = f:CreateFontString()
			t:SetFontObject('GameFontNormalLarge')
			t:SetText(k:upper() .. ' TEST PANEL')
			t:SetPoint('CENTER')

			OmniCCOptions:AddTab(k, f)
		end
	end

	optionsPanel_OnHide = function(self)
		groupSets_Cleanup()
	end

	optionsPanel_GetCurrentPanel = function(self)
		return self.tabs[PanelTemplates_GetSelectedTab(self)].panel
	end
end


--[[ build the main options panel ]]--
do
	local f = optionsPanel_Create(select(2, GetAddOnInfo('OmniCC')))

	OmniCCOptions.AddTab = function(self, name, panel)
		tab_Create(f, name, panel)
	end

	OmniCCOptions.GetGroupSets = function(self)
		return groupSets_Get(f.selectedGroup or 'base')
	end
end