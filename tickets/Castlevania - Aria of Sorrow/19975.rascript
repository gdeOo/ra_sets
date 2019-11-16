// Castlevania - Aria of Sorrow
// #ID = 510

// $01B27F: MAX HP high
function max_hp_high() => byte(0x01B27F)

// $01B31C: (RED) Bat - Winged Skeleton Soul Amount
function winged_skeleton_soul_amount_bit0() => bit0(0x01B31C)

// Ticket 19975: Triggered after I copied the first file to the slot 3
//               MD5: 023deff01a5285d1539d18266903a050
//               Emulator: RetroArch (mGBA)
achievement(
    title = "That Was Easy", description = "Obtain Your 1st Soul", points = 1,
    id = 3086, badge = "03570", published = "10/1/2013 6:16:30 AM", modified = "7/29/2019 10:05:10 PM",
    trigger =
        winged_skeleton_soul_amount_bit0() > prev(winged_skeleton_soul_amount_bit0())
        && never(prev(max_hp_high()) == 0)
)
