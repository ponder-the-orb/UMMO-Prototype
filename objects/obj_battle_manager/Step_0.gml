// --- Add this at the very top of your STEP EVENT ---
cx = camera_get_view_x(view_camera[0]);
cy = camera_get_view_y(view_camera[0]);


// 1. Safety Check: If we are in a state that REQUIRES a user, but have none, exit.
// But we allow CALCULATE_TURN_ORDER to run even if current_user is noone!
if (current_user == noone && battle_state != BATTLE_STATE.CALCULATE_TURN_ORDER) {
    // If we get stuck, force a calculation
    battle_state = BATTLE_STATE.CALCULATE_TURN_ORDER;
}

// 2. THE STATE MACHINE (Now it can actually breathe!)
switch (battle_state) 
{
    case BATTLE_STATE.IDLE:
        break;

// --- Inside obj_battle_manager STEP EVENT ---

case BATTLE_STATE.CALCULATE_TURN_ORDER:
    // 1. The "Race" Logic: Everyone charges at once
    var _turn_ready = noone;
    
    // Loop through all units in the battle
    for (var i = 0; i < array_length(units); i++) {
        var _u = units[i];
        
        if (instance_exists(_u)) {
            // Speed directly affects how much the bar fills per frame
            // We pull 'speed' from the suitcase!
            var _spd = _u.actor_data.body.stats.speed;
            _u.atb_value += _spd * 0.1; // Multiplier adjusts the "feel" of the battle speed
            
            // First person to hit 100 wins the turn
            if (_u.atb_value >= 100) {
                _turn_ready = _u;
                break; // Stop the loop, we found our attacker!
            }
        }
    }

    // 2. Transition Logic: If someone is ready, start their turn
    if (_turn_ready != noone) {
        current_user = _turn_ready;
        _turn_ready.atb_value = 0; // Reset their charge for the next round
        
        show_debug_message("ATB_LOG: " + _turn_ready.actor_data.identity.name + " is ready!");
        battle_state_transition_to(BATTLE_STATE.SELECT_ACTION);
    }
break;

   case BATTLE_STATE.SELECT_ACTION:
    // 1. SAFETY CHECK: If this isn't a player, they have no business in the menu state!
    if (!current_user.actor_data.is_player) {
        show_debug_message("REDIRECT: " + string(current_user.actor_data.identity.name) + " is an enemy. Sending to ENEMY_TURN.");
        battle_state_transition_to(BATTLE_STATE.ENEMY_TURN);
        break;
    }

    // 2. CLEAR PREVIOUS SELECTION: Make sure we aren't using the last turn's action
    current_action = -4; 
    target_unit = -4;

    // 3. Only create the menu if we don't already have one
    if (!instance_exists(obj_menu)) 
    {
        // Position it using your Camera variables
        var _menu_x = cx + 20; 
        var _menu_y = cy + 240; 
        
        // Create the instance
        menu_instance = instance_create_depth(_menu_x, _menu_y, -10000, obj_menu);
        
        // 4. TETHER: Tell the menu who is using it
        menu_instance.current_user = current_user;
        
        // 5. SETUP: Feed it the REAL actions from the character
        var _actions = current_user.actor_data.actions;
        var _description = "What will " + string(current_user.actor_data.identity.name) + " do?";
        
        menu_instance.setup_actions(_actions, _description);
        
        show_debug_message("Battle State: Menu created for " + string(current_user.actor_data.identity.name));
    }
    break;
    
    // --- 3. TARGETING ---
    // This state runs AFTER you pick "Attack" but BEFORE you deal damage.
    case BATTLE_STATE.SELECTING_TARGET:
        // Find everyone who is alive on the opposing side
        var _targets = (pending_action.target_enemy_by_default) ? enemy_units : player_units;
        var _living_targets = array_filter(_targets, function(_u) { return _u.actor_data.body.hp > 0; });
        var _target_count = array_length(_living_targets);
        
        // --- THE FIX ---
        // If our cursor is pointing at a number higher than the enemies left, 
        // or if it's below 0, force it back into range.
        cursor_index = clamp(cursor_index, 0, max(0, _target_count - 1));

        if (_target_count > 0) 
        {
            // Move selection cursor left/right
            if (keyboard_check_pressed(vk_right)) cursor_index = (cursor_index + 1) % _target_count;
            if (keyboard_check_pressed(vk_left)) cursor_index = (cursor_index - 1 + _target_count) % _target_count;

            // CONFIRM TARGET
            if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
            pending_targets = [_living_targets[cursor_index]];
    
            // --- SERVER AUTHORITY LOGIC ---
            // Instead of jumping straight to animation, we ask for permission
            battle_state_transition_to(BATTLE_STATE.WAITING_FOR_SERVER);
    
            // FAKE SERVER CALL (For now)
            // We send the request, and for the demo, we'll auto-reply in the next state
            show_debug_message("Requesting action from server...");
            }
            
            // CANCEL: If they change their mind, go back to the Main Menu
            if (keyboard_check_pressed(vk_escape)) {
                battle_state_transition_to(BATTLE_STATE.SELECT_ACTION);
                if (instance_exists(menu_instance)) menu_instance.active = true;
            }
        }
        break;
    
case BATTLE_STATE.WAITING_FOR_SERVER:
    // Increment the timer we made in the Create Event
    fake_server_timer++;
    
    // After about half a second (assuming 60fps)
    if (fake_server_timer >= 30) { 
        fake_server_timer = 0; // Reset it for the next turn!
        current_action_executing = true;
        battle_state_transition_to(BATTLE_STATE.EXECUTING_ACTION);
        show_debug_message("Fake Server: Action Authorized.");
    }
    break;

// --- 4. ANIMATION & DAMAGE ---
    case BATTLE_STATE.EXECUTING_ACTION:
        
        // Step A: Start the sequence (Runs once)
        if (current_action_executing) {
            current_user.state = "DASHING_FORWARD"; // We use a specific dash state now!
            current_user.home_x = current_user.x;
            current_user.home_y = current_user.y;
            current_action_executing = false; 
        }

        var _target = pending_targets[0];
        var _target_exists = instance_exists(_target);

        // Step B: Dash to Target
        if (current_user.state == "DASHING_FORWARD") {
            if (!_target_exists) {
                // If the target vanished/disconnected, abort the attack and go home
                current_user.state = "RETURNING"; 
            } else {
                var _dist = point_distance(current_user.x, current_user.y, _target.x, _target.y);
                
                if (_dist > 40) {
                    // Keep running!
                    with (current_user) move_towards_point(_target.x, _target.y, 10);
                } else {
                    // We Arrived! Stop moving!
                    current_user.speed = 0;
                    current_user.state = "ATTACKING";
                    current_user.image_index = 0; // Reset animation to frame 0
                    
                    // NOW we apply the damage exactly when they reach the target!
                    begin_action(current_user, pending_action, pending_targets);
                }
            }
        }

        // Step C: Play the Attack Animation
        if (current_user.state == "ATTACKING") {
            current_user.speed = 0; // Force them to stay still
            
            // Wait for the animation to finish
            if (current_user.image_index >= current_user.image_number - 1) {
                current_user.state = "RETURNING";
            }
        }

        // Step D: Hop Back Home
        if (current_user.state == "RETURNING") {
            var _home_dist = point_distance(current_user.x, current_user.y, current_user.home_x, current_user.home_y);
            
            if (_home_dist > 5) {
                with (current_user) move_towards_point(home_x, home_y, 8);
            } else {
                // We are home! Lock them exactly to the starting coordinates
                current_user.x = current_user.home_x;
                current_user.y = current_user.home_y;
                current_user.speed = 0;
                current_user.state = "BATTLE"; // Back to combat idle
                
                // FINISH THE STATE
                battle_state_transition_to(BATTLE_STATE.CHECK_WIN_LOSS);
            }
        }
        break;

case BATTLE_STATE.ENEMY_TURN:
    // 1. INITIALIZATION: Run this only on the very first frame of the turn
    if (battle_wait_time_remaining <= 0) {
        // Reset data so we don't accidentally use the Player's last move
        pending_action = -4; 
        pending_targets = [];
        
        // Set the "Think Time" (60 frames = 1 second at 60fps)
        battle_wait_time_remaining = 60; 
        
        show_debug_message("Enemy " + string(current_user.actor_data.identity.name) + " is thinking...");
    }
    
    // 2. TICK TOCK: Count down the timer
    battle_wait_time_remaining--;

    // 3. EXECUTION: When the timer hits 1, pick a target and lunge!
    if (battle_wait_time_remaining == 1) {
        // Find living players
        var _target_list = array_filter(player_units, function(_u) { 
            return instance_exists(_u) && _u.actor_data.body.hp > 0; 
        });
        
        if (array_length(_target_list) > 0) {
            // AI Logic: Just grab the first available player for now
            var _target = _target_list[0];
            var _enemy_action = current_user.actor_data.actions[0]; 

            // Pack the data for the Execution state
            pending_action = _enemy_action;
            pending_targets = [_target];
            
            show_debug_message("Enemy " + string(current_user.actor_data.identity.name) + " attacking " + string(_target.actor_data.identity.name));
            
            // Go to the lunge/damage state
            current_action_executing = true;
            battle_state_transition_to(BATTLE_STATE.EXECUTING_ACTION);
        } else {
            // No players left? Check if game is over
            battle_state_transition_to(BATTLE_STATE.CHECK_WIN_LOSS);
        }
    }
break;

case BATTLE_STATE.CHECK_WIN_LOSS:
    // 1. Run your cleanup (Make sure this function updates the 'units' array!)
    clean_dead_units();
    
    // 2. Scan the master list using 'any' (Super fast check)
    var _players_alive = array_any(units, function(_u) { 
    return _u.actor_data.is_player && _u.actor_data.body.hp > 0; 
});
    var _enemies_alive = array_any(units, function(_u) { 
    return !_u.actor_data.is_player && _u.actor_data.body.hp > 0; 
});
    // 3. The Decision Tree
    if (!_enemies_alive) {
        show_debug_message("BATTLE LOGIC: No enemies left. Transitioning to Victory.");
        battle_state_transition_to(BATTLE_STATE.VICTORY_REWARDS); 
    } 
    else if (!_players_alive) {
        show_debug_message("BATTLE LOGIC: Player is dead. Transitioning to Defeat.");
        battle_state_transition_to(BATTLE_STATE.END_BATTLE); 
    }
    else {
        // Everyone is still swinging!
        battle_state_transition_to(BATTLE_STATE.CALCULATE_TURN_ORDER);
    }
break;

case BATTLE_STATE.END_BATTLE:
    show_message("You were defeated by a goblin... How embarrassing.");
    game_restart(); // For now, just restart the game!
break;


case BATTLE_STATE.VICTORY_REWARDS:
    // Reset all surviving actors back to overworld
    for (var i = 0; i < array_length(player_units); i++) {
        var _u = player_units[i];
        if (instance_exists(_u)) {
            _u.state = "IDLE";
            _u.speed = 0;
        }
    }
    
    // Unlock the world
    global.in_battle = false;
    global.selected_target = noone;
    
    // Destroy the manager itself
    instance_destroy(menu_instance); // safe even if noone
    instance_destroy(id);
break;

}
