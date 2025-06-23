local f = CreateFrame("Frame")
local addonPrefix = '|cffd6266cKeystoneInserter|r'
KEYSTONEINSERTER = {}

-- Dispatcher für Events
function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- ADDON_LOADED: Initialisiere SavedVars
function f:ADDON_LOADED(event, addOnName)
    if addOnName == 'KeystoneInserter' then
        KEYSTONEINSERTER = KEYSTONEINSERTER or {}
    end
end

-- LFG_LIST_APPLICATION_STATUS_UPDATED: Wenn Einladung akzeptiert wird
function f:LFG_LIST_APPLICATION_STATUS_UPDATED(event, searchResultID, newStatus, oldStatus, groupName)
    if newStatus ~= "inviteaccepted" then
        return
    end

    -- 1) Hole die Suchergebnis-Daten
    local searchInfo = C_LFGList.GetSearchResultInfo(searchResultID)
    if not searchInfo then
        print(addonPrefix .. " Fehler: Kein Suchergebnis gefunden.")
        return
    end

    -- 2) Extrahiere activityID mit Fallback auf activityIDs[1]
    local activityID = searchInfo.activityID or (searchInfo.activityIDs and searchInfo.activityIDs[1])
    if not activityID then
        print(addonPrefix .. " Fehler: Keine gültige activityID gefunden.")
        return
    end

    -- 3) questID extrahieren (kann nil sein)
    local questID = searchInfo.questID

    -- 4) Hole die vollständigen Activity‑Infos (ohne Warmode)
    local activityInfo = C_LFGList.GetActivityInfoTable(activityID, questID, false)
    if not activityInfo then
        print(addonPrefix .. " Fehler: activityInfo konnte nicht geladen werden.")
        return
    end

    -- 5) Setze den letzten Dungeon-Namen plus Gruppennamen
    KEYSTONEINSERTER.lastdg = activityInfo.fullName .. ' ' .. groupName
    print(addonPrefix .. ' ' .. (KEYSTONEINSERTER.lastdg or 'Yet to accept invites'))
end

-- Events registrieren
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
f:SetScript("OnEvent", f.OnEvent)
