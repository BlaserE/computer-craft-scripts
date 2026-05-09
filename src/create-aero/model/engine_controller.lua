-- model/engine_controller.lua
local config = require("config")

local Controller = {}
Controller.__index = Controller

function Controller.new(engine_id)
  return setmetatable({
    engine_id      = engine_id,
    target_signal  = config.HOVER_SIGNAL,
    current_signal = 0,
    last_command_tick = 0,
    status = "ok",
  }, Controller)
end

function Controller:set_target(signal)
  self.target_signal = math.max(config.MIN_SIGNAL,
                       math.min(config.MAX_SIGNAL, signal))
end

-- Advance one tick: move current_signal toward target_signal by SLEW_RATE.
function Controller:tick()
  local diff = self.target_signal - self.current_signal
  if math.abs(diff) <= config.SLEW_RATE then
    self.current_signal = self.target_signal
  elseif diff > 0 then
    self.current_signal = self.current_signal + config.SLEW_RATE
  else
    self.current_signal = self.current_signal - config.SLEW_RATE
  end
  return math.floor(self.current_signal + 0.5)  -- round for redstone output
end

function Controller:current_rpm()
  local rounded = math.floor(self.current_signal + 0.5)
  return config.THRUST_CURVE[rounded] or 0
end

function Controller:telemetry()
  return {
    engine_id = self.engine_id,
    target_signal  = self.target_signal,
    current_signal = math.floor(self.current_signal + 0.5),
    current_rpm    = self:current_rpm(),
    status         = self.status,
  }
end

return Controller