// Strider
// #ID = 250

// $E95E: Upgrades
function upgrades() => byte(0x00E95E)

// $FC0B: Stage id
function stage_id() => byte(0x00FC0B)

// $FDE2: Difficulty
function difficulty() => byte(0x00FDE2)

function in_demo() => byte(0x00e188) == 0x01

function hard_difficulty() => difficulty() == 2

function just_got_to_stage_trigger(n) {
    // When a demo starts, the in-demo flag only activates quite a few frames after the stage id changes.
    // To make matters worse, the stage id keeps its value after the demo ends.
    return once(prev(stage_id()) == (n-1)
                && stage_id() == n)           // must watch the stage change from n-1 to n
           && repeated(100, stage_id() == n)  // must be in stage n for 100 frames to give the in-demo flag time to active before triggering
           && never(in_demo())                // reset if in a demo
           && never(stage_id() != n)          // reset if stage is not n to clear any hits leftover from the title screen
}

// Ticket 22955: The Iron Ruler Achievements Triggered without i start the game
//               MD5: Unknown
//               Emulator: RAGens
achievement(
    title = "The Iron Ruler", description = "Defeat Ouroboros", points = 5,
    id = 1360, badge = "01612", published = "5/29/2013 6:11:27 PM", modified = "5/29/2013 7:29:30 PM",
    trigger = just_got_to_stage_trigger(1)
)

achievement(
    title = "The Iron Slayer", description = "Defeat Ouroboros On Hard Difficulty", points = 20,
    id = 1359, badge = "01613", published = "5/29/2013 6:11:24 PM", modified = "10/8/2019 11:27:01 AM",
    trigger = just_got_to_stage_trigger(1) && hard_difficulty()
)

achievement(
    title = "Ton Pooh", description = "Defeat The Kuniang M.A Team", points = 5,
    id = 1361, badge = "01614", published = "5/29/2013 6:51:09 PM", modified = "5/29/2013 7:29:31 PM",
    trigger = just_got_to_stage_trigger(2)
)

achievement(
    title = "Sky Thunder Airship", description = "Defeat The Kuniang M.A Team On Hard Difficulty", points = 20,
    id = 1362, badge = "01615", published = "5/29/2013 6:54:59 PM", modified = "10/8/2019 11:27:01 AM",
    trigger = just_got_to_stage_trigger(2) && hard_difficulty()
)

achievement(
    title = "Abandon Ship", description = "Defeat Captain Beard Jnr.", points = 5,
    id = 1363, badge = "01616", published = "5/29/2013 7:13:03 PM", modified = "5/29/2013 8:01:33 PM",
    trigger = just_got_to_stage_trigger(3)
)

achievement(
    title = "Bring Down The Balrog Flying Fortress", description = "Defeat Captain Beard Jnr. On Hard Difficulty", points = 20,
    id = 1364, badge = "01617", published = "5/29/2013 7:13:07 PM", modified = "10/2/2019 10:06:01 AM",
    trigger = just_got_to_stage_trigger(3) && hard_difficulty()
)

achievement(
    title = "Through The Amazon", description = "Defeat Lago", points = 5,
    id = 1365, badge = "01620", published = "5/29/2013 7:13:11 PM", modified = "10/20/2019 2:40:01 PM",
    trigger = just_got_to_stage_trigger(4)
)

achievement(
    title = "Mecha T-Rex", description = "Defeat Lago On Hard Difficulty", points = 20,
    id = 1366, badge = "01618", published = "5/29/2013 7:13:14 PM", modified = "10/14/2019 12:56:01 PM",
    trigger = just_got_to_stage_trigger(4) && hard_difficulty()
)

achievement(
    title = "The Last Laugh", description = "Defeat Meio", points = 30,
    id = 1367, badge = "01622", published = "5/29/2013 7:23:48 PM", modified = "10/14/2019 12:56:01 PM",
    trigger = just_got_to_stage_trigger(5)
)

achievement(
    title = "Grandmaster Of The Third Moon", description = "Defeat Meio On Hard Difficulty", points = 40,
    id = 1368, badge = "01621", published = "5/29/2013 7:23:51 PM", modified = "10/23/2019 3:37:01 PM",
    trigger = just_got_to_stage_trigger(5) && hard_difficulty()
)

achievement(
    title = "Dipodal Saucer", description = "Collect Your First Dipodal Saucer Upgrade", points = 5,
    id = 1356, badge = "01609", published = "5/29/2013 4:25:05 PM", modified = "5/29/2013 7:29:18 PM",
    trigger = upgrades() == 4 && !in_demo()
)

achievement(
    title = "Robot Hawk", description = "Collect Your First Robot Hawk Upgrade", points = 5,
    id = 1357, badge = "01610", published = "5/29/2013 4:45:55 PM", modified = "5/29/2013 7:29:21 PM",
    trigger = upgrades() == 2 && !in_demo()
)

achievement(
    title = "Terapodal RoboPanther", description = "Collect Your First Terapodal RoboPanther Upgrade", points = 10,
    id = 1358, badge = "01611", published = "5/29/2013 4:45:57 PM", modified = "5/29/2013 7:29:23 PM",
    trigger = upgrades() == 3 && !in_demo()
)
