// scr_game_init


global.version = "PreAlpha 1.14";
global.dev_mode = true;

//Set the Screen Resolution
global.res_height = 640;
global.res_width = 360;
global.res_scale = 1;

//Scale to adjust
window_set_size(res_height * res_scale, res_width * res_scale);
surface_resize(application_surface, 640 * res_scale, 360 * res_scale);
display_set_gui_size(640, 360); // Keeps your UI sharp and easy to place


//Force layer depth for 2.5D 
layer_force_draw_depth(true, 0);

//Set the in game time, will actually use node.js server?
global.world_clock = {
    day: 1,
    hour: 8,    // 0 to 23 (Military Time)
    minute: 0,  // 0 to 59
    second: 0,
    time_speed: 1, // How many minutes pass per real-world second
    is_paused: false
};

global.debug_mode = false; // Set to true so you can see your cones immediately!

// This script initializes global game variables at the start of the game.
global.in_battle = false; // Initialize the battle state flag to false (no battle active yet).

// Initialize global battle variables
global.selected_target = noone;


//Draw Actors on map already?

function scr_actor_visual_update(_inst) {
    var _d = _inst.actor_data;
    if (_d != noone) {
        _inst.sprite_index = _d.sprites.idle;
        _inst.image_xscale = (_d.identity.type == "HUMAN_PLAYER") ? 1 : -1;
        _inst.visible = true;
    }
}