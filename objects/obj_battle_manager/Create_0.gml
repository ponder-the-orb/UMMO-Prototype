// --- obj_battle_manager CREATE EVENT ---
show_debug_message("BATTLE_LOG: --- Manager Initializing ---");

// 1. DATA INITIALIZATION
depth = -400;
battle_state = BATTLE_STATE.IDLE;
current_user = noone;
turn = -1; 
pending_targets = []; 
pending_action = noone;
current_action_executing = false;
fake_server_timer = 0;
battle_wait_time_frames = 60; 
battle_wait_time_remaining = 0;

// Initialize these arrays ONCE
player_units = [];
enemy_units = [];
units = []; 
unit_turn_order = []; 

// --- 2 & 3. ENROLL ALL PARTICIPANTS ---
with (obj_actor) {
    // Only bring in the player and the specific target we clicked on
    if (is_local_player || id == global.selected_target) {
        
        // NEW: Initialize the ATB bar for this vessel
        atb_value = 0; 

        if (is_local_player) {
            array_push(other.player_units, id);
            show_debug_message("BATTLE_LOG: Player enrolled: " + actor_data.identity.name);
        } else {
            array_push(other.enemy_units, id);
            show_debug_message("BATTLE_LOG: Enemy enrolled: " + actor_data.identity.name);
        }
    }
}

// --- 4. COMBINE ---
// This is your master list for the ATB "Race"
units = array_concat(player_units, enemy_units);

// 4. DEFINE TOOLS (State Machine Function)
battle_state_transition_to = function(_new_state) 
{
    if (battle_state == _new_state) return; 
    
    // Reset timer on specific transitions
    if (_new_state == BATTLE_STATE.ENEMY_TURN || _new_state == BATTLE_STATE.CALCULATE_TURN_ORDER) {
        battle_wait_time_remaining = 0; 
    }

    battle_state = _new_state;
    show_debug_message("BATTLE_STATE: Transitioned to -> " + string(_new_state));
}

// 5. UI SETUP (Spawning the Battle Menu)
var _options = global.local_player_stats.actions; 
var _desc = "Select an action!";
var _menu_x = 30;  
var _menu_y = 290; 

menu_instance = create_menu(_menu_x, _menu_y, _options, _desc);

// Link the player to the menu so it knows WHO is attacking
if (array_length(player_units) > 0) {
    menu_instance.current_user = player_units[0];
    show_debug_message("BATTLE_LOG: Menu linked to user: " + string(player_units[0].actor_data.identity.name))
} else {
    show_debug_message("BATTLE_ERROR: No player found to link to menu!");
}

// 6. KICKSTART
// Get the camera pos for UI positioning if needed
cx = camera_get_view_x(view_camera[0]);
cy = camera_get_view_y(view_camera[0]);

show_debug_message("BATTLE_LOG: Initialization Complete. Starting Calculation.");
battle_state_transition_to(BATTLE_STATE.CALCULATE_TURN_ORDER);