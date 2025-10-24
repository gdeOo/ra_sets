// Tomb Raider II
// #ID = 11341

// existing achievement sets:
// - https://tombraider.fandom.com/wiki/Tomb_Raider_II/Achievements
// - https://www.tombraiderforums.com/showthread.php?t=181253
// - https://www.tombraiderforums.com/showthread.php?t=167807
// - https://www.tombraiderforums.com/showthread.php?t=180183
// - https://www.tombraiderforums.com/showthread.php?t=164045

//
//   U T I L S
//

function just_changed(mem, from, to)  => prev(mem) == from && mem == to
function just_changed_from(mem, from) => prev(mem) == from && mem != from
function just_changed_to(mem, to) => prev(mem) != to && mem == to

function is_negative(sign_bit) => sign_bit == 1

function zip4(arr_a, arr_b, arr_c, arr_d) {
    arr = []
    i = 0
    for a in arr_a {
        array_push(arr, [a, arr_b[i], arr_c[i], arr_d[i]])
        i = i + 1
    }
    return arr
}

//
//   S T R U C T S
//

lara_info__struct = {
    "entity id":                0,  // word
    "gun status":               2,  // word (gun_status)
    "gun type":                 4,  // word (gun_type)
    "request gun type":         6,  // word (gun_type)
    "last gun type":            8,  // word (gun_type)
    "water status":            12,  // word (water_status)
    "facing climbable wall":   14,  // word (boolean) (freeze at 1 to climb any wall)
    "air remaining":           22,  // word (max = 1800)
    "flare remaining":         32,  // word (counts from 0 to 1800)
    "vehicle entity id":       34,  // word
    "gun on back":             38,  // word (gun_type)
    "flags":                   42,  // word (lara_info_flags)
    "water surface distance":  44,  // dword (0x00007f00 if no water, 0xffffffff if on surface)
    "position x":              48,  // dword
    "position y":              52,  // dword
    "position z":              56,  // dword
    "targeted entity ptr":    128,  // dword
    "turn rate":              136,  // word
    "angle":                  138,  // word
    "left arm animation id":  158,  // word
    "left arm targetting":    160,  // word (boolean)
    "right arm animation id": 178,  // word
    "right arm targetting":   180,  // word (boolean)
    "pistol ammo":            192,  // dword (unused)
    "automatic pistol ammo":  196,  // dword
    "uzi ammo":               200,  // dword
    "shotgun ammo":           204,  // dword
    "harpoon gun ammo":       206,  // dword
    "grenade launcher ammo":  210,  // dword
    "m16 ammo":               214,  // dword
}

entity__struct = {
    "floor height":        0,  // dword
    "touch flags":         4,  // dword (related to interactions with other entities)
    "model id":           12,  // word (model_id)
    "current action id":  14,  // word (action_id[model])
    "goal action id":     16,  // word (action_id[model])
    "required action id": 18,  // word (action_id[model])
    "animation id":       20,  // word
    "animation timer":    22,  // word
    "room number":        24,  // word
    "horizontal speed":   30,  // word
    "vertical speed":     32,  // word (signed, negative is up)
    "hit points":         34,  // word
    "box number":         36,  // word
    "timer":              38,  // word
    "flags":              40,  // word (entity_flags)
    "dropped entity id":  46,  // word
    "data":               48,  // dword (void*)
    "position x":         52,  // dword
    "position y":         56,  // dword
    "position z":         60,  // dword
    "pitch":              64,  // word
    "yaw":                66,  // word
    "roll":               68,  // word
    "flags2":             72,  // byte (entity_flags2)
}
entity__sizeof = 76

inventory_item__struct = {
    "name":     0,  // dword (char*)
    "model id": 4,  // word (model id)
}

statistics__struct = {
    "timer":            0,  // dword
    "shots fired":      4,  // dword
    "hits":             8,  // dword
    "distance":        12,  // dword
    "kills":           16,  // word
    "secrets":         18,  // byte (secrets)
    "medipacks used":  19   // byte
}

camera__struct = {
    "position x":        0,  // dword
    "position y":        4,  // dword
    "position z":        8,  // dword
    "position room no": 12,  // word
    "position box no":  14,  // word
    "target x":         16,  // dword
    "target y":         20,  // dword
    "target z":         24,  // dword
    "target room no":   28,  // word
    "target box no":    30,  // word
    "fixed?":           44,  // dword (boolean)
    "underwater?":      56,  // dword (boolean)
    // ...
}

creature__struct = {
    "head rotation":  0,  // word
    "neck rotation":  2,  // word
    "flags":          6,  // word
    "entity number":  8,  // word
    "mood":          12,  // word (mood)
    "target entity": 64,  // dword (entity*)
}

sfx_info__struct = {
    "volume":        0,  // dword (float(value) / 0x7fff)
    "sample index":  8,  // dword
    "probability":  12,  // dword
}
sfx_info__sizeof = 16

function struct_field(struct_def, base, field) => base + struct_def[field]

function _lara_info_field(base, field) => struct_field(lara_info__struct, base, field)
function entity_field(base, field) => struct_field(entity__struct, base, field)
function inventory_item_field(base, field) => struct_field(inventory_item__struct, base, field)
function statistics_field(base, field) => struct_field(statistics__struct, base, field)
function _camera_field(base, field) => struct_field(camera__struct, base, field)
function creature_field(base, field) => struct_field(creature__struct, base, field)
function sfx_info_field(base, field) => struct_field(sfx_info__struct, base, field)

//
//   E N U M S
//

gun_status__enum = {
    "no gun (can draw)":    0,
    "no gun (cannot draw)": 1,
    "drawing gun":          2,
    "undrawing gun":        3,
    "gun drawn":            4,
}

gun_type__enum = {
    "unarmed":           0,
    "pistols":           1,
    "automatic pistols": 2,
    "uzis":              3,
    "shotgun":           4,
    "m16":               5,
    "grenade launcher":  6,
    "harpoon gun":       7,
    "flare":             8,
    "snowmobile gun":    9
}

water_status__enum = {
    "not in water": 0,
    "underwater":   1,
    "on surface":   2,
    "wading":       4
}

function lara_info_flags__bitflags(flags_mem, flag) {
    flags = {
        "extra animation": bit2(flags_mem),
        "burning":         bit4(flags_mem)
    }
    return flags[flag]
}

model_id__enum = {
    "Lara":                       0,
    "Flare":                    152,
    "Shotgun Option":           158,
    "Automatic Pistols Option": 159,
    "Uzis Option":              160,
    "Harpoon Gun Option":       161,
    "M16 Option":               162,
    "Grenade Launcher Option":  163,
    // ...
}

action_id__enum = {
    "Lara": {
        "Walk":            0x00,
        "Run":             0x01,
        "Stopped":         0x02,
        "Hang":            0x0a,
        "Reaching":        0x0b,
        "Swim":            0x11,
        "Pull Up":         0x13,
        "Upwards Jump":    0x1c,
        "Slide Backwards": 0x20,
        "Dive":            0x23,
        "Pickup":          0x27,
        "Swan Dive Start": 0x34,
        "Swan Dive Fall":  0x35,
        "Handstand":       0x36,
        "Climbing":        0x39
    },
    "Underwater Fan":   { "Moving": 0, "Stopped": 1 },
    "Underwater Lever": { "Not Pulled": 1, "Pulled": 0 },
    "Trapdoor 1":       { "Closed": 0, "Open": 1 },
    "Trapdoor 2":       { "Closed": 0, "Open": 1 },
    "Guardian":         { "Confused": 8, "Dying": 9 },
    "Dragon Front":     { "Incapacitated": 0xb }
}

animation_id__enum = {
    "Lara": {
        "Somersault":         0x0d0,
        "In Boat":            0x104,
        "Leave Boat (Left)":  0x108,
        "Leave Boat (Right)": 0x10a
    },
    "Door 2": { "Closed":   0x187, "Opening":   0x18a, "Open":   0x189, "Closing":   0x188 },
    "Door 3": { "Closed":   0x18b, "Opening":   0x18e, "Open":   0x18d, "Closing":   0x18c },
    "Door 4": { "Closed":   0x0fc, "Opening":   0x0fd, "Open":   0x0fe, "Closing":   0x0ff,
                "Closed 2": 0x173, "Opening 2": 0x174, "Open 2": 0x175, "Closing 2": 0x176 },
    "Door 5": { "Closed":   0x1ae, "Opening":   0x1b1, "Open":   0x1b0, "Closing":   0x1af },
    "Door 6": { "Closed":   0x1b2, "Opening":   0x1b5, "Open":   0x1b4, "Closing":   0x1b3 },
    "Door 8": { "Closed":   0x1d0, "Opening":   0x1d2, "Open":   0x1d1, "Closing":   0x1d3,
                "Closed 2": 0x1a9, "Opening 2": 0x1ab, "Open 2": 0x1aa, "Closing 2": 0x1ac }
}

function entity_flags__bitflags(flags_mem) => {
    "invisible": bit0(flags_mem + 1),
    "trigger":   byte(flags_mem)   // 0x3e is used to trigger some entities, such as traps
    // ...
}

function entity_flags2__bitflags(flags_mem, flag) {
    flags = {
        "active":            bit0(flags_mem),
        "status (bit0)":     bit1(flags_mem),  // status: 00 = inactive, 01 = active
        "status (bit1)":     bit2(flags_mem),  //         10 = disabled, 11 = invisible
        "pulled by gravity": bit3(flags_mem),
        "took hit":          bit4(flags_mem),
        "is collidable":     bit5(flags_mem),
        "being looked at":   bit6(flags_mem),
        "dynamic light":     bit7(flags_mem),
        //"clear body":        bit8(flags_mem)
    }
    return flags[flag]
}

level_id__enum = {
    "Lara's Home":              0,
    "The Great Wall":           1,
    "Venice":                   2,
    "Bartoli's Hideout":        3,
    "Opera House":              4,
    "Offshore Rig":             5,
    "Diving Area":              6,
    "40 Fathoms":               7,
    "Wreck of the Maria Doria": 8,
    "Living Quarters":          9,
    "The Deck":                 10,
    "Tibetan Foothills":        11,
    "Barkhang Monastery":       12,
    "Catacombs of the Talion":  13,
    "Ice Palace":               14,
    "Temple of Xian":           15,
    "Floating Islands":         16,
    "Dragon's Lair":            17,
    "Home Sweet Home":          18
}

cutscene_id__enum = {
    "The Great Wall End": 0,
    "Opera House End":    1,
    "Diving Area End":    2,
    "Temple of Xian End": 3
}

script_op__enum = {
    "PICTURE":         0,
    "PSX_TRACK":       1,
    "PSX_FMV":         2,
    "FMV":             3,
    "GAME":            4,
    "CUT":             5,
    "COMPLETE":        6,
    "DEMO":            7,
    "PSX_DEMO":        8,
    "END":             9,
    "TRACK":          10,
    "SUNSET":         11,
    "LOAD_PIC":       12,
    "DEADLY_WATER":   13,
    "REMOVE_WEAPONS": 14,
    "GAMECOMPLETE":   15,
    "CUTANGLE":       16,
    "NOFLOOR":        17,
    "STARTINV":       18,
    "STARTANIM":      19,
    "SECRETS":        20,
    "KILLTOCOMPLETE": 21,
    "REMOVE_AMMO":    22
}

function secrets__bitflags(secrets_mem, secret) {
    secrets = {
        "Gold":   bit0(secrets_mem),
        "Jade":   bit1(secrets_mem),
        "Silver": bit2(secrets_mem)
    }
    return secrets[secret]
}
secrets__all_bitflags = 0x07

level_type__enum = {
    "None":     -1,
    "Title":     0,
    "Normal":    1,
    "Saved":     2,
    "Demo":      3,
    "Cutscene":  4,
    "Story":     5,
    "Quiet":     6,
    "Midstory":  7
}

music_track__enum = {
    "Venice Violins": 0x28,
    "Title Screen":   0x40
}

mood__enum = {
    "Bored":  0,
    "Attack": 1,
    "Escape": 2,
    "Stalk":  3
}

//
//   G A M E
//

// Determining in which mode the game is isn't trivial. There's no global mode value as is
// common in most games. Some things have their own global flags, whilst others require a
// bit more work, because the information about what the game's doing is only present on the
// stack, used by a script interpreter state machine.
//
// Global flags can be used to detect:
//   * Title screen;
//   * FMV. The specific FMV playing can be determined by looking at the instruction being
//     executed, as explained below. Also, the new game PMV occurs whilst the title screen
//     flag is active.
//
// For the others we use the level-specific instructions executed by the engine. When
// executing there is an instruction pointer (IP) maintained on the stack, even though its
// address depends on the context (whether the player is in a level, watching a cutscene, ...).
//
// Because they're in the stack, they aren't usable whenever. Luckily, the script instructions
// are all inside a static buffer, a fact which we can use to determine when the stack variables
// are usable/valid.
//
// In addition, there may be more than one of these IPs with valid values at the same time,
// in which case we need additional info to determine where the player is and which IP should be
// used. Luckily, while a cutscene is playing, the in-game IP doesn't have a valid pointer. As
// such:
//   * If the in-cutscene IP is valid and the in-level IP isn't:
//     * If the in-cutscene IP points to a CUT instruction, the player is in a cutscene
//     * If the in-cutscene IP points to a GAMECOMPLETE instruction, the player is watching the credits
//   * Otherwise, if the in-level IP is valid:
//     * If the IP points to a GAME instruction, the player is playing a level (includes loading)
//     * If the IP points to a COMPLETE instruction, the player is in the level-completed screen
//     * If the IP points to a GAMECOMPLETE instruction, the player is in the game-completed screen


fmv_playing__addr = 0x085a49
fmv_playing__mem = byte(fmv_playing__addr)  // boolean

function in_a_fmv() => fmv_playing__mem == 1

in_title__addr = 0x089ce8
in_title__mem = word(in_title__addr)  // bool

function in_title() => !in_a_fmv() && in_title__mem == 1

loading_level__addr = 0x08a1e8
loading_level__mem = word(loading_level__addr)

function loading_level() => loading_level__mem == 1
function just_finished_loading_level() => just_changed(loading_level__mem, 1, 0)

// loading_level__mem turns off one frame before the level becomes ready/playable (entities initialized, etc...).
// In some situations we want to observe this second event, not the first.
level_playable__addr = 0x089d40
level_playable__mem = word(level_playable__addr)

function level_was_playable() => prev(level_playable__mem) == 1
function level_just_became_playable() => just_changed(level_playable__mem, 0, 1)

script_buffer_start__addr = 0x0e0588
script_buffer_end__addr = 0x0e087c

function points_at_script_buffer(ptr) =>
    ptr >= script_buffer_start__addr && ptr <= script_buffer_end__addr

function never_points_at_script_buffer(ptr) =>
    never(ptr < script_buffer_start__addr) && never(ptr > script_buffer_end__addr)

in_level_script_ptr__addr = 0x1fff1c
in_level_script_ptr__mem = tbyte(in_level_script_ptr__addr)
cutscene_script_ptr__addr = 0x1fff14
cutscene_script_ptr__mem = tbyte(cutscene_script_ptr__addr)
fmv_script_ptr__addr = 0x1fff04
fmv_script_ptr__mem = tbyte(fmv_script_ptr__addr)

function in_a_level() =>
    !in_a_fmv()
    && !loading_level()
    && points_at_script_buffer(in_level_script_ptr__mem)
    && word(in_level_script_ptr__mem) == script_op__enum["GAME"]

function never_not_in_a_level() =>
    never(in_a_fmv())
    && never(loading_level())
    && never_points_at_script_buffer(in_level_script_ptr__mem)
    && never(word(in_level_script_ptr__mem) != script_op__enum["GAME"])

function in_a_post_level() =>
    !in_a_fmv()
    && points_at_script_buffer(in_level_script_ptr__mem)
    && word(in_level_script_ptr__mem) == script_op__enum["COMPLETE"]

function never_not_in_a_level_post_level_or_loading() =>
    never(in_a_fmv())
    && never_points_at_script_buffer(in_level_script_ptr__mem)
    && never(word(in_level_script_ptr__mem) != script_op__enum["GAME"]
             && word(in_level_script_ptr__mem) != script_op__enum["COMPLETE"])

function never_not_in_or_post_a_level() =>
    never(in_a_fmv())
    && never(loading_level())
    && never_points_at_script_buffer(in_level_script_ptr__mem)
    && never(word(in_level_script_ptr__mem) != script_op__enum["GAME"]
             && word(in_level_script_ptr__mem) != script_op__enum["COMPLETE"])

function in_or_loading_a_level() =>
    !in_a_fmv()
    && points_at_script_buffer(in_level_script_ptr__mem)
    && word(in_level_script_ptr__mem) == script_op__enum["GAME"]

function in_a_cutscene() =>
    !in_a_fmv()
    && !points_at_script_buffer(in_level_script_ptr__mem)
    && points_at_script_buffer(cutscene_script_ptr__mem)
    && word(cutscene_script_ptr__mem) == script_op__enum["CUT"]

current_cutscene_id__addr = 0x08aac4
current_cutscene_id__mem = dword(current_cutscene_id__addr)  // cutscene_id

cutscene_ptr__addr = 0x0936e0  // in cutscene if non-null
cutscene_ptr__mem = tbyte(cutscene_ptr__addr)

current_level_id__addr = 0x089cf4
current_level_id__mem = dword(current_level_id__addr)  // level_id

level_ended__addr = 0x089cfc  // signals both before and after final cutscenes
level_ended__mem = word(level_ended__addr)  // boolean

function level_just_ended() =>
    just_changed(level_ended__mem, 0, 1)

function in_level(name) =>
    in_a_level() && current_level_id__mem == level_id__enum[name]

function never_not_in_level(name) =>
    never_not_in_a_level() && never(current_level_id__mem != level_id__enum[name])

function never_not_in_or_post_or_loading_level(name) =>
    never_not_in_a_level_post_level_or_loading()
    && never(current_level_id__mem != level_id__enum[name])

function never_not_in_or_post_level(name) =>
    never_not_in_or_post_a_level()
    && never(current_level_id__mem != level_id__enum[name])

function in_post_level(name) =>
    in_a_post_level() && current_level_id__mem == level_id__enum[name]

function in_or_loading_level(name) =>
    in_or_loading_a_level() && current_level_id__mem == level_id__enum[name]

function in_cutscene(name) =>
    in_a_cutscene() && current_cutscene_id__mem == cutscene_id__enum[name]

function in_credits() =>
    !in_a_fmv()
    && !points_at_script_buffer(in_level_script_ptr__mem)
    && points_at_script_buffer(cutscene_script_ptr__mem)
    && word(cutscene_script_ptr__mem) == script_op__enum["GAMECOMPLETE"]

function in_post_game() =>
    !in_a_fmv()
    && points_at_script_buffer(in_level_script_ptr__mem)
    && word(in_level_script_ptr__mem) == script_op__enum["GAMECOMPLETE"]

level_type__addr = 0x1fff20  // important: stack var; use only when in_a_level() is true
level_type__mem = dword(level_type__addr)  // level_type

function in_saved_level() => level_type__mem == level_type__enum["Saved"]

music_track__addr = 0x087a7c
music_track__mem = dword(music_track__addr)  // music_track__enum

function a_track_was_playing() =>
    prev(music_track__mem) != 0

music_track_playing__addr = 0x08d979
music_track_playing__mem = byte(music_track_playing__addr)  // boolean

function music_track_playing(track) =>
    music_track__mem == music_track__enum[track]
    && music_track_playing__mem == 1

save_load_step__addr = 0x08a228
save_load_step__mem = word(save_load_step__addr)
save_load_step__values = {
    "None":                   0x1,
    "Load Game":              0x6,
    "Loading Game":           0xd,
    "Save Game":              0x2,
    "Save Game Confirmation": 0x3,
    "Saving Game":            0xc
}

function saving_game() =>
    save_load_step__mem == save_load_step__values["Saving Game"]

level_flipped__addr = 0x08b544
level_flipped__mem = word(level_flipped__addr)

function level_just_flipped() =>
    just_changed(level_flipped__mem, 0, 1)

paused__addr = 0x089b20
paused__mem = byte(paused__addr)
function is_paused() => paused__mem == 1

//
//   I N P U T
//

input__addr = 0x08aad4
input__bitflags = {
    "Forward": bit0(input__addr),
    "Back":    bit1(input__addr),
    "Left":    bit2(input__addr),
    "Right":   bit3(input__addr),
    "Jump":    bit4(input__addr),
    "Draw":    bit5(input__addr),
    "Action":  bit6(input__addr),
    "Walk":    bit7(input__addr),
    "Option":  bit0(input__addr + 1),
    "Look":    bit1(input__addr + 1),
    "Roll":    bit4(input__addr + 1),
    "Pause":   bit5(input__addr + 1),
    "Flare":   bit3(input__addr + 2),
    "Step":    bit0(input__addr + 4)
}

function inputting(button) => input__bitflags[button] == 1

//
//   I N - G A M E   C H E A T S
//

cheat_input_counter__addr = 0x087a20
cheat_input_counter__mem = word(cheat_input_counter__addr)
cheat_trigger_values = {
    "level skip": 0x12,
    "all guns":   0x10
}

function cheat_just_used(name) => cheat_input_counter__mem == cheat_trigger_values[name]

function ingame_cheat_just_used() =>
    cheat_just_used("level skip") || cheat_just_used("all guns")

explode_input_counter__addr = 0x087a1c
explode_input_counter__mem = word(explode_input_counter__addr)
explode_trigger_value = 0x08

function just_exploded() =>
    explode_input_counter__mem == explode_trigger_value

//
//   L A R A
//

lara_info__addr = 0x08c4e8
function lara_info_field(field) => _lara_info_field(lara_info__addr, field)

function water_status() => word(lara_info_field("water status"))

function vehicle_entity_id() => word(lara_info_field("vehicle entity id"))
function in_a_vehicle() => vehicle_entity_id() != 0xffff

function position_x() => dword(lara_info_field("position x"))
function position_y() => dword(lara_info_field("position y"))
function position_z() => dword(lara_info_field("position z"))

function position_y_sign() => bit7(lara_info_field("position y") + 3)

lara_entity_ptr__addr = 0x08c6b8
lara_entity_ptr__mem = dword(lara_entity_ptr__addr)

function in_2d_box(x_min, x_max, z_min, z_max) =>
    position_x() >= x_min && position_x() <= x_max
    && position_z() >= z_min && position_z() <= z_max

function height_ge(h) {
    if (h < 0)       return position_y() >= 0x80000000 && position_y() <= h
    else if (h == 0) return position_y() == 0 || position_y() >= 0x80000000
    else             return position_y() <= h
}

function in_water() => water_status() != water_status__enum["not in water"]

function on_water_surface() => water_status() == water_status__enum["on surface"]
function was_on_water_surface() => prev(water_status()) == water_status__enum["on surface"]

function ran_out_of_air() =>
    word(lara_info_field("air remaining")) == 0

function burning() =>
    lara_info_flags__bitflags(lara_info_field("flags"), "burning") == 1

function angle() =>
    word(lara_info_field("angle"))

function weapons_drawn() =>
    word(lara_info_field("gun status")) == gun_status__enum["gun drawn"]

function weapon_is(weapon) =>
    word(lara_info_field("gun type")) == gun_type__enum[weapon]

//
//   C A M E R A
//

camera__addr = 0x08b258
function camera_field(field) => _camera_field(camera__addr, field)

function camera_is_fixed() => dword(camera_field("fixed?")) == 1
function camera_was_fixed() => prev(dword(camera_field("fixed?"))) == 1
function camera_became_fixed() => !camera_was_fixed() && camera_is_fixed()

//
//   I N V E N T O R Y
//

main_inv_item_array__addr = 0x088ad8  // INVENTORY_ITEM*[23]
main_inv_n_items__addr = 0x088aa0
main_inv_n_items__mem = word(main_inv_n_items__addr)
main_inv_max_items = 23

function main_inv_at(slot_n) => tbyte(main_inv_item_array__addr + (4 * slot_n))

function main_inv_just_got(model_name) {
    // on the previous frame none of the inventory items were the one we're looking for
    prev_cond = always_true()
    for i in range(0, main_inv_max_items-1)
        prev_cond = prev_cond && (
            main_inv_n_items__mem <= i
            || word(inventory_item_field(prev(main_inv_at(i)), "model id")) != model_id__enum[model_name]
        )

    // on the current frame at least one of them is
    cur_cond = always_false()
    for i in range(0, main_inv_max_items-1)
        cur_cond = cur_cond || (
            main_inv_n_items__mem > i
            && word(inventory_item_field(main_inv_at(i), "model id")) == model_id__enum[model_name]
        )

    return prev_cond && cur_cond
}

cur_statistics__addr = 0x0de670  // statistics
function cur_statistics_field(field) => statistics_field(cur_statistics__addr, field)

function cur_statistics_timer() => dword(cur_statistics_field("timer"))
function cur_statistics_secrets() => byte(cur_statistics_field("secrets"))
function cur_statistics_meds_used() => byte(cur_statistics_field("medipacks used"))
function cur_statistics_kills() => word(cur_statistics_field("kills"))

function has_all_secrets() =>
    cur_statistics_secrets() == secrets__all_bitflags

function just_collected_all_secrets() =>
    prev(cur_statistics_secrets()) > 0
    && prev(cur_statistics_secrets()) < secrets__all_bitflags
    && cur_statistics_secrets() == secrets__all_bitflags

function just_collected_secret(secret) =>
    just_changed(secrets__bitflags(cur_statistics_field("secrets"), secret), 0, 1)

function used_no_meds() =>
    cur_statistics_meds_used() == 0

function just_used_a_medipack() =>
    prev(cur_statistics_meds_used()) < cur_statistics_meds_used()

//
//   S O U N D   E F F E C T S
//

// These ids correspond to the intermediate level of sound mapping.
sfx_samples = {
    "Lara's Home": {
        "Winston Fart": 90
    }
}

sfx_array__addr = 0x089fd8
sfx_array__size = 32

function sfx_at(i) => sfx_array__addr + (i * sfx_info__sizeof)

function sfx_sample_index(sfx) => dword(sfx_info_field(sfx, "sample index"))

function sfx_playing(level, name) {
    cond = always_false()
    for i in range(0, sfx_array__size-1)
        cond = cond || sfx_sample_index(sfx_at(i)) == sfx_samples[level][name]
    return cond
}

//
//   E N T I T I E S
//

// there's a pointer to the current entity array, but the arrays are at static locations

function entity_array_def(addr, n) => {"addr": addr, "n": n}

entity_array_ptr__addr = 0x08aaac
entity_arrays__addr = {
    "Lara's Home":              entity_array_def(0x0017c61c,  40),
    "The Great Wall":           entity_array_def(0x0019c940, 106),
    "Venice":                   entity_array_def(0x001c19c4, 133),
    "Bartoli's Hideout":        entity_array_def(0x001cefd0, 134),
    "Opera House":              entity_array_def(0x001cc4d0, 216),
    "Offshore Rig":             entity_array_def(0x001be674, 112),
    "Diving Area":              entity_array_def(0x001bc950, 131),
    "40 Fathoms":               entity_array_def(0x001bb460,  69),
    "Wreck of the Maria Doria": entity_array_def(0x001cc39c, 199),
    "Living Quarters":          entity_array_def(0x001b6694,  92),
    "The Deck":                 entity_array_def(0x001dc540, 105),
    "Tibetan Foothills":        entity_array_def(0x001da714, 108),
    "Barkhang Monastery":       entity_array_def(0x001dfa6c, 217),
    "Catacombs of the Talion":  entity_array_def(0x001c5830, 170),
    "Ice Palace":               entity_array_def(0x001c72fc, 158),
    "Temple of Xian":           entity_array_def(0x001d6d5c, 240),
    "Floating Islands":         entity_array_def(0x001d1b28, 141),
    "Dragon's Lair":            entity_array_def(0x001a1dc4,  66),
    "Home Sweet Home":          entity_array_def(0x001b1fe8, 108),
}

function entity_def(index, model) => {"index": index, "model": model}

entities = {
    "Lara's Home": {
        "Lara":                entity_def( 8, "Lara"),
        "Winston":             entity_def( 9, "Winston"),
        "Freezer Door":        entity_def(38, "Door 4")
    },
    "The Great Wall": {
        "Lara":                entity_def( 20, "Lara"),
        "T-Rex 1":             entity_def(104, "T-Rex"),
        "T-Rex 2":             entity_def( 99, "T-Rex"),
        "Spike Wall 1":        entity_def( 78, "Spike Wall"),
        "Spike Wall 2":        entity_def( 79, "Spike Wall"),
        "Spike Wall 3":        entity_def( 80, "Spike Wall"),
        "Spike Wall 4":        entity_def( 81, "Spike Wall"),
    },
    "Venice": {
        "Lara":                entity_def(  0, "Lara"),
        "Gondola 1":           entity_def( 67, "Gondola"),
        "Gondola 2":           entity_def( 68, "Gondola"),
        "Gondola 3":           entity_def( 70, "Gondola"),
        "Gondola 4":           entity_def( 71, "Gondola"),
        "Gondola 5":           entity_def( 72, "Gondola"),
        "Mine 1":              entity_def(106, "Mine"),
        "Left Final Door":     entity_def( 73, "Door 5"),
        "Right Final Door":    entity_def( 74, "Door 6"),
        "Boat 1":              entity_def( 26, "Boat"),
        "Boat 2":              entity_def( 91, "Boat")
    },
    "Bartoli's Hideout": {
        "Lara":                entity_def( 97, "Lara"),
        "Boat":                entity_def( 96, "Boat"),
        "Detonator":           entity_def( 75, "Detonator")
    },
    "Opera House": {
        "Lara":                entity_def(155, "Lara"),
        "Lighting Booth Goon": entity_def(  7, "Stick Goon 1"),
        "Left Final Door":     entity_def(133, "Door 8"),
        "Right Final Door":    entity_def(134, "Door 8"),
        "Boss":                entity_def(142, "Shotgun Goon"),
        "Boss Goon 1":         entity_def(136, "Masked Goon 3"),
        "Boss Goon 2":         entity_def(135, "Masked Goon 2"),
        "Boss Dog 1":          entity_def(137, "Dog"),
        "Boss Dog 2":          entity_def(138, "Dog")
    },
    "Offshore Rig": {
        "Lara":                entity_def( 20, "Lara"),
        "Pistols":             entity_def(  4, "Pistols"),
        "Scuba Diver 1":       entity_def(106, "Scuba Diver"),
        "Scuba Diver 2":       entity_def(107, "Scuba Diver")
    },
    "Diving Area": {
        "Lara":                entity_def( 68, "Lara"),
        "Underwater Fan":      entity_def( 91, "Underwater Fan"),
        "Underwater Lever 1":  entity_def(128, "Underwater Lever"),
        "Underwater Lever 2":  entity_def(129, "Underwater Lever")
    },
    "40 Fathoms": {
        "Lara":                entity_def(  0, "Lara"),
        "Trapdoor 1":          entity_def( 10, "Trapdoor 1"),
        "Burner 1":            entity_def( 22, "Flame Emitter"),
        "Burner 2":            entity_def( 23, "Flame Emitter"),
        "Burner 3":            entity_def( 24, "Flame Emitter"),
        "Burner 4":            entity_def( 25, "Flame Emitter"),
        "Burner Door":         entity_def( 27, "Door 3"),
        "Underwater Door 1":   entity_def( 31, "Door 2")
    },
    "Wreck of the Maria Doria": {
        "Lara":                entity_def(198, "Lara")
    },
    "Living Quarters": {
        "Lara":                entity_def(  8, "Lara")
    },
    "The Deck": {
        "Lara":                entity_def( 26, "Lara"),
        "Raft Key":            entity_def(  8, "Key 4")
    },
    "Tibetan Foothills": {
        "Lara":                entity_def( 53, "Lara"),
        "Bottom Boulders 1":   entity_def( 56, "Boulders"),
        "Top Boulders 1":      entity_def( 62, "Boulders")
    },
    "Barkhang Monastery": {
        "Lara":                entity_def(186, "Lara")
    },
    "Catacombs of the Talion": {
        "Lara":                entity_def(  0, "Lara"),
        "Jail Door 1":         entity_def( 32, "Door 8"),
        "Jail Yeti 1":         entity_def( 42, "Yeti"),
        "Jail Yeti 2":         entity_def( 43, "Yeti"),
        "Jail Yeti 3":         entity_def( 26, "Yeti"),
        "Jail Yeti 4":         entity_def( 27, "Yeti")
    },
    "Ice Palace": {
        "Lara":                entity_def( 58, "Lara"),
        "Guardian":            entity_def(148, "Guardian"),
        "Guardian's Uzi Ammo": entity_def(149, "Uzi Ammo"),
        "Guardian's Medipack": entity_def(151, "Large Medipack")
    },
    "Temple of Xian": {
        "Lara":                entity_def(238, "Lara"),
        "Trapfloor 1":         entity_def( 72, "Trapdoor 2"),
        "Trapfloor 2":         entity_def( 73, "Trapdoor 2"),
        "Trapfloor 3":         entity_def( 74, "Trapdoor 2"),
        "Trapfloor 4":         entity_def( 75, "Trapdoor 2"),
        "Cave Spider 1":       entity_def(211, "Spider")
    },
    "Floating Islands": {
        "Lara":                entity_def( 10, "Lara"),
    },
    "Dragon's Lair": {
        "Lara":                entity_def( 42, "Lara"),
        "Dragon Front":        entity_def( 67, "Dragon Front"),
        "Dragon Back":         entity_def( 66, "Dragon Back")
    },
    "Home Sweet Home": {
        "Lara":                entity_def( 43, "Lara"),
        "Boss":                entity_def(  4, "Shotgun Goon"),
        "Freezer Door":        entity_def(105, "Door 4")
    }
}

entity_groups = {
    "Barkhang Monastery": {
        "Monks":        [50, 106, 191, 175, 19, 135, 167, 136, 128, 94, 189, 61, 55, 139, 60, 190, 43, 198, 45, 180, 16, 51],
        "Mercenaries":  [25, 35, 38, 39, 46, 47, 56, 59, 75, 78, 85, 86, 90, 117, 118, 153, 154, 155, 156, 164, 165, 173, 174, 177, 178, 179],
        "Crows":        [34, 44, 54, 166, 193, 194]
    },
    "Temple of Xian": {
        "Cave Spiders": [210, 211, 219, 221, 222, 223, 218,  // normal
                         209, 214, 215, 216, 220          ]  // giant
    },
    "Floating Islands": {
        "Guards":       [33, 34, 35, 70, 71, 85, 86, 87, 108, 111, 116, 120,  // spear
                         2, 17, 18, 43, 52, 88, 90, 91 ]                      // sword
    }
}

function entity_index(level, name) => entities[level][name]["index"]
function entity_model(level, name) => entities[level][name]["model"]

function entity_at_index(level, idx) =>
    entity_arrays__addr[level]["addr"] + (idx * entity__sizeof)

function entity_addr(level, name) =>
    entity_at_index(level, entity_index(level, name))

function _entity_floor_height      (addr) => dword(entity_field(addr, "floor height"))
function _entity_touch_flags       (addr) => dword(entity_field(addr, "touch flags"))
function _entity_model_id          (addr) =>  word(entity_field(addr, "model id"))
function _entity_room_number       (addr) =>  word(entity_field(addr, "room number"))
function _entity_action_id         (addr) =>  word(entity_field(addr, "current action id"))
function _entity_animation_id      (addr) =>  word(entity_field(addr, "animation id"))
function _entity_hit_points        (addr) =>  word(entity_field(addr, "hit points"))
function _entity_timer             (addr) =>  word(entity_field(addr, "timer"))
function _entity_speed             (addr) =>  word(entity_field(addr, "horizontal speed"))
function _entity_position_x        (addr) => dword(entity_field(addr, "position x"))
function _entity_position_y        (addr) => dword(entity_field(addr, "position y"))
function _entity_position_z        (addr) => dword(entity_field(addr, "position z"))
function _entity_data              (addr) => dword(entity_field(addr, "data"))
function _entity_flags_trigger     (addr) => entity_flags__bitflags(entity_field(addr, "flags"), "trigger")
function _entity_flags2_active     (addr) => entity_flags2__bitflags(entity_field(addr, "flags2"), "active")
function _entity_flags2_status_bit0(addr) => entity_flags2__bitflags(entity_field(addr, "flags2"), "status (bit0)")
function _entity_flags2_status_bit1(addr) => entity_flags2__bitflags(entity_field(addr, "flags2"), "status (bit1)")
function _entity_flags2_collidable (addr) => entity_flags2__bitflags(entity_field(addr, "flags2"), "is collidable")
function _entity_flags2_took_hit   (addr) => entity_flags2__bitflags(entity_field(addr, "flags2"), "took hit")

function entity_at_touch_flags      (level, idx) => _entity_touch_flags      (entity_at_index(level, idx))
function entity_at_model_id         (level, idx) => _entity_model_id         (entity_at_index(level, idx))
function entity_at_room_number      (level, idx) => _entity_room_number      (entity_at_index(level, idx))
function entity_at_hit_points       (level, idx) => _entity_hit_points       (entity_at_index(level, idx))
function entity_at_position_y       (level, idx) => _entity_position_y       (entity_at_index(level, idx))
function entity_at_position_z       (level, idx) => _entity_position_z       (entity_at_index(level, idx))
function entity_at_flags2_active    (level, idx) => _entity_flags2_active    (entity_at_index(level, idx))
function entity_at_flags2_collidable(level, idx) => _entity_flags2_collidable(entity_at_index(level, idx))

function entity_floor_height      (level, entity) => _entity_floor_height      (entity_addr(level, entity))
function entity_model_id          (level, entity) => _entity_model_id          (entity_addr(level, entity))
function entity_room_number       (level, entity) => _entity_room_number       (entity_addr(level, entity))
function entity_action_id         (level, entity) => _entity_action_id         (entity_addr(level, entity))
function entity_animation_id      (level, entity) => _entity_animation_id      (entity_addr(level, entity))
function entity_hit_points        (level, entity) => _entity_hit_points        (entity_addr(level, entity))
function entity_timer             (level, entity) => _entity_timer             (entity_addr(level, entity))
function entity_speed             (level, entity) => _entity_speed             (entity_addr(level, entity))
function entity_position_x        (level, entity) => _entity_position_x        (entity_addr(level, entity))
function entity_position_z        (level, entity) => _entity_position_z        (entity_addr(level, entity))
function entity_data              (level, entity) => _entity_data              (entity_addr(level, entity))
function entity_flags_trigger     (level, entity) => _entity_flags_trigger     (entity_addr(level, entity))
function entity_flags2_active     (level, entity) => _entity_flags2_active     (entity_addr(level, entity))
function entity_flags2_status_bit0(level, entity) => _entity_flags2_status_bit0(entity_addr(level, entity))
function entity_flags2_status_bit1(level, entity) => _entity_flags2_status_bit1(entity_addr(level, entity))
function entity_flags2_took_hit   (level, entity) => _entity_flags2_took_hit   (entity_addr(level, entity))

function entity_ptr_action_id   (ptr) => _entity_action_id   (ptr)
function entity_ptr_animation_id(ptr) => _entity_animation_id(ptr)

function entity_room_is(level, entity, room_no) =>
    entity_room_number(level, entity) == room_no

function entity_room_was(level, entity, room_no) =>
    prev(entity_room_number(level, entity)) == room_no

function entity_prior_room_was(level, entity, room_no) =>
    prior(entity_room_number(level, entity)) == room_no

function entity_room_changed_to(level, entity, room_no) =>
    !entity_room_was(level, entity, room_no) && entity_room_is(level, entity, room_no)

function entity_room_changed_from_to(level, entity, from_room_no, to_room_no) =>
    entity_room_was(level, entity, from_room_no) && entity_room_is(level, entity, to_room_no)

function entity_animation_is(level, entity, animation) =>
    entity_animation_id(level, entity) == animation_id__enum[entity_model(level, entity)][animation]

function entity_ptr_animation_is(ptr, model, animation) =>
    entity_ptr_animation_id(ptr) == animation_id__enum[model][animation]

function entity_animation_was(level, entity, animation) =>
    prev(entity_animation_id(level, entity)) == animation_id__enum[entity_model(level, entity)][animation]

function entity_ptr_animation_was(ptr, model, animation) =>
    prev(entity_ptr_animation_id(ptr)) == animation_id__enum[model][animation]

function entity_animation_changed_to(level, entity, to_animation) =>
    !entity_animation_was(level, entity, to_animation) && entity_animation_is(level, entity, to_animation)

function entity_ptr_animation_changed_to(ptr, model, to_animation) =>
    !entity_ptr_animation_was(ptr, model, to_animation) && entity_ptr_animation_is(ptr, model, to_animation)

function entity_animation_changed_from_to(level, entity, from_animation, to_animation) =>
    entity_animation_was(level, entity, from_animation) && entity_animation_is(level, entity, to_animation)

function entity_action_is(level, entity, action) =>
    entity_action_id(level, entity) == action_id__enum[entity_model(level, entity)][action]

function entity_ptr_action_is(ptr, model, action) =>
    entity_ptr_action_id(ptr) == action_id__enum[model][action]

function entity_action_was(level, entity, action) =>
    prev(entity_action_id(level, entity)) == action_id__enum[entity_model(level, entity)][action]

function entity_ptr_action_was(ptr, model, action) =>
    prev(entity_ptr_action_id(ptr)) == action_id__enum[model][action]

function entity_ptr_action_prior_was(ptr, model, action) =>
    prior(entity_ptr_action_id(ptr)) == action_id__enum[model][action]

function entity_action_changed_to(level, entity, to_action) =>
    !entity_action_was(level, entity, to_action) && entity_action_is(level, entity, to_action)

function entity_ptr_action_changed_to(ptr, model, to_action) =>
    !entity_ptr_action_was(ptr, model, to_action) && entity_ptr_action_is(ptr, model, to_action)

function entity_action_changed_from_to(level, entity, from_action, to_action) =>
    entity_action_was(level, entity, from_action) && entity_action_is(level, entity, to_action)

function entity_ptr_action_changed_from_to(ptr, model, from_action, to_action) =>
    entity_ptr_action_was(ptr, model, from_action) && entity_ptr_action_is(ptr, model, to_action)

function entity_is_active(level, entity) => entity_flags2_active(level, entity) == 1
function entity_was_active(level, entity) => prev(entity_flags2_active(level, entity)) == 1

function entity_activated(level, entity) =>
    !entity_was_active(level, entity) && entity_is_active(level, entity)

function entity_deactivated(level, entity) =>
    entity_was_active(level, entity) && !entity_is_active(level, entity)

function _entity_status_is(addr, status) {
    status_checks = {
        "Inactive":  (_entity_flags2_status_bit1(addr) == 0 && _entity_flags2_status_bit0(addr) == 0),
        "Active":    (_entity_flags2_status_bit1(addr) == 0 && _entity_flags2_status_bit0(addr) == 1),
        "Disabled":  (_entity_flags2_status_bit1(addr) == 1 && _entity_flags2_status_bit0(addr) == 0),
        "Invisible": (_entity_flags2_status_bit1(addr) == 1 && _entity_flags2_status_bit0(addr) == 1)
    }
    return status_checks[status]
}
function entity_status_is(level, entity, status) => _entity_status_is(entity_addr(level, entity), status)
function entity_at_status_is(level, idx, status) => _entity_status_is(entity_at_index(level, idx), status)

function entity_status_was(level, entity, status) {
    status_checks = {
        "Inactive":  (prev(entity_flags2_status_bit1(level, entity)) == 0 && prev(entity_flags2_status_bit0(level, entity)) == 0),
        "Active":    (prev(entity_flags2_status_bit1(level, entity)) == 0 && prev(entity_flags2_status_bit0(level, entity)) == 1),
        "Disabled":  (prev(entity_flags2_status_bit1(level, entity)) == 1 && prev(entity_flags2_status_bit0(level, entity)) == 0),
        "Invisible": (prev(entity_flags2_status_bit1(level, entity)) == 1 && prev(entity_flags2_status_bit0(level, entity)) == 1)
    }
    return status_checks[status]
}

function entity_status_changed_from_to(level, entity, from_status, to_status) =>
    entity_status_was(level, entity, from_status) && entity_status_is(level, entity, to_status)

function entity_at_touching_lara(level, entity) =>
    entity_at_touch_flags(level, entity) != 0

// there are dynamic entities, such as flares, which are placed in a free slot after the static
// entities of the level
function dynamic_entities(level) =>
    range(entity_arrays__addr[level]["n"], 255)

//
//   l a r a - s p e c i f i c
//

function doing_basic_movement(level) =>
    entity_action_id(level, "Lara") <= 2  // little hack: avoids ||s because Walk, Run & Stopped are 0-2

function ptr_doing_basic_movement() =>
    entity_ptr_action_id(lara_entity_ptr__mem) <= 2

function took_damage(level) =>
    prev(entity_hit_points(level, "Lara")) > entity_hit_points(level, "Lara")
    || prev(entity_hit_points(level, "Lara")) > 0 && entity_hit_points(level, "Lara") == 0xffff

function took_damage_ge(level, n) =>
    (prev(entity_hit_points(level, "Lara")) > entity_hit_points(level, "Lara")
     && (prev(entity_hit_points(level, "Lara")) - entity_hit_points(level, "Lara")) >= n)
    || (prev(entity_hit_points(level, "Lara")) > 0 && entity_hit_points(level, "Lara") == 0xffff)

function in_vehicle(level, vehicle) =>
    vehicle_entity_id() == entity_index(level, vehicle)

function alive(level) =>
    entity_hit_points(level, "Lara") != 0xffff

//
//   e n t i t y - s p e c i f i c
//

boat_max_speed = 0x8d

function enemy_entity_is_dead(level, entity) =>
    entity_hit_points(level, entity) == 0xc000

function enemy_entiy_at_just_died(level, idx) =>
    just_changed_to(entity_at_hit_points(level, idx), 0xc000)

function burner_is_on(level, entity) =>
    entity_data(level, entity) != 0  // data contains the fx id of the flame

function boulders_started_moving(level, entity) =>
    prev(entity_speed(level, entity)) == 0 && entity_speed(level, entity) > 0

function boulders_stopped_moving(level, entity) =>
    prev(entity_speed(level, entity)) > 0 && entity_speed(level, entity) == 0

function enemy_entity_group_n_dead(level, group) {
    n = 0
    for idx in entity_groups[level][group]
        n = n + bit7(entity_field(entity_at_index(level, idx), "hit points") + 1)
    return n
}

function creature_mood(level, entity) =>
    word(creature_field(entity_data(level, entity), "mood"))

function creature_mood_is(level, entity, mood) =>
    creature_mood(level, entity) == mood__enum[mood]

function creature_just_activated(level, entity) =>
    just_changed_from(entity_data(level, entity), 0)

function spike_wall_just_triggered(level, entity) =>
    entity_flags_trigger(level, entity) == 0x3e

//
//   A S S A U L T   C O U R S E
//

assault_course_timer__mem = cur_statistics_timer()

assault_course_timer_visible__addr = 0x087bec
assault_course_timer_visible__mem = word(assault_course_timer_visible__addr)

assault_course_timer_active__addr = 0x087bf0
assault_course_timer_active__mem = word(assault_course_timer_active__addr)

function assault_course_timer_lt(min, sec, tens_sec) =>
    assault_course_timer__mem < ((min * 600) + (sec * 10) + tens_sec) * 3

function assault_course_just_started() =>
    assault_course_timer_active__mem == 1
    && just_changed(assault_course_timer__mem, 1, 2)

function assault_course_just_ended() =>
    just_changed(assault_course_timer_active__mem, 1, 0)

function assault_course_just_completed() =>
    assault_course_just_ended()                  // the assault course may end by failure so restrict further:
    && entity_room_is("Lara's Home", "Lara", 2)  // - lara must be in room 2
    && in_2d_box(38910, 41970, 55300, 58365)     // - more specifically, in the sandbox past the last arch

function assault_course_just_failed() =>
    assault_course_just_ended()
    && (!entity_room_is("Lara's Home", "Lara", 2)
        || !in_2d_box(38910, 41970, 55300, 58365))

//
//   M I S C
//

monks_hostile__addr = 0x087bf8
monks_hostile__mem = word(monks_hostile__addr)
function monks_hostile() => monks_hostile__mem == 1

infinite_ammo__addr = 0x0de690
infinite_ammo__mem = word(infinite_ammo__addr)
function no_infinite_ammo() => infinite_ammo__mem == 0

// =============================== //
//                                 //
//      P A U S E   L O C K S      //
//                                 //
// =============================== //

function cheat_pause_lock() =>
    unless(once(cheat_just_used("level skip")))
    && unless(once(cheat_just_used("all guns")))
    && (always_true() || never(in_title()))

//achievement("cheat pause lock", "...", 5, cheat_pause_lock())

upwards_teleport_threshold = 500

// logic is always unsigned, so we need to handle signness explicitly
function upwards_teleport_neg_neg() =>
    is_negative(prev(position_y_sign())) && is_negative(position_y_sign())
    && prev(position_y()) > position_y()
    && prev(position_y()) - position_y() >= upwards_teleport_threshold

function upwards_teleport_pos_pos() =>
    !is_negative(prev(position_y_sign())) && !is_negative(position_y_sign())
    && prev(position_y()) > position_y()
    && prev(position_y()) - position_y() >= upwards_teleport_threshold

function upwards_teleport_pos_neg() =>
    !is_negative(prev(position_y_sign())) && is_negative(position_y_sign())
    && prev(position_y()) + (0xffffffff - position_y()) >= upwards_teleport_threshold

function corner_bug_pause_lock() {
    // blacklist approach:
    //   - avoid triggering on actions that are known to suddently increase lara's height
    //   - catches every upwards teleport bug, but has potential to trigger when it shouldn't
    //   - actions: "Pull Up", "Climbing", "Handstand"

    // whitelist approach:
    //   - trigger only on actions that are used for the most common corner bugs
    //   - doesnt catch everything, but has much less of a chance to mistakenly trigger
    //   - still catches the vast majority of upward teleports
    //   - actions: "Upwards Jump", "Run", "Swim"

    cond = always_true()
    for action in ["Upwards Jump", "Run", "Swim"] {
        common_cond = level_was_playable()
                      && !in_a_vehicle()
                      && prev(lara_entity_ptr__mem) == lara_entity_ptr__mem
                      && entity_ptr_action_was(lara_entity_ptr__mem, "Lara", action)
                      && entity_ptr_action_is(lara_entity_ptr__mem, "Lara", action)

        // Exception: hanging from the opening of a trapdoor, letting it close, and then letting go.
        // Action goes from hanging to upwards jump for 2 frames, during which lara teleports upwards,
        // triggering the protection.
        if (action == "Upwards Jump")
            common_cond = common_cond && !entity_ptr_action_prior_was(lara_entity_ptr__mem, "Lara", "Hang")

        cond = cond
            && unless(once(common_cond && upwards_teleport_neg_neg()))
            && unless(once(common_cond && upwards_teleport_pos_pos()))
            && unless(once(common_cond && upwards_teleport_pos_neg()))
    }
    
    return cond
}

function just_used_corner_bug() {
    cond = always_false()
    for action in ["Upwards Jump", "Run", "Swim"] {
        action_cond = (
            entity_ptr_action_was(lara_entity_ptr__mem, "Lara", action)
            && entity_ptr_action_is(lara_entity_ptr__mem, "Lara", action)
            && (upwards_teleport_neg_neg() || upwards_teleport_pos_pos() || upwards_teleport_pos_neg())
        )

        if (action == "Upwards Jump")
            action_cond = action_cond && !entity_ptr_action_prior_was(lara_entity_ptr__mem, "Lara", "Hang")

        cond = cond || action_cond
    }

    return level_was_playable()
           && !in_a_vehicle()
           && cond
}

//achievement("corner bug pause lock", "...", 5, inputting("Flare") && corner_bug_pause_lock())

// RATools doesn't have a way to support pause locks yet. We can trick it into generating one
// for simple achievements, but for achievements that already have complex logic the workarounds
// quickly become unmanageable.
//
// To get around this limitation, pause locks are added to RATools-generated achievements
// by a custom tool. The tool replaces known placeholder logic with the logic for the corresponding
// pause lock. As such, in this script, pause locks are placed on achievements using the
// placeholders, such as cheat_pause_lock_placeholder.

function ingame_cheats_pause_lock_placeholder()  => word(0x1) == 1
function corner_bug_pause_lock_placeholder()     => word(0x3) == 3

//
// same problem exists for any alt that contains resets and pauses

function never_loading_unsaved() =>
    never(loading_level())
    && unless(once(saving_game()))  // pause the reset's alt group if the player saves

function never_loading_unsaved_placeholder() => word(0x1111) == 0

//achievement("alt group", "...", 5, never_loading_unsaved())


// ================================ //
//                                  //
//      A C H I E V E M E N T S     //
//                                  //
// ================================ //

function cheat_protection() =>
    ingame_cheats_pause_lock_placeholder()  // ban all guns + level skip
    && corner_bug_pause_lock_placeholder()  // ban corner bugs
    && no_infinite_ammo()                   // bug inite ammo / NG+

function corner_bug_protection() =>
    corner_bug_pause_lock_placeholder()

//
//   P R O G R E S S I O N
//

function beat_level_achievement(level_name, id, badge_id, points) {
    n = level_id__enum[level_name]
    if (n == 1) ordinal = "st" else if (n == 2) ordinal = "nd" else if (n == 3) ordinal = "rd" else ordinal = "th"
    achievement(
        id=id,
        badge=format("{0}", badge_id),
        title=level_name,
        description=format("Complete the {0}{1} level, {2}", n, ordinal, level_name),
        points=points,
        trigger=cheat_protection() && in_post_level(level_name)
    )
}

//
//   A L L   S E C R E T S
//

function all_secrets_achievement(level_name, id, badge_id) {
    achievement(
        id=id,
        badge=format("{0}", badge_id),
        title=format("Secrets of {0}", level_name),
        description=format("Collect the three secrets of {0}", level_name),
        points=3,
        trigger=cheat_protection()
                // Same trick as the weapon-related achievements: require the player to be in
                // the level for at least a second to avoid mistriggers during loads.
                && never_not_in_level(level_name)
                && repeated(30, always_true())
                && entity_action_is(level_name, "Lara", "Pickup")
                && just_collected_all_secrets()
    )
}

//
//   N O   L O A D S ,   N O   M E D S ,   A L L   S E C R E T S
//

function nlnmas_achievement(level_name, id, badge_id, points) {
    achievement(
        id=id,
        badge=format("{0}", badge_id),
        title=format("NLNMAS in {0}", level_name),
        description=format("Complete '{0}' without loading or using medipacks, and having found all secrets", level_name),
        points=points,
        trigger=(
            cheat_protection()

            && once(level_just_became_playable()  // no loads: remember the start of the level
                    && !in_saved_level())         // ... if it was started from the beginning, not loaded from a save
            && never(loading_level())             // .. and reset if there's another load

            && in_post_level(level_name)  // finished the level
            && used_no_meds()             // ... having used no medipacks
            && has_all_secrets()          // ... and having collected all secrets
        )
    )
}

//
//   L A R A ' S   H O M E
//

achievement(
    id=132506,
    badge="145987",
    title="Assault Course Ace",
    description="[Lara's Home] Finish the assault course in 1 minute 25 seconds or less",
    points=5,
    trigger=corner_bug_protection()
            && in_level("Lara's Home")
            && assault_course_just_completed()
            && assault_course_timer_lt(1, 25, 1)
)

achievement(
    id=132507,
    badge="145988",
    title="No Winston, I Don't Fancy Some Tea",
    description="[Lara's Home] Lock the butler in the freezer where he can't bother you",
    points=2,
    trigger=in_level("Lara's Home")
            && entity_room_is("Lara's Home", "Winston", 94)
            && entity_animation_is("Lara's Home", "Freezer Door", "Closed")
)

achievement(
    id=132508,
    badge="145989",
    title="The Family Riches",
    description="[Lara's Home] Visit the treasure room of Croft Manor",
    points=2,
    trigger=corner_bug_protection()
            && in_level("Lara's Home")
            && entity_room_is("Lara's Home", "Lara", 53)
)

achievement(
    id=132509,
    badge="145990",
    title="The Fanciest of Swans",
    description="[Lara's Home] Do an handstand on the diving board and then swan dive into the pool, all to the sound of some classical music",
    points=2,
    trigger=never_not_in_level("Lara's Home")

            // store a hit when lara handstands on the board
            && once(in_2d_box(26950, 29575, 91065, 92725)
                    && entity_action_is("Lara's Home", "Lara", "Handstand"))

            // reset the hit if lara walks or runs outside of the board
            && never(doing_basic_movement("Lara's Home")
                     && entity_room_is("Lara's Home", "Lara", 13))

            // trigger when lara swan dives into the pool...
            && entity_room_is("Lara's Home", "Lara", 14)
            && entity_action_changed_from_to("Lara's Home", "Lara", "Swan Dive Fall", "Dive")
            
            // ... as long as Venice Violins is playing
            && music_track_playing("Venice Violins")
)

achievement(
    id=132510,
    badge="145991",
    title="Locked From the Outside",
    description="[Lara's Home] Exit the mansion through the back door",
    points=2,
    trigger=corner_bug_protection()
            && in_level("Lara's Home")
            && entity_room_changed_from_to("Lara's Home", "Lara", 59, 19)
)

//
//   T H E   G R E A T   W A L L
//

beat_level_achievement("The Great Wall", 132511, 145923, 5)

all_secrets_achievement("The Great Wall", 132512, 145951)

nlnmas_achievement("The Great Wall", 132513, 145967, 10)

achievement(
    id=132514,
    badge="145992",
    title="A Swan in China",
    description="[The Great Wall] Swan dive into the pool on the side of the wall from the roof of one of the towers (no glitches)",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("The Great Wall")
            && once(entity_action_changed_to("The Great Wall", "Lara", "Swan Dive Start")
                    && height_ge(-6144))
            && never(doing_basic_movement("The Great Wall"))
            && entity_room_is("The Great Wall", "Lara", 9)
            && entity_action_changed_from_to("The Great Wall", "Lara", "Swan Dive Fall", "Dive")
)

achievement(
    id=132515,
    badge="145993",
    title="Dart Across the Pond",
    description="[The Great Wall] Make it through the dart traps without hanging from the crevice or taking damage",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("The Great Wall")
            && once(entity_room_changed_from_to("The Great Wall", "Lara", 44, 45))  // store an hit when entering the water
            && never(entity_action_is("The Great Wall", "Lara", "Hang"))            // reset if lara hangs from the crevice...
            && never(took_damage("The Great Wall"))                                 // ... or takes damage
            && entity_room_changed_to("The Great Wall", "Lara", 47)                 // trigger upon reaching the tunnel past the water
)

function standing_in_front_of_triggered_spike_wall() {
    cond = always_false()
    for _ in [["Spike Wall 1", 44030, 46080],
              ["Spike Wall 2", 46080, 48125],
              ["Spike Wall 3", 49150, 51195],
              ["Spike Wall 4", 51195, 53240]] {
        wall = _[0]
        x_start = _[1]
        x_end = _[2]

        cond = cond || (
            // trigger if lara was in front of the wall when it stopped and remains there for 2 seconds zafterwards
            once(just_changed_to(entity_position_z("The Great Wall", wall), 0xf000)  // resting position of the walls post-trigger
                 && position_x() >= x_start && position_x() <= x_end)
            && repeated(2*30, entity_position_z("The Great Wall", wall) == 0xf000
                              && position_x() >= x_start && position_x() <= x_end)

            // pause lock the group if lara stops being in front of the wall after it has stopped
            && unless(once(entity_position_z("The Great Wall", wall) == 0xf000
                      && (position_x() < x_start || position_x() > x_end)))
        )
    }
    return cond
}

achievement(
    id=132516,
    badge="145994",
    title="You Talkin' to Me?",
    description="[The Great Wall] Stand in front of a spike wall and call out its bluff",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("The Great Wall")
            && standing_in_front_of_triggered_spike_wall()
)

achievement(
    id=132517,
    badge="145995",
    title="Apex Predator",
    description="[The Great Wall] Defeat both T-Rexes without using medipacks or hiding out where they can't easily reach you",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("The Great Wall")

            // store an hit when the first t-rex activates
            && once(entity_activated("The Great Wall", "T-Rex 1"))
            
            // reset if a medipack is used
            && never(just_used_a_medipack())
            
            // reset if the player stands for more than 5 seconds in either the secret area's
            // or the entrace's tunnels, but only if one of the t-rexes is active and doesn't
            // have max hp (alowing the player to collect the secret that triggers the second
            // t-rex)
            && never(repeated(5*30, in_2d_box(79905, 87040, 72725, 75775)  // secret area
                                    && entity_is_active("The Great Wall", "T-Rex 1")
                                    && entity_hit_points("The Great Wall", "T-Rex 1") < 0x64))
            && never(repeated(5*30, in_2d_box(62485, 63470, 67585, 70615)  // entrance
                                    && entity_is_active("The Great Wall", "T-Rex 1")
                                    && entity_hit_points("The Great Wall", "T-Rex 1") < 0x64))
            && never(repeated(5*30, in_2d_box(79905, 87040, 72725, 75775)
                                    && entity_is_active("The Great Wall", "T-Rex 2")
                                    && entity_hit_points("The Great Wall", "T-Rex 2") < 0x64))
            && never(repeated(5*30, in_2d_box(62485, 63470, 67585, 70615)
                                    && entity_is_active("The Great Wall", "T-Rex 2")
                                    && entity_hit_points("The Great Wall", "T-Rex 2") < 0x64))

            // trigger when the second t-rex dies
            && entity_deactivated("The Great Wall", "T-Rex 2")
)

achievement(
    id=132518,
    badge="145996",
    title="Tomb Conservationinst",
    description="[The Great Wall] Complete the level without killing any wildlife",
    points=5,
    trigger=cheat_protection()
            && in_post_level("The Great Wall")
            && cur_statistics_kills() == 0  // no humans in the level
)

//
//   V E N I C E
//

beat_level_achievement("Venice", 132519, 145924, 5)

all_secrets_achievement("Venice", 132520, 145952)

nlnmas_achievement("Venice", 132521, 145968, 10)

// Note: This achievement forces the player to bypass the final timed race, the same technique
// used to end the level without destroying the mines. This is why the latter doesn't have
// it's own achievement.
achievement(
    id=132522,
    badge="146022",
    title="Tomb Curator",
    description="[Venice] Preserve the cultural heritage of Venice by completing the level without destroying any gondolas",
    points=10,
    trigger=cheat_protection()
            && in_post_level("Venice")
            && entity_is_active("Venice", "Gondola 1")
            && entity_is_active("Venice", "Gondola 2")
            && entity_is_active("Venice", "Gondola 3")
            && entity_is_active("Venice", "Gondola 4")
            && entity_is_active("Venice", "Gondola 5")
)

achievement(
    id=132523,
    badge="146023",
    title="Lara Croft Boat Racing",
    description="[Venice] Starting at the ramp, do 3 laps around the buildings on the left without letting go of the throttle or taking damage (map in comments)",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Venice")

            // must be in one of the two driveable boats
            && never(!in_vehicle("Venice", "Boat 1") && !in_vehicle("Venice", "Boat 2"))

            // reset if:
            // - throttle is not down (action is not pressed)
            && never(!inputting("Action"))
            // - lara takes damage (from hitting walls)
            && never(took_damage("Venice"))
            // - lara leaves the track
            && never(in_2d_box(36870, 39835, 43025, 60400))

            // trigger when the finish line is crossed 4 times (camera changes to a fixed position)
            && repeated(4, camera_became_fixed())
)

achievement(
    id=132524,
    badge="146025",
    title="Did I Leave the Mines On?",
    description="[Venice] Start the final boat race having \"forgotten\" to clear the mines, but complete the level nonetheless",
    points=10,
    trigger=cheat_protection()
            && never_not_in_or_post_level("Venice")

            // store a hit when the final doors' timer starts counting down, if the mines are still there
            // note: the doors reopen when the timer starts, even though they had already opened during the
            // cutscene. we store the hit at that moment, because for 1 frame the door is closed and that
            // would trigger the reset if the hit had been stored earlier
            && once(in_level("Venice")
                    && entity_timer("Venice", "Left Final Door") > 0 && entity_timer("Venice", "Left Final Door") <= 0x2d0
                    && entity_animation_changed_from_to("Venice", "Left Final Door", "Closed", "Opening")
                    && entity_is_active("Venice", "Mine 1"))

            // reset if the door closes and lara is not past it
            && never(entity_animation_is("Venice", "Left Final Door", "Closed")
                     && !entity_room_is("Venice", "Lara", 146))

            // trigger when the level is beaten
            && in_post_level("Venice")
)

//
//   B A R T O L I ' S   H I D E O U T
//

beat_level_achievement("Bartoli's Hideout", 132525, 145925, 5)

all_secrets_achievement("Bartoli's Hideout", 132526, 145953)

nlnmas_achievement("Bartoli's Hideout", 132527, 145969, 10)

achievement(
    id=132528,
    badge="146026",
    title="Making an Entrance",
    description="[Bartoli's Hideout] At the start, jump off the boat at maximum speed and land safely on the wooden dock",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Bartoli's Hideout")

            // store a hit if lara jumps out of the boat in the correct room at max speed
            && once(entity_room_is("Bartoli's Hideout", "Lara", 106)
                    && entity_animation_changed_to("Bartoli's Hideout", "Lara", "Leave Boat (Left)")
                    && entity_speed("Bartoli's Hideout", "Boat") >= (boat_max_speed - 8))  // some leeway

            // reset if in the water
            && never(in_water())

            // trigger after landing on the dock
            && entity_room_is("Bartoli's Hideout", "Lara", 106)
            && doing_basic_movement("Bartoli's Hideout")
)

achievement(
    id=132529,
    badge="146027",
    title="What's the Detonator For?",
    description="[Bartoli's Hideout] Complete the level without blowing up the bomb",
    points=5,
    trigger=cheat_protection()
            && in_post_level("Bartoli's Hideout")
            && entity_status_is("Bartoli's Hideout", "Detonator", "Inactive")  // changes to disabled upon detonation
)

function flare_in_final_shaft() {
    // flares are instantiated as entities when lara lets go of them
    level = "Bartoli's Hideout"
    cond = always_false()
    for i in dynamic_entities(level) {
        cond = cond || (
            entity_at_model_id(level, i) == model_id__enum["Flare"]  // a flare
            && entity_at_flags2_active(level, i) == 1                // ... that's still lit
            && entity_at_room_number(level, i) == 138                // ... in the final shaft
            && entity_at_position_z(level, i) >= 41500               // ... in the last tile and a half
        )
    }
    return cond
}

achievement(
    id=132530,
    badge="146028",
    title="See Through the Simulation",
    description="[Bartoli's Hideout] Throw a flare down the exit shaft and contemplate your existence",
    points=2,
    trigger=cheat_protection()
            && in_level("Bartoli's Hideout")
            && flare_in_final_shaft()
)

//
//   O P E R A   H O U S E
//

beat_level_achievement("Opera House", 132531, 145926, 10)

all_secrets_achievement("Opera House", 132532, 145954)

nlnmas_achievement("Opera House", 132533, 145970, 25)

achievement(
    id=132534,
    badge="146029",
    title="Through the Glass",
    description="[Opera House] Enter the opera house without opening the wooden trapdoors on the domed roof",
    points=5,
    trigger=cheat_protection()
            && in_level("Opera House")

            // the goon leaves the room when the trapdoors open for the first time
            && entity_room_is("Opera House", "Lighting Booth Goon", 0)

            // trigger when in one of the rooms right past the door
            && (entity_room_is("Opera House", "Lara", 37)
                || entity_room_is("Opera House", "Lara", 5))
)

achievement(
    id=132535,
    badge="146030",
    title="I Don't Want No Trouble",
    description="[Opera House] Creep on board the plane without killing anyone or using medipacks in the final storage room",
    points=5,
    trigger=cheat_protection()
            && never(loading_level())

            // store a hit when lara is in the entrace tile with the door still closed
            && once(in_2d_box(69680, 70650, 47105, 48125)
                    && entity_animation_is("Opera House", "Right Final Door", "Closed"))

            // reset if lara uses a medipack
            && never(just_used_a_medipack())
            
            // enemies must all be alive
            && entity_is_active("Opera House", "Boss")
            && entity_is_active("Opera House", "Boss Goon 1")
            && entity_is_active("Opera House", "Boss Goon 2")
            && entity_is_active("Opera House", "Boss Dog 1")
            && entity_is_active("Opera House", "Boss Dog 2")

            && in_cutscene("Opera House End")
)

//
//   O F F S H O R E   R I G
//

beat_level_achievement("Offshore Rig", 132536, 145927, 5)

all_secrets_achievement("Offshore Rig", 132537, 145955)

nlnmas_achievement("Offshore Rig", 132538, 145971, 10)

achievement(
    id=132539,
    badge="146031",
    title="Mind Opening the Window for Me?",
    description="[Offshore Rig] From the start, recover your gear from the plane without entering the water",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Offshore Rig")
            
            // store a hit when entering the second room (lara can't go back)
            && once(entity_room_changed_from_to("Offshore Rig", "Lara", 4, 10))
            
            // reset if lara enters the water
            && never(in_water())
            
            // trigger when lara retrieves her gear
            && entity_status_changed_from_to("Offshore Rig", "Pistols", "Inactive", "Invisible")
)

achievement(
    id=132540,
    badge="146032",
    title="Killer Swan",
    description="[Offshore Rig] Swan dive from the catwalks and kill both full-hp scuba divers without taking damage or coming up for air",
    points=10,
    trigger=cheat_protection()
            && never_not_in_level("Offshore Rig")

            // store a hit when the swan dive starts from the catwalks and both divers are at max hp
            && once(height_ge(2560)
                    && entity_action_changed_to("Offshore Rig", "Lara", "Swan Dive Start")
                    && entity_hit_points("Offshore Rig", "Scuba Diver 1") == 20
                    && entity_hit_points("Offshore Rig", "Scuba Diver 2") == 20)

            // reset if:
            // - doing basic movement anywhere
            // - lara takes damage
            // - lara runs out of air
            // - lara comes to the surface
            && never(doing_basic_movement("Offshore Rig"))
            && never(took_damage("Offshore Rig"))
            && never(ran_out_of_air())
            && never(on_water_surface())

            // trigger when both scuba divers die
            && enemy_entity_is_dead("Offshore Rig", "Scuba Diver 1")
            && enemy_entity_is_dead("Offshore Rig", "Scuba Diver 2")
)

//
//   D I V I N G   A R E A
//

beat_level_achievement("Diving Area", 132541, 145928, 5)

all_secrets_achievement("Diving Area", 132542, 145956)

nlnmas_achievement("Diving Area", 132543, 145972, 10)

achievement(
    id=132544,
    badge="146033",
    title="Power Swimming",
    description="[Diving Area] Get to the second room of the level without turning off the underwater fan",
    points=2,
    trigger=cheat_protection()
            && in_level("Diving Area")
            && entity_room_is("Diving Area", "Lara", 42)
            && entity_action_is("Diving Area", "Underwater Fan", "Moving")
)

achievement(
    id=132545,
    badge="146034",
    title="Hold Your Breath",
    description="[Diving Area] Complete the 2-lever underwater section near the circular saw in one go without running out of air",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Diving Area")
    
            // store hits when the levers are pulled
            && once(entity_action_changed_from_to("Diving Area", "Underwater Lever 1", "Not Pulled", "Pulled"))
            && once(entity_action_changed_from_to("Diving Area", "Underwater Lever 2", "Not Pulled", "Pulled"))
            
            // reset if lara comes up for air or runs out of air
            && never(ran_out_of_air())
            && never(was_on_water_surface())  // prev because we need one frame for the trigger
            
            // trigger when resurfacing
            && on_water_surface()
)

//
//   4 0   F A T H O M S
//

beat_level_achievement("40 Fathoms", 132546, 145929, 5)

all_secrets_achievement("40 Fathoms", 132547, 145957)

nlnmas_achievement("40 Fathoms", 132548, 145973, 10)

achievement(
    id=132549,
    badge="146035",
    title="A Little Obvious, Don't You Think?",
    description="[40 Fathoms] In the silver secret room, jump over the trapdoors as they open",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("40 Fathoms")

            // store a hit when the trapdoor opens
            && once(entity_action_changed_from_to("40 Fathoms", "Trapdoor 1", "Closed", "Open"))

            // reset if lara goes below floor height
            && never(!height_ge(-5888))
            
            // trigger when lara's back to doing basic movement
            // ... and require the trapdoor to be open for at least 1 second,
            //     to make sure we can't trigger before the jump
            && repeated(30, entity_action_is("40 Fathoms", "Trapdoor 1", "Open"))
            && doing_basic_movement("40 Fathoms")
)

achievement(
    id=132550,
    badge="146036",
    title="Through Hell and Back",
    description="[40 Fathoms] Get through the door past the burners without turning them off and survive",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("40 Fathoms")
            
            // store a hit when lara's at the start of the corridor with all burners on
            // and the door closed
            && once(entity_room_is("40 Fathoms", "Lara", 28)
                    && position_z() >= 59400
                    && burner_is_on("40 Fathoms", "Burner 1")
                    && burner_is_on("40 Fathoms", "Burner 2")
                    && burner_is_on("40 Fathoms", "Burner 3")
                    && burner_is_on("40 Fathoms", "Burner 4")
                    && entity_animation_is("40 Fathoms", "Burner Door", "Closed"))

            // reset if lara leaves the corridor through the entrance
            && never(entity_room_is("40 Fathoms", "Lara", 25))

            // trigger when entering the water past the door,
            // as long as lara's still alive and not burning (death could occur midair, for example)
            && entity_room_is("40 Fathoms", "Lara", 29)
            && !burning()
            && alive("40 Fathoms")
)

achievement(
    id=132551,
    badge="146037",
    title="Hold Your Breath Again",
    description="[40 Fathoms] Complete the vertical underwater sequence, getting the gold secret, in one go and without running out of air",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("40 Fathoms")
    
            // store hits when the first underwater door is opened and the gold secret is collected
            && once(entity_animation_changed_from_to("40 Fathoms", "Underwater Door 1", "Closed", "Opening"))
            && once(just_collected_secret("Gold"))
            
            // reset if lara comes up for air or runs out of air
            && never(ran_out_of_air())
            && never(was_on_water_surface())  // prev because we need one frame for the trigger
            
            // trigger when resurfacing
            && on_water_surface()
)

//
//   W R E C K   O F   T H E   M A R I A   D O R I A
//

beat_level_achievement("Wreck of the Maria Doria", 132552, 145930, 10)

all_secrets_achievement("Wreck of the Maria Doria", 132553, 145958)

nlnmas_achievement("Wreck of the Maria Doria", 132554, 145974, 25)

achievement(
    id=132555,
    badge="146038",
    title="Avoidant Swan",
    description="[Wreck of the Maria Doria] Swan dive into the pool from the second level and swim to the end of the level without taking damage",
    points=5,
    trigger=cheat_protection()
            && never_not_in_or_post_level("Wreck of the Maria Doria")
    
            // store a hit when a swan dive takes place from the correct height
            && once(height_ge(2560)
                    && entity_action_changed_to("Wreck of the Maria Doria", "Lara", "Swan Dive Start"))

            // reset if lara takes damage
            && never(took_damage("Wreck of the Maria Doria"))

            // since we're swiming to the end, reset if lara does basic movement
            && never(doing_basic_movement("Wreck of the Maria Doria"))
            
            // trigger when the level completes
            && in_post_level("Wreck of the Maria Doria")
)

//
//   L I V I N G   Q U A R T E R S
//

beat_level_achievement("Living Quarters", 132556, 145931, 5)

all_secrets_achievement("Living Quarters", 132557, 145959)

nlnmas_achievement("Living Quarters", 132558, 145975, 10)

achievement(
    id=132559,
    badge="146039",
    title="Safety Drop",
    description="[Living Quarters] After pulling the lever to flood the burner room, drop down to the floor without taking damage",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Living Quarters")

            // store a hit when lara is in the lever's platform
            && once(entity_room_is("Living Quarters", "Lara", 1)
                    && position_x() <= 69630)

            // reset if lara takes damage or leaves the area
            && never(took_damage("Living Quarters"))
            && never(!entity_room_is("Living Quarters", "Lara", 0)
                     && !entity_room_is("Living Quarters", "Lara", 1)
                     && !entity_room_is("Living Quarters", "Lara", 12))

            // trigger when lara reaches the floor
            // also basic movement to avoid triggering during the fall before damage is taken
            && entity_room_is("Living Quarters", "Lara", 0)
            && !height_ge(-257)
            && doing_basic_movement("Living Quarters")
)

//
//   T H E   D E C K
//

beat_level_achievement("The Deck", 132560, 145932, 10)

all_secrets_achievement("The Deck", 132561, 145960)

nlnmas_achievement("The Deck", 132562, 145976, 25)

achievement(
    id=132563,
    badge="146040",
    title="Aquaphobia",
    description="[The Deck] Starting at the entrance of the subterranean lake, collect the key on the raft without entering the water",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("The Deck")
            && once(entity_room_is("The Deck", "Lara", 22))  // entrance of the lake
            && never(in_water())
            && entity_status_changed_from_to("The Deck", "Raft Key", "Inactive", "Disabled")
)

//
//   T I B E T A N   F O O T H I L L S
//

beat_level_achievement("Tibetan Foothills", 132564, 145933, 10)

all_secrets_achievement("Tibetan Foothills", 132565, 145961)

nlnmas_achievement("Tibetan Foothills", 132566, 145977, 25)

achievement(
    id=132567,
    badge="146041",
    title="Ice Queen",
    description="[Tibetan Foothills] Survive the avalanches at the start without hiding in the cave or crevice, and without taking damage",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Tibetan Foothills")
    
            // store a hit when the bottom boulders start moving
            && once(boulders_started_moving("Tibetan Foothills", "Bottom Boulders 1"))
            
            // reset if lara takes damage, goes into the cave, or goes into the crevice
            && never(took_damage("Tibetan Foothills"))
            && never(entity_room_is("Tibetan Foothills", "Lara", 80))
            && never(entity_room_is("Tibetan Foothills", "Lara", 78) && position_z() <= 9190)
            
            // trigger a bit after the top boulders stop moving.
            // the wait avoids triggering when lara gets killed at the very
            // bottom of the hill a couple frames _after_ the top boulders have stopped
            && once(boulders_stopped_moving("Tibetan Foothills", "Top Boulders 1"))
            && repeated(15, entity_speed("Tibetan Foothills", "Top Boulders 1") == 0
                            && entity_position_x("Tibetan Foothills", "Top Boulders 1") >= 81000)
)

achievement(
    id=132568,
    badge="146042",
    title="Canyon Gymnastics",
    description="[Tibetan Foothills] Get past the canyon before the hut without entering its cave system",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Tibetan Foothills")
            && once(entity_room_is("Tibetan Foothills", "Lara", 10))
            && never(entity_room_is("Tibetan Foothills", "Lara", 39))  // room with the pool and icycles
            && entity_room_is("Tibetan Foothills", "Lara", 12)
)

function snowmobile_explode_trigger() {
    // the armed snowmobiles are spawned dynamically, only the riders are static
    cond = always_false()
    for i in dynamic_entities("Tibetan Foothills") {
        cond = cond || (
            // lara was riding this entity (only possible with a snowmobile)
            once(vehicle_entity_id() == i)
            // and it reached the bottom of the final pool of the level
            && entity_at_room_number("Tibetan Foothills", i) == 129
            && entity_at_position_y("Tibetan Foothills", i) == 0x4800
        )
    }
    return cond
}

achievement(
    id=132569,
    badge="146043",
    title="Snowmobile or Submarine?",
    description="[Tibetan Foothills] Attempt to bring an armed snowmobile into Barkhang Monastery and survive",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Tibetan Foothills")
            && snowmobile_explode_trigger()
            && never(vehicle_entity_id() == 0xffff && doing_basic_movement("Tibetan Foothills"))
            && alive("Tibetan Foothills")
)

achievement(
    id=132570,
    badge="146044",
    title="Risky Swan",
    description="[Tibetan Foothills] Swan dive into the last pool of the level from the top of the chasm",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Tibetan Foothills")
            && once(entity_action_changed_to("Tibetan Foothills", "Lara", "Swan Dive Start")
                    && height_ge(0xc00))
            && never(doing_basic_movement("Tibetan Foothills"))
            && entity_room_is("Tibetan Foothills", "Lara", 129)
)

achievement(
    id=132571,
    badge="146045",
    title="Tomb Hiker",
    description="[Tibetan Foothills] Complete the level without mounting a snowmobile [Single Session, Save-Load Allowed]",
    points=10,
    trigger=cheat_protection()
            && never_not_in_or_post_or_loading_level("Tibetan Foothills")
    
            // store a hit when loading the level from the beginning
            && once(level_just_became_playable() && !in_saved_level())
            && measured(once(level_just_became_playable() && !in_saved_level()))
    
            // reset if loading a level from the beginning or loading an unearned save
            && never(loading_level() && !in_saved_level())
            && never_loading_unsaved_placeholder()
            
            // reset if lara gets on a vehicle
            && never(vehicle_entity_id() != 0xffff)
            
            // trigger upon beating the level
            && in_post_level("Tibetan Foothills")
)

//
//   B A R K H A N G   M O N A S T E R Y
//

beat_level_achievement("Barkhang Monastery", 132572, 145934, 10)

all_secrets_achievement("Barkhang Monastery", 132573, 145962)

nlnmas_achievement("Barkhang Monastery", 132574, 145978, 25)

achievement(
    id=132575,
    badge="146046",
    title="Run the Gauntlet",
    description="[Barkhang Monastery] Get through the trap gauntlet without taking damage, collecting the jade secret on the way",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Barkhang Monastery")
    
            // store a hit before the first burner trap
            && once(entity_room_is("Barkhang Monastery", "Lara", 39)
                    && position_x() >= 38900)

            // store another hit when the jade secret is collected
            && once(just_collected_secret("Jade"))

            // reset if lara takes damage or leaves the gauntlet rooms
            && never(took_damage("Barkhang Monastery"))
            && never(!entity_room_is("Barkhang Monastery", "Lara", 39)
                     && !entity_room_is("Barkhang Monastery", "Lara", 133)
                     && !entity_room_is("Barkhang Monastery", "Lara", 160)
                     && !entity_room_is("Barkhang Monastery", "Lara", 134)
                     && !entity_room_is("Barkhang Monastery", "Lara", 159)
                     && !entity_room_is("Barkhang Monastery", "Lara", 153))
            
            // trigger upon reaching the room with the key
            && entity_room_is("Barkhang Monastery", "Lara", 153)
            && position_x() <= 27650
)

achievement(
    id=132576,
    badge="146047",
    title="Tomb Desecrator",
    description="[Barkhang Monastery] Complete the level having the monks be hostile since the first encounter [Single Session, Save-Load Allowed]",
    points=10,
    trigger=cheat_protection()
            && never_not_in_or_post_or_loading_level("Barkhang Monastery")
            
            // store a hit when loading the level from the beginning
            && once(level_just_became_playable() && !in_saved_level())
            && measured(once(level_just_became_playable() && !in_saved_level()))
            
            // reset if loading a level from the beginning or loading an unearned save
            && never(loading_level() && !in_saved_level())
            && never_loading_unsaved_placeholder()
            
            // reset if lara enters the library without the monks being hostile
            && never(entity_room_is("Barkhang Monastery", "Lara", 15)
                     && !monks_hostile())

            // trigger upon beating the level
            && in_post_level("Barkhang Monastery")
)

achievement(
    id=132577,
    badge="146048",
    title="Holier Than Thou",
    description="[Barkhang Monastery] Complete the level without killing neither monks nor mercenaries",
    points=10,
    trigger=cheat_protection()
            && in_post_level("Barkhang Monastery")
            && enemy_entity_group_n_dead("Barkhang Monastery", "Crows") == cur_statistics_kills()
)

//
//   C A T A C O M B S   O F   T H E   T A L I O N
//

beat_level_achievement("Catacombs of the Talion", 132578, 145935, 5)

all_secrets_achievement("Catacombs of the Talion", 132579, 145963)

nlnmas_achievement("Catacombs of the Talion", 132580, 145979, 10)

function yetis_at_the_gate() {
    // at least one of the four yetis is at the gate in front of lara
    gate_cond = always_false()
    for i in range(1,4) {
        yeti = format("Jail Yeti {0}", i)
        gate_cond = gate_cond || (
            entity_room_is("Catacombs of the Talion", yeti, 11)
            && entity_position_z("Catacombs of the Talion", yeti) <= position_z() + 500
            && entity_position_z("Catacombs of the Talion", yeti) >= position_z() - 500
        )
    }

    // none of the yetis are inside the jail
    not_jail_cond = always_true()
    for i in range(1,4) {
        yeti = format("Jail Yeti {0}", i)
        not_jail_cond = not_jail_cond && (
            !entity_room_is("Catacombs of the Talion", yeti, 83)
            && !entity_room_is("Catacombs of the Talion", yeti, 77)
        )
    }

    return gate_cond && not_jail_cond
}

achievement(
    id=132581,
    badge="146049",
    title="Barbarians at the Gate",
    description="[Catacombs of the Talion] Lock yourself in jail, leaving the Yetis to wail at the gates",
    points=2,
    trigger=cheat_protection()
            && in_level("Catacombs of the Talion")

            // lara is in the jail
            && entity_room_is("Catacombs of the Talion", "Lara", 83)

            // the door is closed
            && entity_animation_is("Catacombs of the Talion", "Jail Door 1", "Closed 2")
            
            // the yetis are at the gate in front of lara
            && yetis_at_the_gate()

            // lara is facing the gates
            && doing_basic_movement("Catacombs of the Talion")  // because backwards jumps change the angle...
            && angle() >= 0x6000 && angle() <= 0xe000
)

achievement(
    id=132582,
    badge="146050",
    title="No, You're Locked in Here With Me",
    description="[Catacombs of the Talion] Kill the 4 jailed Yetis using only your pistols without taking damage",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Catacombs of the Talion")
    
            // store a hit when the level flips (that's how the yetis are freed)
            && once(entity_room_is("Catacombs of the Talion", "Lara", 11)
                    && level_just_flipped())
            
            // reset if lara takes damage or draws a weapon other than the pistols
            && never(took_damage("Catacombs of the Talion"))
            && never(weapons_drawn() && !weapon_is("pistols"))
            
            // trigger when the 4 yetis are dead
            && !entity_is_active("Catacombs of the Talion", "Jail Yeti 1")
            && !entity_is_active("Catacombs of the Talion", "Jail Yeti 2")
            && !entity_is_active("Catacombs of the Talion", "Jail Yeti 3")
            && !entity_is_active("Catacombs of the Talion", "Jail Yeti 4")
)

//
//   I C E   P A L A C E
//

beat_level_achievement("Ice Palace", 132583, 145936, 5)

all_secrets_achievement("Ice Palace", 132584, 145964)

nlnmas_achievement("Ice Palace", 132585, 145980, 10)

achievement(
    id=132586,
    badge="146051",
    title="Anti-Gravity Sliding",
    description="[Ice Palace] Drop down to the gong without losing half your health",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Ice Palace")
            
            // store a hit when lara is in the room above the gong
            && once(entity_room_is("Ice Palace", "Lara", 80))
            
            // reset if lara takes more than 500 damage
            && never(took_damage_ge("Ice Palace", 500))
            
            // trigger when lara is in the gong room doing basic movement
            && entity_room_is("Ice Palace", "Lara", 10)
            && doing_basic_movement("Ice Palace")
)

achievement(
    id=132587,
    badge="146052",
    title="The Real Treasure",
    description="[Ice Palace] Loot the Guardian's cave and then kill it, without hiding where you can't be attacked or using medipacks",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Ice Palace")
            
            // store a hit when the guardian is confused in its initial position
            // AFAIK it can't happen again once the fight starts
            && once(entity_action_is("Ice Palace", "Guardian", "Confused")
                    && entity_room_is("Ice Palace", "Guardian", 143))

            // reset if lara uses a medipack
            && never(just_used_a_medipack())
            
            // reset if lara hides where the guardian can't attack (5 seconds leeway)
            && never(repeated(5*30, !creature_mood_is("Ice Palace", "Guardian", "Attack")
                                    && !entity_room_is("Ice Palace", "Guardian", 143)))
            
            // trigger when the guardian dies, as long as both guardian pickups are gone
            && entity_status_is("Ice Palace", "Guardian's Uzi Ammo", "Invisible")
            && entity_status_is("Ice Palace", "Guardian's Medipack", "Invisible")
            && entity_action_is("Ice Palace", "Guardian", "Dying")
)

//
//   T E M P L E   O F   X I A N
//

beat_level_achievement("Temple of Xian", 132588, 145937, 10)

all_secrets_achievement("Temple of Xian", 132589, 145965)

nlnmas_achievement("Temple of Xian", 132590, 145981, 25)

function never_triggered_trapfloors() {
    cond = always_true()
    for i in range(1, 4)
        cond = cond && never(
            entity_room_is("Temple of Xian", "Lara", 17)
            && entity_action_is("Temple of Xian", format("Trapfloor {0}", i), "Open")
        )
    return cond
}

achievement(
    id=132591,
    badge="146053",
    title="Fall for It on Your Own Terms",
    description="[Temple of Xian] Start down the slide without triggering the trap floors, take no damage, and swan dive into the lake at the end",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Temple of Xian")

            // store a hit when lara is a the top, before the slide
            && once(entity_room_is("Temple of Xian", "Lara", 17))
            
            // reset if a trap floor opens withlst lara is still at the top
            // (2 of the floors open during the slide for some reason)
            && never_triggered_trapfloors()
            
            // reset if lara takes damage
            && never(took_damage("Temple of Xian"))
            
            // store a hit when a swan dive is initiated from the slide and trigger when it finishes on the pool below
            && once((entity_room_is("Temple of Xian", "Lara", 188)
                     || entity_room_is("Temple of Xian", "Lara", 189)
                     || entity_room_is("Temple of Xian", "Lara", 8))
                    && height_ge(13500)
                    && position_z() >= 57150
                    && position_z() <= 59550
                    && entity_action_changed_to("Temple of Xian", "Lara", "Swan Dive Start"))
            && entity_room_is("Temple of Xian", "Lara", 10)
)

achievement(
    id=132592,
    badge="146054",
    title="Demanding but Worthwhile Gymnastics",
    description="[Temple of Xian] Bypass most of the level by reaching the wooden bridge above the lake right after coming down the slide",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Temple of Xian")
    
            // store a hit when lara is in the gold secret crevice
            && once(entity_room_is("Temple of Xian", "Lara", 162))

            // reset if lara falls into the pool
            && never(entity_room_is("Temple of Xian", "Lara", 10))

            // trigger when lara reaches the bridge
            && entity_room_is("Temple of Xian", "Lara", 8)
            && position_z() <= 52750
            && doing_basic_movement("Temple of Xian")
)

achievement(
    id=132593,
    badge="146055",
    title="Get Baited Son",
    description="[Temple of Xian] Attempt to climb up to the alcove with a large medipack above the lake, opposite the wooden bridge",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Temple of Xian")
    
            // store a hit when lara is attempting to grab the fake ladder
            && once(position_x() >= 23560 && position_x() <= 24575
                    && position_z() == 59291  // right against the wall
                    && height_ge(16500)
                    && entity_action_is("Temple of Xian", "Lara", "Reaching"))

            // reset if lara enter the lake, just to be scope the hit... shouldnt be possible afaik                    
            && never(entity_room_is("Temple of Xian", "Lara", 10))

            // trigger when lara reaches the bottom of the ladder and starts sliding
            && entity_action_is("Temple of Xian", "Lara", "Slide Backwards")
)

function never_touched_by_spider() {
    cond = always_true()
    for idx in entity_groups["Temple of Xian"]["Cave Spiders"]
        cond = cond && never(entity_at_touching_lara("Temple of Xian", idx))
    return cond
}

achievement(
    id=132594,
    badge="146056",
    title="Nope",
    description="[Temple of Xian] Make it through the spider cave without letting any spider touch you",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Temple of Xian")

            // store a hit when the first spider activates, because it's an event that only happens once
            && once(creature_just_activated("Temple of Xian", "Cave Spider 1"))
            
            // reset if lara is hit by spiders
            && never_touched_by_spider()
            
            // trigger when the end of the cave is reached
            && entity_room_changed_from_to("Temple of Xian", "Lara", 154, 151)
)

achievement(
    id=132595,
    badge="146057",
    title="Perilous Climb",
    description="[Temple of Xian] Starting from the dragon, perform the final climb of the level without taking damage",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Temple of Xian")
            && once(entity_room_is("Temple of Xian", "Lara", 129)
                    || entity_room_is("Temple of Xian", "Lara", 97))
            && never(took_damage("Temple of Xian"))
            && entity_room_is("Temple of Xian", "Lara", 33)
)

//
//   F L O A T I N G   I S L A N D S
//

beat_level_achievement("Floating Islands", 132596, 145938, 10)

all_secrets_achievement("Floating Islands", 132597, 145966)

nlnmas_achievement("Floating Islands", 132598, 145982, 25)

function petrified_guard_killed() {
    cond = always_false()
    for idx in entity_groups["Floating Islands"]["Guards"]
        cond = cond || (
            entity_at_status_is("Floating Islands", idx, "Inactive")
            && enemy_entiy_at_just_died("Floating Islands", idx)
        )
    return cond
}

achievement(
    id=132599,
    badge="146058",
    title="Dream Eater",
    description="[Floating Islands] Kill a stone warrior while it's still petrified",
    points=2,
    trigger=cheat_protection()
            && in_level("Floating Islands")
            && petrified_guard_killed()
)

achievement(
    id=132600,
    badge="146059",
    title="Roast Swan",
    description="[Floating Islands] Swan dive into the trapdoors inside a lava pool",
    points=2,
    trigger=cheat_protection()
            && never_not_in_level("Floating Islands")
            && once(entity_action_changed_to("Floating Islands", "Lara", "Swan Dive Start")
                    && height_ge(-3840))
            && never(doing_basic_movement("Floating Islands"))
            && entity_room_is("Floating Islands", "Lara", 119)
            && entity_action_changed_from_to("Floating Islands", "Lara", "Swan Dive Fall", "Dive")
)

//
//   D R A G O N ' S   L A I R
//

beat_level_achievement("Dragon's Lair", 132601, 145939, 5)

// Dragon's Lair has no secrets
achievement(
    id=132602,
    badge="145983",
    title="NLNM in Dragon's Lair",
    description="Complete Dragon's Lair without loading or using medipacks",
    points=10,
    trigger=(
        cheat_protection()

        && once(level_just_became_playable()  // no loads: remember the start of the level
                && !in_saved_level())         // ... if it was started from the beginning, not loaded from a save
        && never(loading_level())             // ... and reset if there's another load

        && in_post_level("Dragon's Lair")  // finished the level
        && used_no_meds()                  // ... having used no medipacks
    )
)

achievement(
    id=132603,
    badge="146060",
    title="What Am I Supposed to Do?!",
    description="[Dragon's Lair] Incapacitate the Dragon at least five times before finishing the fight, without using medipacks",
    points=5,
    trigger=cheat_protection()
            && never_not_in_level("Dragon's Lair")
            && repeated(5, entity_action_changed_to("Dragon's Lair", "Dragon Front", "Incapacitated"))
            && never(just_used_a_medipack())
            && entity_status_changed_from_to("Dragon's Lair", "Dragon Front", "Active", "Disabled")
)

achievement(
    id=132604,
    badge="146061",
    title="Tis but an Inconvenience",
    description="[Dragon's Lair] Complete the level while on fire",
    points=2,
    trigger=cheat_protection()
            && burning()
            && in_post_level("Dragon's Lair")
)

//
//   H O M E   S W E E T   H O M E
//

achievement(
    id=132605,
    badge="145940",
    title="Don't You Think You've Seen Enough?",
    description="Complete the last level, Home Sweet Home",
    points=25,
    trigger=cheat_protection() && in_post_game()
)

// Home Sweet Home has no secrets and ends differently
achievement(
    id=132606,
    badge="145984",
    title="NLNM in Home Sweet Home",
    description="Complete Home Sweet Home without loading or using medipacks",
    points=10,
    trigger=(
        cheat_protection()

        && once(level_just_became_playable()  // no loads: remember the start of the level
                && !in_saved_level())          // ... if it was started from the beginning, not loaded from a save
        && never(loading_level())              // ... and reset if there's another load

        && in_credits()    // finished the level
        && used_no_meds()  // ... having used no medipacks
    )
)

achievement(
    id=132607,
    badge="146062",
    title="Back to Basics",
    description="[Home Sweet Home] Lock the last goon in the freezer",
    points=5,
    trigger=cheat_protection()
            && in_level("Home Sweet Home")
            && entity_room_is("Home Sweet Home", "Boss", 70)
            && entity_animation_is("Home Sweet Home", "Freezer Door", "Closed 2")
)

//
//   M I S C E L L A N E O U S
//

achievement(
    id=132608,
    badge="145985",
    title="This Just Might Work",
    description="Input one of the cheat codes from the PC version of the original Tomb Raider",
    points=1,
    trigger=in_a_level() && just_exploded()
)

achievement(
    id=132609,
    badge="145986",
    title="Tomb of the Diver",
    description="Initiate two somersaults during a swan dive and survive",
    points=5,
    trigger=cheat_protection()
            && never_not_in_a_level()

            // store a hit when a swan dive starts
            && once(entity_ptr_action_changed_to(lara_entity_ptr__mem, "Lara", "Swan Dive Start"))

            // reset if the dive is done
            && never(ptr_doing_basic_movement())

            // expect 2 somersaults during the dive, but only trigger when the dive ends
            && repeated(2, entity_ptr_animation_changed_to(lara_entity_ptr__mem, "Lara", "Somersault"))
            && entity_ptr_action_changed_from_to(lara_entity_ptr__mem, "Lara", "Swan Dive Fall", "Dive")
)

//
//   W E A P O N S
//

weapons = ["Automatic Pistols", "Uzis", "Harpoon Gun", "M16", "Grenade Launcher"]

for it in zip4(weapons, range(132610, 132614), range(145944, 145948),
               ["Potent Pistols", "Rapid Pistols", "Underwater Pistol", "Assault Pistol", "Explosive Pistol"]) {
    weapon = it[0]
    id = it[1]
    badge_id = it[2]
    title = it[3]
    achievement(
        id=id,
        badge=format("{0}", badge_id),
        title=title,
        description=format("Obtain the {0}", weapon),
        points=2,
        trigger=cheat_protection()
                // When loading, the inventory is filled a few frames after the loading flag turns off,
                // which would cause the achievement to trigger. To avoid this problem we require the
                // player to be in the level for at least one second before we can trigger.
                && never_not_in_a_level()
                && repeated(30, always_true())
                && main_inv_just_got(format("{0} Option", weapon))
    )
}

// =================================== //
//                                     //
//      R I C H   P R E S E N C E      //
//                                     //
// =================================== //

rich_presence_conditional_display(
    in_title(),
    "Lara is getting ready"
)

rich_presence_conditional_display(
    in_a_fmv(),
    "Lara is watching events unfold"
)

rich_presence_conditional_display(
    in_credits() || in_post_game(),
    "Lara has reached the end of her adventure"
)

rich_presence_conditional_display(
    in_a_cutscene(),
    "Lara is watching events unfold"
)

level__lookup = rich_presence_lookup("Level", current_level_id__mem, {
    0:  "Lara's Home",
    1:  "The Great Wall",
    2:  "Venice",
    3:  "Bartoli's Hideout",
    4:  "Opera House",
    5:  "Offshore Rig",
    6:  "Diving Area",
    7:  "40 Fathoms",
    8:  "Wreck of the Maria Doria",
    9:  "Living Quarters",
    10: "The Deck",
    11: "Tibetan Foothills",
    12: "Barkhang Monastery",
    13: "Catacombs of the Talion",
    14: "Ice Palace",
    15: "Temple of Xian",
    16: "Floating Islands",
    17: "Dragon's Lair",
    18: "Home Sweet Home"
}, "an unknown location")

rich_presence_conditional_display(
    in_or_loading_level("Lara's Home"),
    "Lara is relaxing at home"
)

rich_presence_conditional_display(
    in_or_loading_a_level(),
    "Lara is making her way through {0}",
    level__lookup
)

rich_presence_conditional_display(
    in_a_post_level(),
    "Lara has made it through {0}",
    level__lookup
)

rich_presence_display("Lara is in parts unknown")

// ================================ //
//                                  //
//      L E A D E R B O A R D S     //
//                                  //
// ================================ //

leaderboard(
    title="Assault Course",
    description="Finish the Assault Course in Lara's Home as fast as possible",
    start=in_level("Lara's Home")
          && assault_course_just_started(),
    cancel=just_used_corner_bug()
           || assault_course_just_failed(),
    submit=assault_course_just_completed(),
    value=assault_course_timer__mem * 2,
    format="FRAMES"
)

function level_leaderboard_start(level) =>
    level_just_became_playable()
    && !in_saved_level()
    && in_level(level)
    && no_infinite_ammo()

function level_leaderboard_cancel(level) =>
    // cancel if cheats or corner bugs are used
    ingame_cheat_just_used()
    || just_used_corner_bug()

    // also cancel if loading a level form the start...
    || (loading_level() && !in_saved_level())
    // ...or loading a saved level before having saved in the current session
    || (loading_level() && unless(once(saving_game())))
    // reset the player-has-saved pause when the leaderboard starts
    || (always_false() && never(level_leaderboard_start(level)))

function level_leaderboard_submit(level) =>
    level_just_ended()

function level_leaderboard(level) {
    leaderboard(
        title=format("{0} RTA", level),
        description=format("Complete '{0}' as fast as possible [Single Session, Save-Load Allowed]", level),
        start=level_leaderboard_start(level),
        cancel=level_leaderboard_cancel(level),
        submit=level_leaderboard_submit(level),
        value=measured(!is_paused()),
        format="FRAMES"
    )
}

for level in [
    "The Great Wall",
    "Venice",
    "Bartoli's Hideout",
    "Opera House",
    "Offshore Rig",
    "Diving Area",
    "40 Fathoms",
    "Wreck of the Maria Doria",
    "Living Quarters",
    "The Deck",
    "Tibetan Foothills",
    "Barkhang Monastery",
    "Catacombs of the Talion",
    "Ice Palace",
    "Temple of Xian",
    "Floating Islands",
    "Dragon's Lair"
] {
    level_leaderboard(level)
}

level_leaderboard("Home Sweet Home")

// ========================== //
//                            //
//      D E B U G G I N G     //
//                            //
// ========================== //

achievement(
    id=132761,
    title="Corner Bug Detection",
    description="Triggers when a corner bug is detected (for debugging purposes)",
    points=0,
    trigger=just_used_corner_bug()
)
