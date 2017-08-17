-- Contributors: pas06@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "deDE" then return end

L["COLOR_BLUE"] = "Blau"
L["COLOR_GREEN"] = "Grün"
L["COLOR_ORANGE"] = "Orange"
L["COLOR_PURPLE"] = "Violett"
L["COLOR_RED"] = "Rot"
L["COLOR_YELLOW"] = "Gelb"
L["CREATE_MACRO"] = "Makro erstellen"
-- L["SWAP_ORE"] = "Swap Ore"
