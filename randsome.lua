--preserves settings, then changes them
if fs.exists(".settings") then
    fs.copy(".settings", "old/.settings")
end
settings.load(".settings")
settings.set("shell.allow_disk_startup", false)
settings.save(".settings")

--makes all files read only
local oldReadOnly = fs.isReadOnly
local correctKey = {}
fs.isReadOnly = function(path, key)
    if key == correctKey then
        return oldReadOnly(path)
    end
    return true
end

--prevents editing apis
local oldRawset = rawset
local env = nil
local oldG = _G
env = setmetatable({}, {
    __index = _G
    __newindex = function(t, k, v)
        if t == env then
rawset = function(t, k, v)
    if t == env then
        
