local f = CreateFrame("Frame")
local addonPrefix = '|cffd6266cKeystoneInserter|r'
KEYSTONEINSERTER = {}

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

function f:ADDON_LOADED(event, addOnName)
    if addOnName == 'KeystoneInserter' then
        KEYSTONEINSERTER = KEYSTONEINSERTER or {}
    end
end

function f:LFG_LIST_APPLICATION_STATUS_UPDATED(event, searchResultID, newStatus, oldStatus, groupName)
    if newStatus ~= "inviteaccepted" then
        return
    end

    KEYSTONEINSERTER.lastdg = C_LFGList.GetActivityInfoTable(C_LFGList.GetSearchResultInfo(searchResultID).activityID).fullName .. ' ' .. groupName
    print(addonPrefix .. ' ' .. (KEYSTONEINSERTER.lastdg or 'Yet to accept invites'))
end

f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)
