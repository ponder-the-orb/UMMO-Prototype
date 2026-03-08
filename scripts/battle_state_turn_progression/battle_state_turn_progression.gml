// State: Turn Progression
// This function handles advancing the turn to the next unit.
function battle_state_turn_progression()
{
    turn_count++; // Increment overall turn counter
    turn++;       // Move to the next index in the turn order array

    // If we've gone through all units in the turn order array,
    // reset turn to 0 and increment the round count.
    if (turn > array_length(unit_turn_order) - 1)
    {
        turn = 0;
        round_count++;
        // (Future: Re-sort unit_turn_order here if speed changes, or handle other round-based events)
    }

    // Transition back to the 'select_action' state for the next unit.
    battle_state = BATTLE_STATE.SELECT_ACTION;
}

// --- Initial Battle State ---
// Set the very first state of the battle manager when it is created.
battle_state = BATTLE_STATE.SELECT_ACTION; // Starts the battle by having the first unit select an action