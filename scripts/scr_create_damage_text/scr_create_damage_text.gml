function scr_create_damage_text(_x, _y, _str, _col){
    var _t = instance_create_depth(_x, _y, -1000, obj_battle_effect);
    _t.text = _str;
    _t.color = _col;
}