-- bridge/main_loop.lua
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

local function handle_telemetry()
  -- Drain any pending telemetry messages without blocking the main loop.
  while true do
    local sender, msg = rednet.receive(config.REDNET_PROTOCOL, 0)
    if not msg then break end
    if msg.type == "telemetry" then
      fleet[msg.engine_id] = msg
    end
  end
end

while true do
  local inputs = read_inputs()
  local targets = mixer.compute(inputs)
  broadcast_commands(targets)
  handle_telemetry()
  -- Telemetry is captured in `fleet` for the view layer (later stages).
  os.sleep(config.TICK_INTERVAL)
end