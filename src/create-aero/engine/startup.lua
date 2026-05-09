-- engine/startup.lua
package.path = package.path .. ";/?.lua;/?/init.lua"

local engine_id = require("engine_id")  -- written by installer
print("Helicarrier Engine " .. engine_id .. " booting...")
print("Computer ID: " .. os.getComputerID())
sleep(1)

local ok, err = pcall(function()
  shell.run("/engine/main_loop.lua")
end)

if not ok then
  print("Engine crashed: " .. tostring(err))
  print("Press any key to exit.")
  os.pullEvent("key")
end