-- engine/main_loop.lua

package.path = package.path .. ";/?.lua;/?/init.lua"
local config = require("config")

local Controller = require("model.engine_controller")

local ENGINE_ID = require("engine_id")  -- "FL", "FR", "BL", or "BR"

-- Adjust these to match your physical setup.
local modem_side  = "back"
local output_side = "right"

rednet.open(modem_side)

local ctrl = Controller.new(ENGINE_ID)
local current_tick = 0

print("Engine " .. ENGINE_ID .. " online. Listening for commands.")

while true do
  current_tick = current_tick + 1

  -- Wait up to one tick for a command. This call doubles as our tick clock.
  local sender, msg = rednet.receive(config.REDNET_PROTOCOL, config.TICK_INTERVAL)

  if msg and msg.type == "cmd" and sender == config.BRIDGE_ID then
    ctrl:set_target(msg.target_signal)
    ctrl.last_command_tick = current_tick
  end

  -- Failsafe: no command for too long → mark status, hold last value.
  if current_tick - ctrl.last_command_tick > config.COMMAND_TIMEOUT_TICKS then
    ctrl.status = "no_command"
  else
    ctrl.status = "ok"
  end

  -- Advance controller and emit redstone signal.
  local signal = ctrl:tick()
  redstone.setAnalogOutput(output_side, signal)

  -- Send telemetry back to bridge.
  local t = ctrl:telemetry()
  t.type = "telemetry"
  t.version = 1
  rednet.send(config.BRIDGE_ID, t, config.REDNET_PROTOCOL)
end