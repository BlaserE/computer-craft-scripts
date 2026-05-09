-- install.lua
local role = ...  -- "bridge", "engine-FL", "engine-FR", "engine-BL", "engine-BR"

if not role then
  print("Usage: install.lua <role>")
  print("Roles: bridge, engine-FL, engine-FR, engine-BL, engine-BR")
  return
end

local BASE = "https://raw.githubusercontent.com/BlaserE/computer-craft-scripts/main/src/create-aero/"

-- Files everyone needs.
local common = {
  "config.lua",
}

-- Files per role.
local role_files = {
    ["bridge"] = {
    "bridge/startup.lua",
    "bridge/main_loop.lua",
    "model/mixer.lua",
    },
    ["engine"] = {
    "engine/startup.lua",
    "engine/main_loop.lua",
    "model/engine_controller.lua",
    },
}

local function fetch(path)
  local url = BASE .. path
  local dest = "/" .. path  -- absolute
  print("Fetching " .. path)
  if fs.exists(dest) then fs.delete(dest) end
  shell.run("wget", url, dest)
end

-- Pull common files.
for _, f in ipairs(common) do fetch(f) end

-- Pull role-specific files.
local engine_role = role:match("^engine")
local files = engine_role and role_files["engine"] or role_files[role]
if not files then
  print("Unknown role: " .. role)
  return
end
for _, f in ipairs(files) do fetch(f) end

-- For engine roles, write the engine ID into a small local config.
if engine_role then
  local engine_id = role:match("^engine%-(%a+)$")
  
  local id_file = fs.open("/engine_id.lua", "w")
  id_file.write("return \"" .. engine_id .. "\"")
  id_file.close()
  print("Engine ID set to " .. engine_id)

  local startup_file = fs.open("/startup.lua", "w")
  startup_file.write('shell.run("/engine/startup.lua")\n')
  startup_file.close()
elseif role == "bridge" then
  local f = fs.open("/startup.lua", "w")
  f.write('shell.run("/bridge/startup.lua")\n')
  f.close()
end