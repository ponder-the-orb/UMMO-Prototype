if (!active) exit;
var _mgr = obj_battle_manager;

// 1. LOCAL DATA (Grabbing our pre-calculated folders)
var _options = content_data.options;
var _sel_index = content_data.selected_option;
var _width = layout_settings.width_full;
var _height = layout_settings.height_full;
var _margin = layout_settings.x_margin;
var _line_h = layout_settings.height_line;

// 2. DRAW THE MENU'S OWN BOX
// We use the 'x' and 'y' of the object, which the Manager already set!
draw_sprite_stretched(spr_box, 0, x, y, _width, _height);

// 3. SELECTION BAR (The highlight)
var _sel_y = y + layout_settings.y_margin + (_sel_index * _line_h);
draw_set_color(c_dkgray);
draw_rectangle(x + 4, _sel_y, x + _width - 4, _sel_y + _line_h, false);

// 4. DRAW OPTIONS
draw_set_font(fnM5x7);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

for (var i = 0; i < array_length(_options); i++) {
    var _opt_y = y + layout_settings.y_margin + (i * _line_h);
    draw_text(x + _margin, _opt_y, _options[i].name);
}

// 5. DRAW THE SELECTOR HAND
// Floating just to the left of the current selection
draw_sprite(spr_selector, 0, x - layout_settings.cursor_padding, _sel_y + (_line_h / 2));