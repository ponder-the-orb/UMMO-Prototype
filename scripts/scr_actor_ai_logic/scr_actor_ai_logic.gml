function scr_actor_ai_logic() {
    var _p = noone;
    with (obj_actor) { if (is_local_player) _p = id; }
    if (_p == noone) exit;

    var _dist = point_distance(x, y, _p.x, _p.y);
    var _dir_to_p = point_direction(x, y, _p.x, _p.y);
    
    // 1. PERCEPTION
    var _angle_diff = abs(angle_difference(actor_data.perception.facing_direction, _dir_to_p));
    var _can_hear = (_dist < (actor_data.perception.hearing_range * _p.current_noise_level));
    var _can_see = (_dist < actor_data.perception.view_distance && _angle_diff < actor_data.perception.view_angle / 2);

    // 2. TACTICAL STATUS (Using Utilities)
    is_flanked = scr_calculate_flanking(_p, id);
    can_be_sneak_attacked = (_dist < 50 && !actor_data.perception.is_alert && is_flanked);

    // 3. STATE UPDATES
    if (_can_hear || _can_see) {
        actor_data.perception.is_alert = true;
        state = "BATTLE";
        actor_data.perception.facing_direction = _dir_to_p;
    }
}