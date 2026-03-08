function clean_dead_units() {
    with (obj_battle_manager) {
        for (var i = 0; i < array_length(units); i++) {
            var _u = units[i];
            if (instance_exists(_u) && _u.actor_data.body.hp <= 0) {
                instance_destroy(_u);
            }
        }
        var _is_alive = function(_u) { 
            return instance_exists(_u) && _u.actor_data.body.hp > 0; 
        };
        units = array_filter(units, _is_alive);
        unit_turn_order = array_filter(unit_turn_order, _is_alive);
        
        show_debug_message("Bones Cleaned: Arrays updated to living units only.");
    }
}




 
