local hiddenFiles = {"/hijack", "/hijack", "/hijack"}

math.randomseed(os.time()); math.random(); math.random()

local function hideFile(file)
    local pass = {}
    --local id = #hiddenFiles + 1 --We can use sequential ids, because code using this is trusted
    local id = false --Fine...
    while true do
        id = math.random(1, 65536)
        if not hiddenFiles[id] then break end
    end
    hiddenFiles[id] = {pass = pass, file = file} --Program needs pass, which can only be given 'cause pointers
    return id, pass
end

local function showFile(id, pass)
    if hiddenFiles[id] and (hiddenFiles[id].pass == pass) then
        table.remove(hiddenFiles, id)
        return true
    end
    return false
end

local env = {}
do
    local mvValues = {}


local function fileUnderstander(file)
    local newPath = {}
    for p in file:gfind("[^/\\]*") do
        if p == ".." then
            newPath[#newPath] = nil
        elseif p ~= "." then
            newPath[#newPath] = p
        end
    end
    
end

local function createFilter(funct, fileNameArgImdex)
    return function(...)
        local file = args[fileNameArgIndex]
        if file:sub(1, 1) ~= "/" then file = "/" .. file end
        file = "/sand" .. file
        args[fileNameArgIndex] = file
        local data = {pcall(function() return funct(args) end)}
        local ok = data[1]
        local err = data[2]
        table.remove(data, 1)
        if not ok then error(err, 0) end
        return data
    end
end

function createFilters(argIndex, ...)
    local filters = {}
    for k, v in ipairs(args) do
        filters[k] = createFilter(v, argIndex)
    end
    return table.unpack(filters)
end

