-- config.lua
return {
  -- The thrust curve: signal (0-14) → output RPM, given fixed 16 RPM input.
  -- Signal 15 is forbidden (breaks the transmission).
  THRUST_CURVE = {
    [0]  = 16,
    [1]  = 18.29,
    [2]  = 19.69,
    [3]  = 21.33,
    [4]  = 23.27,
    [5]  = 25.6,
    [6]  = 28.44,
    [7]  = 32,
    [8]  = 36.57,
    [9]  = 42.67,
    [10] = 51.2,
    [11] = 64,
    [12] = 85.33,
    [13] = 128,
    [14] = 256,
  },

  MAX_SIGNAL = 14,
  MIN_SIGNAL = 0,

  -- Engine identifiers and their physical positions on the ship.
  ENGINES = {
    FL = { rednet_id = 6, position = "front-left"  },
    FR = { rednet_id = 7, position = "front-right" },
    BL = { rednet_id = 8, position = "back-left"   },
    BR = { rednet_id = 9, position = "back-right"  },
  },

  BRIDGE_ID = 5,
  REDNET_PROTOCOL = "helicarrier-v1",

  -- The throttle signal that produces stable hover. Calibrate in-game.
  -- 11 = 64 RPM per engine; adjust based on ship weight.
  HOVER_SIGNAL = 11,

  -- Maximum signal-units of authority for pitch and roll, regardless of throttle.
  -- ±3 means full deflection on the steering wheel adjusts an engine by 3 signal levels.
  PITCH_AUTHORITY = 3,
  ROLL_AUTHORITY  = 3,

  -- Slew limit: maximum signal change per tick. Gives the "heavy" feel.
  -- 1 means full-throttle change takes 14 ticks (~0.7 seconds).
  SLEW_RATE = 1,

  -- Loop tick rate. 0.05 = 20 Hz (one Minecraft tick).
  TICK_INTERVAL = 0.05,

  -- If the engine receives no command for this many ticks, fail safe.
  COMMAND_TIMEOUT_TICKS = 40,  -- 2 seconds
}