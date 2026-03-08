   function menu_select_action(_arg_array)
   {
       show_debug_message("=== scr_menu_select_action IS RUNNING ===");
       show_debug_message("menu_select_action called with arg_array: " + string(_arg_array));
   
       var _user = _arg_array[0];
       var _action = _arg_array[1];
   
       show_debug_message("menu_select_action - Unpacked User: " + string(_user) + " (Name: " + string(_user.actor_data.identity.name) + ")");
       show_debug_message("menu_select_action - Unpacked Action: " + string(_action) + " (Name: " + string(_action.name) + ")");
   
       // Cleanup menu (destroy it here, as selection is done)
       if (instance_exists(obj_menu))
       {
           instance_destroy(obj_menu);
           obj_battle_manager.menu_instance = noone; // Clear reference in battle manager
           show_debug_message("menu_select_action - obj_menu destroyed.");
       }
       
       // Set battle manager variables for the upcoming action
       obj_battle_manager.current_user = _user; // Ensure current_user is correctly set for execution
       obj_battle_manager.pending_action = _action; // Store the action to be executed
       obj_battle_manager.current_action_executing = true; // Flag for execution in progress
       
       
   
   if (_action.target_required)
   {
       show_debug_message("Target required. Handing control to SELECTING_TARGET state.");
       
       // 1. Tell the manager what action we are trying to do
       obj_battle_manager.pending_action = _action;
       obj_battle_manager.current_user = _user;
       
       // 2. Start the cursor at the first target
       obj_battle_manager.cursor_index = 0; 
   
       // 3. Move to the targeting state
       obj_battle_manager.battle_state_transition_to(BATTLE_STATE.SELECTING_TARGET);
       
       show_debug_message("=== scr_menu_select_action FINISHED (Targeting Mode) ===");
       return; // EXIT. We do NOT transition to state 6 yet.
   }
   else 
   {
           // Handle "All" or "Self" targets immediately
           if (_action.target_all == MODE.ALL_ENEMIES) {
               obj_battle_manager.pending_targets = array_filter(obj_battle_manager.enemy_units, function(_u){ return _u.actor_data.body.hp > 0; });
           } 
           else if (_action.target_all == MODE.ALL_ALLIES) {
               obj_battle_manager.pending_targets = array_filter(obj_battle_manager.player_units, function(_u){ return _u.actor_data.body.hp > 0; });
           } 
           else { 
               obj_battle_manager.pending_targets = [_user]; 
           }
   
           // Multiplayer Checkpoint: 
           // Here is where you would eventually send your "Action Packet" 
           // before transitioning to EXECUTING_ACTION.
           
           obj_battle_manager.current_action_executing = true;
           obj_battle_manager.battle_state_transition_to(BATTLE_STATE.EXECUTING_ACTION);
           show_debug_message("Auto-target set. Moving to EXECUTING_ACTION."); 
       }
   }