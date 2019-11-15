// Castlevania - Aria of Sorrow
// #ID = 510

// $01B27F: MAX HP high
function max_hp_high() => byte(0x01B27F)

red_souls = {
    "Bat":            high4(0x01B31C), "Winged Skeleton": low4(0x01B31C),
    "Merman":         high4(0x01B31D), "Skeleton":        low4(0x01B31D),
    "Skull Archer":   high4(0x01B31E), "Axe Armor":       low4(0x01B31E),
    "Blue Crow":      high4(0x01B31F), "Killer Fish":     low4(0x01B31F),
    "Ghost":          high4(0x01B320), "Zombie Soldier":  low4(0x01B320),
    "Tiny Devil":     high4(0x01B321), "Siren":           low4(0x01B321),
    "Rock Armor":     high4(0x01B322), "Durga":           low4(0x01B322),
    "Arachne":        high4(0x01B323), "Student Witch":   low4(0x01B323),
    "Evil Butcher":   high4(0x01B324), "Fleaman":         low4(0x01B324),
    "Altair":         high4(0x01B325), "Waiter Skeleton": low4(0x01B325),
    "Cockatrice":     high4(0x01B326), "Mudman":          low4(0x01B326),
    "Harpy":          high4(0x01B327), "Werewolf":        low4(0x01B327),
    "Needles":        high4(0x01B328), "Une":             low4(0x01B328),
    "Ukoback":        high4(0x01B329), "Man-Eater":       low4(0x01B329),
    "Disc Armor":     high4(0x01B32A), "Fish Head":       low4(0x01B32A),
    "Slime":          high4(0x01B32B), "Nightmare":       low4(0x01B32B),
    "Ripper":         high4(0x01B32C), "Dryad":           low4(0x01B32C),
    "Weretiger":      high4(0x01B32D), "Werejaguar":      low4(0x01B32D),
    "Mandragora":     high4(0x01B32E), "Biphron":         low4(0x01B32E),
    "Skull Millione": high4(0x01B32F), "Beam Skeleton":   low4(0x01B32F),
    "Gladiator":      high4(0x01B330), "Gaint Skeleton":  low4(0x01B330),
    "Flame Demon":    high4(0x01B331), "Demon Lord":      low4(0x01B331),
    "Valkyrie":       high4(0x01B332), "Lightning Doll":  low4(0x01B332),
    "Red Minotaur":   high4(0x01B333), "Bomber Armor":    low4(0x01B333),
    "Balore":         high4(0x01B334), "Legion":          low4(0x01B334),
    "Nemesis":        high4(0x01B335), "Killer Doll":     low4(0x01B335),
    "Kyoma Demon":    high4(0x01B336), "Killer Mantle":   low4(0x01B336),
                                       "Chronomage":      low4(0x01B337)
}

blue_souls = {
    "Giant Bat":      high4(0x01B354), "Flying Armor":  low4(0x01B354),
    "Buer":           high4(0x01B355), "Black Panther": low4(0x01B355),
    "Giant Ghost":    high4(0x01B356), "Witch":         low4(0x01B356),
    "Great Armor":    high4(0x01B357), "Final Guard":   low4(0x01B357),
    "Bone Pillar":    high4(0x01B358), "Catoblepas":    low4(0x01B358),
    "Big Golem":      high4(0x01B359), "Cagnazzo":      low4(0x01B359),
    "Creaking Skull": high4(0x01B35A), "Shadow Knight": low4(0x01B35A),
    "Persephone":     high4(0x01B35B), "Medusa Head":   low4(0x01B35B),
    "Devil":          high4(0x01B35C), "Alura Une":     low4(0x01B35C),
    "Curly":          high4(0x01B35D), "Manticore":     low4(0x01B35D),
    "Imp":            high4(0x01B35E), "Sky Fish":      low4(0x01B35E),
    "Death":          high4(0x01B35F), "Alastor":       low4(0x01B35F)
}

yellow_souls = {
    "Skula":           high4(0x01B36E), "Undine":         low4(0x01B36E),
    "Iron Golem":      high4(0x01B36F), "Zombie Officer": low4(0x01B36F),
    "Peeping Eye":     high4(0x01B370), "Dead Warrior":   low4(0x01B370),
    "Flesh Golem":     high4(0x01B371), "Succubus":       low4(0x01B371),
    "Giant Work":      high4(0x01B372), "Tsuchinoko":     low4(0x01B372),
    "Zombie":          high4(0x01B373), "Wooden Golem":   low4(0x01B373),
    "Headhunter":      high4(0x01B374), "Lubicant":       low4(0x01B374),
    "Erinys":          high4(0x01B375), "Basilisk":       low4(0x01B375),
    "Arc Demon":       high4(0x01B376), "Mimic":          low4(0x01B376),
    "Ectoplasm":       high4(0x01B377), "Poison Worm":    low4(0x01B377),
    "Skeleton Knight": high4(0x01B378), "Gargoyle":       low4(0x01B378),
    "Golem":           high4(0x01B379), "Minotaur":       low4(0x01B379),
    "White Dragon":    high4(0x01B37A), "Triton":         low4(0x01B37A),
    "Gorgon":          high4(0x01B37B), "Quezlcoatl":     low4(0x01B37B),
    "Red Crow":        high4(0x01B37C), "Dead Crusader":  low4(0x01B37C),
    "Bael":            high4(0x01B37D), "Lilith":         low4(0x01B37D),
    "Ghost Dancer":    high4(0x01B37E), "Stolas":         low4(0x01B37E),
                                        "Gremlin":        low4(0x01B37F)
}

function has_all_souls(souls) {
    cond = always_true()
    for soul in souls {
        cond = cond && souls[soul] >= 1
    }
    return cond
}

function just_got_all_souls(souls) {
    prev_cond = always_false()
    for soul in souls {
        prev_cond = prev_cond || repeated(120, souls[soul] == 0)
    }
    return has_all_souls(souls) && prev_cond
}

function just_got_all_red_souls()    => just_got_all_souls(red_souls)
function just_got_all_blue_souls()   => just_got_all_souls(blue_souls)
function just_got_all_yellow_souls() => just_got_all_souls(yellow_souls)

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
