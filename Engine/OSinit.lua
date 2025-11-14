local OS = love.system.getOS()


if OS == "Windows" then
    package.cpath = package.cpath .. ";Steam/Windows/?.dll"
end


Steam = require "luasteam"