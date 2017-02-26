local addonName = ...

-- Lua
local _G = getfenv(0)
local math = _G.math
local table = _G.table
local next = _G.next
local pairs =_G.pairs
local type = _G.type
local unpack = _G.unpack

-- Mine
local PROSPECTING_ID = 31252
local PROSPECTING_NAME, _, PROSPECTING_ICON = _G.GetSpellInfo(PROSPECTING_ID)
local ORE_COUNT_TEMLATE = "%s|T%s:0|t"
local MACRO_TEMPLATE = "/cast %s\n/use item:%s"

local CHIPS = {
	[1379182] = "blue",
	[1379183] = "green",
	[1379184] = "orange",
	[1379185] = "purple",
	[1379186] = "red",
	[1379188] = "yellow",
	blue = 1379182,
	green = 1379183,
	orange = 1379184,
	purple = 1379185,
	red = 1379186,
	yellow = 1379188,
}

local ORES = {
	leystone = {
		id = 123918,
		texture = 1394960
	},
	felslate = {
		id = 123919,
		texture = 1394961
	},
}

------------
-- CONFIG --
------------

local CFG = {}
local DEFAULTS = {
	point = {"TOPLEFT", "UIParent", "TOPLEFT", 256, -256},
	legion = {
		use_felslate = {
			blue = false,
			green = false,
			orange = false,
			purple = false,
			red = false,
			yellow = false
		}
	}
}

----------------
-- MAIN FRAME --
----------------

local function CalculatePosition(self)
	local selfCenterX, selfCenterY = self:GetCenter()
	local screenWidth = _G.UIParent:GetRight()
	local screenHeight = _G.UIParent:GetTop()
	local screenCenterX, screenCenterY = _G.UIParent:GetCenter()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3
	local p, x, y

	if selfCenterY >= screenCenterY then
		p = "TOP"
		y = self:GetTop() - screenHeight
	else
		p = "BOTTOM"
		y = self:GetBottom()
	end

	if selfCenterX >= screenRight then
		p = p.."RIGHT"
		x = self:GetRight() - screenWidth
	elseif selfCenterX <= screenLeft then
		p = p.."LEFT"
		x = self:GetLeft()
	else
		x = selfCenterX - screenCenterX
	end

	return p, p, math.floor(x + 0.5), math.floor(y + 0.5)
end

local frame = _G.CreateFrame("Frame", "LSProspectorFrame", _G.UIParent, "PortraitFrameTemplate")
frame:SetSize(192, 313)
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()
frame.Refresh = function()
	frame:SetMovable(true)
	frame:ClearAllPoints()
	frame:SetPoint(unpack(CFG.point))
end
frame.StartDrag = function()
	if not _G.InCombatLockdown() then
		frame:StartMoving()
	end
end
frame.StopDrag = function()
	if not _G.InCombatLockdown() then
		frame:StopMovingOrSizing()

		local anchor = "UIParent"
		local p, rP, x, y = CalculatePosition(frame)

		frame:ClearAllPoints()
		frame:SetPoint(p, anchor, rP, x, y)

		CFG.point = {p, anchor, rP, x, y}
	end
end
frame:SetScript("OnShow", function(self)
	self:RefreshOreCounters()
	self:RefreshGemFilters()

	if not _G.InCombatLockdown() then
		self:SetOre(self:GetPrevOre())
		self.ProspectButton:Enable()
		self.SwapButton:Enable()
	end
end)
frame:SetScript("OnDragStart", frame.StartDrag)
frame:SetScript("OnDragStop", frame.StopDrag)

do
	frame.portrait:SetMask("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
	frame.portrait:SetTexture(PROSPECTING_ICON)

	frame.TitleText:SetPoint("RIGHT", -30, 0)
	frame.TitleText:SetText("ls: |cff1a9fc0Prospector|r")

	frame.CloseButton:SetScript("OnClick", function()
		if not _G.InCombatLockdown() then
			frame:Hide()
			frame:SetOre("")
			frame.ProspectButton:Disable()
			frame.SwapButton:Disable()
		end
	end)

	local inset = _G.CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	inset:SetPoint("TOPLEFT", 3, -60)
	inset:SetPoint("BOTTOMRIGHT", -5, 5)

	-- Ore Counters
	local fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fs:SetFormattedText(ORE_COUNT_TEMLATE, 0, ORES.felslate.texture)
	fs:SetJustifyH("RIGHT")
	fs:SetPoint("BOTTOMRIGHT", inset, "TOPRIGHT", -4, 4)
	frame.FelslateCounter = fs

	fs = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fs:SetFormattedText(ORE_COUNT_TEMLATE, 0, ORES.leystone.texture)
	fs:SetJustifyH("RIGHT")
	fs:SetPoint("BOTTOMRIGHT", frame.FelslateCounter, "TOPRIGHT", 0, 4)
	frame.LeystoneCounter = fs

	function frame:RefreshOreCounters()
		self.LeystoneCounter:SetFormattedText(ORE_COUNT_TEMLATE, _G.GetItemCount(ORES.leystone.id) or 0, ORES.leystone.texture)
		self.FelslateCounter:SetFormattedText(ORE_COUNT_TEMLATE, _G.GetItemCount(ORES.felslate.id) or 0, ORES.felslate.texture)
	end

	-- Ore, Chip icons
	local icon = inset:CreateTexture(nil, "ARTWORK", nil, 1)
	icon:SetSize(36, 36)
	icon:SetPoint("TOPRIGHT", inset, "TOPRIGHT", -6, -6)
	icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	frame.OreIcon = icon

	local border = inset:CreateTexture(nil, "ARTWORK", nil, 2)
	border:SetTexture("Interface\\Common\\WhiteIconFrame")
	border:SetAllPoints(icon)

	icon = inset:CreateTexture(nil, "ARTWORK", nil, 1)
	icon:SetSize(36, 36)
	icon:SetPoint("TOP", frame.OreIcon, "BOTTOM", 0, -4)
	icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	frame.ChipIcon = icon

	border = inset:CreateTexture(nil, "ARTWORK", nil, 2)
	border:SetTexture("Interface\\Common\\WhiteIconFrame")
	border:SetAllPoints(icon)

	-- Gem Filter
	local buttons = {
		[1] = {
			text = "Blue",
			gem = "blue"
		},
		[2] = {
			text = "Green",
			gem = "green"
		},
		[3] = {
			text = "Orange",
			gem = "orange"
		},
		[4] = {
			text = "Purple",
			gem = "purple"
		},
		[5] = {
			text = "Red",
			gem = "red"
		},
		[6] = {
			text = "Yellow",
			gem = "yellow"
		},
	}

	local function Button_OnClick(self)
		CFG.legion.use_felslate[self.gem] = not CFG.legion.use_felslate[self.gem]
	end

	for i = 1, 6 do
		local button = _G.CreateFrame("CheckButton", nil, inset, "UICheckButtonTemplate")
		button:SetScript("OnClick", Button_OnClick)
		button.gem = buttons[i].gem
		button.text:SetText(buttons[i].text)
		buttons[i].button = button

		if i == 1 then
			buttons[i].button:SetPoint("TOPLEFT", 2, -1)
		else
			buttons[i].button:SetPoint("TOP", buttons[i - 1].button, "BOTTOM", 0, 0)
		end
	end

	function frame:RefreshGemFilters()
		for i = 1, 6 do
			buttons[i].button:SetChecked(CFG.legion.use_felslate[buttons[i].button.gem])
		end
	end

	local button = _G.CreateFrame("Button", "$parentSwapOreButton", inset, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOM", 0, 5)
	button:SetWidth(174)
	button:SetText("Swap Ore")
	button:SetScript("OnClick", function()
		if frame:GetOre() == "leystone" then
			frame:SetOre("felslate")
		else
			frame:SetOre("leystone")
		end
	end)
	frame.SwapButton = button

	button = _G.CreateFrame("Button", "$parentProspectButton", inset, "UIPanelButtonTemplate SecureActionButtonTemplate")
	button:SetPoint("BOTTOM", frame.SwapButton, "TOP", 0, 2)
	button:SetWidth(174)
	button:SetText(PROSPECTING_NAME)
	button:SetAttribute("type*", "macro")
	frame.ProspectButton = button

	function frame:SetOre(ore)
		if not _G.InCombatLockdown() then
			if ore == "leystone" or ore == "felslate" then
				self.prevOre = (self.curOre and self.curOre ~= "") and self.curOre or nil
				self.curOre = ore

				self.OreIcon:SetTexture(ORES[ore].texture)
				self.ProspectButton:SetAttribute("macrotext", MACRO_TEMPLATE:format(PROSPECTING_NAME, ORES[ore].id))
			else
				self.prevOre = (self.curOre and (self.curOre == "leystone" or self.curOre == "felslate")) and self.curOre or nil
				self.curOre = ""

				self.OreIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
				self.ProspectButton:SetAttribute("macrotext", "")
			end
		end
	end

	function frame:GetOre()
		return self.curOre or ""
	end

	function frame:GetPrevOre()
		return self.prevOre or "leystone"
	end

	button = _G.CreateFrame("Button", "$parentMacroButton", inset)
	button:SetPoint("BOTTOMRIGHT", frame.ProspectButton, "TOPRIGHT", -1, 2)
	button:SetSize(36, 36)
	button:SetScript("OnClick", function()
		if not _G.InCombatLockdown() then
			_G.DeleteMacro("LSPMacro")

			local id = _G.CreateMacro("LSPMacro", PROSPECTING_ICON, "/click LSProspectorFrameProspectButton")

			if id then
				_G.PickupMacro(id)
			end
		end
	end)
	button:SetScript("OnEnter", function(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:AddLine(_G.CREATE_MACROS)
		_G.GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		_G.GameTooltip:Hide()
	end)
	frame.MacroButton = button

	icon = button:CreateTexture(nil, "ARTWORK", nil, 1)
	icon:SetSize(36, 36)
	icon:SetAllPoints()
	icon:SetAtlas("NPE_Icon")

	border = button:CreateTexture(nil, "ARTWORK", nil, 2)
	border:SetTexture("Interface\\Common\\WhiteIconFrame")
	border:SetAllPoints(icon)
end

----------------
-- DISPATCHER --
----------------

local dispatcher = _G.CreateFrame("Frame", nil, _G.UIParent)
dispatcher:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

local allowLootCheck

function dispatcher:LOOT_READY()
	if allowLootCheck then
		local lootInfo = _G.GetLootInfo()
		local chip

		for _, item in pairs(lootInfo) do
			if CHIPS[item.texture] then
				chip = CHIPS[item.texture]
			else
				chip = nil

				break
			end
		end

		frame.ChipIcon:SetTexture(chip and CHIPS[chip] or "Interface\\ICONS\\INV_Misc_QuestionMark")

		if not _G.InCombatLockdown() and frame:IsShown() then
			if chip then
				frame:SetOre(CFG.legion.use_felslate[chip] and "felslate" or "leystone")
			else
				frame:SetOre("leystone")
			end
		end

		allowLootCheck = nil
	end
end

function dispatcher:LOOT_CLOSED()
	if not _G.InCombatLockdown() and frame:IsShown() then
		frame.ProspectButton:Enable()
		frame.SwapButton:Enable()
	end
end

function dispatcher:BAG_UPDATE_DELAYED()
	if frame:IsShown() then
		frame:RefreshOreCounters()
	end
end

function dispatcher:PLAYER_REGEN_ENABLED()
	if frame:IsShown() then
		frame:SetOre(frame:GetPrevOre())
		frame.ProspectButton:Enable()
		frame.SwapButton:Enable()
	end
end

function dispatcher:PLAYER_REGEN_DISABLED()
	if frame:IsShown() then
		frame:StopDrag()
		frame:Hide()

		frame:SetOre("")
		frame.ProspectButton:Disable()
		frame.SwapButton:Disable()
	end
end

local curLineID

function dispatcher:UNIT_SPELLCAST_START(_, _, _, lineID, id)
	if id == PROSPECTING_ID then
		if not _G.InCombatLockdown() and frame:IsShown() then
			frame.ProspectButton:Disable()
			frame.SwapButton:Disable()
		end

		curLineID = lineID
	end
end

function dispatcher:UNIT_SPELLCAST_SUCCEEDED(_, _, _, lineID)
	if lineID == curLineID then
		allowLootCheck = true
		curLineID = nil
	end
end

function dispatcher:UNIT_SPELLCAST_INTERRUPTED(_, _, _, lineID)
	if lineID == curLineID then
		if not _G.InCombatLockdown() and frame:IsShown() then
			frame.ProspectButton:Enable()
			frame.SwapButton:Enable()
		end

		curLineID = nil
	end
end

function dispatcher:UNIT_SPELLCAST_STOP(_, _, _, lineID)
	if lineID == curLineID then
		if not _G.InCombatLockdown() and frame:IsShown() then
			frame.ProspectButton:Enable()
			frame.SwapButton:Enable()
		end

		curLineID = nil
	end
end

------------
-- CONFIG --
------------

local function CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = CopyTable(v, dest[k])
		elseif type(v) ~= type(dest[k]) then
			dest[k] = v
		end
	end

	return dest
end

local function ReplaceTable(src, dest)
	return CopyTable(src, table.wipe(dest))
end

local function DiffTable(src, dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return CopyTable(dest)
	end

	for k, v in pairs(dest) do
		if type(v) == "table" then
			if not next(DiffTable(src[k], v)) then
				dest[k] = nil
			end
		elseif v == src[k] then
			dest[k] = nil
		end
	end

	return CopyTable(dest)
end

function dispatcher:ADDON_LOADED(arg)
	if arg ~= addonName then return end

	if not _G.LS_PROSPECTOR_CFG then
		_G.LS_PROSPECTOR_CFG = {}
	end

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_PROSPECTOR_CFG), CFG)

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("ADDON_LOADED")
end

function dispatcher:PLAYER_LOGIN()
	frame:Refresh()

	_G.SLASH_LSPROSPECT1 = "/lsprospect"
	_G.SlashCmdList["LSPROSPECT"] = function()
		if not _G.InCombatLockdown() then
			if frame:IsShown() then
				frame:Hide()
			else
				frame:Show()
			end
		end
	end

	self:RegisterEvent("LOOT_READY")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end

function dispatcher:PLAYER_LOGOUT()
	_G.LS_PROSPECTOR_CFG = DiffTable(DEFAULTS, CFG)
end

dispatcher:RegisterEvent("ADDON_LOADED")
