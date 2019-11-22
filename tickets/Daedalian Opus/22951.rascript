// Daedalian Opus
// #ID = 6906

// $C35D: Timer seconds position
function time_seconds() => byte(0x00C35D)

// $C35E: Timer ten-second position
function time_ten_seconds_and_seconds() => word(0x00C35E)

// $C35F: Timer minute position
function time_minutes() => byte(0x00C35F)

// $C35F: Timer minute position
function time_minutes_and_ten_seconds() => word(0x00C35F)

// $D00F: Stage Number
function stage_id() => byte(0x00D00F)

// $D02C: lvl
function in_level() => byte(0x00D02C)

achievement(
    title = "Stage 01 mastered", description = "Beat Stage 1 under 30 secondes", points = 10,
    id = 32113, badge = "29969", published = "1/19/2016 2:18:16 PM", modified = "1/19/2016 5:02:22 PM",
    trigger = stage_id() == 1 && time_ten_seconds_and_seconds() <= 258 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 03 mastered", description = "Beat Stage 04 under 30 secondes", points = 10,
    id = 32114, badge = "29970", published = "1/19/2016 2:18:23 PM", modified = "1/19/2016 3:27:37 PM",
    trigger = stage_id() == 3 && time_ten_seconds_and_seconds() <= 258 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 07 mastered", description = "Beat Stage 07 under 1 minute", points = 10,
    id = 32115, badge = "29971", published = "1/19/2016 2:18:25 PM", modified = "1/19/2016 3:05:03 PM",
    trigger = stage_id() == 7 && time_minutes() == 0 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 11 mastered", description = "Beat Stage 11  under 2 minutes", points = 20,
    id = 32116, badge = "29972", published = "1/19/2016 2:18:28 PM", modified = "1/19/2016 3:05:29 PM",
    trigger = stage_id() == 11 && time_ten_seconds_and_seconds() <= 514 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 15 mastered", description = "Beat Stage 15  under 2 minutes", points = 20,
    id = 32117, badge = "29973", published = "1/19/2016 2:18:31 PM", modified = "9/30/2019 8:11:01 PM",
    trigger = stage_id() == 15 && time_ten_seconds_and_seconds() <= 514 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 19 mastered", description = "Beat Stage 19 under 2 minutes", points = 30,
    id = 32118, badge = "29974", published = "1/19/2016 2:18:34 PM", modified = "9/30/2019 8:11:01 PM",
    trigger = stage_id() == 19 && time_ten_seconds_and_seconds() <= 514 && in_level() == 0 && time_seconds() > 0
)

// Ticket 22951: Doesn't trigger if you have 00 in the seconds position I believe. I beat level 23 with a time of 01:00
//               and it didn't trigger, beat it again with a time of 01:15 and it triggered.
//               MD5: 34b3d0f0843b83e5b0e00bc3d0669793
achievement(
    title = "Stage 23 mastered", description = "Beat Stage 23  under 3 minutes", points = 30,
    id = 32119, badge = "29975", published = "1/19/2016 2:18:37 PM", modified = "1/19/2016 4:45:39 PM",
    trigger = stage_id() == 23 && time_ten_seconds_and_seconds() <= 768 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 27 mastered", description = "Beat Stage 27  under 3  minutes", points = 30,
    id = 32120, badge = "29976", published = "1/19/2016 2:18:40 PM", modified = "1/19/2016 4:45:42 PM",
    trigger = stage_id() == 27 && time_ten_seconds_and_seconds() <= 768 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 31 mastered", description = "Beat Stage 31  under 3 minutes", points = 40,
    id = 32121, badge = "29977", published = "1/19/2016 2:18:43 PM", modified = "9/24/2019 7:42:01 PM",
    trigger = stage_id() == 31 && time_ten_seconds_and_seconds() <= 768 && in_level() == 0 && time_seconds() > 0
)

achievement(
    title = "Stage 35 mastered", description = "Beat Stage 35  under 3  minutes", points = 40,
    id = 32122, badge = "29978", published = "1/19/2016 2:18:46 PM", modified = "10/19/2019 12:30:01 AM",
    trigger = stage_id() == 35 && time_minutes_and_ten_seconds() <= 768 && in_level() == 126 && time_seconds() > 0
)
