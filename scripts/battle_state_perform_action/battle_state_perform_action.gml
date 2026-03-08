
// This function handles the ongoing animation and resolution of the current action.
function battle_state_perform_action()
{
    // Check if the current user is still 'acting' (meaning their animation is still playing)
    if (current_user.acting)
    {
        // Check if the user's animation has finished (image_index is at or past the last frame)
        if (current_user.image_index >= current_user.image_number -1)
        {
            // Reset the user's sprite and acting flag now that the animation is done
            with (current_user)
            {
                sprite_index = sprites_data.idle; // Return to idle sprite (using the 'sprites_data' struct from the unit)
                image_index = 0;                  // Reset image index
                acting = false;                   // Clear the acting flag
            }

            // --- Effect Creation (visual effects like 'bonk' sprites) ---
            // Check if the current action has an 'effect_sprite' defined.
            if (variable_struct_exists(current_action, "effect_sprite"))
            {
                // Determine where to play the effect: on targets always, or if it varies and only one target.
                if (current_action.effect_on_target == MODE.ALWAYS) || ( (current_action.effect_on_target == MODE.VARIES) && (array_length(current_targets) <= 1) )
                {
                    // Create effect on each target's position
                    for (var i = 0; i < array_length(current_targets); i++)
                    {
                        // Create obj_battle_effect at target's position, slightly in front, with the effect sprite.
                        instance_create_depth(current_targets[i].x, current_targets[i].y, current_targets[i].depth-1, obj_battle_effect, {sprite_index : current_action.effect_sprite});
                    }
                }
                else // Play the effect at the battle manager's origin (0,0,0) if it's a general effect not tied to targets
                {
                    var _effect_sprite = current_action.effect_sprite;
                    // If a specific 'no_target' sprite exists for this action, use it
                    if (variable_struct_exists(current_action, "effect_sprite_no_target")) _effect_sprite = current_action.effect_sprite_no_target;
                    instance_create_depth(x, y, depth - 100, obj_battle_effect, {sprite_index : _effect_sprite});
                }
            }

            // --- Action Resolution (applying damage/status) ---
            // Call the function associated with the current action.
            // This is where actual damage calculations, healing, status effects, etc., happen.
            current_action.func(current_user, current_targets);
        }
    }
    else // The user is no longer acting (animation finished)
    {
        // Wait for any visual effects (like obj_battle_effect) to finish.
        // This creates a short pause after the attack animation and effect play.
        if (!instance_exists(obj_battle_effect)) // Check if any effect instances still exist
        {
            obj_battle_manager.battle_wait_time_remaining--; // Countdown the wait time
            if (obj_battle_manager.battle_wait_time_remaining == 0)
            {
                // Once wait time is over, move to check for victory conditions.
                battle_state = BATTLE_STATE.CHECK_WIN_LOSS;
            }
        }
    }
}