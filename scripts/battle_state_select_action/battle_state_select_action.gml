// battle_state_select_action
function battle_state_select_action()
{
    show_debug_message("=== scr_battle_state_select_action IS RUNNING ===");
    show_debug_message("DEBUG BATTLE STATE SELECT ACTION: obj_battle_manager.current_user value: " + string(obj_battle_manager.current_user));
    show_debug_message("DEBUG BATTLE STATE SELECT ACTION: Does obj_battle_manager.current_user exist? " + string(instance_exists(obj_battle_manager.current_user)));
    show_debug_message("BATTLE STATE SELECT ACTION: current_user.actions before loop: " + string(obj_battle_manager.current_user.actions));
    show_debug_message("BATTLE STATE SELECT ACTION: current_user.actions array length: " + string(array_length(obj_battle_manager.current_user.actions)));
    if (obj_battle_manager.current_user.is_player_character)
    {
        show_debug_message("BATTLE STATE SELECT ACTION: Current user IS player character.");
        show_debug_message("BATTLE STATE SELECT ACTION: Bypassing instance_exists check. Proceeding to create menu.");

        // Build the menu options dynamically based on the current player unit's actions
        var _menu_options = []; // This will hold the options for the MAIN menu
        var _sub_menus = {};    // This will hold structs for sub-menus (e.g., _sub_menus.Magic = [Ice, Fire])

        var _actionList = obj_battle_manager.current_user.actions; // Get the unit's actions

        for (var i = 0; i < array_length(_actionList); i++)
        {
            var _action = _actionList[i]; // Get the current action struct (e.g., Attack, Ice)
            show_debug_message("DEBUG BEFORE _action.name: i=" + string(i) + ", _action type: " + typeof(_action) + ", _action value: " + string(_action));
            var _nameAndCount = _action.name; // This will be "Attack" or "Ice"
            var _available = true; // Assume available for now

            // Check if this action belongs to a sub-menu
            // IMPORTANT: If you want "Fight" to be a top-level option, global.action_library.attack.sub_menu MUST be noone or -1.
            // Currently, it's "Fight", so it will fall into the ELSE block.
            if (_action.sub_menu == noone || _action.sub_menu == -1)
            {
                 show_debug_message("DEBUG: Entering TOP-LEVEL action block for action: " + _action.name); // Add this
                // This is a TOP-LEVEL action (like "Fight" if it's not a sub_menu, or "Escape")
                array_push(_menu_options, {
                    text: _nameAndCount, // e.g., "Attack" (if sub_menu is noone)
                    action: menu_select_action, // Function to handle selecting this action
                    arg: [obj_battle_manager.current_user, _action],
                    enabled: _available,
                    // Add icon and tooltip properties here if they exist in _action
                    //icon: _action.icon, // Assuming _action.icon exists
                    //tooltip: string_format(_action.description, obj_battle_manager.current_user.name) // Assuming _action.description exists
                });
            }
            else
            {
                 show_debug_message("DEBUG: Entering SUB-MENU action block for action: " + _action.name);
                // This action belongs to a SUB-MENU (e.g., "Ice" spell belongs to "Magic" sub-menu)
                var _sub_menu_name = _action.sub_menu; // e.g., "Magic"

                // IMPORTANT: If this is the FIRST time we encounter an action for this sub-menu
                // (e.g., the first spell for the "Magic" menu), we need to create the main menu option
                // that will *lead* to this sub-menu (e.g., the "Magic" button itself).
                if (!variable_struct_exists(_sub_menus, _sub_menu_name))
                {
                    // Initialize the array that will hold the specific options for this sub-menu (e.g., [Ice, Fire])
                    variable_struct_set(_sub_menus, _sub_menu_name, []);

                    // NOW, ADD THE TOP-LEVEL MENU OPTION FOR THIS SUB-MENU TO THE MAIN MENU OPTIONS
                    // This is the option that will appear on the main screen (e.g., "Magic" button)
                    array_push(_menu_options, {
                        text: _sub_menu_name, // The text for the main menu option (e.g., "Magic")
                        action: menu_switch_to_sub_menu, // This action will switch the menu to the sub-menu
                        // The arg for change_menu should be the array of options for the sub-menu
                        arg: variable_struct_get(_sub_menus, _sub_menu_name),
                        enabled: true,
                        // Add icon and tooltip for the sub-menu button itself if desired
                    });
                }

                // Now that we've ensured the top-level sub-menu option exists,
                // add the specific action (e.g., "Ice") to its respective sub-menu array.
                var _target_sub_menu_array = variable_struct_get(_sub_menus, _sub_menu_name);
                array_push(_target_sub_menu_array, {
                    text: _nameAndCount, // e.g., "Ice"
                    action: menu_select_action, // This handles selecting the specific action
                    arg: [obj_battle_manager.current_user, _action], // Pass user and action
                    enabled: _available,
                    // Add icon and tooltip from the _action struct here
                    //icon: _action.icon, // Assuming _action.icon exists
                    //tooltip: string_format(_action.description, obj_battle_manager.current_user.name) // Assuming _action.description exists
                });
            }
        }

        // --- Debug Messages for _menu_options array ---
        show_debug_message("BATTLE STATE SELECT ACTION: _menu_options array length BEFORE create_menu: " + string(array_length(_menu_options)));
        for (var i = 0; i < array_length(_menu_options); i++)
        {
            show_debug_message("  Option " + string(i) + ": Text='" + _menu_options[i].text + "'");
        }
        // --- End of Debug Messages ---

        current_menu = create_menu( // Assign to current_menu (assuming it's a global or obj_battle_manager var)
            obj_battle_manager.current_user.x - 20, // Adjust position as needed
            obj_battle_manager.current_user.y + 30, // Adjust position as needed
            _menu_options, // Pass the now populated _menu_options
            "Choose Action"
        );

        if (instance_exists(obj_menu)) // obj_menu is created by scr_create_menu
        {
            obj_menu.active = true;
            obj_menu.user = obj_battle_manager.current_user; // Assign the user to the menu
            show_debug_message("BATTLE STATE SELECT ACTION: obj_menu activated. Current active status: " + string(obj_menu.active));
        }
        else
        {
            show_debug_message("BATTLE STATE SELECT ACTION: ERROR! obj_menu did not get created by create_menu function.");
        }
        show_debug_message("BATTLE STATE SELECT ACTION: Setting battle_state to battle_state_player_input.");
        

      
    }
    else 
    {
        show_debug_message("BATTLE STATE SELECT ACTION: Current user is NOT player character. Skipping menu creation.");
    }
}