function scr_actor_try_engage() {
    var _range = 150; // Noir engagement distance
    var _target = noone;

    // Find the closest non-player actor
    with (obj_actor) {
        if (id != other.id && !actor_data.is_player) {
            var _d = point_distance(x, y, other.x, other.y);
            if (_d < _range) {
                _range = _d;
                _target = id;
            }
        }
    }

    // Start the transition to the Battle State
    if (_target != noone) {
        global.selected_target = _target;
        state = "BATTLE"; // Switch the initiator to battle mode
        _target.state = "BATTLE"; // Switch the victim to battle mode
        
        // Only create the manager if it doesn't exist
        if (!instance_exists(obj_battle_manager)) {
            instance_create_depth(x, y, 0, obj_battle_manager);
        }
        
        // ==========================================
        // --- NETWORK TRANSMISSION: LOCK TARGET ---
        // ==========================================
        if (variable_global_exists("client_socket") && global.client_socket >= 0) {
            
            // 1. Package the battle data (Node.js is looking for 'enemy_id')
            var _battle_packet = {
                type: "BATTLE_START",
                network_id: global.local_player_instance_id,
                enemy_id: _target.my_instance_id_str 
            };
            
            // 2. Turn it into a JSON string
            var _json_string = json_stringify(_battle_packet);
            
            // 3. Use a temporary buffer to mail it
            var _temp_buffer = buffer_create(256, buffer_fixed, 1);
            buffer_write(_temp_buffer, buffer_string, _json_string);
            
            // 4. Fire it off!
            network_send_udp(global.client_socket, global.server_ip, global.server_port, _temp_buffer, buffer_tell(_temp_buffer));
            
            // 5. Delete the temporary envelope so we don't leak memory
            buffer_delete(_temp_buffer);
        }
        
        return true; // Engagement successful
    }
    
    return false; // Nothing nearby
}