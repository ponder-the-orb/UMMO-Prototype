function scr_sync_time(_server_days, _server_hours, _server_minutes) {
    // This function is the "Plug." 
    // Right now, we call it locally. 
    // Later, your Node.js socket will call this with server data.
    
    var _old_hour = global.time_state.hours;
    
    global.time_state.days = _server_days;
    global.time_state.hours = _server_hours;
    global.time_state.minutes = _server_minutes;
    
    // --- TRIGGER EVENTS ---
    // If the hour changed, trigger the things that care about hours (like hunger)
    if (global.time_state.hours != _old_hour) {
        scr_global_hunger_tick(2); 
    }
}

function scr_on_clock_tick() {
    // This is the "Local Server" logic
    var _m = global.time_state.minutes + 1;
    var _h = global.time_state.hours;
    var _d = global.time_state.days;
    
    if (_m >= 60) {
        _m = 0;
        _h += 1;
    }
    if (_h >= 24) {
        _h = 0;
        _d += 1;
    }
    
    // Sync the new calculated time to the game
    scr_sync_time(_d, _h, _m);
}

function scr_format_time_string(_value) {
    // If the number is 9, it becomes "09". If it's 12, it stays "12".
    if (_value < 10) {
        return "0" + string(_value);
    }
    return string(_value);
}

function scr_get_clock_string() {
    var _h = scr_format_time_string(global.world_clock.hour);
    var _m = scr_format_time_string(global.world_clock.minute);
    var _s = scr_format_time_string(global.world_clock.second);
    
    return _h + ":" + _m + ":" + _s;
}

