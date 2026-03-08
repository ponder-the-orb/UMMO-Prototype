function create_menu(_x, _y, _options, _description = -1, _width = undefined, _height = undefined)
{
    // 1. Spawn the object
    var _inst = instance_create_depth(_x, _y, -10000, obj_menu);
    
    
    with (_inst) // We are now "Inside" the menu
    {
        setup_actions(_options, _description);
        
        // 'current_user' is the MENU's variable.
        // 'other.current_user' in the MANAGER's variable.
        current_user = other.current_user;
    }

    
    // 2. Use 'with' to talk to it
    with (_inst)
    {
        setup_actions(_options, _description);
        
        // IMPORTANT: If we specifically told the script to be a certain size,
        // we override the "Tape Measure" math here.
        if (_width != undefined)  layout_settings.width_full = _width;
        if (_height != undefined) layout_settings.height_full = _height;
    } 
    
    return _inst; 
}