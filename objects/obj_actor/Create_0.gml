// --- obj_actor CREATE EVENT ---
actor_data = noone;
is_local_player = false;
my_instance_id_str = "";
state = "IDLE"; 
image_blend = c_white;
atb_value = 0; // The ATB bar lives here
is_moving = false; // Everyone starts still!
is_flanked = false;
can_be_sneak_attacked = false;
ghost_x = x;
ghost_y = y;
ghost_alpha = 0;

home_x = x;
home_y = y;

// We don't need init_stats() anymore because scr_actor_init does it all

// THIS IS THE IMPORTANT PART:
if (is_local_player) {
    actor_data = scr_actor_init("PLAYER"); // Or "PLAYER", whatever you named it in init
} else {
    actor_data = noone; // NPCs get their data when spawned via the S key
}