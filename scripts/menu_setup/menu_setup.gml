// In a setup script or obj_battle_manager Create, when defining actions for a unit:
function player_player_attack_action(_user, _arg) {
    show_debug_message("player performed an attack!");
    // ... attack logic ...
}

function player_player_skill_action(_user, _arg) {
    show_debug_message("player used a skill!");
    // ... skill logic ...
}

function skill_fireball_action(_user, _arg) {
    show_debug_message("player used Fireball!");
}

function skill_heal_action(_user, _arg) {
    show_debug_message("player used Heal!");
}

// Define a sub-menu for skills
var skill_submenu_data = {
    description: "Choose a Skill:",
    options: [
        { name: "Fireball", action: skill_fireball_action, enabled: true, description: "Hurls a fiery orb.", sub_menu: -4, target_enemy_by_default: true, target_required: true, user_animation: "cast" },
        { name: "Heal", action: skill_heal_action, enabled: true, description: "Restores a small amount of HP.", sub_menu: -4, target_enemy_by_default: false, target_required: true, user_animation: "cast" },
        { name: "Back", action: -4, enabled: true, description: "Go back to main menu.", sub_menu: -4, target_required: false, user_animation: "" } // A 'back' option
    ]
};

// Main menu options for player
var player_actions = [
    { name: "Attack", action: player_player_attack_action, enabled: true, description: "Attacks a single enemy.", sub_menu: -4, target_enemy_by_default: true, target_required: true, user_animation: "attack" },
    { name: "Skill", action: -4, enabled: true, description: "Use a special ability.", sub_menu: skill_submenu_data, target_required: false, user_animation: "" }, // POINTS TO THE SUB-MENU
    { name: "Item", action: -4, enabled: false, description: "Use an item from inventory.", sub_menu: -4, target_required: false, user_animation: "" }
];

