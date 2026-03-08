function scr_draw_version_tag() {
    // We want to draw our version global. 
    // Remember: To combine a Word (String) with a Variable, we use the + sign.
    draw_set_font(fnM5x7);
    draw_set_halign(fa_top);
    draw_set_valign(fa_left);
    draw_set_colour(c_white)
    
    
    // THE MATH: 
    // X = The far right edge of the screen minus a small gap
    // Y = The very bottom edge of the screen minus a small gap
    
    var _x_pos = global.res_width - 40;
    var _y_pos = global.res_height - 40;
    
    var new_string = "Ver: " + global.version;
    //draw_text(10, 10, "Current Version: " + global.version);
    
    draw_text(_x_pos, _y_pos, new_string);
    
    //show_debug_message(new_string)
}
    
    
