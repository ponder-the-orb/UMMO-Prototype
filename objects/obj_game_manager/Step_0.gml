    
 //Press F3 to toggle debug visuals (common in many games!)
if (keyboard_check_pressed(vk_f3)) {
    global.debug_mode = !global.debug_mode;
    show_debug_message("DEBUG MODE: " + (global.debug_mode ? "ON" : "OFF"));
}