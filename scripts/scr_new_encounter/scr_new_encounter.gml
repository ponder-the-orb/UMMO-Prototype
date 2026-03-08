function new_encounter(_enemies, _bg, _players_data, _battle_creator_id)
{
    // --- 1. Check if a battle is already active ---
    if (global.in_battle)
    {
        show_debug_message("Attempted to start new battle, but one is already active. Ignoring.");
        return; 
    }

    // --- NEW: 1.5 Send Battle Lock to Server ---
    // We tell the server: "I (local_player) am fighting this specific goblin"
    // This allows the server to 'lock' that goblin for other players.
    if (variable_global_exists("client_socket") && global.client_socket != noone) {
        var _battle_init_data = {
            type: "BATTLE_START",
            player_id: global.local_player_instance_id,
            enemy_id: _battle_creator_id.my_instance_id_str // The ID of the goblin you hit
        };
        var _json = json_stringify(_battle_init_data);
        var _buf = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
        buffer_write(_buf, buffer_string, _json);
        network_send_udp(global.client_socket, global.server_ip, global.server_port, _buf, buffer_tell(_buf));
        buffer_delete(_buf);
    } else {
    // If the socket isn't ready, just log it instead of crashing
    show_debug_message("BATTLE ERROR: global.client_socket is not initialized yet!");
}
    

    // --- 2. Get Camera Position ---
    var _active_camera_id = view_get_camera(0);
    var _cam_x = camera_get_view_x(_active_camera_id);
    var _cam_y = camera_get_view_y(_active_camera_id);

    // --- 3. Create the obj_battle_manager instance ---
    // Note: Use -999 for depth so it is ALWAYS above overworld players
    instance_create_depth
    (
        _cam_x,
        _cam_y,
        -999, 
        obj_battle_manager, 
        {
            enemies: _enemies,
            creator: _battle_creator_id,
            battle_background: _bg,
            players: _players_data
        }
    );

    // --- 4. Set the Global Battle Flag ---
    global.in_battle = true;

    // --- 5. MODIFY: Handle Overworld Player State instead of Deactivating ---
    // We DON'T deactivate anymore because if we do, our Networking Event stops running!
    // Instead, we tell the player object to stop accepting movement input.
    if (instance_exists(_battle_creator_id))
    {
        _battle_creator_id.is_acting = false; // Stop mouse movement
        //_battle_creator_id.visible = false;   // Hide local player (the Battle Units replace them visually)
    }
}

