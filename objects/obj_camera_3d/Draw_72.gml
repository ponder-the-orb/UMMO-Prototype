show_debug_message("CAMERA DRAW BEGIN FIRING");

var _player = noone;
with (obj_actor) {
    if (is_local_player) {
        _player = id;
        break;
    }
}

if (_player == noone) exit; // no local actor yet, skip

var _x2 = _player.x;
var _y2 = _player.y;
var _z2 = 0;

var _xfrom = _player.x;
var _yfrom = _player.y - 600;
var _zfrom = 600;

var _cam = camera_get_active();

camera_set_view_mat(_cam, matrix_build_lookat(
    _xfrom, _yfrom, _zfrom,
    _x2, _y2, _z2,
    0, 0, -1
));

camera_set_proj_mat(_cam, matrix_build_projection_perspective_fov(
    -20, -window_get_width() / window_get_height(), 1, 1000
));

camera_apply(_cam);