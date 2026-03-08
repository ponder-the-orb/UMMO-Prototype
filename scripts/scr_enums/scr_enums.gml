// scr_enums
// Defines the different states for the battle manager
enum BATTLE_STATE
{
    IDLE,                   // No battle active
    START_BATTLE,           // Initial setup for a battle
    CALCULATE_TURN_ORDER,   // Determine who acts next
    SELECT_ACTION,          // Player selecting action (e.g., Attack, Magic)
    PLAYER_INPUT,           // Waiting for player input to select menu option
    SELECTING_TARGET,       // Player selecting a target after choosing an action
    WAITING_FOR_SERVER,     // Waiting for Server Auth
    EXECUTING_ACTION,       // An action is being performed (animations, effects, damage)
    TURN_PROGRESSION,       // <--- THIS ONE: Logic for "Who goes next?"
    ACTION_WAIT,            // Short pause after an action for readability
    ENEMY_TURN,             // Enemy AI deciding and performing action
    CHECK_WIN_LOSS,         // Check if battle has ended
    VICTORY_REWARDS,
    END_BATTLE,             // Battle ending sequence
}

//Important: The order matters for the default integer values, 
//but you generally just list them. 
//IDLE will be 0, START_BATTLE will be 1, and so on. 

// --- Combat Targeting ENUMS ---
enum MODE {
    NEVER,
    ALWAYS,
    VARIES,
    ALL_ENEMIES,
    ALL_ALLIES
}