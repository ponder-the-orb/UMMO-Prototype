// obj_menu Step Event   

if (!active) exit; // If menu is not active, do nothing.

// --- 1. Handle Input (Keyboard) ---
// Checks for key presses (only once per press using keyboard_check_pressed)
var _up = keyboard_check_pressed(vk_up);
var _down = keyboard_check_pressed(vk_down);
var _enter = keyboard_check_pressed(vk_enter);
var _escape = keyboard_check_pressed(vk_escape); // For going back in sub-menus


// --- 2. Navigation (Selecting Options) ---
if (array_length(content_data.options) > 0)
{
    if (_up)
{
    // Check array_length directly from the struct to be safe
    content_data.selected_option = max(0, content_data.selected_option - 1);
    show_debug_message("Menu Current Index: " + string(content_data.selected_option));
}
    
if (_down)
{
    // Use array_length of the actual options list
    var _max_index = array_length(content_data.options) - 1;
    content_data.selected_option = min(_max_index, content_data.selected_option + 1);
    show_debug_message("Menu Current Index: " + string(content_data.selected_option));
}
}


// --- 3. Confirming Selection (vk_enter) ---
if (_enter)
{
    // audio_play_sound(snd_menu_confirm, 0, false); // Play confirmation sound

    // Check if there are options and a valid one is selected
   var _chosen_option = content_data.options[content_data.selected_option];

// --- SUB-MENU LOGIC (First Priority) ---
// If the chosen option has a valid sub_menu (a struct, not the -4 placeholder)
if (is_struct(_chosen_option.sub_menu) && _chosen_option.sub_menu != -4)
{
    // Store current menu's data to go back later
    array_push(content_data.options_above, {
        options: content_data.options,
        selected_option: content_data.selected_option,
        scroll_push: content_data.scroll_push,
        description: content_data.description // Save current description too
    });
    
    // Set the menu to display the new sub-menu's options
    content_data.options = _chosen_option.sub_menu.options;
    content_data.description = _chosen_option.sub_menu.description; // Update description for new menu
    content_data.selected_option = 0; // Reset selection for the new menu
    content_data.scroll_push = 0;    // Reset scroll for the new menu
    content_data.sub_menu_level++;   // Increment sub-menu depth
    
    show_debug_message("DEBUG: Entered sub-menu: " + _chosen_option.name);
}
// --- REGULAR ACTION LOGIC (Second Priority) ---
// If it's NOT a sub-menu, then check if it has a valid action function.
// IMPORTANT: We check if _chosen_option.action is NOT -4 first.
else if (_chosen_option.action != -4 && (typeof(_chosen_option.action) == "method" || script_exists(_chosen_option.action)))
{
    show_debug_message("DEBUG: Selected action: " + _chosen_option.name + ". Preparing to execute its function.");
    
    // Call the newly created script to handle action selection and battle manager transition.
    // This script (`scr_menu_select_action`) will also destroy obj_menu itself.
    menu_select_action([current_user, _chosen_option]);
}
// --- NO ACTION / INVALID OPTION (Last Priority) ---
// If it's neither a sub-menu nor a valid action function (e.g., action is -4 for an unhandled option)
else
{
    show_debug_message("DEBUG: Selected option " + _chosen_option.name + " has no executable action or invalid sub-menu. Its 'action' value is: " + string(_chosen_option.action));
    // You might play a "bloop" sound here, or do nothing.

        // --- END SUB-MENU LOGIC ---
        }
    }


// --- 4. Going Back (vk_escape) ---
if (_escape)
{
    // audio_play_sound(snd_menu_cancel, 0, false); // Play cancel sound

    // If we are in a sub-menu (i.e., we have options stored in options_above)
    if (array_length(content_data.options_above) > 0)
    {
        // Pop the last menu's data to return to it
        var _previous_menu_data = array_pop(content_data.options_above);
        
        content_data.options = _previous_menu_data.options;
        content_data.selected_option = _previous_menu_data.selected_option;
        content_data.scroll_push = _previous_menu_data.scroll_push;
        content_data.description = _previous_menu_data.description;
        content_data.sub_menu_level--; // Decrement sub-menu depth
    }
    else // If there are no more menus above, the menu is fully exited.
    {
        // This means the player has pressed 'cancel' on the top-level menu.
        // It signals obj_battle_manager to go back to the previous state (e.g., SELECT_UNIT).
        // It will also destroy this menu instance.
        // IMPORTANT: Make sure this `battle_state_transition_to` is a function in obj_battle_manager.
        with (obj_battle_manager) {
            battle_state_transition_to(BATTLE_STATE.SELECT_ACTION); // Or whatever state you want to go back to
        }
    }
}

// Ensure the `active` variable is handled correctly elsewhere (e.g., in obj_battle_manager setting it to true/false)
// Also ensure instance_destroy() is called by obj_battle_manager when menu is no longer needed (e.g., after action or transition).