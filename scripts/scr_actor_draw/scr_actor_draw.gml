// --- MASTER CONTROLLER ---
// This is the only one you call in the obj_actor Draw Event
function scr_actor_draw() {
    if (actor_data == noone) { draw_self(); exit; }

    scr_actor_draw_body(); 

    if (is_local_player) {
        scr_actor_draw_radar(); 
    }

    if (global.debug_mode) {
        scr_draw_actor_debug(); 
        scr_draw_actor_stats(); 
    }
}
 /*
// --- BOX 1: PHYSICAL BODY ---
function scr_actor_draw_body() {
    if (is_local_player) {
        draw_self();
    } 
    else {
        var _p = noone;
        with (obj_actor) { if (is_local_player) _p = id; }
        
        var _can_be_seen = false;
        if (_p != noone) {
            var _dist = point_distance(_p.x, _p.y, x, y);
            var _dir_to_me = point_direction(_p.x, _p.y, x, y);
            var _angle_diff = abs(angle_difference(_p.actor_data.perception.facing_direction, _dir_to_me));
            
            if (_dist < _p.actor_data.perception.view_distance && _angle_diff < _p.actor_data.perception.view_angle / 2) {
                _can_be_seen = true;
            }
        } else { _can_be_seen = true; }

        if (_can_be_seen) {
            draw_self();
        } else if (ghost_alpha > 0.1) {
            var _ghost_color = (actor_data.identity.faction == "WILD") ? c_red : c_white;
            draw_sprite_ext(sprite_index, image_index, ghost_x, ghost_y, image_xscale, image_yscale, 0, _ghost_color, ghost_alpha);
        }
    }
}
 * */

// --- BOX 1: PHYSICAL BODY ---
function scr_actor_draw_body() {
    // We are disabling the line-of-sight math for now.
    // Everyone is always visible!
    draw_self(); 
}

// --- BOX 2: RADAR ---
function scr_actor_draw_radar() {
    if (keyboard_check(ord("O"))) {
        var _range = 150 + ((actor_data.body.stats[$ "awareness"] ?? 5) * 40);
        draw_set_alpha(0.15);
        draw_circle_color(x, y, _range, c_aqua, c_black, false);
        draw_set_alpha(0.6);
        draw_circle_color(x, y, _range, c_aqua, c_white, true);
        draw_set_alpha(1.0);
        draw_text(x - 50, y + 20, "RADAR: " + string(_range));
    }
}

// --- BOX 3: DEBUG CONES ---
function scr_draw_actor_debug() {
    var _v_dist  = actor_data.perception.view_distance;
    var _v_angle = actor_data.perception.view_angle;
    var _v_dir   = actor_data.perception.facing_direction;
    var _cone_color = actor_data.perception.is_alert ? c_red : c_yellow;
    
    draw_set_alpha(0.15);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(x, y, _cone_color, 0.4);
    for (var i = -_v_angle/2; i <= _v_angle/2; i += 5) {
        draw_vertex_color(x + lengthdir_x(_v_dist, _v_dir + i), y + lengthdir_y(_v_dist, _v_dir + i), _cone_color, 0);
    }
    draw_primitive_end();
    
    var _h_range = actor_data.perception.hearing_range;
    draw_set_alpha(0.3);
    draw_circle_color(x, y, _h_range, c_white, c_white, true);
    draw_set_alpha(1.0);
}

// --- BOX 4: TAB STATS ---
function scr_draw_actor_stats() {
    if (keyboard_check(vk_tab)) {
        var _dx = x + 40; var _dy = y - 100;
        draw_set_alpha(0.8);
        draw_rectangle_color(_dx-5, _dy-5, _dx+130, _dy+85, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
        draw_text_color(_dx, _dy, "NAME: "+string(actor_data.identity.name), c_aqua, c_aqua, c_white, c_white, 1);
        draw_text(_dx, _dy+15, "MASS: "+string(actor_data.body.mass));
        draw_text(_dx, _dy+30, "AWARE: "+string(actor_data.body.stats.awareness));
        draw_text(_dx, _dy+45, "HEAR: "+string(actor_data.perception.hearing_range));
        draw_set_alpha(1.0);
    }
}