-- Contributors: BLizzatron@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "ruRU" then return end

L["COLOR_BLUE"] = "Синий"
L["COLOR_GREEN"] = "Зелёный"
L["COLOR_ORANGE"] = "Оранжевый"
L["COLOR_PURPLE"] = "Фиолетовый"
L["COLOR_RED"] = "Красный"
L["COLOR_YELLOW"] = "Желтый"
L["CREATE_MACRO"] = "Создать макрос"
L["SWAP_ORE"] = "Поменять руду"
