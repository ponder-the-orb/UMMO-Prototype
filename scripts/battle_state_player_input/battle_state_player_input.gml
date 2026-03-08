// battle_state_player_input.gml script
function battle_state_player_input()
{
    
    show_debug_message(">>> BATTLE STATE: battle_state_player_input is RUNNING.");
    // This state is primarily responsible for waiting for player input via obj_menu.
    // The obj_menu instance itself handles all the input detection and action selection.

    // As long as obj_menu exists and is active, we simply do nothing here,
    // effectively "pausing" the battle state progression in obj_battle_manager
    // until obj_menu processes an action (e.g., by destroying itself via menu_select_action).
    if (!instance_exists(obj_menu) || !obj_menu.active)
    {
        // If the menu doesn't exist anymore, or is no longer active,
        // it means the player has made a selection and the menu has destroyed itself (or gone to a sub-menu).
        // At this point, battle_state_select_action will have already chosen the next action
        // or the menu's action will have set obj_battle_manager.battle_state
        // to battle_state_perform_action.
        // For now, we'll transition back to battle_state_select_action
        // to re-evaluate whose turn it is after the menu has done its job.
        // Or, more accurately, the menu's chosen action will directly set the state to battle_state_perform_action.
        // So, this state usually just waits.
        
        // This is a placeholder for safety. In a complete system,
        // obj_menu's action would directly transition the battle_state
        // to battle_state_perform_action after input is handled.
        // For now, we can just ensure it doesn't get stuck.
        
        // Example: If an action has been selected from the menu
        if (obj_battle_manager.current_action != noone)
        {
            obj_battle_manager.battle_state = BATTLE_STATE.EXECUTING_ACTION;
        }
        else // If no action has been set, something went wrong, go back to select_action
        {
             obj_battle_manager.battle_state = BATTLE_STATE.SELECT_ACTION;
        }
    }
    
    // If obj_menu exists and is active, we just do nothing here.
    // The obj_menu's Step Event will handle input.
}