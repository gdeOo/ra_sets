// Castlevania - Aria of Sorrow
// #ID = 510

// $01B1F8: LCK (status)
function lck_stat() => byte(0x01b1f8)

// $01B31C: (RED) Bat - Winged Skeleton Soul Amount
function winged_skeleton_soul_amount() => low4(0x01B31C)

function got_first_soul() {
    return prev(winged_skeleton_soul_amount()) == 0
           && winged_skeleton_soul_amount() == 1
}

// The previous in-game check was using the player's max hp value, under the
// assumption that it could only be non-zero during gameplay. This was not correct,
// however: the max hp value is part of the SRAM, which is loaded into memory
// when a save game is copied or deleted, both operations that occur in the main
// menu, not in-game.
// Character stats do not suffer from this problem, because they're calculated,
// not stored in SRAM. As such, the in-game check not uses the LCK stat value
// (could use any stat, but for good luck...)
function in_game() => never(prev(lck_stat()) == 0)

// Ticket 19975: Triggered after I copied the first file to the slot 3
//               MD5: 023deff01a5285d1539d18266903a050
//               Emulator: RetroArch (mGBA)
achievement(
    title = "That Was Easy", description = "Obtain Your 1st Soul", points = 1,
    id = 3086, badge = "03570", published = "10/1/2013 6:16:30 AM", modified = "7/29/2019 10:05:10 PM",
    trigger = in_game() && got_first_soul()
)
