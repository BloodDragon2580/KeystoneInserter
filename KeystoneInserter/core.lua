local InsertKeystone = function(self)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, _, _, _, _, _, itemName = GetContainerItemInfo(bag, slot)
            
            if itemName and itemName:match("keystone:") then
                PickupContainerItem(bag, slot)
                
                if (CursorHasItem()) then
                    C_ChallengeMode.SlotKeystone()
                end
            end
        end
    end
end

local frame = CreateFrame("Frame", "InsertKeystone", UIParent);
frame:RegisterEvent("ADDON_LOADED");

frame:SetScript("OnEvent", function(self, event, addonName, ...)
    if event == "ADDON_LOADED" and addonName == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", InsertKeystone);
        frame:UnregisterEvent("ADDON_LOADED");
        return;
	end
end);