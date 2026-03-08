// Make it pulse (this is the secret sauce)
var _pulse = 1 + sin(get_timer() * 0.000005) * 0.1;

// 1. Turn OFF Depth Writing (The light won't block 3D objects)
gpu_set_zwriteenable(false);
gpu_set_ztestenable(false); 

// 2. Turn ON Additive Mode
gpu_set_blendmode(bm_add);

// 3. Position it - let's put it at Z = 1 so it's slightly ABOVE the floor
var _m = matrix_build(x, y, 1, 0, 0, 0, 2, 2, 1); 
matrix_set(matrix_world, _m);

// 4. Draw that soft white/orange cookie
draw_sprite_ext(spr_light_glow, 0, 0, 0, 1, 1, 0, c_orange, 0.5);

// 5. RESET EVERYTHING (Reset to normal 3D rules)
matrix_set(matrix_world, matrix_build_identity());
gpu_set_blendmode(bm_normal);
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);