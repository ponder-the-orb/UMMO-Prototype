// obj_game_manager Async - Networking Event
// This event is automatically triggered by GameMaker whenever a network event occurs
// on any socket that GameMaker is listening to. In our case, it's the 'global.client_socket'
// that we created in obj_game_manager's Create Event.
// Think of this as the game's 'network inbox' where all messages from the server arrive.

// --------------------------------------------------------------------------------------
// Section 1: Extracting Core Event Information
// --------------------------------------------------------------------------------------

// The 'async_load' variable is a special GameMaker built-in variable (a temporary ds_map)
// that contains information about the asynchronous event that just happened.
// It's like an envelope containing details about the message that just arrived.

var _socket_id = async_load[? "id"];      // The ID of the socket that received the data (should be our global.client_socket)
var _event_type = async_load[? "type"];  // The type of network event (e.g., data received, connection made, disconnection)

// IMPORTANT: We only want to process messages from *our* main client socket.
// If you had multiple sockets for different purposes, this check would filter them.
if (_socket_id != global.client_socket) {
    // If the socket ID doesn't match our main client socket, it's either an error or
    // an event from another (unintended) socket. We'll ignore it.
    show_debug_message("MANAGER RECEIVER WARNING: Async event triggered by an unexpected socket ID: " + string(_socket_id) + ". Ignoring.");
    exit; // Stop executing this event for this particular message, as it's not for us.
}

// --------------------------------------------------------------------------------------
// Section 2: Handling Different Network Event Types (Switch Statement)
// --------------------------------------------------------------------------------------

// A 'switch' statement is perfect here because we want to perform different actions
// depending on the '_event_type' (what kind of network event occurred).
switch (_event_type) {

    // --- Case 1: network_type_data ---
    // This is the most common case: we've received actual data (a message) from the server.
    case network_type_data:
        // 'buffer' contains the raw bytes of the message. We need to read from it.
        var _buffer = async_load[? "buffer"];

        // Reset the buffer's read/write position to the very beginning.
        // This is crucial to ensure we read the entire message from the start.
        buffer_seek(_buffer, buffer_seek_start, 12);

        // Read the entire message from the buffer as a string (since we're sending JSON text).
        var _raw_string = buffer_read(_buffer, buffer_string);
        //show_debug_message("MANAGER RECEIVER: Raw string from buffer: " + _raw_string);

        // Now, we'll try to parse this raw string, which we expect to be JSON,
        // into a GameMaker 'struct' (which is like a flexible object that holds key-value pairs).
        var _received_data_struct = undefined; // Initialize as 'undefined' to indicate no valid data yet.

        // Use a 'try-catch' block to gracefully handle potential errors during JSON parsing.
        // If the server sends malformed JSON, this prevents the game from crashing.
        try {
            // json_parse() converts a JSON string into a GameMaker struct (or array if JSON is an array).
            _received_data_struct = json_parse(_raw_string);
        } catch (_e) {
            // If parsing fails, log an error message to help debug.
            show_debug_message("MANAGER RECEIVER ERROR: Failed to parse JSON. Raw message: '" + _raw_string + "'. Error: " + _e.message);
            exit; // Stop processing this message; it's invalid.
        }

        // ---------------------------------------------------------------------------
        // Section 2.1: Processing the Parsed JSON Data (based on its content/type)
        // ---------------------------------------------------------------------------

        // After successfully parsing the JSON, we need to figure out what kind of message it is.
        // We do this by checking for specific keys (fields) within the received struct.

        // --- NEW Message Type: God Command (GOTO_ROOM) ---
        // We check this FIRST. If the server says "Leave the room," we don't need to process anything else.
        if (is_struct(_received_data_struct) && variable_struct_exists(_received_data_struct, "type") && _received_data_struct.type == "GOTO_ROOM") {
            var _target_room_name = _received_data_struct.room_name;
            var _target_room_id = asset_get_index(_target_room_name);
            
            if (_target_room_id != -1) {
                show_debug_message("MANAGER RECEIVER: Server ordered world-jump to: " + _target_room_name);
                room_goto(_target_room_id);
                exit; // We 'exit' the event because there is no point updating players in a room we just left!
            }
        }

        // --- Message Type A: Player States Broadcast (e.g., {"players": [...]}) ---
        // This is the most frequent message, containing the positions of all players in the game.
        // Note: We removed 'else' so it can check for room changes AND players in one packet if needed.
        if (is_struct(_received_data_struct) && variable_struct_exists(_received_data_struct, "players")) {
            var _players_array = _received_data_struct.players;
            //show_debug_message("MANAGER RECEIVER: Received player states broadcast containing " + string(array_length(_players_array)) + " players.");

            for (var i = 0; i < array_length(_players_array); i++;) {
                var _player_data = _players_array[i];

                if (!is_struct(_player_data) || !variable_struct_exists(_player_data, "network_id") || 
                    !variable_struct_exists(_player_data, "x") || !variable_struct_exists(_player_data, "y")) {
                    show_debug_message("MANAGER RECEIVER WARNING: Malformed player data in broadcast at index " + string(i) + ". Skipping this player.");
                    continue; 
                }

                var _remote_network_id_str = _player_data.network_id;
                var _remote_x = _player_data.x;
                var _remote_y = _player_data.y;

                if (_remote_network_id_str == global.local_player_instance_id) {
                    //show_debug_message("MANAGER RECEIVER: Own player (" + _remote_network_id_str + ") position echoed from server. Ignoring position update.");
                } else {
                    var _target_remote_gms_instance = noone;

                    if (variable_struct_exists(global.remote_players_map, _remote_network_id_str)) {
                        _target_remote_gms_instance = variable_struct_get(global.remote_players_map, _remote_network_id_str);
                    }

                    if (!instance_exists(_target_remote_gms_instance)) {
                        
                        // 1. Spawn the universal actor instead of the deleted obj_player_online
                        _target_remote_gms_instance = instance_create_layer(_remote_x, _remote_y, "Instances", obj_actor);
                        
                        // 2. Setup their network identity
                        _target_remote_gms_instance.is_local_player = false; 
                        _target_remote_gms_instance.my_instance_id_str = _remote_network_id_str; 
                        
                        // 3. Give them the player bible and wake them up!
                        _target_remote_gms_instance.actor_data = scr_actor_init("HUMAN_PLAYER");
                        scr_actor_visual_update(_target_remote_gms_instance);

                        variable_struct_set(global.remote_players_map, _remote_network_id_str, _target_remote_gms_instance);
                        show_debug_message($"MANAGER RECEIVER: Created new remote player instance for Network ID: {_remote_network_id_str}");
                    }
                    

                    if (instance_exists(_target_remote_gms_instance)) {
                        _target_remote_gms_instance.x = _remote_x;
                        _target_remote_gms_instance.y = _remote_y;
                    }
                }
            } 
        }

// --- Enemy States ---
        if (is_struct(_received_data_struct) && variable_struct_exists(_received_data_struct, "enemies")) {
            var _enemies_array = _received_data_struct.enemies;
            
            // Build a set of IDs the server just sent us
            var _server_ids = {};
            for (var j = 0; j < array_length(_enemies_array); j++) {
                variable_struct_set(_server_ids, _enemies_array[j].id, true);
            }
            
            // Destroy any local enemy the server didn't include (it's dead)
            with (obj_actor) {
                if (!is_local_player && variable_instance_exists(id, "my_instance_id_str")) {
                    if (string_starts_with(my_instance_id_str, "goblin")) {
                        if (!variable_struct_exists(_server_ids, my_instance_id_str)) {
                            instance_destroy(id);
                        }
                    }
                }
            }
            
            for (var j = 0; j < array_length(_enemies_array); j++) {
                var _e_data = _enemies_array[j];
                var _enemy_exists = false;
                
                with (obj_actor) { 
                    if (variable_instance_exists(id, "my_instance_id_str") && my_instance_id_str == _e_data.id) {
                        actor_data.body.hp = _e_data.hp; 
                        in_combat = (_e_data.status == "IN_BATTLE");
                        image_alpha = 1.0; 
                        _enemy_exists = true;
                    }
                }
                
                if (!_enemy_exists && _e_data.status != "DEAD") {
                    var _new_goblin = instance_create_layer(_e_data.x, _e_data.y, "Instances", obj_actor);
                    _new_goblin.is_local_player = false;
                    _new_goblin.my_instance_id_str = _e_data.id;
                    _new_goblin.actor_data = scr_actor_init("goblin");
                    scr_actor_visual_update(_new_goblin);
                    show_debug_message("SERVER SPAWN: Materialized " + _e_data.id + " from server data!");
                }
            }
        }
        

        // --- Message Type B: Initial Connection Confirmation ---
        if (is_struct(_received_data_struct) && variable_struct_exists(_received_data_struct, "status")) {
            var _status = _received_data_struct.status;
            var _server_assigned_network_id = _received_data_struct.your_instance_id;
            show_debug_message("MANAGER RECEIVER: Server confirmation: " + _status + ", for: " + string(_server_assigned_network_id));
        }

        // --- Message Type C: Player Disconnected ---
        if (is_struct(_received_data_struct) && variable_struct_exists(_received_data_struct, "type") && _received_data_struct.type == "player_removed") {
            var _disconnected_network_id_str = _received_data_struct.network_id;
            if (variable_struct_exists(global.remote_players_map, _disconnected_network_id_str)) {
                var _instance_to_destroy = variable_struct_get(global.remote_players_map, _disconnected_network_id_str);
                if (instance_exists(_instance_to_destroy)) {
                    instance_destroy(_instance_to_destroy);
                }
                variable_struct_remove(global.remote_players_map, _disconnected_network_id_str);
            }
        }
        
        break; 

    // --- Case 2: network_type_connect ---
    case network_type_connect:
        show_debug_message("MANAGER RECEIVER: Network connection event received.");
        break;

    // --- Case 3: network_type_disconnect ---
    case network_type_disconnect:
        show_debug_message("MANAGER RECEIVER: Disconnected from server. All remote players will be cleared.");
        var _player_network_ids_to_clear = variable_struct_get_names(global.remote_players_map);
        for (var k = 0; k < array_length(_player_network_ids_to_clear); k++) {
            var _network_id = _player_network_ids_to_clear[k];
            var _gms_instance_id = variable_struct_get(global.remote_players_map, _network_id);
            if (instance_exists(_gms_instance_id)) {
                instance_destroy(_gms_instance_id);
            }
        }
        global.remote_players_map = {};
        break;

    default:
        show_debug_message("MANAGER RECEIVER WARNING: Unhandled network event type: " + string(_event_type));
        break;
}