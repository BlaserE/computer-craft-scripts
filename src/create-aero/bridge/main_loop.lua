-- bridge/main_loop.lua
package.path = package.path .. ";/?.lua;/?/init.lua"
local config = require("config")
local mixer  = require("model.mixer")

local modem_side = "top"  -- adjust
rednet.open(modem_side)

-- Wire up your input devices. These sides correspond to where the Create
-- analog levers and steering wheels feed redstone signal into the bridge.
-- Adjust based on actual setup.
local INPUT_SIDES = {
  throttle    = "left",
  pitch_up    = "right",   -- top side of pitch steering wheel
  pitch_down  = "front",   -- bottom side of pitch steering wheel
  roll_left   = "back",    -- top side of roll steering wheel
  roll_right  = "bottom",  -- bottom side of roll steering wheel
}

-- Storage for incoming telemetry, keyed by engine_id.
local fleet = { FL = nil, FR = nil, BL = nil, BR = nil }

local function read_inputs()
  local inputs = {}
  for name, side in pairs(INPUT_SIDES) do
    inputs[name] = redstone.getAnalogInput(side)
  end
  return inputs
end

local function broadcast_commands(targets)
  for engine_id, target_signal in pairs(targets) do
    local engine = config.ENGINES[engine_id]
    rednet.send(engine.rednet_id, {
      version = 1,
      type = "cmd",
      target_signal = target_signal,
    }, config.REDNET_PROTOCOL)
  end
end

local function broadcast_commands(targets)
  for engine_id, target_signal in pairs(targets) do
    local engine = config.ENGINES[engine_id]
    rednet.send(engine.rednet_id, {
      version = 1,
      type = "cmd",
      target_signal = target_signal,
    }, config.REDNET_PROTOCOL)
  end
end

-- Main loop: strict tick clock, with telemetry drained inside each tick budget.
while true do
  local tick_start = os.clock()

  local inputs = read_inputs()
  local targets = mixer.compute(inputs)
  broadcast_commands(targets)

  -- Drain telemetry until ~80% of tick budget is used, then sleep the rest.
  local deadline = tick_start + config.TICK_INTERVAL * 0.8
  repeat
    local remaining = deadline - os.clock()
    if remaining <= 0 then break end
    local sender, msg = rednet.receive(config.REDNET_PROTOCOL, remaining)
    if msg and msg.type == "telemetry" then
      fleet[msg.engine_id] = msg
    end
  until false

  -- Sleep any remaining tick budget.
  local elapsed = os.clock() - tick_start
  if elapsed < config.TICK_INTERVAL then
    os.sleep(config.TICK_INTERVAL - elapsed)
  end
end