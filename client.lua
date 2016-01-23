shell.setDir("sand")

--Edits shell.resolve()
local shell.resolve = function(s)
    

--Gets startup file
local path = ""
if fs.exists("sand/startup") and then
    startup

--Runs payload and shell in parallel
term.clear()
term.setCursorPos(1, 1)
parallel.waitForAny(loadfile("
