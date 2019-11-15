// World of Illusion Starring Mickey Mouse and Donald Duck
// #ID = 40

// $FFD9: 01 - Mickey 00 - Donald
function character_id() => byte(0x00FFD9)
function is_mickey() => character_id() == 1
function is_donald() => character_id() == 0

// $FFDA: Stages
function stage_id() => byte(0x00FFDA)

// $FFDC: Next Door: |01 - 05 - Spider boss|
function next_door() => byte(0x00FFDC)

// $FD30: displayed hp
function display_hp() => byte(0x00FD30)

// $A039: hp
function hp() => byte(0x00a039)

function in_stage(id) => stage_id() == id

function just_took_damage() => prev(hp()) > hp()

function gameplay_start_scope() {
    // scopes an achievement to the period after the player first gains control in a stage / act.
    // uses the fact the the displayed hp counts upwards from 0 to the actual hp value at the start of gameplay.
    // note/assumption: while it's possible for the display hp to count up when an health item is picked
    //                  up, it'll never count from 0 except at the start of gameplay
    return once(prev(display_hp()) == 0 && display_hp() == 1)
}

// Ticket 11770: Neither working on Retroarch nor on Ragens.
//               Thx in advance.
//               MD5: c6ba2aa696d90bbcc21aec786877fcee
achievement(
    title = "Alakazam!", description = "Clear stage 2 - act 1 without taking any damage", points = 10,
    id = 6386, badge = "06833", published = "3/20/2014 6:44:03 PM", modified = "10/2/2019 9:12:01 AM",
    trigger =
        gameplay_start_scope()        // scope the achievement to the current "gameplay session"
        && never(!in_stage(2))        // must be in the second stage...
        && never(just_took_damage())  // reset upon taking damage
        && (
            (next_door() == 12 && once(is_mickey()))    // trigger when leaving act 1
            || (next_door() == 1 && once(is_donald()))
        )
)
