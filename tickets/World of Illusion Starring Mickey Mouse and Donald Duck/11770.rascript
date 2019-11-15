// World of Illusion Starring Mickey Mouse and Donald Duck
// #ID = 40

// $FD31: Hit player
function stage2_player_hit() => byte(0x00FD31) == 0xff

// $FFD9: 01 - Mickey 00 - Donald
function character_id() => byte(0x00FFD9)
function is_mickey() => character_id() == 1
function is_donald() => character_id() == 0

// $FFDA: Stages
function stage_id() => byte(0x00FFDA)

// $FFDC: Next Door: |01 - 05 - Spider boss|
function next_door() => byte(0x00FFDC)

// Ticket 11770: Neither working on Retroarch nor on Ragens.
//               Thx in advance.
//               MD5: c6ba2aa696d90bbcc21aec786877fcee
achievement(
    title = "Alakazam!", description = "Clear stage 2 - act 1 without taking any damage", points = 10,
    id = 6386, badge = "06833", published = "3/20/2014 6:44:03 PM", modified = "10/2/2019 9:12:01 AM",
    trigger =
        never(stage_id() != 2)
        && once(next_door() == 0)
        && never(stage2_player_hit())      // doesn't work on EU ROM
        && once(word(0x00FF92) == 0xfff3)  // triggers on level start, but only on US ROM
        && (
            (next_door() == 12 && once(is_mickey()))
            || (next_door() == 1 && once(is_donald()))
        )
)
