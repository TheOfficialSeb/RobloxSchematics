local simpleUSON = require("simpleUSON")
local MD5 = require("md5")
local Data = {
    ["extraParticleEmitters"] = false,
    ["useCommands"] = true
}
local Hash = MD5.new()
Hash:update("popbob.lua")
local File = io.open(MD5.tohex(Hash:finish())..".uson","w")
File:write(simpleUSON.encode(Data))
File:close()