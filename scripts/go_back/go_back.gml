/// @function scr_go_back(target_menu_instance)
/// @param {Id.Instance} target_menu_instance The ID of the obj_menu instance to navigate back
function go_back(_target_menu_instance)
{
    with (_target_menu_instance)
    {
        sub_menu_level--;
        content_data.options = content_data.options_above[sub_menu_level];
        hover = 0;

        // Recalculate dimensions for the returned menu
        content_data.visible_options_max = array_length(content_data.options);
        var _options_count = array_length(content_data.options);
        layout_settings.width = 1;
        // Recalculate width based on new options
        for (var i = 0; i < _options_count; i++) {
            layout_settings.width = max(layout_settings.width, string_width(content_data.options[i].text));
        }
        layout_settings.width_full = layout_settings.width + layout_settings.x_margin * 2;

        layout_settings.height = layout_settings.height_line * (_options_count + !(content_data.description == -1));
        layout_settings.height_full = layout_settings.height + layout_settings.y_margin * 2;

        // Re-evaluate scrolling if applicable for the new menu
        var _content_height_needed = layout_settings.height_line * (content_data.visible_options_max + !(content_data.description == -1));
        if (_content_height_needed > (layout_settings.height_full - (layout_settings.y_margin * 2)))
        {
            scrolling = true;
            content_data.visible_options_max = (layout_settings.height_full - layout_settings.y_margin * 2) div layout_settings.height_line;
        } else {
            scrolling = false;
        }
    }
}