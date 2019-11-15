// Castlevania - Aria of Sorrow
// #ID = 510

// $01B27F: MAX HP high
function max_hp_high() => byte(0x01B27F)

// When a saved game is copied, the souls are not carried over in the "normal"
// memory addresses. Instead, they are stored in a same-size array *after*
// the normal array. So, the souls layout in memory is:
//
//   - 28 bytes for red souls
//   - 28 bytes for red souls from the copied save game
//   - 12 bytes for blue souls
//   - 1 byte with unknown meaning (???)
//   - 12 bytes for blue souls from the copied save game
//   - 18 bytes for yellow souls
//   - 18 bytes for yellow souls from the copied save game
//
// As such, we must sum both the "normal" and "copy" values to obtain the actual
// amount of souls, which is what the game display in the menu.

red_souls = {
    "Bat":            [0x01B31C, 0], "Winged Skeleton": [0x01B31C, 1],
    "Merman":         [0x01B31D, 0], "Skeleton":        [0x01B31D, 1],
    "Skull Archer":   [0x01B31E, 0], "Axe Armor":       [0x01B31E, 1],
    "Blue Crow":      [0x01B31F, 0], "Killer Fish":     [0x01B31F, 1],
    "Ghost":          [0x01B320, 0], "Zombie Soldier":  [0x01B320, 1],
    "Tiny Devil":     [0x01B321, 0], "Siren":           [0x01B321, 1],
    "Rock Armor":     [0x01B322, 0], "Durga":           [0x01B322, 1],
    "Arachne":        [0x01B323, 0], "Student Witch":   [0x01B323, 1],
    "Evil Butcher":   [0x01B324, 0], "Fleaman":         [0x01B324, 1],
    "Altair":         [0x01B325, 0], "Waiter Skeleton": [0x01B325, 1],
    "Cockatrice":     [0x01B326, 0], "Mudman":          [0x01B326, 1],
    "Harpy":          [0x01B327, 0], "Werewolf":        [0x01B327, 1],
    "Needles":        [0x01B328, 0], "Une":             [0x01B328, 1],
    "Ukoback":        [0x01B329, 0], "Man-Eater":       [0x01B329, 1],
    "Disc Armor":     [0x01B32A, 0], "Fish Head":       [0x01B32A, 1],
    "Slime":          [0x01B32B, 0], "Nightmare":       [0x01B32B, 1],
    "Ripper":         [0x01B32C, 0], "Dryad":           [0x01B32C, 1],
    "Weretiger":      [0x01B32D, 0], "Werejaguar":      [0x01B32D, 1],
    "Mandragora":     [0x01B32E, 0], "Biphron":         [0x01B32E, 1],
    "Skull Millione": [0x01B32F, 0], "Beam Skeleton":   [0x01B32F, 1],
    "Gladiator":      [0x01B330, 0], "Gaint Skeleton":  [0x01B330, 1],
    "Flame Demon":    [0x01B331, 0], "Demon Lord":      [0x01B331, 1],
    "Valkyrie":       [0x01B332, 0], "Lightning Doll":  [0x01B332, 1],
    "Red Minotaur":   [0x01B333, 0], "Bomber Armor":    [0x01B333, 1],
    "Balore":         [0x01B334, 0], "Legion":          [0x01B334, 1],
    "Nemesis":        [0x01B335, 0], "Killer Doll":     [0x01B335, 1],
    "Kyoma Demon":    [0x01B336, 0], "Killer Mantle":   [0x01B336, 1],
                                     "Chronomage":      [0x01B337, 1]
}

red_copy_offset = 28

blue_souls = {
    "Giant Bat":      [0x01B354, 0], "Flying Armor":  [0x01B354, 1],
    "Buer":           [0x01B355, 0], "Black Panther": [0x01B355, 1],
    "Giant Ghost":    [0x01B356, 0], "Witch":         [0x01B356, 1],
    "Great Armor":    [0x01B357, 0], "Final Guard":   [0x01B357, 1],
    "Bone Pillar":    [0x01B358, 0], "Catoblepas":    [0x01B358, 1],
    "Big Golem":      [0x01B359, 0], "Cagnazzo":      [0x01B359, 1],
    "Creaking Skull": [0x01B35A, 0], "Shadow Knight": [0x01B35A, 1],
    "Persephone":     [0x01B35B, 0], "Medusa Head":   [0x01B35B, 1],
    "Devil":          [0x01B35C, 0], "Alura Une":     [0x01B35C, 1],
    "Curly":          [0x01B35D, 0], "Manticore":     [0x01B35D, 1],
    "Imp":            [0x01B35E, 0], "Sky Fish":      [0x01B35E, 1],
    "Death":          [0x01B35F, 0], "Alastor":       [0x01B35F, 1]
}

blue_copy_offset = 13

yellow_souls = {
    "Skula":           [0x01B36E, 0], "Undine":         [0x01B36E, 1],
    "Iron Golem":      [0x01B36F, 0], "Zombie Officer": [0x01B36F, 1],
    "Peeping Eye":     [0x01B370, 0], "Dead Warrior":   [0x01B370, 1],
    "Flesh Golem":     [0x01B371, 0], "Succubus":       [0x01B371, 1],
    "Giant Work":      [0x01B372, 0], "Tsuchinoko":     [0x01B372, 1],
    "Zombie":          [0x01B373, 0], "Wooden Golem":   [0x01B373, 1],
    "Headhunter":      [0x01B374, 0], "Lubicant":       [0x01B374, 1],
    "Erinys":          [0x01B375, 0], "Basilisk":       [0x01B375, 1],
    "Arc Demon":       [0x01B376, 0], "Mimic":          [0x01B376, 1],
    "Ectoplasm":       [0x01B377, 0], "Poison Worm":    [0x01B377, 1],
    "Skeleton Knight": [0x01B378, 0], "Gargoyle":       [0x01B378, 1],
    "Golem":           [0x01B379, 0], "Minotaur":       [0x01B379, 1],
    "White Dragon":    [0x01B37A, 0], "Triton":         [0x01B37A, 1],
    "Gorgon":          [0x01B37B, 0], "Quezlcoatl":     [0x01B37B, 1],
    "Red Crow":        [0x01B37C, 0], "Dead Crusader":  [0x01B37C, 1],
    "Bael":            [0x01B37D, 0], "Lilith":         [0x01B37D, 1],
    "Ghost Dancer":    [0x01B37E, 0], "Stolas":         [0x01B37E, 1],
                                      "Gremlin":        [0x01B37F, 1]
}

yellow_copy_offset = 18

function has_all_souls(souls, copy_offset) {
    cond = always_true()
    for soul in souls {
        if (souls[soul][1] == 0) {
            cond = cond && (high4(souls[soul][0]) + high4(souls[soul][0] + copy_offset)) >= 1
        } else {
            cond = cond && (low4(souls[soul][0]) + low4(souls[soul][0] + copy_offset)) >= 1
        }
    }
    return cond
}

function just_got_all_souls(souls, copy_offset) {
    prev_cond = always_false()
    for soul in souls {
        if (souls[soul][1] == 0) {
            prev_cond = prev_cond || (prev(high4(souls[soul][0]))
                                      + prev(high4(souls[soul][0] + copy_offset))) == 0
        } else {
            prev_cond = prev_cond || (prev(low4(souls[soul][0]))
                                      + prev(low4(souls[soul][0] + copy_offset))) == 0
        }
    }
    return has_all_souls(souls, copy_offset) && prev_cond
}

function just_got_all_red_souls()    => just_got_all_souls(red_souls, red_copy_offset)
function just_got_all_blue_souls()   => just_got_all_souls(blue_souls, blue_copy_offset)
function just_got_all_yellow_souls() => just_got_all_souls(yellow_souls, yellow_copy_offset)

// Ticket 22128: I restarted the game in Hard mode, bringing all the souls I had already caught in the other journey. I
//               took all the souls, not only the yellow ones, but also the blue and red ones, but I didn't get any of
//               the 3 achievements.
//               MD5: Unknown
//               Emulator: RetroArch (VBA-M)
// Ticket 20320: The memory values the achievements are watching reset when starting a new game from a previous file,
//               despite the souls carrying over.
//               I hope this isn't intentional, because there's nothing in-game that tells you if you got a soul in
//               _this_ playthrough, and grinding them out is tedious enough as it is.
//               //               https://cdn.discordapp.com/attachments/249643131404943370/601462061976780812/unknown.png
//               MD5: e7470df4d241f73060d14437011b90ce
achievement(
    title = "Yellow Soul Collector", description = "Obtained All (YELLOW) Souls", points = 25,
    id = 3156, badge = "03635", published = "10/4/2013 5:11:19 AM", modified = "3/15/2019 6:45:43 AM",
    trigger =
        never(prev(max_hp_high()) == 0)
        && just_got_all_yellow_souls()
)

// Ticket 22129: I restarted the game in Hard mode, bringing all the souls I had already caught in the other journey. I
//               took all the souls, not only the yellow ones, but also the blue and red ones, but I didn't get any of
//               the 3 achievements.
//               MD5: Unknown
//               Emulator: RetroArch (VBA-M)
// Ticket 20321: The memory values the achievements are watching reset when starting a new game from a previous file,
//               despite the souls carrying over.
//               I hope this isn't intentional, because there's nothing in-game that tells you if you got a soul in
//               _this_ playthrough, and grinding them out is tedious enough as it is.
//               //               https://cdn.discordapp.com/attachments/249643131404943370/601462061976780812/unknown.png
//               MD5: e7470df4d241f73060d14437011b90ce
achievement(
    title = "Blue Soul Collector", description = "Obtained All (BLUE) Souls", points = 25,
    id = 3157, badge = "03636", published = "10/4/2013 5:30:33 AM", modified = "3/15/2019 6:51:22 AM",
    trigger =
        never(prev(max_hp_high()) == 0)
        && just_got_all_blue_souls()
)

// Ticket 22131: I restarted the game in Hard mode, bringing all the souls I had already caught in the other journey. I
//               took all the souls, not only the yellow ones, but also the blue and red ones, but I didn't get any of
//               the 3 achievements.
//               MD5: Unknown
//               Emulator: RetroArch (VBA-M)
// Ticket 20319: The memory values the achievements are watching reset when starting a new game from a previous file,
//               despite the souls carrying over.
//               I hope this isn't intentional, because there's nothing in-game that tells you if you got a soul in
//               _this_ playthrough, and grinding them out is tedious enough as it is.
//               //               https://cdn.discordapp.com/attachments/249643131404943370/601462061976780812/unknown.png
//               MD5: e7470df4d241f73060d14437011b90ce
achievement(
    title = "Red Soul Collector", description = "Obtained all (RED) Souls", points = 25,
    id = 3144, badge = "03616", published = "10/3/2013 6:36:31 AM", modified = "10/14/2019 9:27:06 PM",
    trigger =
        never(prev(max_hp_high()) == 0)
        && just_got_all_red_souls()
)
