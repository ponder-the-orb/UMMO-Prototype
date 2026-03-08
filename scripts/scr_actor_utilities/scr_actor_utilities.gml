function scr_calculate_flanking(_source, _target) {
    var _dir_to_target = point_direction(_source.x, _source.y, _target.x, _target.y);
    var _target_facing = _target.actor_data.perception.facing_direction;
    
    // Check the angle difference between where the target is looking 
    // and where the attack is coming from
    var _diff = abs(angle_difference(_target_facing, _dir_to_target));
    
    // If the difference is > 90, the source is behind/beside the target
    return (_diff > 90);
}

function scr_calculate_noise(_h, _v, _is_crouching) {
    if (_h == 0 && _v == 0) return 0;
    return _is_crouching ? 0.4 : 1.0;
}

// This lives in a Script Asset file
function scr_get_modified_speed(_base_speed) {
    var _final_speed = _base_speed;

    // 1. Check the global weather "folder"
    if (global.weather == "SNOW") {
        // 2. Do the math
        _final_speed = _base_speed * 0.5; 
    }
    
    // 3. Hand the answer back to whoever asked
    return _final_speed;
}