local myName, me = ...
local L = me.L
local KeystoneButton, ToggleButton

local mapIdToActivity = {
    -- Cataclysm
    [438] = 1195, [456] = 1274,
    -- Mists of Pandaria
    [2] = 1192,
    -- Warlords of Draenor
    [165] = 1193, [166] = 183, [168] = 184, [169] = 180,
    -- Legion
    [197] = 459, [198] = 460, [199] = 463, [200] = 461,
    [206] = 462, [207] = 464, [210] = 466, [227] = 471, [234] = 473,
    -- Battle for Azeroth
    [244] = 502, [250] = 504, [251] = 507, [247] = 510, [249] = 514,
    [245] = 518, [252] = 522, [246] = 526, [248] = 530, [353] = 534,
    [369] = 679, [370] = 683,
    -- Shadowlands
    [375] = 703, [376] = 713, [377] = 695, [378] = 699, [379] = 691,
    [380] = 705, [381] = 709, [382] = 717, [391] = 1016, [392] = 1017,
    -- Dragonflight
    [399] = 1176, [400] = 1184, [401] = 1180, [402] = 1160, [403] = 1188,
    [404] = 1172, [405] = 1164, [406] = 1168, [463] = 1247, [464] = 1248,
    -- The War Within
    [499] = 2649, [500] = 2648, [501] = 2652, [502] = 2669, [503] = 2660,
    [504] = 2651, [505] = 2662, [506] = 2661, [507] = 670, [525] = 2773,
    [542] = 2830,
}

local keystoneLink = '|cffa335ee|Hkeystone:%s:%s:%s:%s:%s:%s:%s|h' .. _G.CHALLENGE_MODE_KEYSTONE_HYPERLINK .. '|h|r'

local function GetKeystoneLink(mapID, level)
    if not mapID or mapID == 0 or not level or level == 0 then return end
    local affixes = C_MythicPlus.GetCurrentAffixes()
    if affixes then
        return string.format(
            keystoneLink,
            180653, mapID, level,
            affixes[1].id, affixes[2].id, affixes[3].id,
            affixes[4] and affixes[4].id or 0,
            C_ChallengeMode.GetMapUIInfo(mapID),
            level
        )
    end
end

-- Hook für automatisches Ausfüllen beim Öffnen des LFG-Fensters
local function UpdateState(self, filters, categoryID, groupID, activityID, fromUs)
    if fromUs then return end

    if LFGListFrame.EntryCreation.selectedCategory == 2 then
        local mapId = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
        local level = C_MythicPlus.GetOwnedKeystoneLevel()
        KeystoneButton.mapId = mapId
        KeystoneButton.level = level
        KeystoneButton.keylink = GetKeystoneLink(mapId, level)

        ToggleButton:SetShown(true)
        KeystoneButton:SetShown(true)

        if KeystoneInserterDB.auto then
            ToggleButton:SetText(L["ON"])
        else
            ToggleButton:SetText(L["OFF"])
        end
    else
        KeystoneButton.LevelText:SetText('')
        ToggleButton:SetShown(false)
        KeystoneButton:SetShown(false)
    end
end

-- Button erstellen (nur Anzeige)
KeystoneButton = CreateFrame('Button', 'KeystoneInserterButton', LFGListFrame.EntryCreation)
KeystoneButton:SetPoint('TOPRIGHT', LFGListFrame.EntryCreation, 'TOPRIGHT', -5, -27)
KeystoneButton:SetSize(32, 32)
KeystoneButton.texture = KeystoneButton:CreateTexture(nil, 'BORDER')
KeystoneButton.texture:SetAllPoints()
KeystoneButton.texture:SetTexture(525134)
KeystoneButton:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square')

KeystoneButton.LevelText = KeystoneButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
KeystoneButton.LevelText:SetPoint('RIGHT', LFGListFrame.EntryCreation.Name, 'LEFT', -4, 0)
KeystoneButton:SetShown(false)

KeystoneButton:SetScript('OnEnter', function(self)
    if not self.keylink then return end
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetHyperlink(self.keylink)
    GameTooltip:Show()
end)

KeystoneButton:SetScript('OnLeave', GameTooltip_Hide)

-- ToggleButton erstellen (nur Anzeige ON/OFF)
ToggleButton = CreateFrame('Button', 'KeystoneInserterToggleButton', LFGListFrame.EntryCreation, 'SharedButtonSmallTemplate')
ToggleButton:SetPoint('RIGHT', PVEFrameCloseButton, 'LEFT', 0, 0)
ToggleButton:SetSize(54, 18)
ToggleButton:SetScript('OnClick', function(self)
    KeystoneInserterDB.auto = not KeystoneInserterDB.auto
    self:SetText(KeystoneInserterDB.auto and L["ON"] or L["OFF"])
end)

-- Event und Hook registrieren
KeystoneButton:RegisterEvent('ADDON_LOADED')
KeystoneButton:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' and ... == 'KeystoneInserter' then
        KeystoneInserterDB = KeystoneInserterDB or { auto = false }
        hooksecurefunc('LFGListEntryCreation_Select', UpdateState)

        _G['SLASH_KEYSTONEINSERTER1'] = '/keyinsert'
        SlashCmdList['KEYSTONEINSERTER'] = function(input)
            if input and string.find(input, 'auto') then
                local _, mode = strsplit(' ', input)
                KeystoneInserterDB.auto = mode == 'on'
                ToggleButton:SetText(KeystoneInserterDB.auto and L["ON"] or L["OFF"])
            end
        end

        self:UnregisterEvent('ADDON_LOADED')
    end
end)
