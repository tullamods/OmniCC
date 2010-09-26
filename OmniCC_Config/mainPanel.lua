--[[
	optionsPanel.lua
		A bagnon options panel
--]]


local function addGroupSelector(self)
	local parent = self
	local dd = OmniCCOptions.Dropdown:New('Group', self, 120)
	dd.titleText:Hide()

	dd.Initialize = function(self)
		self:AddItem('Base', 'base')

		--add sorted groups
		local sortedGroups = {}
		for i, group in pairs(OmniCC.db.groups) do
			table.insert(
				sortedGroups,
				{
					id = group.id,
					name = group.name
				}
			)
		end

		table.sort(sortedGroups, function(a, b) return a.name < b.name end)

		for i, group in ipairs(sortedGroups) do
			self:AddItem(group.name, group.id)
		end
	end

	dd.SetSavedValue = function(self, value)
		parent.selectedGroup = value or 'base'
	end

	dd.GetSavedValue = function(self)
		return parent.selectedGroup or 'base'
	end

	dd:SetPoint('TOPRIGHT', 4, -8)
	dd:OnShow()
end

local function addTitle(self)
	local text = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	text:SetPoint('TOPLEFT', 16, -16)
	if self.icon then
		text:SetFormattedText('|T%s:%d|t %s', self.icon, 32, (self.name .. ': '))
	else
		text:SetText(self.name)
	end

	local subText = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	subText:SetPoint('LEFT', text, 'RIGHT', 2, 0)
	subText:SetTextColor(0.7, 0.7, 0.7)
	subText:SetText('Cooldown count for everything')
end

local function createTab(self, name, panel)
	local parent = self
	if not parent.tabs then
		parent.tabs = {}
	end

	local t = CreateFrame('Button', parent:GetName() .. 'Tab' .. (#parent.tabs + 1), parent, 'OptionsFrameTabButtonTemplate')
	t.panel = panel
	t:SetText(name)
	t:SetScript('OnClick', function(self)
		--update tab selection
		PanelTemplates_Tab_OnClick(self, parent)
		PanelTemplates_UpdateTabs(parent)

		--hide any visible panels
		for i, tab in pairs(parent.tabs) do
			if tab ~= self then
				tab.panel:Hide()
				tab.sl:Hide()
				tab.sr:Hide()
			end
		end

		--show selected tab's panel
		self.panel:Show()
		self.sl:Show()
		self.sr:Show()
	end)

	t.sl = t:CreateTexture(nil, 'BACKGROUND')
	t.sl:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sl:SetPoint('BOTTOMRIGHT', t, 'BOTTOMLEFT', 11, -6)
	t.sl:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 16, -(34 + t:GetHeight() + 7))

	t.sr = t:CreateTexture(nil, 'BACKGROUND')
	t.sr:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-Spacer]])
	t.sr:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', -11, -6)
	t.sr:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', -16, -(34 + t:GetHeight() + 10))

	table.insert(self.tabs, t)

	local numTabs = #parent.tabs

	t:SetID(numTabs)
	if numTabs > 1 then
		t:SetPoint('TOPLEFT', self.tabs[numTabs - 1], 'TOPRIGHT', -8, 0)
		t.sl:Hide()
		t.sr:Hide()
	else
		t:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -34)
		t.sl:Show()
		t.sr:Show()
	end

	PanelTemplates_TabResize(t, 0)
	PanelTemplates_SetNumTabs(parent, numTabs)
	PanelTemplates_SetTab(self, 1)

	panel:SetParent(_G[parent:GetName() .. '_TabPanelArea'])
	panel:SetAllPoints(panel:GetParent())
	panel:Hide()
	if numTabs == 1 then 
		panel:Show() 
	end
end

local function createTabBorderArea(self)
	local f = CreateFrame('Frame', self:GetName() .. '_TabPanelArea', self, 'OmniCC_TabPanelTemplate')
	f:SetPoint('TOPLEFT', 6, -56)
	f:SetPoint('BOTTOMRIGHT', -6, 6)
	self.panelArea = f
end

local function buildFrame()
	local f = CreateFrame('Frame', 'OmniCCOptionsPanel')
	f.name = 'OmniCC'

	addTitle(f)
	addGroupSelector(f)
	createTabBorderArea(f)

	InterfaceOptions_AddCategory(f, 'OmniCC')

	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)

		for i, k in ipairs{'Style', 'Rules', 'Groups'} do
			local f = CreateFrame('Frame')
			local t = f:CreateFontString()
			t:SetFontObject('GameFontNormal')
			t:SetText(k .. ' TEST PANEL')
			t:SetPoint('CENTER')

			OmniCCOptions:AddTab(k, f)
		end
	end)
	
	return f
end


do
	local f = buildFrame()

	OmniCCOptions.AddTab = function(self, name, panel)
		createTab(f, name, panel)
	end

	OmniCCOptions.GetGroupSets = function(self)
		return OmniCC.db.groupSettings[f.selectedGroup or 'base']
	end
end