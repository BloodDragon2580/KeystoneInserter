local myName, me = ...
local L = me.L
local KeystoneButton, ToggleButton;

local mapIdToActivity = {
    [375] = 703, -- Mists of Tirna Scithe
    [376] = 713, -- The Necrotic Wake
    [377] = 695, -- De Other Side
    [378] = 699, -- Halls of Atonement
    [379] = 691, -- Plaguefall
    [380] = 705, -- Sanguine Depths
    [381] = 709, -- Spires of Ascension
    [382] = 717, -- Theater of Pain
    [391] = 1016, -- Tazavesh: Streets of Wonder
    [392] = 1017, -- Tazavesh: So'leah's Gambit
};

local keystoneLink = '|cffa335ee|Hkeystone:%s:%s:%s:%s:%s:%s:%s|h' .. _G.CHALLENGE_MODE_KEYSTONE_HYPERLINK .. '|h|r';
local GetKeystoneLink = function(mapID, level)
	if not mapID or mapID == 0 or not level or level == 0 then
		return;
	end

	local affixes = C_MythicPlus.GetCurrentAffixes();
	if affixes then
		return string.format(keystoneLink, 180653, mapID, level, affixes[1].id, affixes[2].id, affixes[3].id, affixes[4] and affixes[4].id or 0, C_ChallengeMode.GetMapUIInfo(mapID), level);
	end
end

local function UpdateState(self, filters, categoryID, groupID, activityID, fromUs)
    if fromUs then
        return;
    end

    if LFGListFrame.EntryCreation.selectedCategory == 2 then
        KeystoneButton.mapId   = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
        KeystoneButton.level   = C_MythicPlus.GetOwnedKeystoneLevel();
        KeystoneButton.keylink = GetKeystoneLink(KeystoneButton.mapId, KeystoneButton.level);

        ToggleButton:SetShown(true);
        KeystoneButton:SetShown(true);

        if KeystoneInserterDB.auto then
            ToggleButton:SetText(L["ON"]);

            LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[KeystoneButton.mapId], true);
            LFGListFrame.EntryCreation.Name:SetFocus();
            KeystoneButton.LevelText:SetText(KeystoneButton.level);
        else
            ToggleButton:SetText(L["OFF"]);
        end
    else
        KeystoneButton.LevelText:SetText('');

        ToggleButton:SetShown(false);
        KeystoneButton:SetShown(false);
    end
end

KeystoneButton = CreateFrame('Button', 'KeystoneInserterButton', LFGListFrame.EntryCreation);
KeystoneButton:SetPoint('TOPRIGHT', LFGListFrame.EntryCreation, 'TOPRIGHT', -5, -27);
KeystoneButton:SetSize(32, 32);
KeystoneButton.texture = KeystoneButton:CreateTexture(nil, 'BORDER');
KeystoneButton.texture:SetAllPoints();
KeystoneButton.texture:SetTexture(525134);
KeystoneButton:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');
KeystoneButton:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square');

KeystoneButton.LevelText = KeystoneButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
KeystoneButton.LevelText:SetPoint('RIGHT', LFGListFrame.EntryCreation.Name, 'LEFT', -4, 0);

KeystoneButton:SetShown(false);

KeystoneButton:SetScript('OnClick', function(self)
    if not self.mapId then
        return;
    end

    LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[self.mapId]);
    LFGListFrame.EntryCreation.Name:SetFocus();
    self.LevelText:SetText(KeystoneButton.level);
end);

KeystoneButton:SetScript('OnEnter', function(self)
    if not self.keylink then
        return;
    end

    GameTooltip:SetOwner(self, 'ANCHOR_NONE');
    GameTooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', 1, 0);
    GameTooltip:SetHyperlink(self.keylink);
    GameTooltip:Show();
end);

KeystoneButton:SetScript('OnLeave', GameTooltip_Hide);

ToggleButton = CreateFrame('Button', 'KeystoneInserterToggleButton', LFGListFrame.EntryCreation, 'SharedButtonSmallTemplate');
ToggleButton:SetPoint('RIGHT', PVEFrameCloseButton, 'LEFT', 0, 0);
ToggleButton:SetSize(54, 18);
ToggleButton:SetScript('OnClick', function(self)
    KeystoneInserterDB.auto = not KeystoneInserterDB.auto;

    if KeystoneInserterDB.auto then
        self:SetText(L["ON"]);

        LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, mapIdToActivity[KeystoneButton.mapId]);
        LFGListFrame.EntryCreation.Name:SetFocus();
        KeystoneButton.LevelText:SetText(KeystoneButton.level);
    else
        self:SetText(L["OFF"]);
    end
end);

KeystoneButton:RegisterEvent('ADDON_LOADED');
KeystoneButton:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' and ... == 'KeystoneInserter' then
        KeystoneInserterDB = KeystoneInserterDB or { auto = false };

        hooksecurefunc('LFGListEntryCreation_Select', UpdateState);

        _G['SLASH_KEYSTONEINSERTER1'] = '/keyinsert';
        SlashCmdList['KEYSTONEINSERTER'] = function(input)
            if input and string.find(input, 'auto') then
                local _, mode = strsplit(' ', input);

                KeystoneInserterDB.auto = mode == 'on' and true or false;
            end
        end

        self:UnregisterEvent('ADDON_LOADED');
    end
end);

C_LFGList.GetPlaystyleString = function(playstyle, activityInfo)
    if not ( activityInfo and playstyle and playstyle ~= 0
            and C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown ) then
        return nil
    end
    local globalStringPrefix
    if activityInfo.isMythicPlusActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_PLAYSTYLE"
    elseif activityInfo.isRatedPvpActivity then
        globalStringPrefix = "GROUP_FINDER_PVP_PLAYSTYLE"
    elseif activityInfo.isCurrentRaidActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_RAID_PLAYSTYLE"
    elseif activityInfo.isMythicActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_MYTHICZERO_PLAYSTYLE"
    end
    return globalStringPrefix and _G[globalStringPrefix .. tostring(playstyle)] or nil
end

LFGListEntryCreation_SetTitleFromActivityInfo = function(_) end