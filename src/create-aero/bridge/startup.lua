-- bridge/startup.lua
package.path = package.path .. ";/?.lua;/?/init.lua"

print("Helicarrier Bridge booting...")
print("Computer ID: " .. os.getComputerID())

-- Small delay so you can see the boot message and Ctrl+T out if needed.
sleep(1)

-- Hand off to the main loop. Wrapped in pcall so a crash doesn't leave
-- the computer in a weird state — it prints the error and exits cleanly.
local ok, err = pcall(function()
  shell.run("/bridge/main_loop.lua")
end)

if not ok then
  print("Bridge crashed: " .. tostring(err))
  print("Press any key to exit.")
  os.pullEvent("key")
end