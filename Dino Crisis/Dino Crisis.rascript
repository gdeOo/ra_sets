// Dino Crisis
// #ID = 11318

// -------------------------------------------
//   R E G I O N   C O M P A T I B I L I T Y
// -------------------------------------------

// The set was developed using the original USA version
// (not Rev 1 / Greatest Hits).
//
// Literally every other version of the game has incompatible memory.
//
// For non-Japan versions (eur, fr, de, it, sp and usa rev 1), all memory
// addresses are offset by the same amount, except for the debriefing-related
// addresses, which are offset by a different amount). These versions
// could be supported, though at a huge cost for code readability.
//
// The Japan version has different "padding", meaning that the offset relative
// to the USA version increases as we progress in memory. Supporting this
// version would be much more troublesome, since most memory addresses would
// have to be individually checked.

// each region is a list of (addr, offset) tuple, ordered by ascending addr,
// each of which means that the offset should be applied to addresses under
// addr (0x0 means until the end). for example:
//   [[0xef3b0,  0x04a8],  -> apply 0x04a8 offset for addresses < 0xef3b0
//    [0x00000, -0x03f0]]  -> apply -0x03f0 offset for all addresses >= 0xef3b0
region_offsets = {
    "Europe":      [[0xef3b0,  0x04a8], [0x00000, -0x03f0]],
    "France":      [[0xef3b0, -0x74e8], [0x00000,  0x0e70]],
    "Germany":     [[0xef3b0, -0x76a0], [0x00000,  0x0f90]],
    "Italy":       [[0xef3b0, -0x8084], [0x00000,  0x0ff0]],
    "Spain":       [[0xef3b0, -0x7648], [0x00000,  0x0e48]],
    "USA (Rev 1)": [[0xef3b0, -0x01d0], [0x00000, -0x03f0]],
    
    // Japan version is undermapped, the boundaries would have to be adjusted
    "Japan":       [[0xb7a48, -0xb208], [0xc6103, -0xb398], [0xc7c42, -0xb3a0], [0x00000, -0xb39f]]
}

// -------------
//   U T I L S
// -------------

function just_changed(mem, from_val, to_val) => prev(mem) == from_val && mem == to_val
function just_changed_from(mem, from_val) => prev(mem) == from_val && mem != from_val
function just_changed_to(mem, to_val) => prev(mem) != to_val && mem == to_val

function secs_to_frames(secs) => secs * 60

function is_negative_word(word_addr) => bit7(word_addr + 1) == 1
function was_negative_word(word_addr) => prev(bit7(word_addr + 1)) == 1

//
// Game

buttons_pressed__addr = 0xc2550
buttons_pressed__flags = {
    "Square":   bit7(buttons_pressed__addr),
    "X":        bit6(buttons_pressed__addr),
    "Circle":   bit5(buttons_pressed__addr),
    "Triangle": bit4(buttons_pressed__addr),
    "R1":       bit3(buttons_pressed__addr),
    "L1":       bit2(buttons_pressed__addr),
    "R2":       bit1(buttons_pressed__addr),
    "L2":       bit0(buttons_pressed__addr),
    "Left":     bit7(buttons_pressed__addr + 1),
    "Down":     bit6(buttons_pressed__addr + 1),
    "Right":    bit5(buttons_pressed__addr + 1),
    "Up":       bit4(buttons_pressed__addr + 1),
    "Pause":    bit3(buttons_pressed__addr + 1),
    "Select":   bit0(buttons_pressed__addr + 1)
}

mode_id__addr = 0xb7a48
mode_id__mem = byte(mode_id__addr)
mode_id__values = {
    // not sure about these... 1 & 2 are used in many instances other than in the opening
    // "Main Menu":        0x00,
    // "Mission Briefing": 0x01,
    "Loading":          0x02,
    "Gameplay":         0x03,
    "Game Over":        0x04,
    "In-Game Menu":     0x05,
    "Entering Room":    0x06,
    "Saving":           0x07,
    "Select Menu":      0x08,
    "Heliport CG":      0x09,
    "Ending CG":        0x0a  // very briefly, actually 0x01 while CG plays
    // 0x0a trigger a CG movie
    // 0x0b+ are related to operation wipeout
}

function in_mode(name) => mode_id__mem == mode_id__values[name]
function game_over() => in_mode("Game Over")

mission_stage__addr = 0xb7a2a
mission_stage__mem = byte(mission_stage__addr)
mission_stage__values = {
    "Pre Heliport CG":         0x00,
    "In/Post Heliport CG":     0x01,
    "In Gail's Bad Ending CG": 0x02,
    "In Rick's Bad Ending CG": 0x03,
    "In Best Ending CG":       0x04,
    "Post Ending CG":          0x05
}

function in_ending() => mission_stage__mem > mission_stage__values["In/Post Heliport CG"]
function in_post_ending_cg() => mission_stage__mem == mission_stage__values["Post Ending CG"]

cur_ending__addr = 0xb7a5b
cur_ending__mem = byte(cur_ending__addr)
cur_ending__values = { "Gail's Bad Ending": 0, "Rick's Bad Ending": 1, "Best Ending": 2 }

function any_ending_cg_just_started() => just_changed_to(mode_id__mem, mode_id__values["Ending CG"])

function ending_cg_just_started(name) {
    return just_changed_to(mode_id__mem, mode_id__values["Ending CG"])
           && cur_ending__mem == cur_ending__values[name]
}

in_cutscene__addr = 0xb7a5d
in_cutscene__mem = bit4(in_cutscene__addr)
function in_cutscene() => in_cutscene__mem == 1
function cur_cutscene_just_ended() => just_changed(in_cutscene__mem, 1, 0)

paused__addr = 0xb7a5f
paused__mem = bit5(paused__addr)
function game_paused() => paused__mem == 1

camera_id__addr = 0xb7b3c
camera_id__mem = byte(camera_id__addr)
function camera_id() => camera_id__mem

room_id__addr = 0xc14c0
room_id__mem = byte(room_id__addr)

floor_id__addr = 0xc14c1
floor_id__mem = byte(floor_id__addr)

room_floor_id__mem = word(room_id__addr)

num_saves__addr = 0xc14c3
num_saves__mem = byte(num_saves__addr)

timer__addr = 0xc14c4
timer__mem = dword(timer__addr)

game_mode__addr = 0xc14c8
game_mode__mem = byte(game_mode__addr)
game_mode__values = { "Normal": 0, "Easy": 1 }
function in_game_mode(name) => game_mode__mem == game_mode__values[name]

num_continues__addr = 0xc14ca
num_continues__mem = byte(num_continues__addr)

// -------------------------
//   U N L O C K A B L E S
// -------------------------

endings_viewed__addr = 0xc14d3
endings_viewed__flags = {
    "Gail's Bad Ending": bit2(endings_viewed__addr),
    "Rick's Bad Ending": bit1(endings_viewed__addr),
    "Best Ending":       bit0(endings_viewed__addr)
}

function viewed_endings() {
    total = 0
    for ending in endings_viewed__flags {
        total = total + endings_viewed__flags[ending]
    }
    return total
}

function viewed_n_endings(n) => viewed_endings() == n

function just_reached_n_endings_viewed(n) {
    prev_total = 0
    for ending in endings_viewed__flags {
        prev_total = prev_total + prev(endings_viewed__flags[ending])
    }
    total = 0
    for ending in endings_viewed__flags {
        total = total + endings_viewed__flags[ending]
    }
    return prev_total == (n - 1) && total == n
}

unlocked_costumes__addr = 0xc1cf4
unlocked_costumes__flags = {
    "Spy Type":     bit0(unlocked_costumes__addr),
    "Army Type":    bit1(unlocked_costumes__addr),
    "Battle Type":  bit2(unlocked_costumes__addr),
    "Ancient Type": bit3(unlocked_costumes__addr)
}

function just_unlocked_costume(name) => just_changed(unlocked_costumes__flags[name], 0, 1)

cur_costume__addr = 0xc1cf3
cur_costume__mem = byte(cur_costume__addr)
cur_costume__values = {
    "Spy Type":     0,
    "Army Type":    1,
    "Battle Type":  2,
    "Ancient Type": 3
}

function wearing_costume(name) => cur_costume__mem == cur_costume__values[name]

//
// Regina

// there are a bunch more addresses related to animations / character state
// around these, but it's not worth it to map everything...
animation_main__addr = 0xb9499
animation_main__mem = byte(animation_main__addr)
animation_main__values = {
    "Standing Still":          0x00,
    "Walking Forwards":        0x01,
    "Walking Backwards":       0x02,
    "Rotating In-Place":       0x04,
    "Running":                 0x05,
    "Aiming":                  0x06,
    "Push Object":             0x07,
    "Pick Object From Ground": 0x08,
    "180 Turn":                0x09,
    "Taking Damage":           0x0a
}
animation_sub__addr = 0xb949a
animation_sub__mem = byte(animation_sub__addr)
animation_sub__values = {
    "Standing Still": {
        "Completely Still":      0x00,
        "Wobbling":              0x01,
        "Hand On Hip, Still":    0x02,
        "Hand On Hip, Wobbling": 0x03,
        "Hurting":               0x04
    },
    "Running": {
        "Accelerating": 0x01,
        "Full Speed":   0x02
    },
    "Aiming": {
        "Aiming":            0x01,
        "Shooting":          0x02,
        "Cocking":           0x03,
        "Stop Aiming":       0x04,
        "Walking Forwards":  0x05,
        "Walking Backwards": 0x06,
        "Rotating In-Place": 0x07
    }
}

function standing_still() => animation_main__mem == animation_main__values["Standing Still"]
function aiming() => animation_main__mem == animation_main__values["Aiming"]

function moving() {
    return animation_main__mem == animation_main__values["Walking Forwards"]
           || animation_main__mem == animation_main__values["Walking Backwards"]
           || animation_main__mem == animation_main__values["Rotating In-Place"]
           || animation_main__mem == animation_main__values["Running"]
           || animation_main__mem == animation_main__values["180 Turn"]
}

speed__addr = 0xb94a0
speed__mem = word(speed__addr)  // signed

health__addr = 0xb9574
health__mem = word(health__addr)
function just_took_non_bleed_damage() => (prev(health__mem) - health__mem) > 1

ew_coord__addr = 0xb9598
ew_coord__mem = word(ew_coord__addr)  // signed
ns_coord__addr = 0xb959a
ns_coord__mem = word(ns_coord__addr)  // signed

function on_east_side() => !is_negative_word(ew_coord__addr)
function on_west_side() => is_negative_word(ew_coord__addr)

function on_north_side() => !is_negative_word(ns_coord_addr)
function on_south_side() => is_negative_word(ns_coord_addr)

function crossed_ns_origin_heading_north() => was_negative_word(ns_coord__addr) && !is_negative_word(ns_coord__addr)

collision_dir__addr = 0xb959e
collision_dir__mem = byte(collision_dir__addr)
collision_dir__values = {"None": 0, "South": 1, "East": 2, "North": 3, "West": 4}

cur_weapon__addr = 0xb969c
cur_weapon__mem = byte(cur_weapon__addr)
cur_weapon__values = {
    "Shotgun":           0x10,
    "Shotgun Custom":    0x11,
    "Shotgun + Stock":   0x12,
    "SG Custom + Stock": 0x13,
    "Handgun":           0x20,
    "Handgun + Sight":   0x21,
    "Handgun Custom":    0x22,
    "HG Custom + Sight": 0x23,
    "Grenade Gun":       0x30,
    "GG Custom":         0x31
}

function cur_weapon_is_handgun() => high4(cur_weapon__addr) == 2
function cur_weapon_is_grenade_gun() => high4(cur_weapon__addr) == 3

is_shooting__addr = 0xb9683
is_shooting__mem = bit4(is_shooting__addr)
function is_shooting() => is_shooting__mem == 1
function just_started_shooting() => just_changed(is_shooting__mem, 0, 1)

shotgun_num_bullets__addr = 0xb96a0
shotgun_num_bullets__mem = byte(shotgun_num_bullets__addr)

shotgun_cur_ammo__addr = 0xb96a1
shotgun_cur_ammo__mem = byte(shotgun_cur_ammo__addr)
shotgun_cur_ammo__values = {
    "SG Bullets":   0x00,
    "Slag Bullets": 0x01,
    "An. Dart S":   0x02,
    "An. Dart M":   0x03,
    "An. Dart L":   0x04,
    "Poison Dart":  0x05,
}

handgun_num_bullets__addr = 0xb96a2
handgun_num_bullets__mem = byte(handgun_num_bullets__addr)

handgun_cur_ammo__addr = 0xb96a3
handgun_cur_ammo__mem = byte(handgun_cur_ammo__addr)
handgun_cur_ammo__values = {
    "9mm Parabellum": 0x06,
    "40S&W Bullets":  0x07
}

grenade_gun_cur_ammo__addr = 0xb96a5
grenade_gun_cur_ammo__mem = byte(grenade_gun_cur_ammo__addr)
grenade_gun_cur_ammo__values = {
    "Grenade Bullets": 0x08,
    "Heat Bullets":    0x09,
    "Inf. Grenades":   0x0a
}

map__flags = {
    "Main Entrance 1F":                       bit7(0xc15d0),
    "Control Room 1F":                        bit6(0xc15d0),
    "Control Room Hall":                      bit5(0xc15d0),
    "Strategy Room":                          bit4(0xc15d0),
    "Management Office":                      bit3(0xc15d0),
    "Management Office Hallway":              bit2(0xc15d0),
    "Toilet":                                 bit1(0xc15d0),
    "Locker Room":                            bit0(0xc15d0),

    "Backup Generator Room 1F":               bit7(0xc15d1),
    "Passageway to the Backup Generator":     bit6(0xc15d1),
    "Backyard of the Facility":               bit5(0xc15d1),
    "Material Storage":                       bit4(0xc15d1),
    "Office":                                 bit3(0xc15d1),
    "Office Hallway":                         bit2(0xc15d1),
    "Lecture Room":                           bit1(0xc15d1),
    "Lecture Room Hallway":                   bit0(0xc15d1),
    
    "Chief's Room":                           bit7(0xc15d2),
    "Passageway to the Communication Area":   bit6(0xc15d2),
    "Comm Antenna Room":                      bit5(0xc15d2),
    // "Passageway to the Backup Generator"   bit4(0xc15d2),
    "Elevator Hall":                          bit3(0xc15d2),
    "The Backyard":                           bit2(0xc15d2),
    // nothing in 1F                          bit1(0xc15d2),
    // nothing in 1F                          bit0(0xc15d2),

    "Gas Experiment Room":                    bit7(0xc15d3),
    "Research Meeting Room":                  bit6(0xc15d3),
    "Research Area Hall":                     bit5(0xc15d3),
    "Experiment Simulation Room":             bit4(0xc15d3),
    "Main Entrance 2F":                       bit3(0xc15d3),
    "Communication Room":                     bit2(0xc15d3),
    "Lounge":                                 bit1(0xc15d3),
    "Hall 2F":                                bit0(0xc15d3),
    
    "Backup Generator Room B1":               bit7(0xc15d4),
    "Hallway for Carrying in Materials":      bit6(0xc15d4),
    "Hall B1":                                bit5(0xc15d4),
    "Medical Room":                           bit4(0xc15d4),
    "Medical Room Hallway":                   bit3(0xc15d4),
    "Main Hallway B1":                        bit2(0xc15d4),
    "Library Room":                           bit1(0xc15d4),
    "Computer Room":                          bit0(0xc15d4),
    
    "Large Size Elevator Passageway":         bit7(0xc15d5),
    "Heliport":                               bit6(0xc15d5),
    "Hangar":                                 bit5(0xc15d5),
    "Passageway to the Heliport":             bit4(0xc15d5),
    "Front Area of Entrance":                 bit3(0xc15d5),
    // "Hall B1"                              bit2(0xc15d5),
    // "Hallway for Carrying in Materials"    bit1(0xc15d5),
    "Carrying Out Room B1":                   bit0(0xc15d5),
    
    "Liaison Elevator No. 1":                 bit7(0xc15d6),
    "Materials Room":                         bit6(0xc15d6),
    "Underground Passageway to the Facility": bit5(0xc15d6),
    "Liaison Elevator No. 2":                 bit4(0xc15d6),
    "Elevator Power Room":                    bit3(0xc15d6),
    "Passageway to the Power Room":           bit2(0xc15d6),
    "Large Size Elevator Control Room":       bit1(0xc15d6),
    "Large Size Elevator":                    bit0(0xc15d6),
    
    "Security Pass Room":                     bit7(0xc15d7),
    "Researcher Rest Room":                   bit6(0xc15d7),
    "Stabilizer Design Room":                 bit5(0xc15d7),
    "Stabilizer Experiment Room":             bit4(0xc15d7),
    "Experiment Room Hall":                   bit3(0xc15d7),
    // nothing in B2                          bit2(0xc15d7),
    "Passageway to the Experiment Area":      bit1(0xc15d7),
    // nothing in 1F                          bit0(0xc15d7),
    
    "Dr. Kirk's Personal Lab":                bit7(0xc15d8),
    "Passageway to Personal Lab":             bit6(0xc15d8),
    "Power Freq Room":                        bit5(0xc15d8),
    "Third Energy Control Room":              bit4(0xc15d8),
    "unnamed 1":                              bit3(0xc15d8),  // unnamed, unreachable (?) in Facility B3
    "Third Energy Area B2":                   bit2(0xc15d8),
    "Passageway":                             bit1(0xc15d8),
    "Parts Storage":                          bit0(0xc15d8),
    
    "Rest Station":                           bit7(0xc15d9),
    "Passageway to the Carrying Out Room":    bit6(0xc15d9),
    "Control Room B3":                        bit5(0xc15d9),
    "Backup Generator Room B3":               bit4(0xc15d9),
    "Carrying Out Room B3":                   bit3(0xc15d9),
    // "Stabilizer Experiment Room"           bit2(0xc15d9),
    // "Third Energy Control Room"            bit1(0xc15d9),
    "Dr. Kirk's Library Room":                bit0(0xc15d9),
    
    "unnamed 2":                              bit7(0xc15d0),  // unnamed, unreachable (?) in Facility B3
    "Passageway to the Port":                 bit6(0xc15d0),
    "Port":                                   bit5(0xc15d0),
    "Disembarkation Immigration Office":      bit4(0xc15d0),
    "Central Stairway":                       bit3(0xc15d0),
    "Special Weapons Storage":                bit2(0xc15d0),
    "Transport Passageway":                   bit1(0xc15d0),
    "General Weapons Storage":                bit0(0xc15d0),
    
    "Port Transport Passageway":              bit7(0xc15d1),
    // "Port"                                 bit6(0xc15d1),
    // same as bit7(0xc15d0)                  bit5(0xc15d1),
    "Heliport Transport Passageway":          bit4(0xc15d1),
    "Hovercraft Storage":                     bit3(0xc15d1),
    "Large Size Elevator B3":                 bit2(0xc15d1),
    // nothing in B3                          bit1(0xc15d1),
    "Underground Heliport":                   bit0(0xc15d1),
}

function just_unlocked_room_map(name) => map__flags[name] == 1

items__flags = {
    "BG Room B1 Key":                   bit7(0xc15ad),
    "Entrance Key":                     bit6(0xc15ad),
    "Small Size Key":                   bit5(0xc15ad),
    "Locker Room Key":                  bit4(0xc15ad),
    "Plug":                             bit3(0xc15ad),  // TODO: quantity. just setting this makes quantity = 0
    // nothing                          bit2(0xc15ad),
    // nothing                          bit1(0xc15ad),
    // nothing                          bit0(0xc15ad),    
    
    "Key Card Lv. D":                   bit7(0xc15ae),
    "ID Card (Researcher)":             bit6(0xc15ae),
    "Comm. ID Card":                    bit5(0xc15ae),
    "ID Card (Colonel)":                bit4(0xc15ae),
    "unnamed key":                      bit3(0xc15ae),  // unnamed
    "Port Card Key":                    bit2(0xc15ae),
    "C. O. Area Key":                   bit1(0xc15ae),
    "BG Area Key":                      bit0(0xc15ae),
    
    "Startup Batt. R (Uncharged)":      bit7(0xc15af),
    "Panel Key 2":                      bit6(0xc15af),
    "Panel Key 1":                      bit5(0xc15af),
    "C. O. Press Card":                 bit4(0xc15af),
    "ID Card (Project Superintendent)": bit3(0xc15af),
    "Key Card Lv. A":                   bit2(0xc15af),
    "Key Card Lv. B":                   bit1(0xc15af),
    "Key Card Lv. C":                   bit0(0xc15af),
    
    "Key Card L":                       bit7(0xc15b0),
    "B1 Key Chip (Not Rewritten)":      bit6(0xc15b0),
    "Antenna Key":                      bit5(0xc15b0),
    "Screwdriver":                      bit4(0xc15b0),
    "B1 Crane Card":                    bit3(0xc15b0),
    "F. C. Device (With Data)":         bit2(0xc15b0),
    "F. C. Device (No Data)":           bit1(0xc15b0),
    "Startup Batt. R (Charged)":        bit0(0xc15b0),

    "Protect P. 2-A":                   bit7(0xc15b1),
    "Protect P. 1-A":                   bit6(0xc15b1),
    "Initializer":                      bit5(0xc15b1),
    "Stabilizer":                       bit4(0xc15b1),
    "B3 Crane Card 3":                  bit3(0xc15b1),
    "B3 Crane Card 2":                  bit2(0xc15b1),
    "B3 Crane Card 1":                  bit1(0xc15b1),
    "Key Card R":                       bit0(0xc15b1),
    
    "B2 Key Chip 2":                    bit7(0xc15b2),
    "B2 Key Chip 1":                    bit6(0xc15b2),
    "Nucleum":                          bit5(0xc15b2),
    "Energy Tank":                      bit4(0xc15b2),
    "Core Parts 2":                     bit3(0xc15b2),
    "Core Parts 1":                     bit2(0xc15b2),
    "Protect P. 2-B":                   bit1(0xc15b2),
    "Protect P. 1-B":                   bit0(0xc15b2),
    
    // "B2 Key Chip 1"                  bit7(0xc15b3),
    "B1 Key Chip (Rewritten)":          bit6(0xc15b3),
    "Researcher Memo":                  bit5(0xc15b3),
    "unnamed EX":                       bit4(0xc15b3),  // unnamed
    "Secret Disc":                      bit3(0xc15b3),
    "Startup Batt. W":                  bit2(0xc15b3),
    "Startup Batt. R":                  bit1(0xc15b3),
    "Pulse Receiver":                   bit0(0xc15b3),
    
    "DDK Input Disc S":                 bit7(0xc15b4),
    "DDK Input Disc W":                 bit6(0xc15b4),
    "DDK Input Disc E":                 bit5(0xc15b4),
    "DDK Input Disc L":                 bit4(0xc15b4),
    "DDK Input Disc N":                 bit3(0xc15b4),
    "DDK Input Disc H":                 bit2(0xc15b4),
    "Planning Disc":                    bit1(0xc15b4),
    // "B2 Key Chip 2"                  bit0(0xc15b4),
    
    "DDK Code Disc D":                  bit7(0xc15b5),
    "DDK Code Disc S":                  bit6(0xc15b5),
    "DDK Code Disc W":                  bit5(0xc15b5),
    "DDK Code Disc E":                  bit4(0xc15b5),
    "DDK Code Disc L":                  bit3(0xc15b5),
    "DDK Code Disc N":                  bit2(0xc15b5),
    "DDK Code Disc H":                  bit1(0xc15b5),
    "DDK Input Disc D":                 bit0(0xc15b5)
}

// -------------------
//   S U P P L I E S
// -------------------

supplies__arr_addr = 0xc18cc
supplies__arr_size = 10
supplies__struct_fields = {
    "id":       0x00,  // byte
    "quantity": 0x01,  // byte
    "level":    0x02,  // byte (used for the +s of supplies)
    // unknown byte
}
supplies__struct_sizeof = 4

function supply_get_id(addr) => byte(addr + supplies__struct_fields["id"])

supply_id__values = {
    "Shotgun":           0x01,
    "Shotgun Custom":    0x02,
    "Shotgun + Stock":   0x03,
    "SG Custom + Stock": 0x04,
    "Handgun":           0x05,
    "Handgun + Sight":   0x06,
    "Handgun Custom":    0x07,
    "HG Custom + Sight": 0x08,
    "Grenade Gun":       0x09,
    "GG Custom":         0x0a,
    "Shotgun Parts":     0x0b,
    "Shotgun Stocks":    0x0c,
    "Handgun Sights":    0x0d,
    "Handgun Slides":    0x0e,
    "GG Parts":          0x0f,
    "SG Bullets":        0x10,
    "Slag Bullets":      0x11,
    "An. Dart S":        0x12,
    "An. Dart M":        0x13,
    "An. Dart L":        0x14,
    "Poison Dart":       0x15,
    "9mm Parabellum":    0x16,
    "40S&W Bullets":     0x17,
    "Grenade Bullets":   0x18,
    "Heat Bullets":      0x19,
    "Infinite Grenades": 0x1a,
    "Hemostat":          0x1b,
    "Med. Pak S":        0x1c,
    "Med. Pak M":        0x1d,
    "Med. Pak L":        0x1e,
    "Resuscitation":     0x1f,
    "An. Aid":           0x20,
    "Recovery Aid":      0x21,
    "Intensifier":       0x22,
    "Multiplier":        0x23
}

// ---------------
//   M I X I N G
// ---------------

mixing_screen__addr = 0xc6103
mixing_screen__mem = byte(mixing_screen__addr)
mixing_screen__values = {
    "Browsing Supplies":    0x00,
    "Selected Supply Menu": 0x01,
    "Mixing Confirmation":  0x02,
    "Mixing Error":         0x03,
    "Mixing Success":       0x04,  // also "Check" supply, use something else to differentiate
}

mixing_left_supply__addr   = 0xc6148
mixing_right_supply__addr  = 0xc614c
mixing_result_supply__addr = 0xc6150

mixing_num_selected_supplies__addr = 0xc6154
mixing_num_selected_supplies__mem = byte(mixing_num_selected_supplies__addr)

function just_mixed(name) {
    return supply_get_id(mixing_result_supply__addr) == supply_id__values[name]
           && mixing_screen__mem == mixing_screen__values["Mixing Success"]
           && mixing_num_selected_supplies__mem == 2
}

// TODO: what are these?
// Max Item Box Modifier Codes
// Slot 1  800C1744 FF??
// Slot 2  800C1748 FF??
// Slot 3  800C174C FF??
// Slot 4  800C1750 FF??
// Slot 5  800C1754 FF??
// Slot 6  800C1758 FF??
// Slot 7  800C175C FF??
// Slot 8  800C1760 FF??
// Slot 9  800C1764 FF??
// Slot 10 800C1768 FF??

// -----------------------------
//   O W N E D   W E A P O N S
// -----------------------------

weapons__values = {
    "Handgun Custom":    bit7(0xc15a8),
    "Handgun + Sight":   bit6(0xc15a8),
    "Handgun":           bit5(0xc15a8),
    "SG Custom + Stock": bit4(0xc15a8),
    "Shotgun + Stock":   bit3(0xc15a8),
    "Shotgun Custom":    bit2(0xc15a8),
    "Shotgun":           bit1(0xc15a8),
    // nothing           bit0(0xc15a8),
    
    "GG Parts":          bit7(0xc15a9),
    "Handgun Slides":    bit6(0xc15a9),
    "Handgun Sights":    bit5(0xc15a9),
    "Shotgun Stocks":    bit4(0xc15a9),
    "Shotgun Parts":     bit3(0xc15a9),
    "GG Custom":         bit2(0xc15a9),
    "Grenade Gun":       bit1(0xc15a9),
    "HG Custom + Sight": bit0(0xc15a9)
}

function just_got_weapon(name) => just_changed(weapons__values[name], 0, 1)

function just_upgraded_weapon(from_weapons, to_weapon) {
    from_cond = always_false()
    for w in from_weapons {
        from_cond = from_cond || just_changed(weapons__values[w], 1, 0)
    }
    return from_cond && just_changed(weapons__values[to_weapon], 0, 1)
}

function has_weapon(name) => weapons__values[name] == 1

function has_no_weapons() {
    cond = always_true()
    for weapon in ["Handgun", "Handgun Custom", "Handgun + Sight", "HG Custom + Sight",
                   "Shotgun", "Shotgun Custom", "Shotgun + Stock", "SG Custom + Stock",
                   "Grenade Gun", "GG Custom"] {
        cond = cond && !has_weapon(weapon)
    }
    return cond
}

num_plugs__addr = 0xc1b00
num_plugs__mem = byte(num_plugs__addr)

fc_device_fingerprint_id__addr = 0xc14ff
fc_device_fingerprint_id__mem = byte(fc_device_fingerprint_id__addr)
fc_device_fingerprint_id__values = {
    "Researcher": 0x02,
    "Dr. Kirk":   0x03
}
function just_got_fingerprint(name) => just_changed_to(fc_device_fingerprint_id__mem, fc_device_fingerprint_id__values[name])

// -------------
//   R O O M S
// -------------

floor_room__values = {
    "Locker Room":                                          [1, 0],
    "Toilet":                                               [1, 1],
    "Management Office Hallway":                            [1, 2],
    "Management Office":                                    [1, 3],
    "Strategy Room":                                        [1, 4],
    "Control Room Hall":                                    [1, 5],
    "Control Room":                                         [1, 6],
    "Main Entrance 1F":                                     [1, 7],
    "Lecture Room Hallway":                                 [1, 8],
    "Lecture Room":                                         [1, 9],
    "Office Hallway":                                       [1, 10],
    "Office":                                               [1, 11],
    "Material Storage":                                     [1, 12],
    "Backyard of the Facility":                             [1, 13],
    "Passageway to the Backup Generator":                   [1, 14],
    "Backup Generator Room 1F":                             [1, 15],
    "Piping Check Passageway A 1F":                         [1, 16],
    "Piping Check Passageway B 1F":                         [1, 17],
    "The Backyard":                                         [1, 18],
    "Elevator Hall":                                        [1, 19],
    "Passageway to the Backup Generator (Raptor Alt)":      [1, 20],
    
    "Communication Antenna Room":                           [2, 0],
    "Passageway to the Communication Area":                 [2, 1],
    "Chief's Office":                                       [2, 2],
    "Hall F2":                                              [2, 3],
    "Lounge":                                               [2, 4],
    "Communication Room":                                   [2, 5],
    "Main Entrance 2F":                                     [2, 6],

    "Experiment Simulation Room":                           [3, 0],
    "Research Area Hall":                                   [3, 1],
    "Research Meeting Room":                                [3, 2],
    "Gas Experiment Room":                                  [3, 3],
    "Computer Room":                                        [3, 4],
    "Library Room":                                         [3, 5],
    "Main Hallway B1":                                      [3, 6],
    "Medical Room Hallway":                                 [3, 7],
    "Medical Room":                                         [3, 8],
    "Hall B1":                                              [3, 9],
    "Hallway for Carrying in Materials":                    [3, 10],
    "Backup Generator Room B1":                             [3, 11],
    "Carrying Out Room B1":                                 [3, 12],
    "Hallway for Carrying in Materials (Gail's Route Alt)": [3, 13],
    "Hall B1 (Gail's Route Alt)":                           [3, 14],
    
    "Front Area of Entrance":                               [4, 0],
    "Passageway to the Heliport":                           [4, 1],
    "Hangar":                                               [4, 2],
    "Heliport":                                             [4, 3],
    "Large Size Elevator Passageway":                       [4, 4],
    "Large Size Elevator":                                  [4, 5],
    "Large Size Elevator Control Room":                     [4, 6],
    "Passageway to the Power Room":                         [4, 7],
    "Elevator Power Room":                                  [4, 8],
    "Liaison Elevator No. 2":                               [4, 9],
    "Underground Passageway to the Facility":               [4, 10],
    "Materials Room":                                       [4, 11],
    "Liaison Elevator No. 1":                               [4, 12],
    "Heliport (During CG)":                                 [4, 13],
    
    "Passageway to the Experiment Area":                    [5, 0],
    "Piping Check Passageway B2":                           [5, 1],
    "Experiment Room Hall":                                 [5, 2],
    "Stabilizer Experiment Room":                           [5, 3],
    "Stabilizer Design Room":                               [5, 4],
    "Researcher Rest Room":                                 [5, 5],
    "Security Pass Room":                                   [5, 6],
    "Parts Storage":                                        [5, 7],
    "Passageway":                                           [5, 8],
    "Third Energy Area B2":                                 [5, 9],
    "Third Energy Area B3":                                 [5, 10],
    "Third Energy Control Room (Upstairs)":                 [5, 11],
    "Power Frequency Room":                                 [5, 12],
    "Passageway to Personal Lab":                           [5, 13],
    "Dr. Kirk's Personal Lab":                              [5, 14],
    "Dr. Kirk's Library Room":                              [5, 15],
    "Third Energy Control Room (Downstairs)":               [5, 16],
    "Stabilizer Experiment Room (Alt)":                     [5, 17],  // todo: why the alt?
    
    "Carrying Out Room B3":                                 [6, 0],
    "Backup Generator Room B3":                             [6, 1],
    "Control Room B3":                                      [6, 2],
    "Passageway to the Carrying Out Room":                  [6, 3],
    "Rest Station":                                         [6, 4],
    "General Weapons Store":                                [6, 5],
    "Transport Passageway":                                 [6, 6],
    "Special Weapons Storage":                              [6, 7],
    "Central Stairway":                                     [6, 8],
    "Disembarkation Immigration Office":                    [6, 9],
    "Port":                                                 [6, 10],
    "Passageway to the Port":                               [6, 11],
    "Channel":                                              [6, 12],
    "Underground Heliport":                                 [6, 13],
    "Elevator":                                             [6, 14],  // todo: how is this reached legit?
    "Large Size Elevator (Descending & B3)":                [6, 15],
    "Hovercraft Storage":                                   [6, 16],
    "Heliport Transport Passageway":                        [6, 17],
    "Hovercraft":                                           [6, 18],
    "Port (T-Rex Fight)":                                   [6, 19],
    "Port Transport Passageway":                            [6, 20],
    "General Weapons Store (Post Crane Keys Alt)":          [6, 21],
}

function in_room_floor(name) => floor_id__mem == floor_room__values[name][0]
function in_room_only(name) => room_id__mem == floor_room__values[name][1]
function in_room(name) => in_room_floor(name) && in_room_only(name)

function just_changed_room(from, to) {
    from_ids = floor_room__values[from]
    to_ids = floor_room__values[to]
    return just_changed(floor_id__mem, from_ids[0], to_ids[0])
           && just_changed(room_id__mem, from_ids[1], to_ids[1])
}

function just_entered_room(name) {
    // this function is not perfect, as it will not trigger if we move between rooms with
    // the same id but on different floors. this is unlikely to become an issue, so i'll
    // avoid introducing ORs to handle that
    ids = floor_room__values[name]
    return in_room_floor(name)
        && just_changed_to(room_id__mem, floor_room__values[name][1])
}

function security_room_alarm_active() => byte(0xc15cf) != 0
function security_room_solving_stack_puzzle() => byte(0xc15ce) == 1


// ---------------------
//   C U T S C E N E S
// ---------------------

// strictly speaking these are not cutscene flags, but they might as well be
// *most* flags activate when the cutscene starts

cutscene__flags = {
    "Opening (Part 1)":                                     bit2(0xc1506),
    "Opening (Part 2)":                                     bit1(0xc1505),
    "Opening with Gail":                                    bit2(0xc1505),
    "Let's Go Outside":                                     bit3(0xc1505),  // also bit4
    "Guy Split In Half":                                    bit7(0xc1505),
    "First Raptor":                                         bit1(0xc1507),
    "Raptor Fence Jump":                                    bit3(0xc1506),
    "Rick comms after first Raptor encounter":              bit5(0xc1505),
    "Spooked":                                              bit6(0xc1504),
    "Ventilation":                                          bit5(0xc1504),
    "Control Room":                                         bit6(0xc1502),  // also bit2(0xc1503)
    "Dead body in Management Office":                       bit2(0xc1502),
    "Activate Computer in Management Office":               bit1(0xc1502),
    "Raptor Ambush in Locker Room":                         bit1(0xc1501),
    "Main Entrance":                                        bit4(0xc1503),
    "Scientist in Chief's Office":                          bit6(0xc1508),
    "T-Rex in Chief's Office":                              bit7(0xc1507),  // also bit0(0xc1508)
    "Rick Comms About Human":                               bit5(0xc1503),  // also bit4|bit3|bit0(0xc150e)
    "(Optional) Raptor Ambush in Lecture Room Hallway":     bit6(0xc1503),
    "Raptor Ambush in Lecture Room":                        bit1(0xc1504),
    "Rick Comms After Backup Generator B1 Activation":      bit2(0xc150e),
    "Raptor Ambush in Office Hallway":                      bit2(0xc1504),
    "Control Room 1st Decision (Part 1)":                   bit0(0xc1503),
    "Control Room 1st Decision (Part 2)":                   bit4(0xc1502),
    "Follow Rick in Backyard":                              bit3(0xc151c),
    "Pteranodon Ambush":                                    bit1(0xc1510),
    "Finding Tom":                                          bit4(0xc1510),  // also bit4(0xc1517) & bit1(0xc151f)
    "Restore Power to Large Size Elevator":                 bit7(0xc1510),
    "Pteranodon Ambush 2":                                  bit6(0xc1510),
    "Large Size Elevator Passageway Earthquake":            bit0(0xc1510),
    "Let Rick Know the Elevator is Online":                 bit5(0xc1510),
    "Descending Large Size Elevator":                       bit3(0xc1510),  // also bit6(0xc151b)
    "Large Size Elevator Ride Ended":                       bit1(0xc150f),  // also bit0(0xc1510) (Large Size Elevator Passageway Earthquake)
    "Rick Takes Care of Tom":                               bit0(0xc150f),
    "Rick & Tom Ambushed by Raptor":                        bit6(0xc150d),
    "Meet Compsognathus for the First Time":                bit0(0xc1502),
    "Meet Rick & Tom in Medical Room":                      bit6(0xc150c),
    "Raptor Ambush in Elevator":                            bit2(0xc150d),  // also bit3
    "See Dr. Kirk for the First Time with Gail":            bit4(0xc150d),  // also bit1 & bit2(0xc1515)
    "Gail Follows Dr. Kirk":                                bit3(0xc150d),
    "Raptor Ambush in Hallway for Carrying in Materials":   bit5(0xc150d),
    "Rick Comms About Tom's Death":                         bit1(0xc1506),
    "Raptor Ambush in Gas Experiment Room":                 bit0(0xc150b),
    "Call Gail for Help With Key Cards L & R":              bit4(0xc150b),
    "Experiment Simulation Room Entrance":                  bit0(0xc1519),
    "Activate Experiment Simulation":                       bit4(0xc1509),
    "Emergency Lockdown":                                   bit3(0xc150b),
    "Emergency Lockdown Bypassed":                          bit5(0xc150d),
    "Request Helicopter Pickup":                            bit2(0xc1509),
    
    // part 3
    "First Conversation with Dr. Kirk":                     bit7(0xc150e),
    "Antenna Activated":                                    bit2(0xc1507),  // also bit3
    "T-Rex Attack in Passageway to the Communication Area": bit4(0xc1507),
    "Pteranodon in Front Area of Entrance":                 bit2(0xc150f),
    // "T-Rex Attacks Helicopter":                          ???
    "Rick Signals While Running From T-Rex":                bit6(0xc150f),  // also bit5
    "Compsognathus in Underground Passageway":              bit0(0xc1501),
    "Liaison Elevator No. 1 is Broken":                     bit6(0xc1513),
    "Liaison Elevator No. 1 Fixed":                         bit7(0xc1513),
    "Arrive Back at Large Size Elevator":                   bit2(0xc1510),  // also bit2(0xc1519)
    "Power Goes Out While Descending Large Size Elevator":  bit6(0xc1519),
    "Arrive at Carrying Out Room B3":                       bit6(0xc1516),
    "Restore Power in Carrying Out Room B3":                bit7(0xc151a),  // also bit0
    "Therizinosaurus Ambush in General Weapons Store":      bit1(0xc1503),
    "Raptor Ambush in Experiment Room Hall":                bit7(0xc1501),
    "Meet Gail in Researcher Rest Room":                    bit1(0xc1511),
    "Ricks Enables Switches in B2":                         bit4(0xc1512),
    "Survivor Comms in Disembarkation Immigration Office":  bit0(0xc1514),
    "T-Rex Rides the Elevator and Eletrocutes Itself":      bit0(0xc1517),
    "Access the Passageway to the Port":                    bit1(0xc1514),
    "Witness the Vortex in Passageway to the Port":         bit6(0xc1514),
    "Scanned in Parts Storage":                             bit4(0xc151a),
    "First Door Opening in Passageway":                     bit0(0xc1518),
    "Second Door Opening in Passageway":                    bit1(0xc1518),
    "Reach Third Energy Area B2":                           bit6(0xc1515),
    "Fail to Operate the Third Energy Generator":           bit5(0xc1518),
    "Researcher is Dead in Power Frequency Room":           bit1(0xc151b),
    "Chase Dr. Kirk out of Power Frequency Room":           bit7(0xc1517),
    "Chase Dr. Kirk in Passageway to Personal Lab":         bit7(0xc1511),
    "Meet Dr. Kirk in his Personal Lab":                    bit0(0xc1512),
    
    // split 3: rick
    "Listen to Recording in Parts Storage":                 bit3(0xc151b),
    
    // part 4
    "Place the Initializer in the Generator":               bit5(0xc1511),
    "Pre-activate Generator in Third Energy Area B3":       bit6(0xc1511),
    "Place The Stabilizer in the Generator":                bit2(0xc1511),
    "Activate Generator in Third Energy Area B2":           bit3(0xc1511),
    "Third Energy Overload":                                bit0(0xc1515),
    "Gail's Hurt & Dr. Kirk Escapes Captivity":             bit1(0xc1512),
    "Talk to Injured Gail":                                 bit1(0xc1515),
    "Escape Path is Ready":                                 bit2(0xc1514),
    
    // split 4: rick
    "Get Energy Tank from Rick":                            bit7(0xc1512),
    "Receive Items from Rick to Fight the T-Rex":           bit5(0xc1517),
    
    // split 4: gail
    "Recapture Dr. Kirk in Stabilizer Experiments Room":    bit3(0xc1515),
    "Return to Rick with Dr. Kirk":                         bit3(0xc1514),
    "Find the Knocked Out T-Rex in Port":                   bit2(0xc1517),
    "Knocked Out T-Rex Moves":                              bit3(0xc1517),
    "T-Rex Attacks the Hovercraft":                         bit3(0xc1519),
    
    // split 4: rick best ending
    "Recapture Dr. Kirk in Underground Heliport":           bit4(0xc1519),
    
    // split 4: gail best ending
    "Find Helicopter in Underground Heliport":              bit3(0xc1516),
    "Meet Gail & Dr. Kirk":                                 bit4(0xc1515),
    "Reach Undergound Heliport with Gail & Dr. Kirk":       bit5(0xc1519)
}

function cutscene_has_started(name)  => cutscene__flags[name] == 1
function cutscene_just_started(name) => just_changed(cutscene__flags[name], 0, 1)

function cutscene_watched(name) => cutscene_has_started(name)

// ---------------------------
//   I T E M   P I C K U P S
// ---------------------------

item_pickup__flags = {
    "Multiplier (Backyard of the Facility)":                bit0(0xc155f),
    "BG Area Key":                                          bit5(0xc1520),
    "Resuscitation (Material Storage)":                     bit1(0xc1530),
    "9mm Parabellum (Control Room Hall)":                   bit5(0xc153a),
    "Shotgun":                                              bit4(0xc153a),
    "DDK Input Disc H":                                     bit4(0xc152a),
    "Plug (Management Office)":                             bit1(0xc152c),
    "Panel Key 2":                                          bit3(0xc1536),
    "An. Dart M (Locker Room)":                             bit1(0xc1531),
    "DDK Code Disk H":                                      bit0(0xc1528),
    "Entrance Key":                                         bit3(0xc1520),
    "Resuscitation (Management Office)":                    bit5(0xc1530),
    "An. Aid (Main Entrance 1F)":                           bit2(0xc1536),
    "An. Aid (Main Entrance 2F)":                           bit1(0xc1536),
    "SG Bullets (Front Area of Entrance)":                  bit3(0xc1532),
    "DDK Code Disk N":                                      bit1(0xc1528),
    "An. Aid (Front Area of Entrance)":                     bit4(0xc1533),
    "SG Bullets (Hall F2)":                                 bit7(0xc1535),
    "Handgun Slides":                                       bit5(0xc1531),
    "Resuscitation (Lounge)":                               bit0(0xc1536),
    "Panel Key 1":                                          bit0(0xc1520),
    "SG Bullets (Chief's Office)":                          bit3(0xc1530),
    "DDK Input Disk N":                                     bit5(0xc152a),
    "Key Card L":                                           bit5(0xc1508),
    "Plug (Elevator Hall)":                                 bit5(0xc152c),
    "Hemostat/An. Aid (Elevator Hall)":                     bit1(0xc155f),
    "BG Room B1 Key":                                       bit4(0xc1522),
    "An. Aid (Backyard of the Facility)":                   bit2(0xc1530),
    "Startup Batt. R (Charged)":                            bit0(0xc1524),  // unset when used
    "Plug (Backup Generator Room B1)":                      bit5(0xc152f),
    "Slag Bullets (Large Size Elevator Passageway)":        bit3(0xc1531),
    "Resuscitation (Large Size Elevator Passageway)":       bit4(0xc1531),
    "Plug (Large Size Elevator (Outside))":                 bit1(0xc152f),
    "DDK Code Disc L":                                      bit4(0xc1529),
    "DDK Input Disc L":                                     bit3(0xc152b),
    "Random Supply (Large Size Elevator Control Room)":     bit4(0xc155d),
    "An. Aid (Passageway to the Power Room)":               bit6(0xc155d),
    "B1 Crane Card":                                        bit4(0xc1524),
    "Random Supply (Elevator Power Room)":                  bit5(0xc155f),
    "Random Supply (Carrying Out Room B1)":                 bit4(0xc155f),
    "An. Dart M (Carrying Out Room B1)":                    bit0(0xc1531),
    "Random Supply (Hallway for Carrying in Materials)":    bit0(0xc1551),
    "Random Supply (Hall B1)":                              bit4(0xc155b),
    "Med. Pak M (Medical Room 1)":                          bit6(0xc1530),
    "Med. Pak M (Medical Room 2)":                          bit7(0xc1530),
    "Plug (Medical Room)":                                  bit6(0xc152d),
    "ID Card":                                              bit4(0xc1521),
    "DDK Code Disc E":                                      bit3(0xc1528),
    "F. C. Device":                                         bit2(0xc1524),
    "Plug (Strategy Room)":                                 bit2(0xc152c),
    "ID Card (Researcher)":                                 bit5(0xc151b),  // also bit6(0xc1521)
    "Hemostat (Computer Room)":                             bit7(0xc155a),
    "Plug (Computer Room)":                                 bit4(0xc152d),
    "Screwdriver":                                          bit5(0xc1524),
    "DDK Input Disc E":                                     bit7(0xc152a),
    "Plug (Research Meeting Room)":                         bit3(0xc152d),
    "B1 Key Chip":                                          bit7(0xc1524),
    "Small Size Key":                                       bit2(0xc1520),
    "Med. Pak M (Library Room)":                            bit4(0xc1536),
    "Handgun Sights":                                       bit5(0xc152d),
    "B1 Key Chip (Rewritten)":                              bit6(0xc1535),
    "Key Card R":                                           bit1(0xc1525),
    "Shotgun Stocks":                                       bit2(0xc1532),
    "An. Dart L (Experiment Simulation Room)":              bit0(0xc1534),
    "Slag Bullets (Communication Room)":                    bit4(0xc1530),
    "Antenna Key":                                          bit6(0xc1524),
    "Random Supply (Passageway to the Communication Area)": bit4(0xc1559),
    "Grenade Gun":                                          bit2(0xc1531),
    "Grenade Bullets (Hangar 1)":                           bit4(0xc1532),
    "Random Supply (Hangar)":                               bit6(0xc155c),
    "Grenade Bullets (Hangar 2)":                           bit7(0xc1531),
    "C. O. Pass Card":                                      bit5(0xc1522),
    "Grenade Bullets (Carrying Out Room B3)":               bit7(0xc1538),
    "Random Supply (Backup Generator Room B3)":             bit6(0xc155f),
    "Startup Batt. W":                                      bit2(0xc15b3),  // also bit5(0xc1516), but delayed
    "Slag Bullets (Control Room B3)":                       bit7(0xc155f),
    "B3 Crane Card 1":                                      bit2(0xc1525),
    "B3 Crane Card 2":                                      bit1(0xc1533),
    "Plug (Control Room B3)":                               bit5(0xc1537),
    "B3 Crane Card 3":                                      bit4(0xc1525),
    "C. O. Area Key":                                       bit6(0xc1520),
    "Resuscitation (General Weapons Storage)":              bit4(0xc1538),
    "DDK Input Disc W":                                     bit2(0xc152b),
    "Multiplier (Passageway to the Carrying Out Room)":     bit4(0xc155e),
    "Plug (Rest Station)":                                  bit0(0xc1538),
    "An. Aid (Passageway to the Experiment Area)":          bit0(0xc1537),
    "DDK Input Disc S":                                     bit0(0xc152b),
    "B2 Key Chip 1":                                        bit5(0xc1526),
    "Random Supply (Piping Check Passageway B2)":           bit7(0xc1526),
    "An. Dart L (Experiment Room Hall)":                    bit3(0xc1538),
    "Key Card Lv. C":                                       bit0(0xc1522),
    "DDK Code Disc W":                                      bit6(0xc1528),
    "Plug (Disembarkation Immigration Office)":             bit3(0xc152e),
    "B2 Key Chip 2":                                        bit6(0xc1526),
    "Startup Batt. W (2nd time)":                           bit2(0xc15b3),  // also bit7(0xc1516), but delayed
    "Plug (Large Size Elevator)":                           bit3(0xc1539),
    "Port Card Key":                                        bit5(0xc1536),
    "DDK Input Disc D":                                     bit1(0xc152b),
    "DDK Code Disc S":                                      bit4(0xc1528),
    "Resuscitation (Experiment Room Hall)":                 bit6(0xc1531),
    "DDK Code Disc D":                                      bit5(0xc1528),
    "Plug (Stabilizer Experiment Room)":                    bit6(0xc152e),
    "Shotgun Parts":                                        bit0(0xc153a),
    "An. Aid (Passageway)":                                 bit1(0xc1537),
    "Key Card Lv. B":                                       bit1(0xc1522),
    "Intensifier (Third Energy Control Room)":              bit4(0xc1537),
    "Plug (Third Energy Control Room)":                     bit2(0xc1537),
    "Researcher Memo":                                      bit2(0xc1534),
    "Key Card Lv. A":                                       bit2(0xc15af),
    "Planning Disc":                                        bit1(0xc15b4),
    "Med. Pak M (Dr. Kirk's Library Room)":                 bit7(0xc1536),
    "ID Card (Dr. Kirk)":                                   bit6(0xc1522),
    "GG Parts":                                             bit2(0xc1539),
    "Plug (Parts Storage)":                                 bit3(0xc1537),
    "Core Parts 1":                                         bit4(0xc1535),
    "Core Parts 2":                                         bit5(0xc1535),
    "Protect P. 1-B":                                       bit0(0xc1526),
    "Protect P. 2-A":                                       bit1(0xc1526),
    "Protect P. 1-A":                                       bit7(0xc1525),
    "Protect P. 2-B":                                       bit5(0xc1539),
    "Stabilizer (Rick's Route)":                            bit7(0xc1539),
    "Initializer (Rick's Route)":                           bit6(0xc1539),
    "Plug (Transport Passageway) (1)":                      bit1(0xc152d),
    "Grenade Bullets (Transport Passageway)":               bit5(0xc1538),
    "Plug (Transport Passageway) (2)":                      bit0(0xc152d),
    "Stabilizer (Gail's Route)":                            bit2(0xc153a),
    "Initializer (Gail's Route)":                           bit1(0xc153a),
    "Plug (Third Energy Area B3)":                          bit6(0xc1538),
    "Pulse Receiver":                                       bit0(0xc15b3),
    "Multiplier (Passageway to the Port)":                  bit4(0xc1539),
    "Energy Tank":                                          bit0(0xc1533),
    "Nucleum":                                              bit4(0xc1526),
    "Plug (Hovercraft Storage)":                            bit3(0xc1535),
    "Grenade Bullets (Hovercraft Storage) (1)":             bit6(0xc1532),
    "Grenade Bullets (Hovercraft Storage) (2)":             bit1(0xc1534),
    "Recovery Aid (Port)":                                  bit1(0xc1539),
    "Secret Disc":                                          bit3(0xc15b3),
    "Plug (Hovercraft)":                                    bit6(0xc1534),
    "Grenade Bullets (Hovercraft) (1)":                     bit4(0xc1534),
    "Grenade Bullets (Hovercraft) (2)":                     bit5(0xc1534),
    "Plug (Central Stairway)":                              bit1(0xc1538),
    "Slag Bullets (Port Transport Passageway)":             bit6(0xc155e),
    "Plug (Underground Heliport)":                          bit2(0xc1535),
    "Grenade Bullets (Underground Heliport) (1)":           bit0(0xc1535),
    "Grenade Bullets (Underground Heliport) (2)":           bit1(0xc1535),
    "Random Supply (Underground Heliport)":                 bit5(0xc155e),
    "Random Supply (Locker Room)":                          bit5(0xc1557),
    "Random Supply (Lecture Room Hallway)":                 bit4(0xc1558),
    "Random Supply (Piping Check Passageway B 1F)":         bit2(0xc1559)
}

function just_picked_up_item(name) => just_changed(item_pickup__flags[name], 0, 1)

function just_finished_picking_up_items(items) {
    prev_val = 0
    cur_val = 0
    target_val = 0
    for item in items {
        prev_val = prev_val + prev(item_pickup__flags[item])
        cur_val = cur_val + item_pickup__flags[item]
        target_val = target_val + 1
    }
    return prev_val < target_val && cur_val == target_val
}

unlocked_door__flags = {
    "Safe in Management Office":                                      bit3(0xc1502),
    "Main Entrance > Front Area of Entrance":                         bit5(0xc15a0),
    "Hall F2 > Chief's Office":                                       bit4(0xc15a1),
    "Main Entrance > Elevator Hall":                                  bit4(0xc15a0),
    "Elevator Hall > Lecture Room Hallway":                           bit6(0xc15a0),
    "Office > Office Hallway":                                        bit7(0xc15a0),
    "Backyard of the Facility > Backup Generator Room B1":            bit0(0xc15a1),
    "Carrying Out Room B1 > Hallway for Carrying in Materials":       bit0(0xc15a2),
    "Hallway for Carrying in Materials > Backup Generator Room B1":   bit7(0xc15a1),
    "Management Office Hallway > Strategy Room":                      bit6(0xc15a1),
    "Elevator in Elevator Hall":                                      bit7(0xc1506),
    "Management Office Hallway > Strategy Room (Gail's Route Alt)":   bit2(0xc15a0),
    "Hall B1 > Main Hallway B1":                                      bit6(0xc15a1),
    "Research Meeting Room > Gas Experiment Room":                    bit5(0xc15a1),
    "Computer Room > Experiment Simulation Room":                     bit6(0xc15a4),
    "Experiment Simulation Room > Hallway for Carrying in Materials": bit2(0xc1518),
    "Control Room 1F > Communication Room (Elevator)":                bit6(0xc15a5),
    "Communication Room > Passageway to the Communication Area":      bit3(0xc15a1),
    "Front Area of Entrance > Passageway to the Heliport":            bit1(0xc15a2),
    "Carrying Out Room B3 > Passageway to the Carrying Out Room":     bit4(0xc15a3),
    "Experiment Room Hall > Stabilizer Design Room":                  bit4(0xc15a2),
    "Rest Station > Disembarkation Immigration Office":               bit5(0xc15a3),
    "Security Pass Room > Parts Storage":                             bit7(0xc15a2),
    "Parts Storage > Experiment Room Hall":                           bit5(0xc15a2),
    "Experiment Room Hall > Stabilizer Experiment Room":              bit3(0xc15a5),
    "Parts Storage > Passageway":                                     bit0(0xc15a3),
    "Dr. Kirk's Personal Lab > Third Energy Area B2":                 bit1(0xc15a3),
    "Elevator in Third Energy Control Room":                          bit0(0xc15a5),
    "Elevator in Rest Station":                                       bit1(0xc15a5),
    "Transport Passageway > Special Weapons Storage":                 bit6(0xc15a3),
    "Central Stairway > Port Transport Passageway":                   bit2(0xc15a5),
    "Heliport Transport Passageway > Undergroud Heliport":            bit5(0xc15a5),
    "Heliport Transport Passageway > Transport Passageway":           bit7(0xc15a3),
}

function just_unlocked_door(name) => just_changed(unlocked_door__flags[name], 0, 1)

// 0x01 = disabled
switch__flags = {
    "Laser Grid in Management Office Hallway":         bit5(0xc1501),
    "Laser Grid in Lecture Room Hallway":              bit0(0xc1504),
    "Laser Grid in Office Hallway":                    bit4(0xc1504),
    "Laser Grid in Hallway for Carrying in Materials": bit0(0xc150e),
    "Gate in Control Room Hall":                       bit4(0xc1502),
    "Laser Grid in Management Office Hallway 2":       bit4(0xc1501),
    "Laser Grid in Main Hallway B1 (1)":               bit2(0xc150c),
    "Laser Grid in Main Hallway B1 (2)":               bit3(0xc150c),
    "Laser Grid in Research Area Hall (1)":            bit7(0xc1509),
    "Laser Grid in Research Area Hall (2)":            bit6(0xc1509),
    "Laser Grid in Passageway to the Experiment Area": bit1(0xc1516),
    "Laser Grid in Experiment Room Hall":              bit5(0xc1515),
    "Laser Grid in Transport Passageway":              bit3(0xc1512),
    "Laser Grid in Central Stairway":                  bit5(0xc1512),
}

misc_event__flags = {
    "Backup generator 1F activated":                     bit0(0xc1506),
    "Computer in Management Office activated":           bit1(0xc1502),  // could act as a proxy for the memo in the computer
    "Panel Key 1 set in Chief's Office":                 bit2(0xc1508),
    "Panel Key 2 set in Chief's Office":                 bit3(0xc1508),
    "Medal Case opened in Chief's Office":               bit7(0xc1508),
    "Large Size Elevator Control Panel Online":          bit2(0xc1512),
    "Enable Crane Controls in Carrying Out Room B1":     bit0(0xc151b),
    "Shock Raptor in Hallway for Carrying in Materials": bit5(0xc1562),
    "Crane Puzzle Completed":                            bit5(0xc1513),  // TODO: is this the same in rick's route??
    "Panel Opened in Computer Room":                     bit2(0xc1516),
    "Gassed Researcher in Gas Experiment Room":          bit6(0xc150a),
    "Gassed Raptor in Gas Experiment Room":              bit5(0xc1561),
    "Left Emergency Case Opened in Medical Room":        bit5(0xc150c),
    "Right Emergency Case Opened in Medical Room":       bit4(0xc150c),
    "Magnetic Chip Key Puzzle Solved":                   bit0(0xc150c),
    "Locker Opened in Library Room":                     bit7(0xc150b),
    "Emergency Lockdown Puzzle Solved":                  bit4(0xc1513),
    "Failed Code Puzzle in Experiment Simulation Room":  bit5(0xc1509),
    "Read Memo in Materials Room":                       bit6(0xc1512),
    "Set Crane Cards in General Weapons Storage":        bit0(0xc151c),
    "B3 Crane Puzzle Completed":                         bit7(0xc1514),
    "Alarm Deactivate in Security Pass Room":            bit2(0xc151b),
    "Backup Generator B3 Online":                        bit4(0xc1516),
    "Set B2 Key Chip 1 in Security Pass Room":           bit2(0xc1513),  // goes back to 0x00 after solving the puzzle
    "Set B2 Key Chip 2 in Security Pass Room":           bit1(0xc1513),  // same
    "Open Final Door in Passageway":                     bit6(0xc1518),
    "Bridge in Third Energy Area B2 Lowered":            bit4(0xc1511),
    "Circuit Puzzle in Power Frequency Room Solved":     bit4(0xc1518),
    "Sound Puzzle in Parts Storage Solved":              bit5(0xc151a),
    "Activate Generator in Third Energy Control Room":   bit6(0xc151a),
}

function event_has_occurred(name) => misc_event__flags[name] == 1
function event_just_occurred(name) => just_changed(misc_event__flags[name], 0, 1)

// ---------------------------
//   S T O R Y   S P L I T S
// ---------------------------

story_split__addr = 0xc1500
story_split__flags = {
    "Split 1: Gail's Route": bit1(story_split__addr),
    "Split 1: Rick's Route": bit0(story_split__addr),
    "Split 2: Gail's Route": bit3(story_split__addr),
    "Split 2: Rick's Route": bit2(story_split__addr),
    "Split 3: Gail's Route": bit5(story_split__addr),
    "Split 3: Rick's Route": bit4(story_split__addr),
    "Split 4: Gail's Route": bit7(story_split__addr),
    "Split 4: Rick's Route": bit6(story_split__addr)
}

function chose_story_split(name) => story_split__flags[name] == 1

// -----------------
//   E N E M I E S
// -----------------

// these are flags that remember whether an enemy is supposed to spawn or not,
// so some are reused when enemies respawn due to story progression

enemy_death__flags = {
    "Raptor (Passageway to the Backup Generator)":     bit0(0xc1561),
    "Raptor (Managment Office Hallway / Locker Room)": bit2(0xc1560),
    
    "7 Compsognathus (Medical Room Hallway)":          bit5(0xc1565),
    
    "Pteranodon (Large Size Elevator) (1)":            bit2(0xc1564),
    "Pteranodon (Large Size Elevator) (2)":            bit3(0xc1564),
    
    // these 2 do not activate when killing the Pteranodons before restoring
    // power to the Large Size Elevator (they always respawn)
    "Pteranodon (Passageway to the Power Room) (1)":   bit4(0xc1567),
    "Pteranodon (Passageway to the Power Room) (2)":   bit5(0xc1567),
    
    "Raptor (Gas Experiment Room)":                    bit5(0xc1561),
    
    // Split 2: Gail's Route
    "Raptor (Research Area Hall) (1)":                 bit4(0xc1563),
    "Raptor (Research Area Hall) (2)":                 bit3(0xc1563),
    "Raptor (Library Room) (1)":                       bit3(0xc1567),
    "Raptor (Library Room) (2)":                       bit6(0xc1563),
    "Raptor (Main Hallway B1) (1)":                    bit7(0xc1563),
    "Raptor (Main Hallway B1) (2)":                    bit0(0xc1564),
    "Raptor (Hall B1)":                                bit1(0xc1564),
    "Raptor (Hallway for Carrying in Materials)":      bit5(0xc1562),
}

function enemy_is_alive(name) => enemy_death__flags[name] == 0
function enemy_is_dead(name) => enemy_death__flags[name] == 1
function enemy_just_killed(name) => just_changed(enemy_death__flags[name], 0, 1)

// -------------------------
//   P I P E   P U Z Z L E
// -------------------------

pipe_puzzle_state__flags = {
    "Top Left Green":     bit3(0xc15cd),
    "Top Left Red":       bit2(0xc15cd),
    "Top Left Blue":      bit4(0xc15cd),

    "Top Right Green":    bit6(0xc15cd),
    "Top Right Red":      bit5(0xc15cd),
    "Top Right Blue":     bit7(0xc15cd),

    "Middle Left Green":  bit0(0xc15cd),
    "Middle Left Red":    bit7(0xc15cc),
    "Middle Left Blue":   bit1(0xc15cd),
    
    "Middle Right Green": bit1(0xc15ce),
    "Middle Right Red":   bit0(0xc15ce),
    "Middle Right Blue":  bit3(0xc15ce),

    "Lower Left Green":   bit5(0xc15cc),
    "Lower Left Red":     bit4(0xc15cc),
    "Lower Left Blue":    bit6(0xc15cc),

    "Lower Right Green":  bit4(0xc15ce),
    "Lower Right Red":    bit3(0xc15ce),
    "Lower Right Blue":   bit5(0xc15ce)
}

function pipe_puzzle_in_initial_state() {
    cond = always_true()
    for flag in pipe_puzzle_state__flags {
        cond = cond && pipe_puzzle_state__flags[flag] == 0
    }
    return cond
}

function pipe_puzzle_was_in_initial_state() {
    cond = always_true()
    for flag in pipe_puzzle_state__flags {
        cond = cond && prev(pipe_puzzle_state__flags[flag]) == 0
    }
    return cond
}

function pipe_puzzle_n_lowered_on_left() {
    left_flags = ["Top Left Green",    "Top Left Red",    "Top Left Blue",
                  "Middle Left Green", "Middle Left Red", "Middle Left Blue",
                  "Lower Left Green",  "Lower Left Red",  "Lower Left Blue"]
    val = 0
    for flag in left_flags {
        val = val + pipe_puzzle_state__flags[flag]
    }
    return val
}

function pipe_puzzle_n_lowered_on_right() {
    right_flags = ["Top Right Green",    "Top Right Red",    "Top Right Blue",
                   "Middle Right Green", "Middle Right Red", "Middle Right Blue",
                   "Lower Right Green",  "Lower Right Red",  "Lower Right Blue"]
    val = 0
    for flag in right_flags {
        val = val + pipe_puzzle_state__flags[flag]
    }
    return val
}

function pipe_puzzle_change_on_left() {
    val = 0
    for flag in ["Top Left Green",    "Top Left Red",    "Top Left Blue",
                 "Middle Left Green", "Middle Left Red", "Middle Left Blue",
                 "Lower Left Green",  "Lower Left Red",  "Lower Left Blue"] {
        val = val + prev(pipe_puzzle_state__flags[flag]) - pipe_puzzle_state__flags[flag]
    }
    return val != 0
}

function pipe_puzzle_change_on_right() {
    val = 0
    for flag in ["Top Right Green",    "Top Right Red",    "Top Right Blue",
                 "Middle Right Green", "Middle Right Red", "Middle Right Blue",
                 "Lower Right Green",  "Lower Right Red",  "Lower Right Blue"] {
        val = val + prev(pipe_puzzle_state__flags[flag]) - pipe_puzzle_state__flags[flag]
    }
    return val != 0
}

// ---------------------------
//   C R A N E   P U Z Z L E
// ---------------------------

crane_puzzle_holding_container__flag = bit3(0xc15cd)
crane_puzzle_container__flags = {    // [0,0] is top left
    "Carrying Out Room B1": [
        [bit6(0xc15cd), bit2(0xc15ce), bit6(0xc15ce), bit2(0xc15cf), bit6(0xc15cf)],
        [bit5(0xc15cd), bit1(0xc15ce), bit5(0xc15ce), bit1(0xc15cf), bit5(0xc15cf)],
        [bit4(0xc15cd), bit0(0xc15ce), bit4(0xc15ce), bit0(0xc15cf), bit4(0xc15cf)]
    ],
    "General Weapons Store": [
        [bit7(0xc15cd), bit3(0xc15ce), bit7(0xc15ce), bit3(0xc15cf), bit7(0xc15cf)],
        [bit6(0xc15cd), bit2(0xc15ce), bit6(0xc15ce), bit2(0xc15cf), bit6(0xc15cf)],
        [bit5(0xc15cd), bit1(0xc15ce), bit5(0xc15ce), bit1(0xc15cf), bit5(0xc15cf)],
        [bit4(0xc15cd),             0, bit4(0xc15ce), bit0(0xc15cf), bit4(0xc15cf)]
                        // the container at this position is always there and has no bitflag...
                        // because the bit is used to remember if the crane is holding a container
    ]
}

crane_puzzle_num_cards_selected__addr = 0xc0a25
crane_puzzle_num_cards_selected__mem = byte(crane_puzzle_num_cards_selected__addr)
function crane_puzzle_num_cards_selected_is(n) => crane_puzzle_num_cards_selected__mem == n

crane_puzzle_state__addr = 0xc0a1f
crane_puzzle_state__mem = byte(crane_puzzle_state__addr)
crane_puzzle_state__values = {
    "programming":   1,  // while changing cards 2 also flashes, no sure what it is
    "crane moving":  3,
    "not operating": 4
}
function crane_puzzle_turn_just_started() => just_changed_to(crane_puzzle_state__mem, crane_puzzle_state__values["crane moving"])
function crane_puzzle_turn_just_ended() => just_changed_from(crane_puzzle_state__mem, crane_puzzle_state__values["crane moving"])

function crane_puzzle_containers_map_is(room, map, holding) {
    cond = crane_puzzle_holding_container__flag == holding
    row_i = 0
    for row in crane_puzzle_container__flags[room] {
        col_i = 0
        for cell in row {
            if (row_i != 3 || col_i != 1) {  // couldnt find a way to this properly :(
                cond = cond && (cell == map[row_i][col_i])
            }
            col_i = col_i + 1
        }
        row_i = row_i + 1
    }
    return cond
}

// -----------------------
//   G A S   P U Z Z L E
// -----------------------

gas_puzzle_is_pumping__addr = 0xc0a40
gas_puzzle_is_pumping__mem = bit0(gas_puzzle_is_pumping__addr)  // probably a byte tho
function gas_puzzle_is_pumping() => gas_puzzle_is_pumping__mem == 1

gas_puzzle_gas_state__addr = 0xc150a  // excepting bits5-0
function gas_puzzle_chamber_is_clear() {
    return (bit5(gas_puzzle_gas_state__addr)
            + bit4(gas_puzzle_gas_state__addr)
            + low4(gas_puzzle_gas_state__addr)) == 0
}

function gas_puzzle_researcher_is_alive() => !event_has_occurred("Gassed Researcher in Gas Experiment Room")
function gas_puzzle_researcher_just_died() => event_just_occurred("Gassed Researcher in Gas Experiment Room")

raptor_in_gas_chamber__addr = 0xc150b
raptor_in_gas_chamber__mem = bit1(raptor_in_gas_chamber__addr)
function raptor_in_gas_chamber() => raptor_in_gas_chamber__mem == 1

// ---------------------------
//   S T A C K   P U Z Z L E
// ---------------------------

stack_puzzle_left__addr = 0xc0a6c
stack_puzzle_left__mem = byte(stack_puzzle_left__addr)
stack_puzzle_right__addr = 0xc0a6d
stack_puzzle_right__mem = byte(stack_puzzle_right__addr)

function stack_puzzle_state_is(expected_left, expected_right) {
    // state of each side is made up of 8 bits
    // most significant bit represents the top of the stack, least significant represents the bottom
    // each bit is 1 if stack piece is white/red and 0 if it's black
    return stack_puzzle_left__mem == expected_left
           && stack_puzzle_right__mem == expected_right
}

function stack_puzzle_in_initial_state() => stack_puzzle_state_is(0xA5, 0x5A)
function stack_puzzle_is_solved() => stack_puzzle_state_is(0x00, 0xFF)

stack_puzzle_state__addr = 0xc0a67
stack_puzzle_state__mem = byte(stack_puzzle_state__addr)
stack_puzzle_state__values = {
    "Resetting":            0x01,
    "Moving cursor":        0x02,
    "Left Pop (Part I)":    0x04,
    "Left Pop (Part II)":   0x05,
    "Left Pop (Part III)":  0x06,
    "Right Pop (Part I)":   0x07,
    "Right Pop (Part II)":  0x08,
    "Right Pop (Part III)": 0x09,
    "Preparing Swap":       0x0a,
    "Swapping (Part I)":    0x0b,
    "Swapping (Part II)":   0x0c,
    "Swapping (Part III)":  0x0d,
    "Swapping (Part IV)":   0x0e,
    "Swapping (Part V)":    0x0f,
}

function stack_puzzle_just_reset() => just_changed_to(stack_puzzle_state__mem, stack_puzzle_state__values["Resetting"])
function stack_puzzle_just_popped_left() => just_changed_to(stack_puzzle_state__mem, stack_puzzle_state__values["Left Pop (Part I)"])
function stack_puzzle_just_popped_right() => just_changed_to(stack_puzzle_state__mem, stack_puzzle_state__values["Right Pop (Part I)"])
function stack_puzzle_just_swapped() => just_changed_to(stack_puzzle_state__mem, stack_puzzle_state__values["Swapping (Part I)"])

// -----------
//   T E X T
// -----------

// text is layed out as follows:
//   - each character takes 2 bytes
//   - the most significant nibble contains control bits that mark new lines and pages
//   - the remaining 12 bits contain the actual charater value
charmap = {
    " ": 0x00, "A": 0x02, "B": 0x04, "C": 0x06, "D": 0x08, "E": 0x0a, "F": 0x0c, "G": 0x0e,
    "H": 0x10, "I": 0x12, "J": 0x14, "K": 0x16, "L": 0x18, "M": 0x1a, "N": 0x1c, "O": 0x1e,
    "P": 0x20, "Q": 0x22, "R": 0x24, "S": 0x26, "T": 0x28, "U": 0x2a, "V": 0x2c, "W": 0x2e,
    "X": 0x30, "Y": 0x32, "Z": 0x34, "a": 0x36, "b": 0x38, "c": 0x3a, "d": 0x3c, "e": 0x3e,
    "f": 0x40, "g": 0x42, "h": 0x44, "i": 0x46, "j": 0x48, "k": 0x4a, "l": 0x4c, "m": 0x4e,
    "n": 0x50, "o": 0x52, "p": 0x54, "q": 0x56, "r": 0x58, "s": 0x5a, "t": 0x5c, "u": 0x5e,
    "v": 0x60, "w": 0x62, "x": 0x64, "y": 0x66, "z": 0x68, "0": 0x6a, "1": 0x6c, "2": 0x6e,
    "3": 0x70, "4": 0x72, "5": 0x74, "6": 0x76, "7": 0x78, "8": 0x7a, "9": 0x7c, "...": 0x7e,
    "!": 0x80, "?": 0x82, "“": 0x84, "”": 0x86, ":": 0x88, ";": 0x8a, "+": 0x8c, "=": 0x8e,
    "-": 0x90, "[": 0x92, "]": 0x94, "/": 0x96, "&": 0x98, ".": 0x9a, ",": 0x9c, "'": 0x9e,
    "⯈": 0x00, "*": 0x04, "(": 0xa6, ")": 0xa8, "%": 0xaa, "α": 0xac, "β": 0xae,
    "γ": 0xb0,
    // continues with non-english characters, doesnt matter much for now...
}
charmap_control_newline = 0x9000
charmap_control_newpage = 0xc000

// there's also ascii text
ascii = {
    "0": 0x30, "1": 0x31, "2": 0x32, "3": 0x33, "4": 0x34,
    "5": 0x35, "6": 0x36, "7": 0x37, "8": 0x38, "9": 0x39,
    ":": 0x3a
}

// -------------
//   M E M O S
// -------------

memo_textbox_state__addr = 0xb145b
memo_textbox_state__mem = byte(memo_textbox_state__addr)
memo_textbox_state__values = {
    "Opening": 0x01,
    "Open":   0x02,
    "Closed": 0x03
}
function just_read_a_memo() => just_changed(memo_textbox_state__mem,
                                            memo_textbox_state__values["Open"],
                                            memo_textbox_state__values["Closed"])

// -----------------------
//   D E B R I E F I N G
// -----------------------

debriefing_step__addr = 0xef3b0
debriefing_sub_step__addr = 0xef3b1
debriefing_sub_sub_step__addr = 0xef3b2

debriefing_step__mem = byte(debriefing_step__addr)
debriefing_sub_step__mem = byte(debriefing_sub_step__addr)
debriefing_sub_sub_step__mem = byte(debriefing_sub_sub_step__addr)

// during debriefing, the "mode" address is used in a different way than in-game
debriefing_stage__mem = mode_id__mem
debriefing_stage__values = {
    "Ending CG":                0x01,
    "Credits":                  0x02,
    "Debriefing":               0x03,
    "Mad Skills":               0x04,
    "Unlock Operation Wipeout": 0x05,
    "Unlock Costumes":          0x06,
    "Save":                     0x07
}

function in_debriefing() {
    return in_post_ending_cg()
           && (debriefing_step__mem + debriefing_sub_step__mem + debriefing_sub_sub_step__mem) > 0
}

function in_debriefing_stage(name) => debriefing_stage__mem == debriefing_stage__values[name]

function debriefing_final_stats_just_started() {
    return in_debriefing_stage("Debriefing")
           && just_changed(debriefing_step__mem, 1, 2)
}

function debriefing_unlocking_costumes() {
    return in_debriefing_stage("Unlock Costumes")
           && debriefing_step__mem == 5
}

function debriefing_unlocking_operation_wipeout() {
    return in_debriefing_stage("Unlock Operation Wipeout")
           && debriefing_step__mem == 5
}

// ---------------------------------------
//   O P E R A T I O N :   W I P E O U T
// ---------------------------------------

function in_op_wipeout_alt() {
    // event flags are all zero'd out during operation wipeout.
    // because the opening cutscene is mandatory before playing,
    // its event flag can be used to differentiate between normal
    // play and operation wipeout
    return !cutscene_has_started("Opening (Part 1)")
}

in_op_wipeout__addr = 0xc1d01
in_op_wipeout__mem = byte(in_op_wipeout__addr)
function in_operation_wipeout() => in_op_wipeout__mem == 0x01

op_wipeout_stage__addr = 0xc1d03
op_wipeout_stage__mem = byte(op_wipeout_stage__addr)
op_wipeout_stage__values = {
    "Mission 1": 0,
    "Mission 2": 1,
    "Mission 3": 2,
    "Ending":    3
}

function op_wipeout_in_stage(name) => op_wipeout_stage__mem == op_wipeout_stage__values[name]

function op_wipeout_stage_just_changed(from, to) {
    return just_changed(op_wipeout_stage__mem, op_wipeout_stage__values[from], op_wipeout_stage__values[to])
}

// timers are 0 until the mission starts and decrease by 1 every 2 frames
op_wipeout_timers__addr = 0xc1d04
op_wipeout_timers__mem = {
    "Mission 1": word(op_wipeout_timers__addr),
    "Mission 2": word(op_wipeout_timers__addr + 4),
    "Mission 3": word(op_wipeout_timers__addr + 8)
}
op_wipeout_timers_max = {
    "Mission 1": (5 * 60 * 30),  // 9000
    "Mission 2": (4 * 60 * 30),  // 7200
    "Mission 3": (3 * 60 * 30)   // 5400
}
op_wipeout_all_missions_time_max = 12 * 60 * 30

function op_wipeout_ingame_mission(mission_name) {
    return op_wipeout_in_stage(mission_name)
           && op_wipeout_timers__mem[mission_name] != 0
}

function op_wipeout_ingame() {
    return op_wipeout_ingame_mission("Mission 1")
           || op_wipeout_ingame_mission("Mission 2")
           || op_wipeout_ingame_mission("Mission 3")
}

function op_wipeout_total_remaining_time() {
    val = 0
    for mission_name in op_wipeout_timers__mem {
        val = val + op_wipeout_timers__mem[mission_name]
    }
    return val
}

function op_wipeout_total_time_le(minutes, seconds) {
    target_time = ((minutes * 60) + seconds) * 30
    max_remaining = op_wipeout_all_missions_time_max - target_time
    return op_wipeout_total_remaining_time() > max_remaining
}

op_wipeout_final_time_text__addr = 0xb27dd

function op_wipeout_total_time_le_8_30() {
    text_addr = op_wipeout_final_time_text__addr
    return byte(text_addr) == ascii["0"]
        && byte(text_addr + 2) == ascii[":"]
        && ((byte(text_addr + 1) >= ascii["0"] && byte(text_addr + 1) <= ascii["7"])
            || (byte(text_addr + 1) == ascii["8"]
                && ((byte(text_addr + 3) >= ascii["0"] && byte(text_addr + 3) <= ascii["2"])
                    || (byte(text_addr + 3) == ascii["3"] && byte(text_addr + 4) == ascii["0"])))
        )
}

// ---------------------------------
//   D R O P P E D   W E A P O N S
// ---------------------------------

dropped_weapons__arr_addr = 0xc1a00
dropped_weapons__arr_size = 3
dropped_weapons__struct_fields = {
    // mostly unmapped, because there's no need
    "on ground?": 0x13,  // byte
    "weapon id":  0x18,  // byte
    "room id":    0x28,  // byte
    "floor id":   0x29,  // byte
}
dropped_weapons__struct_sizeof = 44
dropped_weapons__array_offsets = {
    "Shotgun":     0,
    "Handgun":     1,
    "Grenade Gun": 2
}

function dropped_weapon_byte_field(weapon, field) {
    return byte(dropped_weapons__arr_addr
                + (dropped_weapons__array_offsets[weapon] * dropped_weapons__struct_sizeof)
                + dropped_weapons__struct_fields[field])
}

function just_grabbed_dropped_weapon_in_room(room_name) {
    cond = always_false()
    for weapon in dropped_weapons__array_offsets {
        cond = cond || (dropped_weapon_byte_field(weapon, "floor id") == floor_room__values[room_name][0]
                        && dropped_weapon_byte_field(weapon, "room id") == floor_room__values[room_name][1]
                        && just_changed(dropped_weapon_byte_field(weapon, "on ground?"), 1, 0))
    }
    return cond
}

function weapon_dropped_in_room(weapon_name, room_name) {
    return dropped_weapon_byte_field(weapon_name, "floor id") == floor_room__values[room_name][0]
           && dropped_weapon_byte_field(weapon_name, "room id") == floor_room__values[room_name][1]
           && dropped_weapon_byte_field(weapon_name, "on ground?") == 1
}

function weapon_not_dropped(name) {
    return dropped_weapon_byte_field(name, "on ground?") == 0
}

// ---------------------
//   M A I N   M E N U
// ---------------------

in_main_menu__addr = 0xc7c40
in_main_menu__mem = byte(in_main_menu__addr)

function in_main_menu() => in_main_menu__mem != 0

mm_demo_playing__addr = 0xc7c41
mm_demo_playing__mem = byte(mm_demo_playing__addr)

mm_selected_opt__addr = 0xc7c43
mm_selected_opt__mem = byte(mm_selected_opt__addr)
mm_selected_opt__values = {"New Game": 0, "Load Game": 1, "Option": 2}

mm_stage__addr = 0xc7c42
mm_stage__mem = byte(mm_stage__addr)
mm_stage__values = {
    "Push Start Button":             1,
    "New Game / Load Game / Option": 2,
    "New Game: Easy / Normal":       3,
    "Load Game: Memory Card":        3,
    "Option":                        3
}

mm_time_to_demo__addr = 0xc7c48
mm_time_to_demo__mem = word(mm_time_to_demo__addr)


//=======================================//
//                                       //
//        A C H I E V E M E N T S        //
//                                       //
//=======================================//

function story_common_trigger() {
    return in_game_mode("Normal")
     // && other limitations: no inf grenade? ...
}

function scoped_cutscene_was_watched(name) {
    return once(cutscene_just_started(name))            // we've witnessed the cutscene start
           && repeated(60, cutscene_has_started(name))  // require a full second in the cutscene to avoid possible few-frame weirdnesses
}

function scoped_cutscene_just_ended(name) {
    return scoped_cutscene_was_watched(name)  // make sure we've watched the cutscene
           && cur_cutscene_just_ended()       // trigger when the current cutscene ends
}

function never_not_in_room(name) {
    return never(!in_room_floor(name) && in_mode("Gameplay"))
           && never(!in_room_only(name) && in_mode("Gameplay"))
}

function never_not_in_rooms(names) {
    floor_cond = always_true()
    room_cond = always_true()
    for name in names {
        floor_cond = floor_cond && !in_room_floor(name)
        room_cond = room_cond && !in_room_only(name)
    }
    return never(floor_cond) && never(room_cond)
}


// ---------------
//   P A R T   I
// ---------------

achievement(
    title="Rick, You're Not Gonna Believe This",
    description="Survive your first Velociraptor encounter",
    points=2,
    trigger=story_common_trigger()
            && in_room("Backyard of the Facility")
            && scoped_cutscene_just_ended("Rick comms after first Raptor encounter")
)

achievement(
    title="Locker Room Talk [m]",
    description="Get ambushed in the Locker Room, read the journal, grab the DDK Code Disk and escape without taking damage or killing the Velociraptor",
    points=5,
    trigger=(
        story_common_trigger()
        && never_not_in_room("Locker Room")                                   // reset if the player's not in the Locker Room
        && scoped_cutscene_was_watched("Raptor Ambush in Locker Room")        // must have watched the ambush cutscene
        && once(just_read_a_memo()                                            // must have read a memo (there's only one in the room)
                && cutscene_watched("Raptor Ambush in Locker Room"))          //   ...but it must have been after the cutscene occurred
        && once(just_picked_up_item("DDK Code Disk H")                        // must have picked up DDK Code Disk H
                && cutscene_watched("Raptor Ambush in Locker Room"))          //   ...also must have been after the cutscene occurred
        && never(just_took_non_bleed_damage())                                // reset if the player takes non-bleed damage
        && enemy_is_alive("Raptor (Managment Office Hallway / Locker Room)")  // the raptor must be alive
        && just_changed_room("Locker Room", "Management Office Hallway")      // trigger upon leaving the Locker Room
    )
)

achievement(
    title="Oh, You've Got to Be Kidding Me [m]",
    description="Escape the T-Rex in the Chief's Office without shooting or taking damage",
    points=5,
    trigger=(
        story_common_trigger()
        && never_not_in_room("Chief's Office")
        && scoped_cutscene_was_watched("T-Rex in Chief's Office")
        && never(just_took_non_bleed_damage())
        && never(is_shooting())
        && just_changed_room("Chief's Office", "Hall F2")
    )
)

achievement(
    title="That's No Lizard, It's a Dinosaur!",
    description="When ambushed in the Lecture Room, perform the pre-historic QTE to summon Deus Ex Gail",
    points=5,
    trigger=story_common_trigger()
            && in_room("Lecture Room")
            && scoped_cutscene_just_ended("Raptor Ambush in Lecture Room")
)

achievement(
    title="So, Do We Have Power Yet?",
    description="Turn on the power for the underground levels of the facility",
    points=5,
    trigger=story_common_trigger()
            && in_room("Backup Generator Room B1")
            && scoped_cutscene_just_ended("Rick Comms After Backup Generator B1 Activation")
            // todo: would be nicer if it triggered only after the 2nd cutscene
)

achievement(
    title="Dr. Regina, MSc",
    description="Steal the identity of an unfortunate Researcher",
    points=5,
    trigger=story_common_trigger()
            && in_room("Office")
            && just_picked_up_item("ID Card (Researcher)")
)

function pipe_puzzle_interleaved_left_and_right_pipes() {

    // now this is some nice toolkit abuse...
    // the game does not remember which pipe was lowered last, only which ones are lowered.
    // as such, we have to remember ourselves... easier said than done.
    //
    // * if the player starts by lowering 2 pipes on the right, we need the cheevo to reset.
    //   on the contrary, if the player were to lower a pipe on the left between the 2 pipes
    //   on the right, we must not reset.
    //
    // * to handle this particular scenario, a dedicated alt group does the following:
    //   * to handle the reset, there's a ResetIf requiring 2 Hits that triggers when the
    //     amount of lowered pipes on the right changes
    //   * to avoid the reset happening if the player lowers a pipe on the left inbetween,
    //     there's a PauseIf requiring 1 Hit that triggers when a pipe is lowered on the left
    //     _and_ the amount of pipes lowered on the right is 1
    //
    // * 3 other similar alt groups are used to handle the other invalid scenarios, such as
    //   (left, left), (left, right, left, left), (right, left, left), etc...
    //   * one of the alts has the left and right sides switched
    //   * the other two are the same but for the "second round" of invalid plays, meaning
    //     the ResetIfs require 3 Hits and the PauseIfs only trigger if the number of
    //     lowered pipes on the relevant side is 2
    //
    // SubHits wen

    return (
        (never(repeated(2, pipe_puzzle_change_on_right()))
            && unless(once(pipe_puzzle_change_on_left() && pipe_puzzle_n_lowered_on_right() == 1)))
        || (never(repeated(3, pipe_puzzle_change_on_right()))
            && unless(once(pipe_puzzle_change_on_left() && pipe_puzzle_n_lowered_on_right() == 2)))
        || (never(repeated(2, pipe_puzzle_change_on_left()))
            && unless(once(pipe_puzzle_change_on_right() && pipe_puzzle_n_lowered_on_left() == 1)))
        || (never(repeated(3, pipe_puzzle_change_on_left()))
            && unless(once(pipe_puzzle_change_on_right() && pipe_puzzle_n_lowered_on_left() == 2)))
        || always_true()
    )
}

achievement(
    title="And That's How T-Rex to SM Odyssey [m]",
    description="Restore power to the Large Size Elevator without operating consoles on the same side twice in a row",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Elevator Power Room")
        && once(pipe_puzzle_was_in_initial_state())        // remember that we were once in the initial state... this
        && pipe_puzzle_interleaved_left_and_right_pipes()  // is the Hit that decides whether the cheevo triggers at the
                                                           // end or not, because it is removed if
                                                           // pipe_puzzle_interleaved_left_and_right_pipes fails.
        && never(pipe_puzzle_in_initial_state())           // reset everything if the player goes back to the initial state
        && cutscene_has_started("Restore Power to Large Size Elevator")
    )
)

achievement(
    title="Judge, Jury and Executioner [m]",
    description="After a Pteranodon attempts to turn you into a smoothie, execute his co-conspirator",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Passageway to the Power Room")
        && enemy_is_dead("Pteranodon (Passageway to the Power Room) (1)")
        && enemy_just_killed("Pteranodon (Passageway to the Power Room) (2)")
        // no further time-frame-limiting conditions are necessary, because the
        // two Pteranodons are only considered dead if killed after the ambush happens
    )
)

achievement(
    title="How Convenient [m]",
    description="Survive a strategically placed earthquake near the Large Size Elevator",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Large Size Elevator Passageway")
        && scoped_cutscene_just_ended("Large Size Elevator Passageway Earthquake")
        && !game_over()
    )
)

// todo: works, but is super easy. review
//achievement(
//    title="What is This? A Dinosaur for Ants? [m]",
//    description="Kill all the Compsognathus in Medical Room Hallway by shooting no more than 7 handgun bullets",
//    points=5,
//    trigger=(
//        story_common_trigger()
//        && once(just_entered_room("Medical Room Hallway"))
//        && in_room("Medical Room Hallway")
//        && enemy_just_killed("7 Compsognathus (Medical Room Hallway)")
//        && never(!cur_weapon_is_handgun() && is_shooting())  // can't shoot any gun other than the handgun
//        && never(repeated(8, just_started_shooting()))       // can't shoot more than 7 times
//    )
//)

function crane_puzzle_one_turn_with(n_cards) {
    return once(crane_puzzle_turn_just_started()
                && crane_puzzle_num_cards_selected_is(n_cards))
}

achievement(
    title="Crainiac [m]",
    description="Solve the crane puzzle in Carrying Out Room B1 using no more than 6 moves",
    points=5,
    trigger=(
        story_common_trigger()
        && never_not_in_room("Carrying Out Room B1")
        && once(crane_puzzle_containers_map_is("Carrying Out Room B1",
                                               [[1,0,1,0,0],         // must have started in the initial state
                                                [0,1,1,0,1],
                                                [1,0,1,0,1]], 0))
        && (
            crane_puzzle_containers_map_is("Carrying Out Room B1",
                                           [[1,1,1,0,0],             // must have reached the state resulting
                                            [0,0,1,0,1],             //   from the optimal solution
                                            [1,0,0,0,1]], 1)
            && never(repeated(3, crane_puzzle_turn_just_started()))  // optimal solution uses 2 turns
            && once(crane_puzzle_one_turn_with(1))                   // 1st turn uses 1 card
            && once(crane_puzzle_one_turn_with(5))                   // 2nd turn uses 5 cards
            && crane_puzzle_turn_just_ended()                        //  wait for the end of the turn to trigger
        )
    )
)

achievement(
    title="Comrade Tom",
    description="Follow the distress signal and locate your comrade [Choice 1: Rick]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 1: Rick's Route")
        && in_room("Large Size Elevator Control Room")
        && scoped_cutscene_just_ended("Finding Tom")
    )
)

achievement(
    title="Farewell, We Hardly Knew Ye",
    description="Realize you just wasted your time and should have gone with Gail's plan [Choice 1: Rick]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 1: Rick's Route")
        && in_room("Medical Room")
        && scoped_cutscene_just_ended("Meet Rick & Tom in Medical Room")
    )
)

achievement(
    title="Dr. Kirk?",
    description="Get your first glimpse of the mission's target [Choice 1: Gail]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 1: Gail's Route")
        && in_room("Hall B1 (Gail's Route Alt)")
        && scoped_cutscene_just_ended("See Dr. Kirk for the First Time with Gail")
    )
)

// -----------------
//   P A R T   I I
// -----------------

achievement(
    title="Aggressive Elevator Pitch",
    description="Go on a dangerous elevator ride to reach the main area of Hall B1",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Hall B1")
        && scoped_cutscene_just_ended("Raptor Ambush in Elevator")
    )
)

achievement(
    title="No Time for Small Talk [m]",  // WIP: For the Greater Good / A Small Price to Pay
    description="Get the B1 Key Chip without talking to the Researcher, shaving 30 seconds off your speedrun!",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Gas Experiment Room")
        && once(gas_puzzle_researcher_just_died()   // the researcher also dies during the cutscene,
                && !gas_puzzle_chamber_is_clear())  // so we have to ensure he died whilst the puzzle was not yet solved
        && just_picked_up_item("B1 Key Chip")
    )
)

achievement(
    title="Ain't No Free Lunch [m]",
    description="Take a cruel revenge on the Velociraptor that ambushes you in the Gas Experiment Room",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Gas Experiment Room")
        && once(raptor_in_gas_chamber()            // the raptor is marked as not being in the chamber *before* it dies
                && gas_puzzle_chamber_is_clear())  // ...thus, we must remember that it was once alive in a non-deadly chamber
        && never(gas_puzzle_chamber_is_clear()     // and reset if the raptor leaves the chamber while it's clear
                 && !raptor_in_gas_chamber())
        && enemy_just_killed("Raptor (Gas Experiment Room)")  // in the current scope, the raptor can only be killed with gas
    )
)

achievement(
    title="Medicine For a Good Samaritan [m]",
    description="Open one of the emergency cases in the Medical Room",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Medical Room")
        && (event_just_occurred("Left Emergency Case Opened in Medical Room")
            || event_just_occurred("Right Emergency Case Opened in Medical Room"))
    )
)

achievement(
    title="Miniature Foreshadowing [m]",
    description="Activate the Third Energy Simulator",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Experiment Simulation Room")
        && scoped_cutscene_just_ended("Activate Experiment Simulation")
    )
)

achievement(
    title="It’s a Unix System! I Know This! [m]",
    description="Successfully escape through the Experiment Simulation Room escape hatch [Choice 2: Rick]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 2: Rick's Route")
        && !cutscene_has_started("First Conversation with Dr. Kirk")
        && just_changed_room("Experiment Simulation Room", "Carrying Out Room B1")
    )
)

achievement(
    title="The Code Did Not Matched [m]",
    description="Go with Gail's idea after failing your escape plan in the Experiment Simulation Room [Choice 2: Rick]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 2: Gail's Route")  // starts with Rick's Route, but changes after the puzzle is failed
        && !cutscene_has_started("First Conversation with Dr. Kirk")
        && event_has_occurred("Failed Code Puzzle in Experiment Simulation Room")
        && just_changed_room("Hallway for Carrying in Materials (Gail's Route Alt)", "Carrying Out Room B1")
    )
)

achievement(
    title="I'll Take Them All Out One By One [m]",
    description="Take Gail literally and kill all 8 Velociraptors on your way out of the Research Area [Choice 2: Gail]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 2: Gail's Route")
        && !cutscene_has_started("First Conversation with Dr. Kirk")
        // avoid triggering when Rick's route was chosen and failed
        && !event_has_occurred("Failed Code Puzzle in Experiment Simulation Room")
        && enemy_is_dead("Raptor (Research Area Hall) (1)")
        && enemy_is_dead("Raptor (Research Area Hall) (2)")
        && enemy_is_dead("Raptor (Library Room) (1)")
        && enemy_is_dead("Raptor (Library Room) (2)")
        && enemy_is_dead("Raptor (Main Hallway B1) (1)")
        && enemy_is_dead("Raptor (Main Hallway B1) (2)")
        && enemy_is_dead("Raptor (Hall B1)")
        && enemy_is_dead("Raptor (Hallway for Carrying in Materials)")
        && just_changed_room("Hallway for Carrying in Materials (Gail's Route Alt)", "Carrying Out Room B1")
    )
)

// -------------------
//   P A R T   I I I
// -------------------

achievement(
    title="You Can't Do This! I Have Rights!",
    description="Apprehend Dr. Kirk",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Carrying Out Room B1")
        && scoped_cutscene_just_ended("First Conversation with Dr. Kirk")
    )
)

achievement(
    title="I'm a Bit Busy Right Now [m]",
    description="Escape the T-Rex after activating the antenna without shooting or taking damage",
    points=5,
    trigger=(
        story_common_trigger()
        && scoped_cutscene_was_watched("T-Rex Attack in Passageway to the Communication Area")
        && never(just_took_non_bleed_damage())
        && never(is_shooting())
        && just_changed_room("Passageway to the Communication Area", "Communication Room")
    )
)

function heliport_cg_just_ended() {
    // could also use the "mode" value, but I trust the room id more
    return just_changed_room("Heliport (During CG)", "Heliport")
}

achievement(
    title="What is That?!?!",
    description="Watch helplessly as that damn T-Rex destroys your ride home",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Heliport")
        && heliport_cg_just_ended()
    )
)

achievement(
    title="In a Hurry [m]",
    description="Escape the T-Rex in the Heliport in under 30 seconds",
    points=5,
    trigger=(
        story_common_trigger()

        // no counting until we're in the Heliport and the opening cutscene ends
        // (no bitflag for that cutscene, so we have to exclude Rick's cutscene)
        && never_not_in_room("Heliport")
        && never(in_cutscene() && !cutscene_has_started("Rick Signals While Running From T-Rex"))
        
        // use the end of the opening cutscene to scope the counter
        && once(in_room("Heliport") && cur_cutscene_just_ended()
                && !cutscene_has_started("Rick Signals While Running From T-Rex"))

        // reset the cheevo at 30 seconds
        && never(repeated(secs_to_frames(35), always_true()))

        // pause the timer when in non-gameplay modes (menus, loading, ...) and when the game's paused
        // note: entering room mode is allowed so that the change-room trigger works
        && unless(!in_mode("Gameplay") && !in_mode("Entering Room"))
        && unless(game_paused())

        // trigger when we enter the elevator
        && just_changed_room("Heliport", "Liaison Elevator No. 2")
    )
)

achievement(
    title="Look at This Absolute Unit",
    description="Barely survive your first encounter with a Therizinosaurus",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("General Weapons Store")
        && scoped_cutscene_just_ended("Therizinosaurus Ambush in General Weapons Store")
    )
)

achievement(
    title="300 IQ [m]",
    description="Solve the crane puzzle in General Weapons Store using no more than 15 moves",
    points=5,
    trigger=(
        story_common_trigger()
        && never_not_in_room("General Weapons Store (Post Crane Keys Alt)")
        && once(crane_puzzle_containers_map_is("General Weapons Store",
                                               [[0,0,1,0,1],
                                                [0,0,0,1,1],
                                                [0,0,1,1,0],
                                                [0,1,0,0,1]], 0))
        && (
            crane_puzzle_containers_map_is("General Weapons Store",
                                           [[1,0,0,0,0],
                                            [0,0,1,1,0],
                                            [0,0,1,1,0],
                                            [0,1,1,0,0]], 1)
            && never(repeated(5, crane_puzzle_turn_just_started()))
            && (
                // possible solutions:
                //   - Up Hook Left Release -> Right Hook -> Release Right Up Hook -> Up Down Release Right Hook (4->2->4->5)
                //   - Up Hook Left Release -> Right Hook -> Release Up Right Hook -> Up Down Release Right Hook (4->2->4->5)
                //   - Up Hook Left Release -> Right Hook -> Up Down Release Right Hook -> Release Right Up Hook (4->2->5->4)
                //   - Up Hook Left Release -> Right Hook -> Up Down Release Right Hook -> Release Up Right Hook (4->2->5->4)
                //   - Up Hook Left Release -> Right Up Hook -> Release Right Hook -> Up Down Release Right Hook (4->3->3->5)
                //   - Up Hook Left Release -> Right Up Hook -> Up Down Release Right Hook -> Release Right Hook (4->3->5->3)
                //   - Up Hook Left Release -> Up Right Hook -> Release Right Hook -> Up Down Release Right Hook (4->3->3->5)
                //   - Up Hook Left Release -> Up Right Hook -> Up Down Release Right Hook -> Release Right Hook (4->3->5->3)
                crane_puzzle_one_turn_with(4)
                && (
                    (crane_puzzle_one_turn_with(2) && crane_puzzle_one_turn_with(4) && crane_puzzle_one_turn_with(5))
                    || (crane_puzzle_one_turn_with(3) && crane_puzzle_one_turn_with(3) && crane_puzzle_one_turn_with(5))
                )
                     
            ) && crane_puzzle_turn_just_ended()
        )
    )
)

achievement(
    title="I Come In Peace [m]",
    description="Collect the B2 Key Chip 1 in the Security Pass Room without having ever triggered the alarm",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Security Pass Room")
        // pick up the item, while the alarm is inactive and without having deactivated it beforehand
        && just_picked_up_item("B2 Key Chip 1")
        && !security_room_alarm_active()
        && !event_has_occurred("Alarm Deactivate in Security Pass Room")
    )
)

achievement(
    title="Elevator T-Rex [m]",
    description="Witness a literal T-Rex come out of an elevator and electrocute itself",
    points=5,
    trigger=(
        story_common_trigger()
        && never_not_in_room("Carrying Out Room B3")
        && scoped_cutscene_just_ended("T-Rex Rides the Elevator and Eletrocutes Itself")
        // this version of the cutscene only happens after the player runs towards the elevator,
        // whilst the other version occurs right as the player enters the room. we use this
        // fact to diferentiate between them.
        && repeated(60, in_room("Carrying Out Room B3") && in_mode("Gameplay") && !in_cutscene())
    )
)

achievement(
    title="Am I Late? [m]",
    description="Get lost and miss the arrival of the T-Rex at level B3",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Carrying Out Room B3")
        && scoped_cutscene_just_ended("T-Rex Rides the Elevator and Eletrocutes Itself")
        // opposite of the other achievement related to this event
        && once(just_entered_room("Carrying Out Room B3"))
        && never(repeated(60, in_room("Carrying Out Room B3") && in_mode("Gameplay") && !in_cutscene()))
    )
)

achievement(
    title="Lost and Found [m]",
    description="Grab a weapon from the Large Size Elevator after the T-Rex electrocutes itself",
    points=5,
    trigger=(
        in_room("Large Size Elevator (Descending & B3)")
        && just_grabbed_dropped_weapon_in_room("Large Size Elevator (Descending & B3)")
    )
)

achievement(
    title="We'll Both End Up as Dino Droppings",
    description="Get denied your ride home once again",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Passageway to the Port")
        && scoped_cutscene_just_ended("Witness the Vortex in Passageway to the Port")
    )
)

achievement(
    title="I'm Chillin', Tryna Stack These Hexillions [m]",
    description="Solve the stack puzzle in the Security Pass Room in no more than 8 moves",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Security Pass Room")
        && never(!security_room_solving_stack_puzzle())          // reset if not solving the puzzle
        && once(stack_puzzle_in_initial_state())                 // puzzle was once in its original state
        && never(stack_puzzle_just_reset())                      // reset if the player resets the puzzle
        && never(repeated(4, stack_puzzle_just_popped_left()))   // optimal solution is 3 left pops
        && never(repeated(4, stack_puzzle_just_popped_right()))  //                   + 3 right pops
        && never(repeated(3, stack_puzzle_just_swapped()))       //                   + 2 swaps
        && stack_puzzle_is_solved()                              // trigger when puzzle is solved
    )
)

achievement(
    title="Password12345",
    description="Gain access to the Third Energy Generator using the world's most nascissistic password",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Parts Storage")
        && just_unlocked_door("Parts Storage > Passageway")
    )
)

achievement(
    title="CSI Ibis Island [m]",
    description="Obtain Dr. Kirk's fingerprint before meeting him in his personal Lab",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Power Frequency Room")
        && just_got_fingerprint("Dr. Kirk")
    )
)

achievement(
    title="Spoken Like a True Devil",
    description="Re-secure Dr. Kirk and listen to his villain speech",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Dr. Kirk's Personal Lab")
        && scoped_cutscene_just_ended("Meet Dr. Kirk in his Personal Lab")
    )
)

achievement(
    title="Dr. Regina, PhD",
    description="Steal the identity of Dr. Kirk himself",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Security Pass Room")
        && just_picked_up_item("ID Card (Dr. Kirk)")
    )
)

achievement(
    title="DIY Third Energy Generator",
    description="Build the parts required to operate the Third Energy Generator yourself [Choice 3: Rick]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 3: Rick's Route")
        && in_room("Stabilizer Experiment Room")
        && just_finished_picking_up_items(["Stabilizer (Rick's Route)", "Initializer (Rick's Route)"])
    )
)

achievement(
    title="Off-The-Shelf Third Energy Generator",
    description="Grab ready-made parts for the Third Energy Generator [Choice 3: Gail]",
    points=5,
    trigger=(
        story_common_trigger()
        && chose_story_split("Split 3: Gail's Route")
        && in_room("Special Weapons Storage")
        && just_finished_picking_up_items(["Stabilizer (Gail's Route)", "Initializer (Gail's Route)"])
    )
)

// -----------------
//   P A R T   I V
// -----------------

achievement(
    title="Let's Go Out With a Boom",
    description="Cause a Third Energy overload to clear your escape path",
    points=5,
    trigger=(
        story_common_trigger()
        // this sequence of cutscenes is special because Regina moves between rooms multiple
        // times without the cutscene actually ending
        && never_not_in_rooms(["Third Energy Control Room (Upstairs)",                 // limit the scope to the Third Energy Control Room
                               "Third Energy Control Room (Downstairs)",               //   ...(both upstairs and downstairs),
                               "Dr. Kirk's Library Room"])                             //   ...and to the Dr Kirk's Library Room
        && once(in_room("Third Energy Control Room (Downstairs)")                      // we were once downstairs before
                && !cutscene_has_started("Gail's Hurt & Dr. Kirk Escapes Captivity"))  //   ...Gail getting hurt
        && in_room("Third Energy Control Room (Upstairs)")                             // trigger when we get back upstairs,
        && in_mode("Gameplay")                                                         //   ...gain control of Regine,
        && cutscene_has_started("Gail's Hurt & Dr. Kirk Escapes Captivity")            //   ...and Gail has already gotten hurt
    )
)

// -----------------
// Rick's Bad Ending
// -----------------

achievement(
    title="Ooooo, Shiny! [m]",
    description="Grab an item during your final T-Rex encounter without doing a lap around the Port or shooting more than 6 times [Rick's Bad Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && once(just_entered_room("Port (T-Rex Fight)"))  // scope the cheevo to the whole fight
        && never(                                         // reset if Regina does an almost-full lap:
             crossed_ns_origin_heading_north()            //   - crossed the north-south origin heading towards the hovercraft
             && on_east_side()                            //   - whilst on the east part of the room (side where the item is)
        )
        && never(repeated(7, just_started_shooting()))    // reset if more then 6 shots are fired
        && in_room("Port (T-Rex Fight)")
        && cutscene_has_started("Receive Items from Rick to Fight the T-Rex")
        && once(just_picked_up_item("Recovery Aid (Port)"))  // remember that we've picked up the item
        && ending_cg_just_started("Rick's Bad Ending")       // trigger when the ending CG starts
    )
)

function ending_trigger(final_choice, ending) {
    return chose_story_split(final_choice)           // we've made the relevant final choice
           && once(ending_cg_just_started(ending))   // we've watched the relevant ending
           && debriefing_final_stats_just_started()  // trigger only at the end of the debriefing
           && never(in_main_menu())                  // forget the ending in the main menu
}

achievement(
    title="Going Home Empty-Handed",
    description="Complete the assignment without accomplishing your mission [Rick's Bad Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && ending_trigger("Split 4: Rick's Route", "Rick's Bad Ending")
    )
)

// -----------------
// Gail's Bad Ending
// -----------------

achievement(
    title="What Do You Mean Our Real Mission?",
    description="Recapture Dr. Kirk and learn about your team's secret mission [Gail's Bad Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Stabilizer Experiment Room")
        && just_picked_up_item("Secret Disc")
    )
)

achievement(
    title="The Professional",
    description="Complete the assignment having accomplished its secret mission [Gail's Bad Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && ending_trigger("Split 4: Gail's Route", "Gail's Bad Ending")
    )
)

// ------------------
// Rick's Best Ending
// ------------------

achievement(
    title="Fine, I'll Do It Myself",
    description="Send Rick and Gail to the Port and recapture Dr. Kirk yourself [Rick's Best Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Underground Heliport")
        && scoped_cutscene_just_ended("Recapture Dr. Kirk in Underground Heliport")
    )
)

achievement(
    title="By The Book",
    description="Complete the assignment having accomplished your mission with minimal casualties [Rick's Best Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && ending_trigger("Split 4: Rick's Route", "Best Ending")
    )
)

// ------------------
// Gail's Best Ending
// ------------------

achievement(
    title="Just a Quick Detour",
    description="Find an helicopter before going after Dr. Kirk [Gail's Best Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Underground Heliport")
        && scoped_cutscene_just_ended("Find Helicopter in Underground Heliport")
    )
)

achievement(
    title="Best Ending",
    description="Complete the assignment having (unknowingly) accomplished both missions with minimal casualties [Gail's Best Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && ending_trigger("Split 4: Gail's Route", "Best Ending")
    )
)


// -----------------
// Both Best Endings
// -----------------

achievement(
    title="Ultimate Final Boss [m]",
    description="Defeat the underground T-Rex without taking damage whilst employing minimal effort and resources [Any Best Ending]",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Heliport Transport Passageway")

        // scope the logic to the whole battle, starting when we gain control
        // note: there is no flag for the final T-Rex cutscene, so detecting the final battle
        //       is done using the unique camera ids used during the battle
        && once(cur_cutscene_just_ended())
        && never(camera_id() != 0 && camera_id() < 6)  // between 6 and 9 during the fight
                                                       // also 0 during the cutscenes

        // no damage
        && never(just_took_non_bleed_damage())

        // minimal effort = no moving (including in-place rotations)
        && never(moving())
        
        // minimal resources = max 6 shots
        && never(repeated(7, just_started_shooting()))
        
        // trigger when the fight-ending cutscene starts
        && in_cutscene()
    )
)

// ---------------------
//   I N V E N T O R Y
// ---------------------

achievement(
    title="Should Have Packed One of These [m]",
    description="Obtain the Franchi PA3 Shotgun",
    points=5,
    trigger=(
        story_common_trigger()
        && in_room("Management Office")
        && just_got_weapon("Shotgun")
    )
)

achievement(
    title="Make Dino Go Boom [m]",
    description="Obtain the 40mmHK Grenade Gun",
    points=5,
    trigger=(
        story_common_trigger()
        && (in_room("Hangar")
            || in_room("Hovercraft Storage")
            || in_room("Hovercraft")
            || in_room("Underground Heliport"))
        && just_got_weapon("Grenade Gun")
    )
)

achievement(
    title="Thanks, I Still Hate It [m]",
    description="Upgrade your Glock 34 into a Glock 35 with a sight",
    points=5,
    trigger=(
        story_common_trigger()
        && just_upgraded_weapon(["Handgun Custom", "Handgun + Sight"], "HG Custom + Sight")
    )
)

achievement(
    title="Should One-Shot Everything Now [m]",
    description="Upgrade your shotgun into a SPAS-12 with a stock",
    points=5,
    trigger=(
        story_common_trigger()
        && just_upgraded_weapon(["Shotgun Custom", "Shotgun + Stock"], "SG Custom + Stock")
    )
)

achievement(
    title="Regina Custom [m]",
    description="Upgrade the grenade gun with a customization of Regina's authorship",
    points=5,
    trigger=(
        story_common_trigger()
        && just_upgraded_weapon(["Grenade Gun"], "GG Custom")
    )
)

achievement(
    title="Master Alchemist [m]",
    description="Make a Poison Dart through mixing",
    points=5,
    trigger=(
        story_common_trigger()
        && just_mixed("Poison Dart")
    )
)

// -------------------------
//   U N L O C K A B L E S
// -------------------------

achievement(
    title="I've Seen It All",
    description="Watch all 3 endings",
    points=5,
    trigger=(
        once(just_reached_n_endings_viewed(3))    // the total changes when the CG starts, so delay the trigger...
        && never(!viewed_n_endings(3))
        && debriefing_final_stats_just_started()  // ...until the debriefing ends
    )
)

achievement(
    title="Say No to Matching Outfits",
    description="Unlock the Army Type and Battle Type costumes by beating the game",
    points=5,
    trigger=(
        debriefing_unlocking_costumes()
        && just_unlocked_costume("Army Type")
        && just_unlocked_costume("Battle Type")
    )
)

achievement(
    title="Flinstones Cosplay",
    description="Unlock the Ancient Type costume by beating the game twice",
    points=5,
    trigger=(
        debriefing_unlocking_costumes()
        && just_unlocked_costume("Ancient Type")
    )
)

achievement(
    title="Operation: Wipeout (WIP)",
    description="Unlock Operation Wipeout by beating the game in under 5 hours",
    points=5,
    trigger=(
        debriefing_unlocking_operation_wipeout()
    )
)

achievement(
    title="Pre-Historic Tech",
    description="Shoot a grenade from a fish's mouth",
    points=5,
    trigger=(
        wearing_costume("Ancient Type")
        && cur_weapon_is_grenade_gun()
        && just_started_shooting()
    )
)

// ---------------------------------------
//   O P E R A T I O N :   W I P E O U T
// ---------------------------------------

function op_wipeout_stage_change_trigger(from, to) {
    return in_operation_wipeout()
           && op_wipeout_stage_just_changed(from, to)
}

achievement(
    title="Triassic Extinction",
    description="Complete Mission 1 of Operation Wipeout",
    points=5,
    trigger=op_wipeout_stage_change_trigger("Mission 1", "Mission 2")
)

achievement(
    title="Jurassic Extinction",
    description="Complete Mission 2 of Operation Wipeout",
    points=5,
    trigger=op_wipeout_stage_change_trigger("Mission 2", "Mission 3")
)

achievement(
    title="Cretacious Extinction",
    description="Complete Mission 3 of Operation Wipeout",
    points=5,
    trigger=op_wipeout_stage_change_trigger("Mission 3", "Ending")
)

achievement(
    title="You're Extinct!",
    description="Complete Operation Wipeout in less than 8 minutes and 30 seconds",
    points=5,
    trigger=(
        op_wipeout_in_stage("Ending")
        //&& op_wipeout_total_time_le(8, 30)  // using the 3 real timers is not possible because the game
                                              // rounds each of them up and them sums to obtain the final
                                              // time, which is impossible to do in the toolkit
        && op_wipeout_total_time_le_8_30()    // so... using text. forgive me euclide, for I have sinned
    )
)

// -------------------------------
//   C H A L L E N G E   R U N S
// -------------------------------

achievement(
    title="No Weapon Run",
    description="Grab no weapons, leave the handgun on the LS Elevator, and beat the game w/o using any continues",
    points=5,
    trigger=(
        story_common_trigger()

        // must have no weapons in the inventory
        && has_no_weapons()

        // the handgun must still be in the Large Size Elevator
        && weapon_dropped_in_room("Handgun", "Large Size Elevator (Descending & B3)")

        // no other weapon should be dropped, because they must never have been picked up
        && weapon_not_dropped("Shotgun") && weapon_not_dropped("Grenade Gun")
        
        && once(any_ending_cg_just_started())     // we've watched an ending
        && debriefing_final_stats_just_started()  // trigger only at the end of the debriefing
        && never(in_main_menu())                  // forget the ending in the main menu
    )
)

//=========================================//
//                                         //
//        R I C H   P R E S E N C E        //
//                                         //
//=========================================//

// ---------------------------
//   M A I N   M E N U   R P
// ---------------------------

rich_presence_conditional_display(
    in_main_menu(),
    "Regina is getting ready for her next assignment"
)

// -----------------------------
//   D E B R I E F I N G   R P
// -----------------------------

rp_difficulty_lookup = rich_presence_lookup(
    "Difficulty",
    game_mode__mem,
    { 0: "Normal", 1: "Easy" },
    "??"
)

rp_time_value = rich_presence_value("Time", timer__mem / 60, "SECS")
rp_continues_value = rich_presence_value("Continues", 5 - num_continues__mem)
rp_saves_value = rich_presence_value("Saves", num_saves__mem)
rp_endings_value = rich_presence_value("Endings", viewed_endings())

rich_presence_conditional_display(
    in_debriefing(),
    "Regina is being debriefed | {0} | {1} | {2} Continues | {3} Saves | {4}/3 Endings",
    rp_difficulty_lookup,
    rp_time_value,
    rp_continues_value,
    rp_saves_value,
    rp_endings_value
)

// -------------------------------------------
//   O P E R A T I O N   W I P E O U T   R P
// -------------------------------------------

rp_op_wipeout_stage_lookup = rich_presence_lookup(
    "OpWipeoutStage",
    op_wipeout_stage__mem,
    { 0: "Mission 1", 1: "Mission 2", 2: "Mission 3" },
    ""
)

rich_presence_conditional_display(
    in_operation_wipeout() && op_wipeout_in_stage("Ending"),
    "Regina has completed Operation Wipeout"
)

rich_presence_conditional_display(
    in_operation_wipeout() && op_wipeout_ingame(),
    "Regina is in {0} of Operation Wipeout",
    rp_op_wipeout_stage_lookup
)

rich_presence_conditional_display(
    in_operation_wipeout(),
    "Regina is getting ready to tackle {0} of Operation Wipeout",
    rp_op_wipeout_stage_lookup
)

// -----------------------
//   I N - G A M E   R P
// -----------------------

rp_location_lookup = rich_presence_lookup(
    "Location",
    room_floor_id__mem,
    {
        0x0100: "Locker Room",
        0x0101: "Toilet",
        0x0102: "Management Office Hallway",
        0x0103: "Management Office",
        0x0104: "Strategy Room",
        0x0105: "Control Room Hall",
        0x0106: "Control Room",
        0x0107: "Main Entrance 1F",
        0x0108: "Lecture Room Hallway",
        0x0109: "Lecture Room",
        0x010a: "Office Hallway",
        0x010b: "Office",
        0x010c: "Material Storage",
        0x010d: "Backyard of the Facility",
        0x010e: "Passageway to the Backup Generator",
        0x010f: "Backup Generator Room 1F",
        0x0110: "Piping Check Passageway A 1F",
        0x0111: "Piping Check Passageway B 1F",
        0x0112: "The Backyard",
        0x0113: "Elevator Hall",
        0x0114: "Passageway to the Backup Generator",

        0x0200: "Communication Antenna Room",
        0x0201: "Passageway to the Communication Area",
        0x0202: "Chief's Office",
        0x0203: "Hall F2",
        0x0204: "Lounge",
        0x0205: "Communication Room",
        0x0206: "Main Entrance 2F",

        0x0300: "Experiment Simulation Room",
        0x0301: "Research Area Hall",
        0x0302: "Research Meeting Room",
        0x0303: "Gas Experiment Room",
        0x0304: "Computer Room",
        0x0305: "Library Room",
        0x0306: "Main Hallway B1",
        0x0307: "Medical Room Hallway",
        0x0308: "Medical Room",
        0x0309: "Hall B1",
        0x030a: "Hallway for Carrying in Materials",
        0x030b: "Backup Generator Room B1",
        0x030c: "Carrying Out Room B1",
        0x030d: "Hallway for Carrying in Materials",
        0x030e: "Hall B1",
    
        0x0400: "Front Area of Entrance",
        0x0401: "Passageway to the Heliport",
        0x0402: "Hangar",
        0x0403: "Heliport",
        0x0404: "Large Size Elevator Passageway",
        0x0405: "Large Size Elevator",
        0x0406: "Large Size Elevator Control Room",
        0x0407: "Passageway to the Power Room",
        0x0408: "Elevator Power Room",
        0x0409: "Liaison Elevator No. 2",
        0x040a: "Underground Passageway to the Facility",
        0x040b: "Materials Room",
        0x040c: "Liaison Elevator No. 1",
        0x040d: "Heliport",
    
        0x0500: "Passageway to the Experiment Area",
        0x0501: "Piping Check Passageway B2",
        0x0502: "Experiment Room Hall",
        0x0503: "Stabilizer Experiment Room",
        0x0504: "Stabilizer Design Room",
        0x0505: "Researcher Rest Room",
        0x0506: "Security Pass Room",
        0x0507: "Parts Storage",
        0x0508: "Passageway",
        0x0509: "Third Energy Area B2",
        0x050a: "Third Energy Area B3",
        0x050b: "Third Energy Control Room",
        0x050c: "Power Frequency Room",
        0x050d: "Passageway to Personal Lab",
        0x050e: "Dr. Kirk's Personal Lab",
        0x050f: "Dr. Kirk's Library Room",
        0x0510: "Third Energy Control Room",
        0x0511: "Stabilizer Experiment Room",
    
        0x0600: "Carrying Out Room B3",
        0x0601: "Backup Generator Room B3",
        0x0602: "Control Room B3",
        0x0603: "Passageway to the Carrying Out Room",
        0x0604: "Rest Station",
        0x0605: "General Weapons Store",
        0x0606: "Transport Passageway",
        0x0607: "Special Weapons Storage",
        0x0608: "Central Stairway",
        0x0609: "Disembarkation Immigration Office",
        0x060a: "Port",
        0x060b: "Passageway to the Port",
        0x060c: "Channel",
        0x060d: "Underground Heliport",
        0x060e: "Elevator",
        0x060f: "Large Size Elevator",
        0x0610: "Hovercraft Storage",
        0x0611: "Heliport Transport Passageway",
        0x0612: "Hovercraft",
        0x0613: "Port",
        0x0614: "Port Transport Passageway",
        0x0615: "General Weapons Store",
    },
    "parts unknown"
)

rich_presence_display(
    "Regina is in {0} | {1} | {2}",
    rp_location_lookup,
    rp_difficulty_lookup,
    rp_time_value
)
