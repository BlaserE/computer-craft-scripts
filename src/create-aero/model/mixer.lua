-- model/mixer.lua
local config = require("config")

local M = {}

-- Compute the four engine signal targets from pilot inputs.
-- All inputs are 0-14 (Create analog redstone).
-- Steering wheels output two unsigned magnitudes per axis.
function M.compute(inputs)
  local throttle    = inputs.throttle    or config.HOVER_SIGNAL
  local pitch_up    = inputs.pitch_up    or 0
  local pitch_down  = inputs.pitch_down  or 0
  local roll_left   = inputs.roll_left   or 0
  local roll_right  = inputs.roll_right  or 0

  -- Scale wheel inputs (0-14) to authority range (e.g. 0-3 signal steps).
  local function scale(wheel_value, authority)
    return (wheel_value / config.MAX_SIGNAL) * authority
  end

  local pitch_bias = scale(pitch_up, config.PITCH_AUTHORITY)
                   - scale(pitch_down, config.PITCH_AUTHORITY)
  local roll_bias  = scale(roll_right, config.ROLL_AUTHORITY)
                   - scale(roll_left,  config.ROLL_AUTHORITY)

  -- Pitch up = nose rises = front engines push less, back engines push more.
  -- Roll right = right side dips = right engines less, left engines more.
  local targets = {
    FL = throttle - pitch_bias + roll_bias,
    FR = throttle - pitch_bias - roll_bias,
    BL = throttle + pitch_bias + roll_bias,
    BR = throttle + pitch_bias - roll_bias,
  }

  -- Clamp to valid signal range. Saturation handling is a separate concern.
  for k, v in pairs(targets) do
    targets[k] = math.max(config.MIN_SIGNAL, math.min(config.MAX_SIGNAL, v))
  end

  return targets
end

-- Saturation handler: if any engine wants > MAX, reduce throttle baseline
-- for all engines so rotation authority is preserved.
function M.with_saturation_handling(inputs)
  local targets = M.compute(inputs)

  -- Find any overflow before clamping (recompute without clamp).
  -- For now, the basic clamp in compute() is fine for stage 4.
  -- Stage 6 will replace this with proper redistribution.
  return targets
end

return M