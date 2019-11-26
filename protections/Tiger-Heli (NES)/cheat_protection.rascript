// Tiger-Heli
// #ID = 1504

// $0523: STAGE
function stage_id() => byte(0x000523)

// $0525: x00.000
function score_100k() => byte(0x000525)

// $0527: 0x0.000
function score_10k() => byte(0x000527)

// $053F: LIVES!!!
function lives() => byte(0x00053F)

// $0541: LIVES LOST
function lives_lost() => byte(0x000541)

// $0004: bit7: in title screen or demo
function in_title_or_demo() => bit7(0x0004) == 1
function was_in_title_or_demo() => prev(bit7(0x0004)) == 1

function just_used_continue_cheat() {
    return prev(lives()) == 0 && lives() == 2  // lives increased from 0 to 2
           && !was_in_title_or_demo()          // ...whilst not transitioning from the title screen to in-game
}

function cheat_protection() {
    // the always_false is there to force the persistent pauseif into another alt group;
    // the resulting always-false alt group should be removed manually
    return never(in_title_or_demo())
           && (always_false() || once(unless(just_used_continue_cheat())))
}

achievement(
    title = "50K", description = "Get 50.000 points!", points = 10,
    id = 20404, badge = "20140", published = "1/26/2015 7:09:33 PM", modified = "1/27/2015 4:53:49 PM",
    trigger = score_10k() == 5 && cheat_protection()
)

achievement(
    title = "100K", description = "Get 100.000 points!", points = 15,
    id = 20405, badge = "20152", published = "1/26/2015 7:09:35 PM", modified = "1/27/2015 4:53:56 PM",
    trigger = score_100k() == 1 && cheat_protection()
)

achievement(
    title = "200K", description = "Get 200.000 points!", points = 25,
    id = 20406, badge = "20141", published = "1/26/2015 7:09:37 PM", modified = "1/27/2015 4:54:04 PM",
    trigger = score_100k() == 2 && cheat_protection()
)

achievement(
    title = "300K", description = "Get 300.000 points!", points = 35,
    id = 20407, badge = "20149", published = "1/26/2015 7:09:39 PM", modified = "10/14/2019 7:37:01 PM",
    trigger = score_100k() == 3 && cheat_protection()
)

achievement(
    title = "500K", description = "Get 500.000 points!", points = 60,
    id = 20408, badge = "20150", published = "1/26/2015 7:09:40 PM", modified = "10/20/2019 9:21:02 PM",
    trigger = score_100k() == 5 && cheat_protection()
)

achievement(
    title = "Hardcore Shooter!", description = "Complete Stage 1, 2 and 3 without lost lives!", points = 55,
    id = 20409, badge = "20151", published = "1/26/2015 7:09:42 PM", modified = "10/14/2019 7:37:01 PM",
    trigger = stage_id() == 3 && lives_lost() == 0 && cheat_protection()
)

achievement(
    title = "Alive!", description = "Acummulate 5 lives!", points = 25,
    id = 20410, badge = "20146", published = "1/26/2015 7:15:02 PM", modified = "1/27/2015 4:55:09 PM",
    trigger = lives() == 5 && cheat_protection()
)

achievement(
    title = "Stage 2", description = "Reach Stage 2", points = 10,
    id = 20411, badge = "20139", published = "1/26/2015 7:15:14 PM", modified = "1/26/2015 9:09:37 PM",
    trigger = stage_id() == 1 && cheat_protection()
)

achievement(
    title = "Stage 3", description = "Reach Stage 3", points = 15,
    id = 20412, badge = "20145", published = "1/26/2015 7:54:36 PM", modified = "10/14/2019 7:37:01 PM",
    trigger = stage_id() == 2 && cheat_protection()
)

achievement(
    title = "Stage 4", description = "Reach Stage 4", points = 20,
    id = 20413, badge = "20147", published = "1/26/2015 7:54:38 PM", modified = "1/26/2015 9:09:41 PM",
    trigger = stage_id() == 3 && cheat_protection()
)

achievement(
    title = "Expert Player!", description = "Acummulate 7 lives!", points = 40,
    id = 20414, badge = "20148", published = "1/26/2015 8:00:17 PM", modified = "10/20/2019 9:21:02 PM",
    trigger = lives() == 7 && cheat_protection()
)

achievement(
    title = "Complete First Loop!", description = "Reach Second Loop!", points = 30,
    id = 20415, badge = "20139", published = "1/26/2015 9:09:49 PM", modified = "12/5/2016 10:58:53 PM",
    trigger = stage_id() == 1 && byte(0x00053A) == 2 && byte(0x00053B) == 2 && byte(0x00053C) == 0
              && cheat_protection()
)

achievement(
    title = "Complete Second Loop!", description = "Reach Third Loop!", points = 60,
    id = 20416, badge = "20139", published = "1/26/2015 9:09:51 PM", modified = "10/20/2019 9:21:02 PM",
    trigger = stage_id() == 1 && byte(0x00053B) == 3
              && cheat_protection()
)
