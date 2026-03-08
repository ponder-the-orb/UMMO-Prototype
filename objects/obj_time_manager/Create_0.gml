// This is the "State" that the server would eventually own
global.time_state = {
    total_ticks: 0,      // Every second or "tick" that has passed since the world started
    seconds: 0,
    minutes: 0,
    hours: 8,
    days: 1,
    seconds_per_tick: 1  // How much real time = 1 in-game minute(?)
};

alarm[0] = game_get_speed(gamespeed_fps); // Set alarm for 1 second (usually 60 frames)

global.is_server_authoritative = false; // We set this to true later when the Node.js server is live