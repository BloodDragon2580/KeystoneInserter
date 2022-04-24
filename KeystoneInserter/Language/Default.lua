local _, me = ...

me.L = {}
local L = me.L
local function defaultFunc(L, key) return key end
setmetatable(L, {__index=defaultFunc})





