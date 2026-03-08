// Function: begin_action
// This function is called to set up and start an action for a unit.
function begin_action(_user, _action, _targets)
{
    // Store details in the manager for the current turn
    current_user = _user;
    current_action = _action;
    current_targets = _targets;

    // Ensure targets are in an array format
    if (!is_array(current_targets)) { current_targets = [current_targets]; }

    // --- NOOB MECHANIC: Execute the Library Action ---
    // This looks at your Action Library (Attack or Ice) and runs the math found there.
    if (!is_undefined(_action[$ "action"])) 
    {
        // This line actually triggers the "battle_change_hp" inside your library!
        _action.action(_user, current_targets);
    }

    // Set the delay frames so the animation has time to play
    obj_battle_manager.battle_wait_time_remaining = obj_battle_manager.battle_wait_time_frames;
    
   // Set the 'acting' flag and switch to the attack/cast animation
    with(_user)
    {
        acting = true; 
        
        // 1. Check if this unit even has a 'sprites_data' struct
        if (variable_instance_exists(self, "sprites_data")) 
        {
            // 2. Check if the action has an animation name AND if that name exists in our sprites
            var _anim_name = _action[$ "user_animation"];
            if (!is_undefined(_anim_name) && !is_undefined(sprites_data[$ _anim_name]))
            {
                sprite_index = sprites_data[$ _anim_name]; 
                image_index = 0; 
                image_speed = 1; // <--- This "turns on" the flipbook!
            }
            else 
            {
                show_debug_message("LOGIC: Action animation '" + string(_anim_name) + "' not found in sprites_data. Using idle.");
            }
        }
        else 
        {
            // We need to use the _user passed into the function!
show_debug_message("LOGIC: Unit " + _user.actor_data.identity.name + " has no sprites_data. Running logic-only.");
        }
    }

    // Destroy the UI menu so it's not on screen during the animation
    if (instance_exists(obj_battle_manager.menu_instance))
    {
        instance_destroy(obj_battle_manager.menu_instance);
        obj_battle_manager.menu_instance = noone; 
    }

    // Move the manager into the EXECUTING state
    obj_battle_manager.battle_state_transition_to(BATTLE_STATE.EXECUTING_ACTION);
}