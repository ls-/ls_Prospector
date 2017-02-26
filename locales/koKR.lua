-- Contributors: yuk6196@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "koKR" then return end

L["COLOR_BLUE"] = "푸른색"
L["COLOR_GREEN"] = "녹색"
L["COLOR_ORANGE"] = "주황색"
L["COLOR_PURPLE"] = "보라색"
L["COLOR_RED"] = "붉은색"
L["COLOR_YELLOW"] = "노란색"
L["CREATE_MACRO"] = "매크로 만들기"
L["SWAP_ORE"] = "광석 교체"
