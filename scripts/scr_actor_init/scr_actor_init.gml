function scr_actor_init(_type, _overrides = {}) {
    // 1. DEFAULT TEMPLATE
    var _data = {
        identity: { type: _type, name: "Unknown", faction: "WILD" },
        body: { hp: 10, max_hp: 10, hunger: 100, max_hunger: 100,mass: 70, height: 1.0, stats: { strength: 1, defense: 1, speed: 1, awareness: 1 } },
        
        // --- THE MISSING FOLDER ---
        perception: {
            view_distance: 200,
            view_angle: 90,
            hearing_range: 100,
            facing_direction: 0, // This is the "eyes" direction
            is_alert: false
        },
        
        sprites: { idle: spr_player_idle, attack: spr_player_attack, down: spr_player_downed },
        actions: [], 
        is_player: false,
        net_buffer: noone,
        net_data: {}
    };

    // 2. FETCH FROM YOUR LIBRARIES
    if (_type == "HUMAN_PLAYER") {
        var _lib = global.local_player_stats;
        _data.identity.name = _lib.name;
        _data.is_player = true;
        _data.body.hp = _lib.hp;
        _data.body.max_hp = _lib.max_hp;
        _data.body.stats = _lib.stats;
        _data.body.hunger = _lib.hunger;
        _data.body.max_hunger = _lib.max_hunger;
        _data.body.mass = _lib.mass;
        _data.body.height = _lib.height;
        
        
        // This won't crash now!
        _data.perception.view_distance = _lib.perception_data.view_distance;
        _data.perception.view_angle = _lib.perception_data.view_angle;
        _data.perception.hearing_range = _lib.perception_data.hearing_range;
        
        _data.actions = _lib.actions; 
        _data.sprites.idle = _lib.sprites_data.idle;
        
        _data.net_buffer = buffer_create(256, buffer_grow, 1);
        
        // Added 'facing' here so the server is ready for it!
        _data.net_data = { type: "POSITION_UPDATE", x: 0, y: 0, facing: 0, network_id: "" };
    }
    
    if (_type == "goblin") {
        var _lib = global.enemies.enemy_goblin;
        _data.identity.name = _lib.name;
        _data.body.hp = _lib.hp;
        _data.body.max_hp = _lib.max_hp;
        _data.body.stats = _lib.stats;
        _data.body.mass = _lib.mass;
        _data.body.height = _lib.height;
        
        // Copying goblin senses
        _data.perception.view_distance = _lib.perception_data.view_distance;
        _data.perception.view_angle = _lib.perception_data.view_angle;
        _data.perception.hearing_range = _lib.perception_data.hearing_range;
        
        _data.actions = _lib.actions; 
        _data.sprites.idle = _lib.sprites_data.idle;
    }

    // 3. APPLY OVERRIDES
    var _keys = variable_struct_get_names(_overrides);
    for (var i = 0; i < array_length(_keys); i++) {
        var _key = _keys[i];
        _data[$ _key] = _overrides[$ _key];
    }

    return _data;
}   