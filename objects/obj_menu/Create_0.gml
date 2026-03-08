show_debug_message("obj_menu create event fired, My ID: " + string(id));

// 1. DATA FOLDERS
content_data = {
    options: [],
    selected_option: 0,
    description: "",
    scroll_push: 0,    // Added this for safety
    scrolling: false   // Added this for safety
};

layout_settings = {
    x_margin: 8,
    y_margin: 8,
    height_line: 12,
    cursor_padding: 1,
    visible_options_max: 5 // Added this! The "Safe Default"
};

// 2. STATE
active = false; 
current_user = noone;
depth = -10000;

// 3. THE "SETUP" TOOL
setup_actions = function(_actions_list, _desc = -1)
{
    content_data.options = _actions_list;
    content_data.description = _desc;
    content_data.selected_option = 0;
    content_data.scroll_push = 0;

    // Calculate if we need to scroll
    content_data.scrolling = (array_length(content_data.options) > layout_settings.visible_options_max);
    
    active = true; // The menu is now "turned on"
    
    show_debug_message("Menu Setup Complete with " + string(array_length(_actions_list)) + " options.");

    // --- THE TAPE MEASURE (Moved from Script to here) ---
    var _max_w = 0;
    
    // 1. Measure the description (if there is one)
    if (_desc != -1) {
        _max_w = string_width(_desc);
    }
    
    // 2. Measure every option in the new list
    for (var i = 0; i < array_length(_actions_list); i++) {
        var _item_w = string_width(_actions_list[i].name);
        _max_w = max(_max_w, _item_w);
    }
    
    // 3. Update the layout folder with the new width
    layout_settings.width_full = _max_w + (layout_settings.x_margin * 2);
    
    // 4. Measure the Height
    // Math: (Number of items + 1 if there's a description) * height of a line + top/bottom margins
    var _menu_height_count = array_length(_actions_list);
    if (_desc != -1) _menu_height_count += 1;

layout_settings.height_full = (_menu_height_count * layout_settings.height_line) + (layout_settings.y_margin * 2); //Margin padding
    
};