// State: Victory Check
// This function will determine if the battle has ended (all enemies defeated or all players defeated).
// For now, it immediately transitions to the next turn for simplicity.
function battle_state_victory_check()
{
    show_debug_message("Running battle_state_victory_check()."); // Add this debug message!
    // (Future: Implement checks for enemy_units array length or player_units health)
    // For now, just proceed to the next turn.
    obj_battle_manager.battle_state = BATTLE_STATE.CALCULATE_TURN_ORDER; // <--- ADD obj_battle_manager. HERE!
    show_debug_message("battle_state_victory_check(): Transitioning to CALCULATE_TURN_ORDER."); // Add this debug message!
}

