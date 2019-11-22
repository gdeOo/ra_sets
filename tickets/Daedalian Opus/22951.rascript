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
function in_level() => byte(0x00D02C) != 0

function time_not_zero() {
    return (time_hours() + time_10_minutes() + time_minutes() + time_10_seconds() + time_seconds()) != 0
}

function level_completed(n) {
    return stage_id() == n     // stage is the targeted one
           && !in_level()      // we're in the overworld
           && time_not_zero()  // *after* having completed the level (timer resets to 0 when stage id increases)
}

function time_below_hours() => dword(0x00C35D)

function time_le(min_hex, ten_secs_hex, secs_hex) {  // expects [min, 10secs, sec] in hex
    return time_hours() == 0
           && time_below_hours() <= (min_hex * 0x10000 + ten_secs_hex * 0x100 + secs_hex)
}

achievement(
    title = "Stage 01 mastered", description = "Beat Stage 1 in 30 seconds or less", points = 10,
    id = 32113, badge = "29969", published = "1/19/2016 2:18:16 PM", modified = "1/19/2016 5:02:22 PM",
    trigger = level_completed(1) && time_le(0, 3, 0)
)

achievement(
    title = "Stage 03 mastered", description = "Beat Stage 03 in 30 seconds or less", points = 10,
    id = 32114, badge = "29970", published = "1/19/2016 2:18:23 PM", modified = "1/19/2016 3:27:37 PM",
    trigger = level_completed(3) && time_le(0, 3, 0)
)

achievement(
    title = "Stage 07 mastered", description = "Beat Stage 07 in 1 minute or less", points = 10,
    id = 32115, badge = "29971", published = "1/19/2016 2:18:25 PM", modified = "1/19/2016 3:05:03 PM",
    trigger = level_completed(7) && time_le(1, 0, 0)
)

achievement(
    title = "Stage 11 mastered", description = "Beat Stage 11 in 2 minutes or less", points = 20,
    id = 32116, badge = "29972", published = "1/19/2016 2:18:28 PM", modified = "1/19/2016 3:05:29 PM",
    trigger = level_completed(11) && time_le(2, 0, 0)
)

achievement(
    title = "Stage 15 mastered", description = "Beat Stage 15 in 2 minutes or less", points = 20,
    id = 32117, badge = "29973", published = "1/19/2016 2:18:31 PM", modified = "9/30/2019 8:11:01 PM",
    trigger = level_completed(15) && time_le(2, 0, 0)
)

achievement(
    title = "Stage 19 mastered", description = "Beat Stage 19 in 2 minutes or less", points = 30,
    id = 32118, badge = "29974", published = "1/19/2016 2:18:34 PM", modified = "9/30/2019 8:11:01 PM",
    trigger = level_completed(19) && time_le(2, 0, 0)
)

// Ticket 22951: Doesn't trigger if you have 00 in the seconds position I believe. I beat level 23 with a time of 01:00
//               and it didn't trigger, beat it again with a time of 01:15 and it triggered.
//               MD5: 34b3d0f0843b83e5b0e00bc3d0669793
achievement(
    title = "Stage 23 mastered", description = "Beat Stage 23 in 3 minutes or less", points = 30,
    id = 32119, badge = "29975", published = "1/19/2016 2:18:37 PM", modified = "1/19/2016 4:45:39 PM",
    trigger = level_completed(23) && time_le(3, 0, 0)
)

achievement(
    title = "Stage 27 mastered", description = "Beat Stage 27 in 3 minutes or less", points = 30,
    id = 32120, badge = "29976", published = "1/19/2016 2:18:40 PM", modified = "1/19/2016 4:45:42 PM",
    trigger = level_completed(27) && time_le(3, 0, 0)
)

achievement(
    title = "Stage 31 mastered", description = "Beat Stage 31 in 3 minutes or less", points = 40,
    id = 32121, badge = "29977", published = "1/19/2016 2:18:43 PM", modified = "9/24/2019 7:42:01 PM",
    trigger = level_completed(31) && time_le(3, 0, 0)
)

achievement(
    title = "Stage 35 mastered", description = "Beat Stage 35 in 3 minutes or less", points = 40,
    id = 32122, badge = "29978", published = "1/19/2016 2:18:46 PM", modified = "10/19/2019 12:30:01 AM",
    trigger = level_completed(35) && time_le(3, 0, 0)
)
