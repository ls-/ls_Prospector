﻿-- Contributors: Gotxiko@GitHub

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "esES" then return end

L["CREATE_MACRO"] = "Crear macro"
L["COLOR_BLUE"] = "Azul"
L["COLOR_GREEN"] = "Verde"
L["COLOR_ORANGE"] = "Naranja"
L["COLOR_PURPLE"] = "Morada"
L["COLOR_RED"] = "Roja"
L["COLOR_YELLOW"] = "Amarilla"
L["SWAP_ORE"] = "Cambiar mena"
