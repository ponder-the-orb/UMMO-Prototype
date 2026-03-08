// Change the script to a function
function npc_generate_soul(_npc_id) {
    
    // Use the passed ID instead of a global variable
    var _npc = _npc_id;

    // Roll the Axis (Example values from our plan)
    _npc.ethics = choose_weighted(["JUST", "NEUTRAL", "SELFISH", "CHAOTIC"], [20, 50, 20, 10]);
    _npc.temper = choose_weighted(["CALM", "GRUMPY", "VOLATILE"], [60, 25, 15]);

    // Inject Random Traits
    // Make sure global.trait_library is initialized elsewhere!
    repeat(irandom_range(1, 3)) {
        var _new_trait = ds_list_find_value(global.trait_library, irandom(global.trait_count - 1));
        array_push(_npc.traits, _new_trait);
    }

    // Visual/Social Flair
    _npc.voice_pitch = random_range(0.8, 1.2); 
}