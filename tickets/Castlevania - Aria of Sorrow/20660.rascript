// Castlevania - Aria of Sorrow
// #ID = 510

// $01B27F: MAX HP high
function max_hp_high() => byte(0x01B27F)

// $01B290: [4 Byte] Gold
function gold() => dword(0x01B290)

// Ticket 20660: I got over 200k gold by selling weapons at  Hammer's shop, but I didn't get the achievement.
//               MD5: Unknown
//               Emulator: RetroArch ()
// Ticket 20333: Got it when I booted up the game
//               MD5: Unknown
//               Emulator: RetroArch ()
achievement(
    title = "Deep Pockets", description = "Obtained 200,000 Gold", points = 10,
    id = 3132, badge = "03600", published = "10/3/2013 2:10:58 AM", modified = "7/29/2019 10:05:15 PM",
    trigger =
        prev(gold()) < 200000
        && gold() >= 200000
        && never(prev(max_hp_high()) == 0)
)
