// Daedalian Opus
// #ID = 6906

// $C35D: Timer seconds position
function time_seconds() => byte(0x00C35D)

// $C35E: Timer ten-second position
function time_10_seconds() => byte(0x00C35E)

// $C35F: Timer minute position
function time_minutes() => byte(0x00C35F)

// $C360: Timer ten-minute position
function time_10_minutes() => byte(0x00C360)

// $C361: Timer hour position position
function time_hours() => byte(0x00C361)

// $D00F: Stage Number
function stage_id() => byte(0x00D00F)

// $D02C: lvl
in_level_mem = byte(0x00D02C)
function in_level() => in_level_mem != 0

function time_not_zero() {
    return (time_hours() + time_10_minutes() + time_minutes() + time_10_seconds() + time_seconds()) != 0
}

function level_completed(n) {
    return stage_id() == n     // stage is the targeted one
           && !in_level()      // we're in the overworld
           && time_not_zero()  // *after* having completed the level (timer resets to 0 when stage id increases)
}

// $D012: Part 1/4 of the animation state of the fairy in the final cutscene (flips between 0x40 & 0x44)
function fairy_anim_1() => byte(0x00c012)

// $C016: Part 2/4 of the animation state of the fairy in the final cutscene (flips between 0x41 & 0x45)
function fairy_anim_2() => byte(0x00c016)

function in_post_35_cutscene() {
    return prev(fairy_anim_1()) == 0xc0 && fairy_anim_1() == 0xc4
           && prev(fairy_anim_2()) == 0xc1 && fairy_anim_2() == 0xc5
}

function level_35_completed() {
    return stage_id() == 35
           && in_post_35_cutscene()
           && time_not_zero()
}

function time_below_hours() => dword(0x00C35D)

function time_le(min_hex, ten_secs_hex, secs_hex) {  // expects [min, 10secs, sec] in hex
    return time_hours() == 0
           && time_below_hours() <= (min_hex * 0x10000 + ten_secs_hex * 0x100 + secs_hex)
}

// Ticket 23197: Didn't trigger for me, although I see that for some people it does trigger, I don't understand why
//               MD5: 34b3d0f0843b83e5b0e00bc3d0669793
achievement(
    title = "Stage 35 mastered", description = "Beat Stage 35 in 3 minutes or less", points = 40,
    id = 32122, badge = "29978", published = "1/19/2016 2:18:46 PM", modified = "10/19/2019 12:30:01 AM",
    trigger = level_35_completed() && time_le(3, 0, 0)
)
