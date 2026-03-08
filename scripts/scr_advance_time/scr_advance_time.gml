function scr_advance_time(_seconds_to_add) {
    // If we are connected to Node.js, we don't advance time ourselves!
    // We wait for the server to tell us what time it is.
    if (global.is_server_authoritative) return;

    global.world_clock.second += _seconds_to_add;
    
    // ... all your current overflow logic (minutes, hours) ...
    
    if (global.world_clock.minute >= 60) {
        global.world_clock.minute = 0;
        global.world_clock.hour += 1;
        
        // This is a "Server-Style" event trigger
        //scr_global_hunger_tick(1); 
    }
}