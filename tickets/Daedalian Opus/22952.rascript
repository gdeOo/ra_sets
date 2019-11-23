// Daedalian Opus
// #ID = 6906

// $D00F: Stage Number
function stage_id() => byte(0x00D00F)

// $D02C: lvl
function in_level() => byte(0x00D02C)

// $D012: Part 1/4 of the animation state of the fairy in the final cutscene (flips between 0x40 & 0x44)
function fairy_anim_1() => byte(0x00c012)

// $C016: Part 2/4 of the animation state of the fairy in the final cutscene (flips between 0x41 & 0x45)
function fairy_anim_2() => byte(0x00c016)

function in_final_cutscene() {
    return prev(fairy_anim_1()) == 0x40 && fairy_anim_1() == 0x44
           && prev(fairy_anim_2()) == 0x41 && fairy_anim_2() == 0x45
}

// Ticket 22952: Triggers after beating level 35, wrong level ID.
//               MD5: 34b3d0f0843b83e5b0e00bc3d0669793
//               Emulator: RAVBA
achievement(
    title = "Daedalian Opus", description = "Finish the game", points = 40,
    id = 32123, badge = "32849", published = "1/19/2016 2:18:49 PM", modified = "1/19/2016 3:45:13 PM",
    trigger =
        stage_id() == 35        // unlike other stages, this id increases before entering the stage
        && in_final_cutscene()  // so we avoid triggering at that point by detecting the final cutscene
)
