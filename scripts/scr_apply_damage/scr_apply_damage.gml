function apply_damage(_source, _target, _dmg) {
    // 1. Get the current HP from the suitcase
    var _current_hp = _target.actor_data.body.hp;
    
    // 2. Subtract the damage
    var _new_hp = _current_hp - _dmg;
    
    // 3. Save it back into the suitcase (clamping so it doesn't go below 0)
    _target.actor_data.body.hp = max(0, _new_hp);
    
    // 4. Debug logs using the new paths
    var _source_name = _source.actor_data.identity.name;
    var _target_name = _target.actor_data.identity.name;
    
    show_debug_message("COMBAT_LOG: " + _source_name + " deals " + string(_dmg) + " damage to " + _target_name);
    show_debug_message(_target_name + " HP is now: " + string(_target.actor_data.body.hp));

// ==========================================
    // --- NETWORK TRANSMISSION: REPORT DAMAGE --
    // ==========================================
    if (variable_global_exists("client_socket") && global.client_socket >= 0) {
        
        // 1. Package up the damage report for the server
        var _damage_packet = {
            type: "BATTLE_DAMAGE",
            network_id: global.local_player_instance_id, // <--- THE MISSING PIECE! Tell the server who swung the sword!
            target_id: _target.my_instance_id_str,       // The ID of the monster taking the hit
            amount: _dmg                                 // How much HP to subtract
        };
        
        // 2. Stringify it
        var _json_string = json_stringify(_damage_packet);
        
        // 3. Put it in a temporary envelope
        var _temp_buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(_temp_buffer, buffer_string, _json_string);
        
        // 4. Fire it off to Node.js!
        network_send_udp(global.client_socket, global.server_ip, global.server_port, _temp_buffer, buffer_tell(_temp_buffer));
        
        // 5. Clean up the envelope
        buffer_delete(_temp_buffer);
    }
}    