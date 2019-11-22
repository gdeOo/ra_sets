// Daedalian Opus
// #ID = 6906

// $D00F: Stage Number
function stage_id() => byte(0x00D00F)

// $D02C: lvl
function in_level() => byte(0x00D02C)

// Ticket 22952: Triggers after beating level 35, wrong level ID.
//               MD5: 34b3d0f0843b83e5b0e00bc3d0669793
//               Emulator: RAVBA
achievement(
    title = "Daedalian Opus", description = "Finish the game", points = 40,
    id = 32123, badge = "32849", published = "1/19/2016 2:18:49 PM", modified = "1/19/2016 3:45:13 PM",
    trigger = stage_id() == 35 && in_level() == 132
)
