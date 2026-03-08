// --- obj_battle_manager DRAW ---
var cx = camera_get_view_x(view_camera[0]);
var cy = camera_get_view_y(view_camera[0]);

//  1. Target Selector
if (battle_state == BATTLE_STATE.SELECTING_TARGET) {
   // 2. Get the current list of who is actually alive
var _targets = (pending_action.target_enemy_by_default) ? enemy_units : player_units;
var _living_targets = array_filter(_targets, function(_u) { return _u.actor_data.body.hp > 0; });

// 3. Only draw if there's someone to point at
if (array_length(_living_targets) > 0) {
    // Safety check the index again
    var _clamped_index = clamp(cursor_index, 0, array_length(_living_targets) - 1);
    var _target_inst = _living_targets[_clamped_index];
    
    // 4. Draw the cursor at the target's current position
    // (Subtract 40 from x to put the hand to the left of the goblin)
    draw_sprite(spr_selector, 0, _target_inst.x - 40, _target_inst.y);
    }
}


var _clock_text = scr_get_clock_string();
draw_text(20, 20, "Day " + string(global.world_clock.day) + " - " + _clock_text);