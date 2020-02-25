// Trojan
// #ID = 1505

// $0322: score x 10000
function score_10k() => byte(0x000322)

// $0335: health
function health() => byte(0x000335)

// $0346: USE WITH STAGE
function use_with_stage() => byte(0x000346)

// $0396: screen distance left to right
function screen_horizontal_pos() => byte(0x000396)

// $03A2: 00=in game, 01=demo mode.
function mode() => byte(0x0003A2)

// $03CC: SPEED
function speed() => byte(0x0003CC)

// $03CD: POWER UP
function power_up() => byte(0x0003CD)

// $03D0: number of lives
function no_lives() => byte(0x0003D0)

// $03D1: stage value
function stage_id() => byte(0x0003D1)

// $061F: DESARMADO
function unarmed() => byte(0x00061F)

function in_game() => byte(0x0300) != 0x00
function was_in_game() => prev(byte(0x0300)) != 0x00
function just_started_game() => !was_in_game() && in_game()

function up_is_pressed() => bit3(0x07f4) == 1

function just_used_continue_cheat() {
    return just_started_game()  // just moved from the title screen into a new game
           && up_is_pressed()   // ...with the Up key pressed (Up + Start to continue)
}

function cheat_protection() {
    // lock the achievement with a persistent pauseif when the cheat is used.
    // reset the lock when the player goes back to the title screen

    // the always_false is there to force the persistent pauseif into another alt group;
    // the resulting always-false alt group should be removed manually

    return never(!in_game())
           && (always_false() || once(unless(just_used_continue_cheat())))
}

achievement(
    title = "One More Chance!", description = "Have 4 lives", points = 10,
    id = 14517, badge = "20551", published = "10/4/2014 8:36:38 PM", modified = "9/26/2019 3:38:01 PM",
    trigger = no_lives() == 4 && cheat_protection()
)

achievement(
    title = "Filled Lives!!!", description = "Have 5 lives", points = 15,
    id = 14518, badge = "20552", published = "10/4/2014 8:36:46 PM", modified = "9/26/2019 3:38:01 PM",
    trigger = no_lives() == 5 && cheat_protection()
)

achievement(
    title = "Faster Now!", description = "Get Speed Up", points = 15,
    id = 14519, badge = "14266", published = "10/4/2014 8:36:56 PM", modified = "10/17/2019 8:28:01 PM",
    trigger = speed() == 1 && cheat_protection()
)

achievement(
    title = "Fighter Attack!", description = "Get a Power Up", points = 10,
    id = 14520, badge = "14264", published = "10/4/2014 8:36:58 PM", modified = "2/6/2015 2:49:22 PM",
    trigger = power_up() == 1 && cheat_protection()
)

achievement(
    title = "Critical Damage!", description = "Get a second Power Up", points = 15,
    id = 14521, badge = "14265", published = "10/4/2014 8:37:01 PM", modified = "9/26/2019 3:38:01 PM",
    trigger = power_up() == 2 && cheat_protection()
)

achievement(
    title = "Prepared to Fight with Achilles!", description = "Get a Speed Up and 2 Power Ups in one playthrough", points = 20,
    id = 14522, badge = "14269", published = "10/4/2014 8:37:07 PM", modified = "10/14/2019 7:38:01 PM",
    trigger = speed() == 1 && power_up() == 2 && cheat_protection()
)

achievement(
    title = "Mastered Achilles!", description = "Beat Achilles without any damage", points = 30,
    id = 14523, badge = "14263", published = "10/4/2014 8:37:13 PM", modified = "10/23/2019 10:18:02 PM",
    trigger = mode() == 0 && stage_id() == 14 && health() == 8 && cheat_protection()
)

achievement(
    title = "Downtown Ruins", description = "Beat Stage 1-1", points = 10,
    id = 10940, badge = "20553", published = "7/31/2014 9:12:26 PM", modified = "2/6/2015 2:53:57 PM",
    trigger = mode() == 0 && stage_id() == 1 && screen_horizontal_pos() >= 1 && cheat_protection()
)

achievement(
    title = "Fighter Score!", description = "Get 80.000 points", points = 25,
    id = 14524, badge = "20554", published = "10/4/2014 8:54:04 PM", modified = "10/23/2019 10:18:02 PM",
    trigger = score_10k() >= 8 && cheat_protection()
)

achievement(
    title = "Downtown Combat Area", description = "Beat Stage 1-2", points = 10,
    id = 10941, badge = "20555", published = "7/31/2014 9:12:27 PM", modified = "2/6/2015 2:55:10 PM",
    trigger = mode() == 0 && stage_id() == 2 && screen_horizontal_pos() >= 1 && cheat_protection()
)

achievement(
    title = "Total Chance!", description = "Have 6 lives", points = 20,
    id = 14525, badge = "20556", published = "10/4/2014 9:08:55 PM", modified = "10/14/2019 7:38:01 PM",
    trigger = no_lives() == 6 && cheat_protection()
)

achievement(
    title = "The Craggy Cliff Rocks", description = "Beat Stage 2-1", points = 10,
    id = 10942, badge = "20557", published = "7/31/2014 9:12:28 PM", modified = "2/6/2015 2:56:28 PM",
    trigger = mode() == 0 && stage_id() == 3 && screen_horizontal_pos() >= 1 && cheat_protection()
)

achievement(
    title = "The Craggy Cliff Swamp", description = "Beat Stage 2-2", points = 10,
    id = 10943, badge = "20558", published = "7/31/2014 9:12:29 PM", modified = "2/6/2015 2:57:15 PM",
    trigger = mode() == 0 && stage_id() == 4 && cheat_protection()
)

achievement(
    title = "Retreat Passageway Opening", description = "Beat Stage 3-1", points = 10,
    id = 10944, badge = "20559", published = "7/31/2014 9:12:31 PM", modified = "2/6/2015 3:34:39 PM",
    trigger = mode() == 0 && stage_id() == 5 && cheat_protection()
)

achievement(
    title = "Retreat Passageway Depths", description = "Beat Stage 3-2", points = 10,
    id = 10945, badge = "20560", published = "7/31/2014 9:12:32 PM", modified = "10/23/2019 10:18:02 PM",
    trigger = mode() == 0 && stage_id() == 6 && cheat_protection()
)

achievement(
    title = "Fallout Shelter Vault", description = "Beat Stage 4-1", points = 10,
    id = 10946, badge = "20561", published = "7/31/2014 9:12:33 PM", modified = "2/6/2015 2:58:34 PM",
    trigger = mode() == 0 && stage_id() == 7 && cheat_protection()
)

achievement(
    title = "Fallout Shelter Chambers", description = "Beat Stage 4-2", points = 10,
    id = 10947, badge = "20562", published = "7/31/2014 9:12:34 PM", modified = "2/6/2015 2:59:00 PM",
    trigger = mode() == 0 && stage_id() == 8 && cheat_protection()
)

achievement(
    title = "Industrial Shaft", description = "Beat Stage 5", points = 15,
    id = 10949, badge = "20563", published = "7/31/2014 9:12:36 PM", modified = "10/5/2019 5:27:01 PM",
    trigger = mode() == 0 && stage_id() == 10 && cheat_protection()
)

achievement(
    title = "Underground Fortress Outer Walls", description = "Beat Stage 6-1", points = 10,
    id = 10950, badge = "20564", published = "7/31/2014 9:12:37 PM", modified = "9/26/2019 3:38:01 PM",
    trigger = mode() == 0 && stage_id() == 11 && cheat_protection()
)

achievement(
    title = "Underground Fortress Inner Walls", description = "Beat Stage 6-2", points = 10,
    id = 10951, badge = "20565", published = "7/31/2014 9:12:38 PM", modified = "2/6/2015 3:00:50 PM",
    trigger = mode() == 0 && stage_id() == 12 && cheat_protection()
)

achievement(
    title = "The Fall of Achilles", description = "Beat the Game", points = 15,
    id = 10952, badge = "20566", published = "7/31/2014 9:12:40 PM", modified = "10/5/2019 5:27:01 PM",
    trigger = mode() == 0 && stage_id() == 14 && cheat_protection()
)

achievement(
    title = "High Score", description = "Get at least 20000 points in one playthrough", points = 20,
    id = 10975, badge = "20567", published = "8/1/2014 5:13:53 PM", modified = "2/6/2015 3:04:35 PM",
    trigger = score_10k() >= 2 && cheat_protection()
)

achievement(
    title = "Secret Place 1", description = "Secret Place on stage 1-1!", points = 5,
    id = 18925, badge = "17574", published = "12/18/2014 7:58:45 PM", modified = "12/18/2014 8:13:07 PM",
    trigger = once(use_with_stage() == 16) && once(stage_id() == 0) && never(stage_id() != 0) && cheat_protection()
)

achievement(
    title = "Secret Place 2", description = "Secret Place on stage 1-2!", points = 5,
    id = 18926, badge = "17575", published = "12/18/2014 7:58:47 PM", modified = "12/18/2014 8:13:10 PM",
    trigger = once(use_with_stage() == 16) && once(stage_id() == 1) && never(stage_id() != 1) && cheat_protection()
)

achievement(
    title = "Street Fighter", description = "Beat Stage 1-2 unarmed", points = 10,
    id = 18927, badge = "18665", published = "12/18/2014 8:12:21 PM", modified = "2/6/2015 3:05:15 PM",
    trigger = once(stage_id() == 2) && once(unarmed() == 255) && never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Weaponless Hero", description = "Beat Stage 3-1 unarmed", points = 10,
    id = 18928, badge = "18666", published = "12/18/2014 8:20:52 PM", modified = "10/5/2019 5:27:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 5) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Pro Pugilist", description = "Beat Stage 3-2 unarmed", points = 10,
    id = 18929, badge = "18667", published = "12/18/2014 8:27:24 PM", modified = "10/14/2019 7:38:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 6) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Expert Kickboxer", description = "Beat Stage 4-1 unarmed", points = 10,
    id = 18930, badge = "18668", published = "12/18/2014 8:37:10 PM", modified = "10/17/2019 8:28:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 7) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Top Brawler", description = "Beat Stage 4-2 unarmed", points = 10,
    id = 18931, badge = "18669", published = "12/18/2014 8:43:05 PM", modified = "10/14/2019 7:38:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 8) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Master Bruiser", description = "Beat Stage 6-1 unarmed", points = 10,
    id = 18932, badge = "18670", published = "12/18/2014 8:49:49 PM", modified = "10/14/2019 7:38:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 11) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)

achievement(
    title = "Martial Champion", description = "Beat Stage 6-2 unarmed", points = 20,
    id = 18933, badge = "18671", published = "12/18/2014 8:54:09 PM", modified = "10/17/2019 8:28:01 PM",
    trigger = once(mode() == 0) && once(stage_id() == 12) && once(unarmed() == 255) && 
              never(unarmed() == 0) && cheat_protection()
)
