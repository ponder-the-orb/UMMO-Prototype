
// --- 1. ACTION LIBRARY ---
global.action_library = {
    attack: {
        name: "Attack",
        description: "Strike a single foe.",
        sub_menu: -4,
        enabled: true, 
        target_required: true,
        target_enemy_by_default: true,
        user_animation: "attack",
        action: function (_user, _targets) {
            var _target = _targets[0];
            var _damage = _user.actor_data.body.stats.strength;
            
            // --- LIVE TACTICAL CHECK ---
            var _dist = point_distance(_user.x, _user.y, _target.x, _target.y);
            
            // 1. Check for Ambush (Close + Behind + Not Alert)
            if (_dist < 60 && _target.can_be_sneak_attacked) {
                _damage *= 5;
                effect_create_above(ef_explosion, _target.x, _target.y, 0, c_orange);
                show_debug_message("BATTLE: LIVE AMBUSH CALCULATED!");
            } 
            // 2. Check for Flanking (Just Behind/Side)
            else if (_target.is_flanked) {
                _damage *= 1.5;
                show_debug_message("BATTLE: LIVE FLANK CALCULATED!");
            }

            apply_damage(_user, _target, _damage);
        }
    }
};

// --- 2. SUB-MENU DATA ---
// We define this first so we can put it INSIDE the player's actions
var _skill_submenu = {
    description: "Select a Skill",
    options: [
        { name: "Fireball", action: menu_select_action, sub_menu: -4, target_required: true, description: "Burn!", enabled: true },
        { name: "Heal",     action: menu_select_action, sub_menu: -4, target_required: true, description: "Mend!",  enabled: true }
    ]
};

// --- 3. PLAYER DATA (The Adventurer) ---
global.local_player_stats = {
    name: "Adventurer",
    is_player_character: true,
    hp: 20,
    max_hp: 20,
    mp: 10,
    max_mp: 10,
    hunger: 100,
    thirst: 100,
    max_thirst: 100,
    max_hunger: 100,
    mass: 70,       // How heavy/loud they are
    height: 1.0,
    perception_data: { 
        view_distance: 250, 
        view_angle: 90, 
        hearing_range: 120 
    },
    stats: { strength: 2, defense: 1, speed: 3, awareness: 1 },
    sprites_data: { idle: spr_player_idle, attack: spr_player_attack },
    
    // THIS ARRAY MUST HAVE 3 ITEMS FOR THE MENU TO MOVE
    actions: [
        global.action_library.attack, 
        { 
            name: "Skills", 
            sub_menu: _skill_submenu, // This triggers your sub-menu logic
            action: -4, 
            target_required: false, 
            description: "Special moves.",
            enabled: true
        },
        { 
            name: "Run",    
            action: function() { room_goto(rm_overworld); }, 
            sub_menu: -4,
            target_required: false, 
            description: "Flee!",
            enabled: true
        }
    ]
};

// --- 4. ENEMY DATA ---
global.enemies = {
    enemy_goblin: {
        name: "goblin",
        is_player_character: false,
        hp: 8,
        max_hp: 8,
        hunger: 100,
        thirst: 100,
        max_thirst: 100,
        max_hunger:100,
        mass: 30,       // How heavy/loud they are
        height: 1.0,
        perception_data: { 
        view_distance: 150, 
        view_angle: 70, 
        hearing_range: 80 
    },
        stats: { strength: 1, defense: 1, speed: 3, awareness: 1 }, 
        sprites_data: { idle: spr_goblin, attack: spr_goblin_attack },
        actions: [global.action_library.attack],
        AIscript: function() { /* AI Logic */ }
    }
};