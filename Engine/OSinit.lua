local OS = love.system.getOS()
local dir = love.filesystem.getSourceBaseDirectory()

if OS == "Windows" then
    package.loadlib(dir .. "/steam_api64.dll", "*")

    package.cpath = package.cpath .. ';' .. 'Steam/Windows/?.dll'
elseif OS == "Linux" then
    dir = dir .."/AGAM"
    package.loadlib(dir .. "/libsteam_api.so", "*")
    
    package.cpath = package.cpath .. ';' .. dir .. '/Steam/Linux/?.so'
end

Steam = require "luasteam"