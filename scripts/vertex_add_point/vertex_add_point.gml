/// @function vertex_add_point(vbuffer, xx, yy, zz, nx, ny, nz, utex, vtex, color, alpha)
/// @param vbuffer
/// @param xx
/// @param yy
/// @param zz
/// @param nx
/// @param ny
/// @param nz
/// @param utex
/// @param vtex
/// @param color
/// @param alpha
function vertex_add_point(_vbuffer, _xx, _yy, _zz, _nx, _ny, _nz, _utex, _vtex, _color, _alpha) {
    
    // We use the names from the parentheses above directly
    vertex_position_3d(_vbuffer, _xx, _yy, _zz); 
    vertex_normal(_vbuffer, _nx, _ny, _nz);
    vertex_texcoord(_vbuffer, _utex, _vtex);
    vertex_colour(_vbuffer, _color, _alpha);
    
}