draw_set_alpha(1);
draw_set_color(c_white);

// Add a check to see if the variable even exists yet
if (!variable_instance_exists(id, "current_user") || current_user == noone) exit;

// We need the camera coordinates to convert Room X/Y to GUI X/Y
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);

// DEBUG: Draw ATB bars above heads
for (var i = 0; i < array_length(units); i++) {
    var _u = units[i];
    
    if (instance_exists(_u)) {
        
        // 1. Sync the coordinates! (Room Position - Camera Position)
        var _draw_x = _u.x - _cx;
        var _draw_y = _u.y - _cy;
        
        // 2. The Color Swap! (Blue for players, Red for enemies)
        var _bar_color = c_red;
        if (_u.actor_data.is_player) {
            _bar_color = c_aqua; 
        }

        // 3. Draw the bar using the synced coordinates and dynamic colors
        draw_healthbar(_draw_x - 20, _draw_y - 50, _draw_x + 20, _draw_y - 45, _u.atb_value, c_black, _bar_color, _bar_color, 0, true, true);
    }
}