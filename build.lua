
return {

  
  name = 'AGAM', -- name of the game for your executable
  developer = 'WHAMBAM', -- dev name used in metadata of the file
  output = 'dist', -- output location for your game, defaults to $SAVE_DIRECTORY
  version = '0.1', -- 'version' of your game, used to name the folder in output
  love = '12.0', -- version of LÖVE to use, must match github releases
  ignore = {'build', 'todo', 'build.lua', 'Git Tools'}, -- folders/files to  ignore in your project
  icon = 'Sprites/Slime.png', -- 256x256px PNG icon for game, will be converted for you
  
  libs = {
    windows = {'Steam/Windows/luasteam.dll', 'steam_api64.dll'},
    linux = {'Steam/Linux/luasteam.so', 'libsteam_api.so'},
    macos = {'Steam/OSX/luasteam.so', 'libsteam_api.dylib'},
    all = {'README.txt', 'steam_appid.txt' }
  },
  platforms = {'windows'}
  -- platforms = {'windows', 'linux'}

}