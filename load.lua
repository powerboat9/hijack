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

local function copy(cpTable)
    local function set(t, index, value)
        local tPath = {""}
        local backslashed = false
        for v in index:gfind(".") do
            if (not backslashed) and (v == "\\") then
                backslashed = true
            elseif (not backslashed) and (v == ".") then
                tPath[#tPath + 1] = ""
            else
                tPath[#tPath] = tPath[#tPath] .. v
                if backslashed then backslashed = false end
            end
        end
        for k, v in ipairs(tPath) do
            if k < #tPath then
                if type(t[k]) ==  "nil" then
                    t[k] = {}
                end
                if type(t[k]) == "table" then
                    t = t[k]
                else
                    return false
                end
            else
                t[k] = value
                return true
            end
        end
    end
    
    local cpData, threds = {}, {}
    local function newThred(t, index)
        threds[#threds + 1] = function()
            sleep(0) --Yes, it slows other computers down, but what else to do?
            if index ~= "" then index = index .. "." end
            for k, v in ipairs(t) do
                if type(v) == "table" then
                    newThred(v, index .. k)
                else
                    set(cpData, index .. k, v)
                end
            end
            for k, v in pairs(t) do
                if type(v) == "table" then
                    newThred(v, index .. k)
                else
                    set(cpData, index .. k, v)
                end
            end
        end
    end
    
    newThred(cpTable, "")
    while threds[1] do threds[1]() end
    return cpData
end

local env = copy(_G)

local function fileUnderstander(file)
    local newPath = {}
    for p in file:gfind("[^/\\]*") do
        if (p == "..") then
            if #newPath > 0 then newPath[#newPath] = nil end
        elseif p ~= "." then
            newPath[#newPath] = p
        end
    end
    local returnPath = ""
    for _, v in returnPath do returnPath = returnPath .. "/" .. v end
    return returnPath
end

local function createFilter(funct, fileNameArgIndices)
    return function(...)
        for _, fileNameArgIndex in ipairs(fileNameArgIndices) do
            if type(args[fileNameArgIndex]) == "string" then
                args[fileNameArgIndex] = "/sand" .. fileUnderstander(args[fileNameArgIndex])
            end
        end
        local data = {pcall(function() return funct(args) end)}
        local ok, err = data[1], data[2]
        if not ok then error(err, 0) end
        table.remove(data, 1)
        return table.unpack(data)
    end
end

function createFilters(argIndex, ...)
    local filters = {}
    for k, v in ipairs(args) do
        filters[k] = createFilter(v, argIndex)
    end
    return table.unpack(filters)
end

function createHideFilter(funct, argIndices)
    return function(...)
        local data = {pcall(function() return funct(args) end)}
        local ok, err = data[1], data[2]
        if not ok then error(err, 0) end
        table.remove(data, 1)
        for _, argIndex in ipairs(argIndices) do
            if type(data[argIndex]) == "string" then
                data[argIndex] = fileUnderstander(data[argIndex]):sub(7, -1) --TODO: Keep a slash at front?
            end
        end
        return table.unpack(data)
    end
end

function createHideFilters(argIndices, ...)
    local returnData = {}
    for k, funct in ipairs(args) do
        returnData[k] = createHideFilter(funct, argIndices)
    end
    return table.unpack(returnData)
end

--Changes file inputs to be from "/sand"
env.fs.list, env.fs.exists, env.fs.isDir, env.fs.isReadOnly, env.fs.getSize, env.fs.makeDir, env.fs.delete, env.fs.open, env.fs.find, env.fs.getDir = createFilers({1}, env.fs.list, env.fs.exists, env.fs.isDir, env.fs.isReadOnly, env.fs.getSize, env.fs.makeDir, env.fs.delete, env.fs.open, env.fs.find, env.fs.getDir)
env.fs.move, env.fs.copy = createFilters({1, 2}, env.fs.move, env.fs.copy)
env.fs.complete = createFilter(env.fs.complete, {2})

--Changes file outputs to be from "/"
env.fs.find, env.fs.getDir = createHideFilters({1}, env.fs.find, env.fs.getDir)
