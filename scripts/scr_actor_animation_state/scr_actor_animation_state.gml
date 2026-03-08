function scr_actor_animation_state() {
    // Safety check: Don't animate if we have no data
    if (actor_data == noone) exit;

    switch (state) {
        case "IDLE":
            sprite_index = actor_data.sprites.idle;
            break;
            
        case "BATTLE":
            // Use combat idle if it exists, otherwise fall back to normal idle
            if (variable_struct_exists(actor_data.sprites, "idle_combat")) {
                sprite_index = actor_data.sprites.idle_combat;
            } else {
                sprite_index = actor_data.sprites.idle;
            }
            break;
            
        case "MOVE":
            sprite_index = actor_data.sprites.walk;
            break;
    }
}