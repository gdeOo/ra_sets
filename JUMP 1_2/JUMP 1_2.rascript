// ~Hack~ JUMP 1/2 | Janked Up Mario Party 1/2
// #ID = 8272

game_mode__addr = 0x000100
game_mode__mem = byte(game_mode__addr)

function in_overworld() => game_mode__mem == 0x0e
function in_a_stage()   => game_mode__mem == 0x14
function just_entered_a_stage() => prev(game_mode__mem) != 0x14 && in_a_stage()

stage_id__addr = 0x0013bf
stage_id__mem = byte(stage_id__addr)
stage_id__values = {
    "Yoshi's House":                      0x71,
    "BEGINNER FRIENDLY":                  0x26,
    "JANK TOWN USA":                      0x6c,
    "Home Run Derby - Baseball Bat":      0x18,
    "Over HIlls and Valleys":             0x2d,
    "Hot Kickin'":                        0x30,
    "Spooooooooky Cave":                  0x2c,
    "Offline Fencing":                    0x47,
    "Helium Caverns":                     0x1e,
    "Bastion 2 Blue":                     0x02,
    "Where No Man Lands":                 0x4f,
    "THIS WHAT GOD FEEL LIKE":            0x66,
    "Riverside Camping Site":             0x72,
    "Destiny of Grassland":               0x4a,
    "VLDC Media Player":                  0x7d,
    "The Rhineland":                      0x27,
    "River of the Living Beards":         0x7e,
    "JUMPING TIME":                       0x2e,
    "Peer Pressure":                      0x25,
    "WINNERS DON'T USE DRUGS":            0x2f,
    "When Porcupuffers Fly":              0x11,
    "Midday and Midnight":                0x5b,
    "PUNCHLINE":                          0x63,
    "Dynamic Dungeon":                    0x0b,
    "Oasis Utility Center":               0x73,
    "Desert Artillery Range":             0x03,
    "Arduous Harbor":                     0x4b,
    "ILLUSIYELLOW":                       0x50,
    "The Bootstrapped":                   0x39,
    "Big Bubble Watchers":                0x4d,
    "Do They Float":                      0x34,
    "Treehouse of the Parakoopas":        0x05,
    "The Lost Lotus Forest":              0x5d,
    "Quillstamp Melody":                  0x3d,
    "hongry plants":                      0x20,
    "i saw you in the forest":            0x68,
    "Koopa Khaos":                        0x43,
    "Bunny Hop":                          0x77,
    "Brain Plague":                       0x78,
    "this group of trees is cOLD":        0x10,
    "the forest has dangerous creatures": 0x04,
    "Caliginous Coppice":                 0x2a,
    "Rubicon":                            0x6d,
    "Do Pilots Wear Capes?":              0x08,
    "Spin Around Spiny":                  0x3a,
    "Worn-out Bridge":                    0x3b,
    "Botanical Plant":                    0x12,
    "Misty Mountain Pass":                0x22,
    "Mountain of Frugality":              0x24,
    "What the Hell Jr.":                  0x35,
    "DANGER TOWN":                        0x67,
    "Color a Dinosaur":                   0x70,
    "Koopa Hiking Trail":                 0x01,
    "Breakdown Bastion":                  0x14,
    "Brothers in Arms":                   0x1a,
    "Germerican Fusion":                  0x2b,
    "Effortland II 2-Hour Challenge":     0x61,
    "The Goon Docks":                     0x28,
    "Bombs Away!":                        0x6e,
    "Battlefield of the Three Kingdoms":  0x32,
    "if my heart were a bridge level":    0x15,
    "Der Lockere Raum":                   0x3e,
    "IT'S BOUNCE TIME":                   0x36,
    "Inappropriate Grinding":             0x17,
    "Amphibious Species":                 0x37,
    "The Best Level Everest":             0x69,
    "The Ruins of Old New York":          0x23,
    "Paraplegic Olymphics":               0x46,
    "Party in the House":                 0x59,
    "A la recherche du goût perdu":       0x3c,
    "Ugoku suponji tachi no doukutsu":    0x40,
    "NOJUNP NOLIFE":                      0x55,
    "Quarrel in the Quarry":              0x41,
    "Royal Palace":                       0x6b,
    "Storehouse on the Waterfall":        0x74,
    "TITANIC":                            0x51,
    "Cotton Candy Resort":                0x56,
    "Aetherial Ascending":                0x06,
    "Not as Dire Docks":                  0x54,
    "Curse of Discontinuity":             0x29,
    "gutter ball":                        0x07,
    "Selective Water":                    0x0a,
    "Penguin Spankin'":                   0x79,
    "RUDE BRIDGE":                        0x62,
    "THROW":                              0x44,
    "Factory of Necessity":               0x1d,
    "R, B, Y":                            0x52,
    "IMPETUOUS ATHLETIC 2":               0x16,
    "Dire Dire Diet":                     0x19,
    "Earthquake Havoc":                   0x58,
    "BRICK JOKE":                         0x0c,
    "It Was a Dark and Foggy Night":      0x6a,
    "ghost bones.":                       0x1c,
    "Nitroglycerin Betrayal":             0x31,
    "Volcanic Volley":                    0x57,
    "Slaughterbahn":                      0x53,
    "So Sadistic it's Mischievous":       0x33,
    "BOWSER'S CASTLE":                    0x38,
    "Bowser's Cinema":                    0x75,
    "Milky Way Base":                     0x76,
    "NEGATIVE SCHOOL":                    0x49,
    "One Step Forward, Two Jumps Back":   0x5f,
    "WE LOVE PIRANHA":                    0x5a,
    "Perturbing Paste":                   0x5c,
    "Goomball Machine":                   0x21,
    "Edinburgh":                          0x4e,
    "Job V 7":                            0x09,
    "Sunset Tower":                       0x0d,
    "SPACE SPAGHETTIS":                   0x5e,
    "Maw of the Beast":                   0x64,
    "Morsel's House":                     0x0e,
    "The Trap Doors":                     0x4c,
    "XXI":                                0x45,
    "you were holding an umbrella":       0x65,
    "RNG":                                0x48,
    "The Switch of Blue Hue":             0x42,
    "CRIMSON BUTTON EMPORIUM":            0x3f,
    "Green Palace of the Alchemist":      0x1b,
    "Questionable Yellow Switch":         0x0f
}

function in_stage(name) => stage_id__mem == stage_id__values[name]

room_id__addr = 0x00010b
room_id__mem = word(room_id__addr)
room_id__values = {
    "Koopa Hiking Trail": {
        "Hidden message room": 0x01d6
    },
    "The Trap Doors": {
        "Outside Traps 1-8":  0x07a,
        "Trap Rooms 1-8":     0x128,  // only traps past x = 0x400
        "Outside Traps 9-16": 0x17d,
        "Trap Rooms 9-16":    0x17b   // only traps here
    }
}

function in_room(stage_name, room_name) => room_id__mem == room_id__values[stage_name][room_name]
function previous_room_was(stage_name, room_name) => prior(room_id__mem) == room_id__values[stage_name][room_name]

mario_power_up__addr = 0x000019
mario_power_up__mem = byte(mario_power_up__addr)
mario_power_up__values = {
    "small":  0,
    "super":  1,
    "cape":   2,
    "flower": 3
}

function no_powerups() => mario_power_up__mem <= mario_power_up__values["super"]

mario_x__addr = 0x000094
mario_x__mem = word(mario_x__addr)

function mario_is_past(x) => mario_x__mem >= x
function mario_is_before(x) => mario_x__mem < x
function mario_is_between_x(x0, x1) => mario_is_past(x0) && mario_is_before(x1)

mario_y__addr = 0x000096
mario_y__mem = word(mario_y__addr)

function mario_is_above(y) => mario_y__mem > 0x8000 || mario_y__mem < y

moon__bitflags = {
    "BEGINNER FRIENDLY": bit1(0x1ff2)
}

function just_collected_moon(moon_name) {
    return prev(moon__bitflags[moon_name]) == 0 && moon__bitflags[moon_name] == 1
}


achievement(
    id=125116,
    badge="148398",
    title="Early Moon [m]",
    description="Collect the moon in BEGINNER FRIENDLY having entered the stage with no power-ups",
    points=2,
    trigger=(
        never(in_overworld())
        && never(!in_stage("BEGINNER FRIENDLY"))
        
        // entered BEGINNER FRIENDLY without a powerup
        && once(
            just_entered_a_stage()
            && in_stage("BEGINNER FRIENDLY")
            && no_powerups()
        )
        
        // collected the moon
        && just_collected_moon("BEGINNER FRIENDLY")
    )
)


achievement(
    id=125117,
    badge="148339",
    title="Half Single Ladies",
    description="Find and read the hidden message in Koopa Hiking Trail",
    points=3,
    trigger=(
        never(in_overworld())
        && never(!in_stage("Koopa Hiking Trail"))
        && never(!in_room("Koopa Hiking Trail", "Hidden message room"))
        // passed through the B in BEYONCE and E in TIME whilst above the wooden boards
        && once(mario_is_above(0x80) && mario_is_between_x(0x20d, 0x26d))
        && once(mario_is_above(0xb0) && mario_is_between_x(0x52d, 0x5bf))
    )
)

function trap_rooms_trigger() {
    room_entries_trigger = always_true()
    for trap_rooms_def in [
        ["Outside Traps 1-8",  "Trap Rooms 1-8",  [0x4a0, 0x600, 0x710, 0x7a0, 0x910, 0xaa0, 0xb90, 0xc50]],
        ["Outside Traps 9-16", "Trap Rooms 9-16", [0x410, 0x870, 0x590, 0xb80, 0x260, 0x9a0, 0x070, 0x740]]
    ] {
        outside_room = trap_rooms_def[0]
        trap_room = trap_rooms_def[1]
        entrances = trap_rooms_def[2]

        for entrance_x in entrances {
            // the trap rooms are actually on the same room/level, so we use the entrance's X position to
            // differentiate between them
            room_entries_trigger = room_entries_trigger && once(
                previous_room_was("The Trap Doors", outside_room)
                && in_room("The Trap Doors", trap_room)
                && mario_x__mem == entrance_x
            )
        }
    }

    return (
        never(!in_stage("The Trap Doors"))

        // must have entered every trap room at least once
        && room_entries_trigger
        
        // trigger after escaping the last one
        && in_room("The Trap Doors", "Outside Traps 9-16")

        // reset upon death
        && never(in_overworld())
    )
}

achievement(
    id=125118,
    badge="148398"
    title="Miss Me With That Trap Shit",
    description="Escape all 16 trap rooms in The Trap Doors without dying or leaving the stage",
    points=10,
    trigger=trap_rooms_trigger()
)
