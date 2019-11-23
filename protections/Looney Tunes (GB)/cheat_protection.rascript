// Looney Tunes
// #ID = 2475

// $C506: Game Pause Flag (Also triggers before death)
function game_paused() => byte(0x00C506) == 1

// $C52C: Time: 1 Second Loop
function time_1() => dword(0x00C52C)

// $C52D: Time 2
function time_2() => byte(0x00C52D)

// $C53A: Room Number
function room_number() => byte(0x00C53A)

// $C551: Win Sequence Flag (Doesn't trigger in Taz Level)
function win_flag() => byte(0x00C551)

// $C552: Clear Bonus 2
function clear_bonus_2() => byte(0x00C552)
function clear_bonus() => clear_bonus_2()

// $C55A: Super Disc Flag
function super_disc_flag() => byte(0x00C55A)

// $C567: Porky and R.Runner Boss Flag
function porky_and_rrunner_flag() => byte(0x00C567)

// $C87B: Game Over Check Flag. (=48)
function game_over_flag() => byte(0x00C87B)

// $C8EA: Title Screen Flag
function title_screen_flag() => byte(0x00C8EA)

// $D918: Number of Hearts
function num_hearts() => byte(0x00D918)

// $D938: Fish, Dracula and Elmer Fudd Boss HP
function fish_dracula_and_elmer_hp() => byte(0x00D938)

// $D9D8: Porky Pig Boss HP
function porky_hp() => byte(0x00D9D8)

stage_room_ranges = {
    "Daffy Duck":      [ 1, 12],
    "Tweety":          [13, 13],
    "Porky Pig":       [14, 14],
    "Taz":             [15, 15],
    "Speedy Gonzales": [16, 29],
    "Road Runner":     [30, 30],
    "Bugs Bunny":      [31, 44]
}

function never_not_in_stage(stage_name) {
    if (stage_room_ranges[stage_name][0] == stage_room_ranges[stage_name][1]) {
        return never(room_number() != stage_room_ranges[stage_name][0])
    } else {
        return never(room_number() < stage_room_ranges[stage_name][0])
               && never(room_number() > stage_room_ranges[stage_name][1])
    }
}

function num_hearts_just_increased() => prev(num_hearts()) < num_hearts()

function just_used_life_refill_cheat() {
    return game_paused() && num_hearts_just_increased()
}

function persistent_life_refill_cheat_protection() {
    return unless(once(just_used_life_refill_cheat()))
}

function beat_stage_trigger(stage_name) {
    return room_number() == stage_room_ranges[stage_name][1]
           && win_flag() == 0xff && clear_bonus_2() != 0
           && never_not_in_stage(stage_name)
           // the always_false is required to sure the main group of conditions is in the core group
           // the resulting alt group should be deleted manually
           && (always_false()
               || persistent_life_refill_cheat_protection())
}

achievement(
    title = "Duck Amuck", description = "Clear Daffy Duck's Stage.", points = 15,
    id = 54288, badge = "56147", published = "11/5/2017 12:46:45 AM", modified = "11/7/2017 1:03:12 PM",
    trigger = beat_stage_trigger("Daffy Duck")
)

achievement(
    title = "I Taw a Putty Tat", description = "Clear Tweety's Stage.", points = 15,
    id = 54289, badge = "56148", published = "11/5/2017 12:46:54 AM", modified = "11/7/2017 1:03:15 PM",
    trigger = beat_stage_trigger("Tweety")
)

achievement(
    title = "Porky Chops", description = "Clear Porky Pig's Stage.", points = 15,
    id = 54290, badge = "56149", published = "11/5/2017 12:46:59 AM", modified = "11/7/2017 1:03:17 PM",
    trigger = beat_stage_trigger("Porky Pig")
)

achievement(
    title = "Devil May Hare", description = "Clear Taz's Stage", points = 15,
    id = 54291, badge = "56150", published = "11/5/2017 12:47:05 AM", modified = "11/7/2017 1:03:20 PM",
    trigger = repeated(130, room_number() == 15) && repeated(130, win_flag() == 0) && 
              repeated(130, time_2() == 0) && never(room_number() != 15) && never(win_flag() != 0) && 
              never(time_2() != 0)
)

achievement(
    title = "Gonzales' Tamales", description = "Clear Speedy Gonzales's Stage.", points = 15,
    id = 54292, badge = "56151", published = "11/5/2017 12:47:09 AM", modified = "11/7/2017 1:03:22 PM",
    trigger = beat_stage_trigger("Speedy Gonzales")
)

achievement(
    title = "Beep, Beep", description = "Clear Road Runner's Stage.", points = 15,
    id = 54293, badge = "56152", published = "11/5/2017 12:47:12 AM", modified = "11/7/2017 1:03:25 PM",
    trigger = beat_stage_trigger("Road Runner")
)

achievement(
    title = "Wabbit Twouble", description = "Clear Bugs Bunny's Stage.", points = 15,
    id = 54294, badge = "56155", published = "11/5/2017 12:48:14 AM", modified = "11/7/2017 1:03:34 PM",
    trigger = beat_stage_trigger("Bugs Bunny")
)

achievement(
    title = "That's all Folks!", description = "Clear the game without using a continue.", points = 35,
    id = 54295, badge = "56125", published = "11/5/2017 12:48:26 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        once(title_screen_flag() == 0)
        && once(room_number() == 1)
        && room_number() == 44
        && win_flag() == 0xff
        && never(game_over_flag() == 72)
        && never(just_used_life_refill_cheat())
)

function beat_stage_boss_damageless_trigger(stage_name, scope_start_cond) {
    return scope_start_cond
           && never(room_number() != stage_room_ranges[stage_name][1])
           && win_flag() == 0xff && clear_bonus() != 0
           && never(num_hearts() < prev(num_hearts()))
           && never(just_used_life_refill_cheat())
}

achievement(
    title = "Aqua Duck", description = "Beat the fish boss without taking any damage.", points = 35,
    id = 54296, badge = "56156", published = "11/5/2017 12:48:31 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        beat_stage_boss_damageless_trigger("Daffy Duck", once(fish_dracula_and_elmer_hp() == 0))
)

achievement(
    title = "Tweet and Sour", description = "Clear Tweety's Stage without getting caught by Sylvester.", points = 35,
    id = 54297, badge = "56172", published = "11/5/2017 12:48:41 AM", modified = "11/8/2017 8:03:11 PM",
    trigger =
        beat_stage_boss_damageless_trigger("Tweety", once(time_1() == 151552))
)

achievement(
    title = "Porky's Last Stand", description = "Beat the star boss without taking any damage.", points = 35,
    id = 54298, badge = "56159", published = "11/5/2017 12:48:47 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        beat_stage_boss_damageless_trigger("Porky Pig", once(porky_and_rrunner_flag() > prev(porky_and_rrunner_flag()))
                                                        && never(porky_hp() == 60))
)

achievement(
    title = "Taz-Mania", description = "Get at least 60 pieces of meat in Taz's Stage.", points = 35,
    id = 54299, badge = "56160", published = "11/5/2017 12:48:59 AM", modified = "10/18/2019 1:41:01 AM",
    trigger = room_number() == 15 && time_2() != 0 && clear_bonus_2() >= 96
)

achievement(
    title = "Rodent to Stardom", description = "Beat Dracula without taking any damage.", points = 35,
    id = 54300, badge = "56162", published = "11/5/2017 12:49:06 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        beat_stage_boss_damageless_trigger("Speedy Gonzales", once(fish_dracula_and_elmer_hp() == 0))
)

achievement(
    title = "Beep Prepared", description = "Beat Wile E. Coyote without taking any damage.", points = 35,
    id = 54301, badge = "56163", published = "11/5/2017 12:49:12 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        beat_stage_boss_damageless_trigger("Road Runner", once(porky_and_rrunner_flag() == 0))
)

achievement(
    title = "What's Up, Doc?", description = "Beat Elmer Fudd without taking any damage.", points = 35,
    id = 54302, badge = "56165", published = "11/5/2017 12:49:16 AM", modified = "10/18/2019 1:41:01 AM",
    trigger =
        beat_stage_boss_damageless_trigger("Bugs Bunny", once(fish_dracula_and_elmer_hp() == 0))
)

achievement(
    title = "Assault and Peppered", description = "Upgrade your Disc Weapon.", points = 15,
    id = 54303, badge = "56169", published = "11/5/2017 12:49:18 AM", modified = "11/7/2017 1:05:29 PM",
    trigger = super_disc_flag() == 1 && room_number() == 45
)
