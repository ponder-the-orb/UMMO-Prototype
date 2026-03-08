// obj_actor Step Event
if (actor_data == noone) exit;

scr_actor_animation_state();

if (is_local_player) {
    scr_actor_control_local();
} else {
    if (state == "IDLE" || state == "MOVE") {
    scr_actor_ai_logic();
    }
}