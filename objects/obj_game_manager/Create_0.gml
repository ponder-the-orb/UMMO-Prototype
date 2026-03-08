// obj_game_manager Create Event

// --- Network Socket Initialization ---
show_debug_message("MANAGER CREATE: --- START of Game Manager Create Event ---");
show_debug_message("MANAGER CREATE: About to call network_create_socket().");

global.client_socket = network_create_socket(network_socket_udp);

// IMPORTANT: Check if socket creation was successful (0 or greater).
if (global.client_socket >= 0) { 
    show_debug_message("MANAGER CREATE: global.client_socket created SUCCESSFULLY.");
} else {

// Debug: Print the raw return value to confirm if it's successful or 'noone'
show_debug_message("MANAGER CREATE: Value of global.client_socket immediately after network_create_socket: " + string(global.client_socket));

// IMPORTANT: Check if socket creation was successful.
// If it's 'noone', it means GameMaker failed to create the socket (e.g., firewall, system issue).
if (global.client_socket != noone) { // <-- CORRECTED VALIDITY CHECK
    show_debug_message("MANAGER CREATE: global.client_socket created SUCCESSFULLY. Socket ID: " + string(global.client_socket));
} else {
    show_debug_message("MANAGER CREATE ERROR: FAILED to create global.client_socket! Returned value: " + string(global.client_socket));
    show_debug_message("MANAGER CREATE ERROR: This usually indicates a firewall blocking GameMaker from creating sockets, or a system networking issue. Game will end.");
    game_end(); // Game cannot proceed without a functional network socket.
    exit;       // Stop execution of this event.
 }
}

// --- Server Connection Details ---
// These are the IP and Port for your Node.js server.
// Use "127.0.0.1" (localhost) if server is on the same computer.
global.server_ip = "127.0.0.1";
global.server_port = 50277; // Must match Node.js server's bind port

// --- Local Player Identification ---
// Generate a unique ID for this local player instance.
// This ID is sent to the server and used to identify *this* specific client/player across the network.
global.local_player_instance_id = "gms_player_" + string(get_timer()) + "_" + string(random(999999));
show_debug_message("MANAGER CREATE: My local network ID (global.local_player_instance_id) is: " + string(global.local_player_instance_id));

// --- Remote Players Data Structure ---
// Initialize a struct (like a dictionary/map) to store all remote player instances.
// The keys will be their network IDs, and values will be references to their obj_player instances.
global.remote_players_map = {};
show_debug_message("MANAGER CREATE: global.remote_players_map initialized as struct.");

show_debug_message("MANAGER CREATE: Initializing Local Actor...");

// 1. Create the universal vessel (formerly obj_player_online)
var _local_actor = instance_create_layer(room_width / 2, room_height / 2, "Instances", obj_actor);

// 2. Identify it as the LOCAL PLAYER
_local_actor.is_local_player = true; 

// 3. Inject the "Base Actor" Struct (The Bible)
_local_actor.actor_data = scr_actor_init("HUMAN_PLAYER"); 

// 4. Tell it to "Wake Up" and put on its sprite
// Use the script instead of the object variable
scr_actor_visual_update(_local_actor);

show_debug_message("MANAGER CREATE: Actor created. ID: " + string(_local_actor.id) + " | Type: " + _local_actor.actor_data.identity.type);

// 2. Assign the globally unique network ID to this local player instance.
//    This 'my_instance_id_str' will be sent to the Node.js server.
_local_actor.my_instance_id_str = global.local_player_instance_id;
show_debug_message("MANAGER CREATE: Set _local_actor.my_instance_id_str to: " + _local_actor.my_instance_id_str);

// ADD THIS LINE: Inject the ID into the network payload so the server doesn't ignore it!
_local_actor.actor_data.net_data.network_id = global.local_player_instance_id;

// 3. Set the visual appearance for the local player (e.g., white).
//    This overrides the default red set in obj_player's Create Event.
_local_actor.image_blend = c_white;
show_debug_message("MANAGER CREATE: Set _local_actor.image_blend to c_white.");

show_debug_message("MANAGER CREATE: --- END of Game Manager Create Event ---");