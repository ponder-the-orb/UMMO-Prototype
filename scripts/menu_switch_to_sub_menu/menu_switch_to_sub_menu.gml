// scr_menu_switch_to_sub_menu(_new_options_array)
// This script is called by obj_menu when a sub-menu option is selected.
// It tells the menu to display a new set of options.

function menu_switch_to_sub_menu(_arg_array)
{
    var _new_options_array = _arg_array[0]; // The actual array of options for the sub-menu
    var _sub_menu_name = _arg_array[1]; // The name of the sub-menu (optional, for debug or specific logic)

    show_debug_message("DEBUG: Switching menu to sub-menu: " + string(_sub_menu_name) + " with " + string(array_length(_new_options_array)) + " options.");

    // Update the menu's internal content_data to reflect the new sub-menu
    with (obj_menu) // Important: call this on the obj_menu instance
    {
        // Store current options to go back
        array_push(content_data.options_above, content_data.options);
        content_data.sub_menu_level++;

        // Set new options
        content_data.options = _new_options_array;
        content_data.selected_option = 0; // Reset selection to top
        content_data.scroll_push = 0; // Reset scroll
    }
}