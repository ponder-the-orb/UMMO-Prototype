//Set up camera
cam = view_camera[0];
follow = obj_actor;
buff = 32;
viewWHalf = camera_get_view_width(cam) * 0.5;
viewHHalf = camera_get_view_height(cam) * 0.5;
xTo = xstart;
yTo = ystart;
display_set_gui_size(640,360);

window_set_size(1600, 900);
surface_resize(application_surface, 1600, 900);
window_center();