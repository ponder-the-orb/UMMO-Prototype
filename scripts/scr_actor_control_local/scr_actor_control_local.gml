function scr_actor_control_local() {
    // --- MOVEMENT LOGIC ---
    var _h = (keyboard_check(vk_right) - keyboard_check(vk_left));
    var _v = (keyboard_check(vk_down) - keyboard_check(vk_up));
    var _is_targeting = mouse_check_button(mb_right);
    var _is_crouching = keyboard_check(vk_lshift);
    
    var _move_speed = actor_data.body.stats.speed;
    if (_is_crouching) _move_speed *= 0.5;
    else if (_is_targeting) _move_speed *= 0.6;
    
    current_noise_level = scr_calculate_noise(_h, _v, _is_crouching);
    
    x += _h * _move_speed;
    y += _v * _move_speed;
    
    if (_is_targeting) {
        actor_data.perception.facing_direction = point_direction(x, y, mouse_x, mouse_y);
    } else if (_h != 0 || _v != 0) {
        actor_data.perception.facing_direction = point_direction(0, 0, _h, _v);
    }
    
    // --- SPACEBAR: ENGAGE ---
    if (keyboard_check_pressed(vk_space)) {
        scr_actor_try_engage(); 
    }

    // --- S KEY: SPAWN goblin (Now safely inside the function!) ---
    if (keyboard_check_pressed(ord("S"))) {
        show_debug_message("S Key Pressed! Trying to spawn...");
        
        var _inst = instance_create_depth(mouse_x, mouse_y, depth, obj_actor);
        
        if (instance_exists(_inst)) {
            show_debug_message("goblin Instance Created!");
            _inst.actor_data = scr_actor_init("goblin");
            _inst.is_local_player = false;
            _inst.state = "IDLE";
            
            // Sync the sprite immediately
            with(_inst) { 
                sprite_index = actor_data.sprites.idle; 
            }
        }
    }
    
// ==========================================
    // --- NETWORK TRANSMISSION (THE RADIO) ---
    // ==========================================
    
    // 1. Safety check: Only run if the global variable actually exists and is connected
    if (variable_global_exists("client_socket") && global.client_socket >= 0) {
        
        // 2. Update our network struct with our CURRENT live coordinates
        actor_data.net_data.x = x;
        actor_data.net_data.y = y;
        actor_data.net_data.facing = actor_data.perception.facing_direction;

        // 3. Turn that struct into a JSON string
        var _json_string = json_stringify(actor_data.net_data);

        // 4. Prepare the envelope (Buffer)
        buffer_seek(actor_data.net_buffer, buffer_seek_start, 0);
        
        // We use buffer_string because it automatically adds the "\0" terminator!
        buffer_write(actor_data.net_buffer, buffer_string, _json_string); 

        // 5. FIRE IT TO THE SERVER! 
        network_send_udp(global.client_socket, global.server_ip, global.server_port, actor_data.net_buffer, buffer_tell(actor_data.net_buffer));
    }

} // <--- THIS BRACKET CLOSES THE ENTIRE FUNCTION! EVERYTHING MUST BE ABOVE THIS!