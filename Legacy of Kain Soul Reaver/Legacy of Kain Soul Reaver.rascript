// Legacy of Kain: Soul Reaver
// #ID = 11297

// ----------------------------------------------- //
//   r e g i o n a l   c o m p a t i b i l i t y   //
// ----------------------------------------------- //

// USA version differs from EU version, but all EU language versions are the same,
// so its reasonable to support them all.
// Besides the used static addresses, the function pointers used as values for
// logic also have to change depending on region.

// Even though there are only US and EU alts, regional support is not possible
// because the instance-brute-force achievements are too large already. Duplicating
// their length for EU support goes over the serialization limit :(

regions = ["us", "eu"]

region_offsets = {
    "us": [[0x000000, 0x1fffff,     0]],
    "eu": [[0x000000, 0x0cf440,     0],
           [0x0cf440, 0x0d1010, 0x71c],
           [0x0d1010, 0x0d1960, 0x72c],
           [0x0d1960, 0x1fffff, 0x734]]
}

// cd serial number can identify with rom is being used to play
//   USA:         cdrom:\SLUS_007.08;1
//   EUR English: chrom:\SLES_013.01;1
//   EUR France:  chrom:\SLES_020.24;1
//   EUR Germany: chrom:\SLES_020.25;1
//   EUR Spain:   chrom:\SLES_020.26;1
//   EUR Italy:   chrom:\SLES_020.27;1
cd_serial__addr = 0xb8b0

function region_is(region_name) {
    char = { "us": "U", "eu": "E" }
    return byte(cd_serial__addr + 9) == ascii[char[region_name]]
}

// ----------------- //
//   s t r u c t s   //
// ----------------- //

function struct_field(struct_def, base, field) => base + struct_def[field]

level__struct = {
    "PuzzleInstances": 220,  // EventPointers*
    "streamUnitID":    248   // dword
}

EventPointers__struct= {
    "numPuzzles": 0,     // dword
    "eventInstances": 4  // Event*[numPuzzles]
}

Event__struct = {
    "eventVariables": 6,  // word[5]
}

_GlobalSaveTracker__struct = {
    "humanOpinionOfRaziel": 12,  // word
}

InstaceList__struct = {
    "numInstances": 0,  // dword
    "first":        4,  // _Instance*
}

_InstancePool__struct = {
    "instance": 8,  // _Instance[60]
}

_Instance__struct = {
    "next":             8,    // _Instance*
    "instanceID":       16,   // dword
    "flags":            20,   // dword
    "flags2":           24,   // dword
    "object":           28,   // Object*
    "data":             36,   // void* (_MonsterAttributes* for MONSTER instances)
    "position.x":       92,   // word (signed)
    "position.y":       94,   // word (signed)
    "position.z":       96,   // word (signed)
    "queryFunc":        252,  // dword(*)()
    "LinkChild":        304,  // _Instance*
    "introName":        320,  // char[12]
    "extraData":        332,  // void* (_MonsterVars* for MONSTER instances)
    "currentMainState": 376,  // dword (MonsterState for MONSTER instances)
    "curAnim":          460,  // dword (couldn't find this in the debug build's source)
}
_Instance__sizeof = 616

__Player__struct = {
    "State.SectionList[0].Process": 12,    // void (*)()
    "Mode":                         868,   // dword
    "Senses.heldClass":             1004,  // dword
    "HealthScale":                  1016,  // word
    "HealthBalls":                  1018,  // word
    "HitPoints":                    1020,  // dword
    "Abilities":                    1032,  // dword
    "GlyphManaMax":                 1040,  // word
    "CurrentPlane":                 1080,  // dword
    "attackCurrentHit":             1108,  // _Instance*
}

MainTracker__struct = {
    "mainState": 0,  // dword
    "movieNum":  8,  // dword
}

GameTracker__struct = {
    "level":          40,   // Level*
    "playerInstance": 44,   // _Instance*
    "instanceList":   52,   // InstanceList*
    "instancePool":   56,   // _InstancePool*
    "StreamUnitID":   376,  // dword
    "controlData":    112,  // dword[2][5]
    "baseAreaName":   348,  // char[16]
    "gameMode":       370,  // word
}

WarpGateLoadInfo__struct = {
    "warpgate_in_use": 0,  // dword
    "loading":         4,  // byte
    "blocked":         5   // byte
}

_MonsterVars__struct = {
    "mvFlags": 0,    // dword
    "enemy":   196,  // _MonsterIR*
}

_MonsterIR__struct = {
    "instance": 4,  // _Instance*
}

__EngagedInstance__struct = {
  "instance": 0,  // _Instance*
}
__EngagedInstance__sizeof = 8

function level_field(base, field) => struct_field(level__struct, base, field)
function EventPointers_field(base, field) => struct_field(EventPointers__struct, base, field)
function Event_field(base, field) => struct_field(Event__struct, base, field)
function _GlobalSaveTracker_field(base, field) => struct_field(_GlobalSaveTracker__struct, base, field)
function InstanceList_field(base, field) => struct_field(InstanceList__struct, base, field)
function _InstancePool_field(base, field) => struct_field(_InstancePool__struct, base, field)
function _Instance_field(base, field) => struct_field(_Instance__struct, base, field)
function __Player_field(base, field) => struct_field(__Player__struct, base, field)
function MainTracker_field(base, field) => struct_field(MainTracker__struct, base, field)
function GameTracker_field(base, field) => struct_field(GameTracker__struct, base, field)
function WarpGateLoadInfo_field(base, field) => struct_field(WarpGateLoadInfo__struct, base, field)
function _MonsterVars_field(base, field) => struct_field(_MonsterVars__struct, base, field)
function _MonsterIR_field(base, field) => struct_field(_MonsterIR__struct, base, field)
function __EngagedInstance_field(base, field) => struct_field(__EngagedInstance__struct, base, field)

// ------------- //
//   u t i l s   //
// ------------- //

ascii = {
    "a": 0x61, "b": 0x62, "c": 0x63, "d": 0x64, "e": 0x65, "f": 0x66, "g": 0x67, "h": 0x68,
    "i": 0x69, "j": 0x6a, "k": 0x6b, "l": 0x6c, "m": 0x6d, "n": 0x6e, "o": 0x6f, "p": 0x70,
    "q": 0x71, "r": 0x72, "s": 0x73, "t": 0x74, "u": 0x75, "v": 0x76, "w": 0x77, "x": 0x78,
    "y": 0x79, "z": 0x7a,
    
    "A": 0x41, "B": 0x42, "C": 0x43, "D": 0x44, "E": 0x45, "F": 0x46, "G": 0x47, "H": 0x48,
    "I": 0x49, "J": 0x4a, "K": 0x4b, "L": 0x4c, "M": 0x4d, "N": 0x4e, "O": 0x4f, "P": 0x50,
    "Q": 0x51, "R": 0x52, "S": 0x53, "T": 0x54, "U": 0x55, "V": 0x56, "W": 0x57, "X": 0x58,
    "Y": 0x59, "Z": 0x5a,
    
    "0": 0x30, "1": 0x31, "2": 0x32, "3": 0x33, "4": 0x34, "5": 0x35, "6": 0x36, "7": 0x37,
    "8": 0x38, "9": 0x39
}

function text_equals(text_ptr, needle) {
    cond = always_true()
    for c in needle {
        cond = cond && byte(text_ptr) == ascii[c]
        text_ptr = text_ptr + 1
    }
    cond = cond && byte(text_ptr) == 0
    return cond
}

function never_text_not_equals(text_ptr, needle) {
    cond = always_true()
    for c in needle {
        cond = cond && never(byte(text_ptr) != ascii[c])
        text_ptr = text_ptr + 1
    }
    cond = cond && never(byte(text_ptr) != 0)
    return cond
}

function just_changed(mem, prev_val, now_val) {
    return prev(mem) == prev_val && mem == now_val
}

function word_is_non_negative(mem) => mem <= 32767


// --------------------------- //
//   p l a y e r   s t a t e   //
// --------------------------- //

raziel__addr = 0xd5278
function raziel_field(field) => __Player_field(raziel__addr, field)

raziel_process__mem = tbyte(raziel_field("State.SectionList[0].Process"))
raziel_process__values = {
    "puppet show (standstill)": 0x09aa98,  // eur=0x09aed0  // StateHandlerPuppetShow
    "puppet show (moving)":     0x09ae34,  // eur=0x09b26c  // StateHandlerMoveToPosition
    // many others.. add as needed
}

function raziel_in_cutscene() {
    return raziel_process__mem == raziel_process__values["puppet show (standstill)"]
           || raziel_process__mem == raziel_process__values["puppet show (moving)"]
}

raziel_mode__mem = dword(raziel_field("Mode"))
raziel_mode__bitflags = {
    "Idle":                      0x00000001,  // also 0x01000000 post-crouching tho
    "Start Turn":                0x00004000,
    "Running":                   0x00000004,
    "Running jump":              0x00000008,
    "Jumping":                   0x00000010,
    "High Jumping":              0x00000020,
    "Crouching":                 0x00000040,
    "Moving while crouched":     0x01000000,
    "Gliding":                   0x00002000,
    "Ledge grabbing":            0x00000100,
    "Sliding":                   0x00400000,
    "Stalking":                  0x00000002,
    "Swimming":                  0x00040000,
    "Landing":                   0x00001000,
    "Picking up object":         0x00000800,
    "In combat":                 0x00200000,
    "Soul sucking":              0x10000000,
    "Getting hit":               0x00008000,
    "Throwing object":           0x00020000,
    "Carrying vampire":          0x20000000,
    "Moving block":              0x00000400,
}

raziel_held_class__mem = dword(raziel_field("Senses.heldClass"))
raziel_held_class__values = {
    "2-handed": 1,
    "1-handed": 2,
    "Rock":     3
}

raziel_hp_scale__mem = word(raziel_field("HealthScale"))
raziel_hp_scale__values = [1, 2, 3, 4]

raziel_hp_balls__mem = word(raziel_field("HealthBalls"))
min_hp_balls = 0
max_hp_balls = 15
hp_scale_balls_step = 5

function just_collected_health_power_up() {
    return prev(raziel_hp_balls__mem) == (raziel_hp_balls__mem - 1)
}

raziel_hp__mem = dword(raziel_field("HitPoints"))
raziel_spectral_max_hp = 100000
function raziel_material_max_hp(hp_scale) => 100000 * (hp_scale + 1)

function raziel_in_spectral_hp_range() => raziel_hp__mem < raziel_spectral_max_hp

function raziel_just_took_damage() {
    // hp seems to decay by 5 every frame, whilst enemy hits reduce hp by values
    // orders of magnitude larger. 1000 should be a safe cutoff point to ignore
    // hp decay
    return prev(raziel_hp__mem) > (raziel_hp__mem + 1000)
}

raziel_max_eldritch__mem = word(raziel_field("GlyphManaMax"))
min_eldritch = 32
max_eldritch = 52
eldritch_powerup_step = 4

raziel_cur_plane__mem = dword(raziel_field("CurrentPlane"))
raziel_cur_plane__values = {
    "Material": 1,
    "Spectral": 2
}

function in_material_plane() => raziel_cur_plane__mem == raziel_cur_plane__values["Material"]
function in_spectral_plane() => raziel_cur_plane__mem == raziel_cur_plane__values["Spectral"]

raziel_abilities__addr = raziel_field("Abilities")
raziel_abilities__bitflags = {
    "Phase through gates":    bit0(raziel_abilities__addr),
    "Scale walls":            bit1(raziel_abilities__addr),
    "Telekinetic projectile": bit2(raziel_abilities__addr),
    "Soul Reaver":            bit3(raziel_abilities__addr),
    "Swimming":               bit4(raziel_abilities__addr),
    "Constrict":              bit5(raziel_abilities__addr)
}

function just_earned_ability(name) {
    return prev(raziel_abilities__bitflags[name]) == 0
        && raziel_abilities__bitflags[name] == 1
}

raziel_cur_hit__mem = tbyte(raziel_field("attackCurrentHit"))

// ----------------------- //
//   g a m e   s t a t e   //
// ----------------------- //

main_tracker__addr = 0xd1280
function main_tracker_field(field) => MainTracker_field(main_tracker__addr, field)

main_state__mem = dword(main_tracker_field("mainState"))
main_state__values = {
    "In-game":              1,
    "Loading":              2,
    "Movie":                6,
    "Retting to Main Menu": 8,
    "Main Menu":            9
}

function in_game() => main_state__mem == main_state__values["In-game"]

main_movie_id__mem = dword(main_tracker_field("movieNum"))
movie_id__values = {
    "None":             0xffffffff,
    "Eidos":            0,
    "Crystal Dynamics": 1,
    "Intro":            2,
    "Ending":           3,
    "Credits":          4
}

function watching_movie(movie_name) {
    return main_state__mem == main_state__values["Movie"]
           && main_movie_id__mem == movie_id__values[movie_name]
}

game_tracker__addr = 0xd1010
function game_tracker_field(field) => GameTracker_field(game_tracker__addr, field)

level__mem = tbyte(game_tracker_field("level"))
raziel_instance__mem = tbyte(game_tracker_field("playerInstance"))
stream_unit_id__mem = dword(game_tracker_field("StreamUnitID"))

instance_pool__addr = tbyte(game_tracker_field("instancePool"))

function puzzles() => tbyte(level_field(level__mem, "PuzzleInstances"))
function n_events() => dword(EventPointers_field(puzzles(), "numPuzzles"))
function event_vars(evt_idx) => tbyte(EventPointers_field(puzzles(), "eventInstances") + 4 * evt_idx)
function event_var(evt_idx, var_idx) => word(Event_field(event_vars(evt_idx), "eventVariables") + 2 * var_idx)

buttons_pressed__mem = game_tracker_field("controlData")
buttons_pressed__bitflags = {
    "D-Pad Up":    bit0(buttons_pressed__mem),
    "D-Pad Down":  bit1(buttons_pressed__mem),
    "D-Pad Left":  bit2(buttons_pressed__mem),
    "D-Pad Right": bit3(buttons_pressed__mem),
    "Triangle":    bit4(buttons_pressed__mem),
    "Square":      bit5(buttons_pressed__mem),
    "Circle":      bit6(buttons_pressed__mem),
    "Cross":       bit7(buttons_pressed__mem),
    "L1":          bit0(buttons_pressed__mem + 1),
    "R1":          bit1(buttons_pressed__mem + 1),
    "L2":          bit2(buttons_pressed__mem + 1),
    "R2":          bit3(buttons_pressed__mem + 1),
    "L3":          bit4(buttons_pressed__mem + 1),
    "R3":          bit5(buttons_pressed__mem + 1),
    "Start":       bit6(buttons_pressed__mem + 1),
    "Select":      bit7(buttons_pressed__mem + 1)
}
function button_pressed(name) => buttons_pressed__bitflags[name] == 1

// null-terminated ascii string: <name><id> (under1, train3, ...)
area_name__addr = game_tracker_field("baseAreaName")

game_mode__mem = byte(game_tracker_field("gameMode"))
game_mode__values = {
    "Gameplay":  0x00,
    "Main Menu": 0x04,
    "Paused":    0x06
}

save_ptr__addr = 0xcfaec  // GlobalSave (_GlobalSaveTracker*)
save_ptr__mem = tbyte(save_ptr__addr)

//  < 1: humans are hostile
// >= 1: humans worship raziel
// when a human is killed (except with a glyph spell), goes to -40, the minimum
// increases by one for each human you encounter but do not kill
function human_opinion_of_raziel() => word(_GlobalSaveTracker_field(save_ptr__mem, "humanOpinionOfRaziel"))

function positive_human_opinion() {
    return word_is_non_negative(human_opinion_of_raziel()) && human_opinion_of_raziel() >= 1
}

// --------------------- //
//   i n s t a n c e s   //
// --------------------- //

animation_ids = {
    "Raziel": {
        "Stunned": 128,
        "Using Torch": 138
    },
    "Melchiah": {
        "Hit on back": 7
    },
    "Kain": {
        "Charging attack": 5,
        "Attack part 1":   3,
        "Attack part 2":   9
    },
    "Rahab": {
        "Melee attack": 2,
        "Ranged attack": 6
    },
    "Kain 2": {
        "Charging attack": 16,
        "Attack part 1":   11,
        "Attack part 2":   13,
        "Teleporting":     15
    },

    "hunter": {  // same as Hunter
        "Worshiping": 29
    },
    "Villager A": {
        "Recovering": 17,
        "Worshiping": 24
    },
    "Villager B": {
        "Recovering": 18,
        "Worshiping": 25
    },
    "Villager C": {
        "Recovering": 18,
        "Worshiping": 25
    }
}

intro_names = {
    "Adult Dumahim":  ["r","o","n","i","n"],
    "Melchiah":       ["s","k","i","n","b","o","s"],
    "Kain":           ["K","a","i","n"],
    "Rahab":          ["a","l","u","k","a","b","s","s"],
    "Kain 2":         ["K","a","i","n"],
    "Rahabim Cocoon": ["e","g","g","s","a","c"],
    "Soul":           ["s","o","u","l"],
    
    "Villager A":     ["v","l","g","r","a"],
    "Villager B":     ["v","l","g","r","b"],
    "Villager C":     ["v","l","g","r","c"],
    
    "Torch":          ["h","n","d","t","r","c","h"]
}

function inst_cur_anim(inst_ptr) => dword(_Instance_field(inst_ptr, "curAnim"))

function inst_anim_is(inst_ptr, inst_type, anim_name) {
    return inst_cur_anim(inst_ptr) == animation_ids[inst_type][anim_name]
}

function inst_is__by_name(inst_ptr, inst_type) {
    // would love to find an id that could replace the intro name,
    // but there seems to be no such thing
    intro_name_ptr = _Instance_field(inst_ptr, "introName")
    return text_equals(intro_name_ptr, intro_names[inst_type])
}

function never_inst_is_not__by_name(inst_ptr, inst_type) {
    intro_name_ptr = _Instance_field(inst_ptr, "introName")
    return never_text_not_equals(intro_name_ptr, intro_names[inst_type])
}

function inst_is_hunter(inst_ptr) {
    // there are two names: Hunter and hunter. we ignore the first character
    // to avoid doubling the amount of alt groups
    intro_name_ptr = _Instance_field(inst_ptr, "introName")
    return text_equals(intro_name_ptr + 1, ["u","n","t","e","r"])
}

function inst_id(inst_ptr) => dword(_Instance_field(inst_ptr, "instanceID"))

function inst_is_active(inst_ptr) => inst_id(inst_ptr) != 0
function inst_was_active(inst_ptr) => prev(inst_id(inst_ptr)) != 0
function inst_changed(inst_ptr) => prev(inst_id(inst_ptr)) != inst_id(inst_ptr)

function inst_just_started_anim(inst_ptr, inst_type, anim_name) {
    return prev(inst_cur_anim(inst_ptr)) != animation_ids[inst_type][anim_name]
           && inst_cur_anim(inst_ptr) == animation_ids[inst_type][anim_name]
}

function inst_just_finished_anim(inst_ptr, inst_type, anim_name) {
    return prev(inst_cur_anim(inst_ptr)) == animation_ids[inst_type][anim_name]
           && inst_cur_anim(inst_ptr) != animation_ids[inst_type][anim_name]
}

function inst_just_changed_anim(inst_ptr, inst_type, from_anim_name, to_anim_name) {
    return prev(inst_cur_anim(inst_ptr)) == animation_ids[inst_type][from_anim_name]
           && inst_cur_anim(inst_ptr) == animation_ids[inst_type][to_anim_name]
}

function inst_extra_data(inst_ptr) => tbyte(_Instance_field(inst_ptr, "extraData"))

function mob_inst_is_dead(inst_ptr) {
    // ((_MonsterVars*)extraData).mvFlags & 0x200,
    // but there are no bitwise operators, so it gets a bit weird
    return bit1(_MonsterVars_field(inst_extra_data(inst_ptr), "mvFlags") + 1) == 1
}

function mob_inst_just_died(inst_ptr) {
    return prev(bit1(_MonsterVars_field(inst_extra_data(inst_ptr), "mvFlags") + 1)) == 0
           && bit1(_MonsterVars_field(inst_extra_data(inst_ptr), "mvFlags") + 1) == 1
}

function mob_inst_has_no_enemy(inst_ptr) {
    enemy = tbyte(_MonsterVars_field(inst_extra_data(inst_ptr), "enemy"))
    return enemy == 0x0
}

function mob_inst_just_killed_by_fire(inst_ptr) {
    // ((_MonsterVars*)extraData).mvFlags & 0x400000
    return prev(bit6(_MonsterVars_field(inst_extra_data(inst_ptr), "mvFlags") + 2)) == 0
           && bit6(_MonsterVars_field(inst_extra_data(inst_ptr), "mvFlags") + 2) == 1
}

mob_inst_state__values = {
    "Missile Hit":  3,
    "Fall":         4,
    "Hit":          8,
    "Stunned":      9,
    "Grabbed":      10,
    "Thrown":       11,
    "Impact":       12,
    "Break Hold":   14,
    "Land on Feet": 15,
}

function mob_inst_cur_state_is(inst_ptr, state_name) {
    return dword(_Instance_field(inst_ptr, "currentMainState")) == mob_inst_state__values[state_name]
}

function mob_inst_prior_state_was(inst_ptr, state_name) {
    return prior(dword(_Instance_field(inst_ptr, "currentMainState"))) == mob_inst_state__values[state_name]
}

function inst_position_x(inst_ptr) => word(_Instance_field(inst_ptr, "position.x"))
function inst_position_y(inst_ptr) => word(_Instance_field(inst_ptr, "position.y"))
function inst_position_z(inst_ptr) => word(_Instance_field(inst_ptr, "position.z"))

function inst_query_func(inst_ptr) => dword(_Instance_field(inst_ptr, "queryFunc"))
inst_query_func__values = {
    "Raziel":   0x800b12d0,
    "Human":    0x8007cdd8,

    "Dumahim + Melchahim + Rahabim + Turelim + Soul": 0x8007e414,
    "Zephonim": 0x80125e9c,

    // ...
}

function inst_is__by_qry_func(inst_ptr, inst_type) {
    return inst_query_func(inst_ptr) == inst_query_func__values[inst_type]
}

// --------------------------------- //
//   r a z i e l   i n s t a n c e   //
// --------------------------------- //

raziel_cur_weapon__mem = tbyte(_Instance_field(raziel_instance__mem, "LinkChild"))

// ----------------------------- //
//   i n s t a n c e   p o o l   //
// ----------------------------- //

function pool_inst_just_finished_anim(inst_type, anim_name) {
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && inst_was_active(p)  // needed because we're using deltas
            && inst_is__by_name(p, inst_type)
            && inst_just_finished_anim(p, inst_type, anim_name)
        )
        p = p + _Instance__sizeof
    }
    return cond
}

function pool_inst_ptr(idx) => _InstancePool_field(instance_pool__addr, "instance") + (idx * _Instance__sizeof)

// ------------------------------------- //
//   e n g a g e d   i n s t a n c e s   //
// ------------------------------------- //

// each position in the EngagedList points to the instance with which Raziel
// is interacting in a certain way: the item/weapon held, the block being moved,
// the door being opened, the enemy being targeted or attacked, etc...
// the instances pointers are not usually reset after the interaction is
// completed.

engaged_list__addr = 0xd5988  // EngagedList (__EngagedInstance[15])
function engaged_instance(n) {
    list_el_addr = engaged_list__addr + (n * __EngagedInstance__sizeof)
    return tbyte(__EngagedInstance_field(list_el_addr, "instance"))
}

// 9 and 10 could also qualify, 8 chosen just because
function attacked_instance() => engaged_instance(8)

// --------------------- //
//   w a r p g a t e s   //
// --------------------- //

// cycles from 0-13, skips warpgate being used
selected_warpgate__addr = 0xcf440  // CurrentWarpNumber (dword)
selected_warpgate__mem = dword(selected_warpgate__addr)

warpgate_load_info__addr = 0xd1960  // WarpGateLoadInfo
warpgate_in_use__mem = dword(WarpGateLoadInfo_field(warpgate_load_info__addr, "warpgate_in_use"))
warpgate_loading__mem = byte(WarpGateLoadInfo_field(warpgate_load_info__addr, "loading"))
warpgate_blocked__mem = byte(WarpGateLoadInfo_field(warpgate_load_info__addr, "blocked"))

n_warpgates = 14
warpgate_indexes = range(0, 13)

function warpgate_active(gate_index) {
    // !! only works while viewing the warp target
    return warpgate_in_use__mem == 1
           && warpgate_loading__mem == 4
           && warpgate_blocked__mem == 0
           && selected_warpgate__mem == gate_index
}


// ------------------------------------------- //
//   a r e a s   /   s t r e a m   u n i t s   //
// ------------------------------------------- //

// maps major area name to:
//   - its base id
//   - its last possible id (same as the base id of the next major area)
major_area_base_ids = {
    "add":     [0x00000181, 0x000003e0],
    "out":     [0x000003e0, 0x000005c5],  // also OUT
    "fire":    [0x000005c5, 0x000005f6],
    "train":   [0x000005f6, 0x0000074d],
    "fill":    [0x0000074d, 0x00000d4d],
    "city":    [0x00000d4d, 0x00000f84],
    "filtuna": [0x00000f84, 0x00000f85],
    "filtunb": [0x00000f85, 0x00001928],
    "stone":   [0x00001928, 0x00001a3e],
    "intvaly": [0x00001a3e, 0x00001a51],
    "boss":    [0x00001a51, 0x00001b55],
    "huba":    [0x00001b55, 0x00001b75],
    "hubb":    [0x00001b75, 0x0000238c],
    "sunrm":   [0x0000238c, 0x000025be],
    "litrnda": [0x000025be, 0x000025bf],  // actually litrndA
    "litrndb": [0x000025bf, 0x00003ac5],  // actually litrndB
    "clfpil":  [0x00003ac5, 0x00004797],
    "suntnlb": [0x00004797, 0x00004851],
    "cliff":   [0x00004851, 0x00005201],
    "skinnr":  [0x00005201, 0x00005387],
    "aluka":   [0x00005387, 0x000053a1],  // also Aluka
    "cityout": [0x00005560, 0x00005eb5],
    "pillar":  [0x00005eb5, 0x0000604d],
    "piston":  [0x0000604d, 0x0000682c],
    "htorm":   [0x0000682c, 0x00006c6f],
    "bonus":   [0x00006c6f, 0x00007684],
    "gastuna": [0x00007684, 0x00007685],  // actually gastunA
    "gastunb": [0x00007685, 0x000077d9],  // actually gastunB
    "conect":  [0x000077d9, 0x00007ad2],
    "pillars": [0x00007ad2, 0x0000fe8f],
    "pistunl": [0x0000fe8f, 0xffff8ada],
    "pistair": [0xffff8ada, 0xffff91e9],
    "suntnl":  [0xffff91e9, 0xffff9351],
    "nighta":  [0xffff9351, 0xffff9371],  // also nightA
    "nightb":  [0xffff9371, 0xffff9705],
    "oracle":  [0xffff9705, 0xffffa3e5],
    "htotun":  [0xffffa3e5, 0xffffa49d],
    "chrono":  [0xffffa49d, 0xffffb171],
    "litein":  [0xffffb171, 0xffffb1c5],
    "tompil":  [0xffffb1c5, 0xffffbbb9],
    "soundg":  [0xffffbbb9, 0xffffc46a],
    "litetun": [0xffffc46a, 0xffffc4f5],
    "chapel":  [0xffffc4f5, 0xffffd551],
    "mrlock":  [0xffffd551, 0xffffd69c],
    "gasrm":   [0xffffd69c, 0xffffdbee],
    "under":   [0xffffdbee, 0xffffdf4e],
    "conecta": [0xffffdf4e, 0xffffdf4f],
    "conectb": [0xffffdf4f, 0xffffdf50],
    "conectc": [0xffffdf50, 0xffffdf51],
    "conectd": [0xffffdf51, 0xffffdf52],
    "conecte": [0xffffdf52, 0xffffdf54],
    "conectg": [0xffffdf54, 0xffffe28e],
    "tower":   [0xffffe28e, 0xffffed42],
    "cathy":   [0xffffed42, 0xffffeef0],
    "pisaira": [0xffffeef0, 0xffffeef1],  // actually pisairA
    "pisairb": [0xffffeef1, 0xfffff8a1],  // actually pisairB
    "clfsubb": [0xfffff8a1, 0xfffff959],
    "tomb":    [0xfffff959, 0xffffffff],
}

function in_major_area(major_area_name) {
    base = major_area_base_ids[major_area_name][0]
    limit = major_area_base_ids[major_area_name][1]
    return stream_unit_id__mem >= base
           && stream_unit_id__mem < limit
}

function gen_area_name_to_id() {
    name_to_id = {}
    for major_area in major_area_base_ids {    
        for n in range(1, 99) {
            name_to_id[major_area + n] = major_area_base_ids[major_area][0] + (n - 1)
        }
    }
    return name_to_id
}

area_name_to_id = gen_area_name_to_id()

function in_area(area_name) {
    return stream_unit_id__mem == area_name_to_id[area_name]
}

function was_in_area(area_name) {
    return prev(stream_unit_id__mem) == area_name_to_id[area_name]
}

function just_entered_area(area_name) {
    return prev(stream_unit_id__mem) != area_name_to_id[area_name]
           && stream_unit_id__mem == area_name_to_id[area_name]
}

// --------------------------------------- //
//   c u t s c e n e s   /   e v e n t s   //
// --------------------------------------- //

function event_def(area, evt_idx, var_idx, pre_value, post_value) {
    return {
        "area": area,
        "evt_idx": evt_idx,
        "var_idx": var_idx,
        "pre_val": pre_value,
        "pos_val": post_value
    }
}

events = {

    // The Necropolis
    "Lake of the Dead":                             event_def("cliff1", 3, 0, 0, 1),
    "Defeated vampires in huba4":                   event_def("huba4", 5, 4, 0, 1),
    "Enter huba6 for the first time":               event_def("huba6", 1, 0, 0, 1),
    "Activate Raziel warpgate":                     event_def("huba8", 2, 0, 0, 1),
    "Drop drawbridge into the Melchahim Clan":      event_def("huba10", 7, 2, 0, 1),
    "Human killed by Melchahim vampires":           event_def("huba13", 1, 1, 0, 1),
    "Monologue in out1":                            event_def("out1", 5, 4, 0, 1),
    "Monologue about mosaic of Melchia in out1":    event_def("out1", 5, 0, 0, 1),
    "Activate Melchahim warpgate":                  event_def("out10", 2, 0, 0, 1),
    "Introduction of Wraiths":                      event_def("skinnr7", 0, 1, 0, 1),
    "Solved first block puzzle in skinnr7":         event_def("skinnr7", 2, 4, 0, 1),
    "Solved second block puzzle in skinnr7":        event_def("skinnr7", 1, 0, 0, 1),
    "Solved block puzzle in skinnr14":              event_def("skinnr14", 0, 0, 0, 1),
    "Activate turbine in skinnr5":                  event_def("skinnr5", 1, 0, 2, 3),
    "Lower platform in skinnr1 for the 1st time":   event_def("skinnr1", 3, 0, 1, 2),
    "Lower platform in skinnr1 for the 2nd time":   event_def("skinnr1", 2, 0, 1, 2),
    "Lower platform in skinnr1 for the 3rd time":   event_def("skinnr1", 2, 0, 2, 3),
    "Start of Melchia's intro":                     event_def("skinnr9", 7, 1, 0, 1),
    "End of Melchia's intro":                       event_def("skinnr9", 7, 0, 0, 1),
    "Start of Melchia's death":                     event_def("skinnr9", 4, 3, 0, 1),
    "End of Melchia's death":                       event_def("skinnr9", 7, 0, 1, 2),
    
    // Sanctuary of the Clans
    "Phase into material in pillars6":              event_def("pillars6", 1, 0, 0, 1),
    "Defeat vampires in pillars6":                  event_def("pillars6", 1, 2, 0, 1),
    "Start of Kain's intro":                        event_def("pillars1", 15, 0, 0, 1),
    "End of Kain's intro":                          event_def("pillars1", 15, 1, 0, 1),
    "Start of Kain's defeat":                       event_def("pillars1", 15, 2, 0, 1),
    "End of Kain's defeat":                         event_def("pillars1", 14, 2, 0, 1),
    
    // Silenced Cathedral
    "Activate Silenced Cathedral warpgate":         event_def("cathy58", 2, 0, 0, 1),
    "Open the Cathedral":                           event_def("cathy3", 0, 1, 0, 1),
    "Entrance to the Silent Cathedral intro":       event_def("cathy5", 1, 0, 0, 1),
    "Vampire cocooning human":                      event_def("cathy6", 0, 0, 0, 1),
    "Cathedral monologue":                          event_def("cathy8", 4, 0, 0, 1),
    "Solved block puzzle in cathy13":               event_def("cathy13", 1, 4, 0, 1),
    "Activate the first air fan in the Cathedral":  event_def("cathy8", 5, 2, 0, 1),
    "Solved block puzzle in cathy59":               event_def("cathy59", 1, 1, 1, 2),
    "Solved block puzzle in cathy60":               event_def("cathy60", 2, 1, 1, 2),
    "Permanently open passage into cathy17":        event_def("cathy17", 1, 2, 0, 2),
    "Solved block puzzle in cathy48":               event_def("cathy48", 3, 4, 0, 1),
    "Solved notes puzzle in cathy25":               event_def("cathy25", 0, 0, 0, 2),
    "Solved notes puzzle in cathy22":               event_def("cathy22", 0, 0, 0, 2),
    "Activate the second air fan in the Cathedral": event_def("cathy19", 3, 4, 0, 1),
    "Activate Zephon warpgate":                     event_def("cathy62", 0, 0, 0, 1),
    "Start of Zephon's intro":                      event_def("cathy55", 5, 0, 0, 1),
    "End of Zephon's intro":                        event_def("cathy55", 6, 4, 0, 1),
    "Start of Zephon's death":                      event_def("cathy55", 6, 4, 1, 2),
    "End of Zephon's death":                        event_def("cathy55", 4, 4, 1, 2),
    "Open the Sounding Pipes":                      event_def("cathy38", 4, 2, 0, 1),
    
    // Tomb of the Sarafan
    "Entrance to the Tomb of the Sarafan intro":    event_def("add1", 1, 0, 0, 1),
    "Activate Tomb of the Sarafan warpgate":        event_def("add6", 2, 0, 0, 1),
    "Elder warning at the entrance of the Tomb":    event_def("add7", 1, 0, 0, 1),
    "Open the Tomb of the Sarafan":                 event_def("tomb1", 3, 0, 0, 1),  // also (2,4,0,1) at the end
    "End of exposition at the Tomb of the Sarafan": event_def("tomb1", 2, 4, 0, 1),
    "Start of Morlock's intro":                     event_def("boss2", 4, 0, 0, 1),
    "Start of Morlock's death":                     event_def("boss2", 4, 0, 1, 2),
    "End of Morlock's death":                       event_def("boss2", 4, 0, 2, 3),
    
    // Drowned Abbey
    "Activate Drowned Abbey warpgate":              event_def("aluka43", 2, 0, 0, 1),
    "Drowned Abbey intro":                          event_def("aluka27", 1, 0, 0, 1),
    "Open gates in Drowned Abbey":                  event_def("aluka44", 2, 4, 0, 1),
    "Start of Rahab's intro":                       event_def("aluka6", 7, 4, 0, 1),
    "Start of Rahab's death":                       event_def("aluka6", 8, 4, 0, 4),
    "End of Rahab's death":                         event_def("aluka6", 6, 1, 1, 2),
    
    // Ruins of the Dumahim
    "Activate The Dumahim warpgate":                event_def("hubb4", 2, 0, 0, 1),
    "Ruins of Dumahim intro":                       event_def("nighta1", 1, 2, 0, 1),
    "Open door with explosion in nightA4":          event_def("nighta4", 2, 4, 0, 1),
    "Drop drawbridge in nightA3":                   event_def("nighta3", 0, 0, 0, 1),
    "Drop the monolith":                            event_def("nightb2", 1, 0, 0, 1),
    "Dumah's intro":                                event_def("nightb3", 9, 0, 0, 1),
    "Dumah's spectral intro":                       event_def("nightb3", 3, 0, 0, 1),
    "Dumah's awakening":                            event_def("nightb3", 7, 0, 0, 1),
    "Retry Dumah's fight":                          event_def("nightb3", 7, 0, 2, 1),
    "Dumah's death":                                event_def("nighta4", 1, 1, 0, 1),
    
    // Force Glyph
    "Reveal the Force Glyph":                       event_def("out15", 1, 4, 0, 1),
    "Collect the Force Glyph":                      event_def("out15", 1, 4, 1, 2),
    
    // Stone Glyph
    "Ruins of Nupraptor's Keep intro":              event_def("stone1", 2, 1, 0, 1),
    "Activate Nupraptor's Keep warpgate":           event_def("stone15", 2, 0, 0, 1),
    "Reveal the Stone Glyph":                       event_def("stone11", 1, 0, 0, 1),
    "Collect the Stone Glyph":                      event_def("stone11", 1, 0, 1, 2),
    
    // Sound Glyph
    "Reveal the Sound Glyph":                       event_def("soundg5", 1, 0, 0, 1),
    "Collect the Sound Glyph":                      event_def("soundg5", 1, 0, 2, 3),
    
    // Water Glyph
    "Human Citadel intro":                          event_def("cityout3", 2, 1, 0, 1),
    "Activate Human Citadel warpgate":              event_def("city6", 2, 0, 0, 1),
    "Block water drain in tower11":                 event_def("tower11", 0, 0, 0, 1),
    "Reveal the Water Glyph":                       event_def("tower8", 0, 0, 0, 1),
    "Collect the Water Glyph":                      event_def("tower8", 0, 0, 1, 2),
    
    // Fire Reaver
    "Obtain the Fire Reaver":                       event_def("aluka47", 1, 0, 0, 1),
    
    // Fire Glyph
    "Reveal the Fire Glyph":                        event_def("fire4", 1, 2, 0, 1),
    "Collect the Fire Glyph":                       event_def("fire4", 1, 2, 1, 2),
    
    // Sunlight Glyph
    "Lighthouse intro":                             event_def("fill1", 2, 2, 0, 1),
    "Activate Lighthouse warpgate":                 event_def("fill3", 2, 0, 0, 1),
    "Solved block puzzle in htorm1":                event_def("htorm1", 0, 4, 0, 2),
    "Reveal the Sunlight Glyph":                    event_def("sunrm1", 0, 0, 0, 1),
    "Collect the Sunlight Glyph":                   event_def("sunrm1", 0, 0, 2, 3),
    
    // Oracle Caves and Chronoplast
    "Open the gates into the Oracle Caves":         event_def("mrlock2", 0, 1, 0, 1),
    "Activate Oracles Caves warpgate":              event_def("oracle1", 2, 0, 0, 1),
    "Solve block puzzle in oracle5":                event_def("oracle5", 1, 2, 0, 1),
    "Solve block puzzle in oracle8":                event_def("oracle8", 0, 0, 0, 1),
    "Solve puzzle in oracle6":                      event_def("oracle6", 1, 0, 0, 1),
    "Gain access to the cauldron":                  event_def("oracle3", 1, 0, 0, 1),
    "Visit Moebius' statue":                        event_def("oracle10", 1, 0, 0, 1),
    "Solve puzzle in oracle13":                     event_def("oracle13", 0, 4, 0, 1),
    "Solve puzzle in oracle15":                     event_def("oracle15", 0, 0, 1, 2),
    "Solve puzzle in oracle18":                     event_def("oracle18", 0, 0, 0, 1),
    "Solve puzzle in oracle22":                     event_def("oracle22", 4, 4, 1, 2),
    "Activate Chronoplast warpgate":                event_def("chrono17", 2, 0, 0, 1),
    "Enter Kain 2":                                 event_def("chrono18", 0, 1, 0, 1),
    "Start of Kain's 2nd defeat":                   event_def("chrono1", 3, 0, 0, 1),
    
    // Others
    "Open health power-up gate in Human Citadel":   event_def("mrlock7", 0, 0, 0, 1)
}

function event_just_occurred(evt_name) {
    evt_def = events[evt_name]
    evt_var = event_var(evt_def["evt_idx"], evt_def["var_idx"])
    return in_area(evt_def["area"])
           && was_in_area(evt_def["area"])
           && prev(evt_var) == evt_def["pre_val"]
           && evt_var == evt_def["pos_val"]
}

function event_has_occurred(evt_name) {
    evt_def = events[evt_name]
    evt_var = event_var(evt_def["evt_idx"], evt_def["var_idx"])
    return in_area(evt_def["area"])
           && evt_var == evt_def["pos_val"]
}

function event_has_not_occurred(evt_name) {
    evt_def = events[evt_name]
    evt_var = event_var(evt_def["evt_idx"], evt_def["var_idx"])
    return in_area(evt_def["area"])
           && evt_var != evt_def["pos_val"]
}


// =========================== //
//                             //
//   A C H I E V E M E N T S   //
//                             //
// =========================== //

function ingame_common_trigger() {
    return in_game()
}

function event_trigger(evt_name) {
    return ingame_common_trigger()
           && event_just_occurred(evt_name)
}

function ability_earned_trigger(area_name, ability_name) {
    return ingame_common_trigger()
           && in_area(area_name)
           && just_earned_ability(ability_name)
}

achievement(
    id=107455,
    badge="117644",
    title="The Womb of My Rebirth",
    description="Reach the Lake of the Dead",
    points=5,
    trigger=event_trigger("Lake of the Dead")
)

achievement(
    id=107456,
    badge="117645",
    title="My Once-Proud Kin, Wiped From This World",
    description="Reach Razielim clan territory",
    points=5,
    trigger=event_trigger("Enter huba6 for the first time")
)

achievement(
    id=107457,
    badge="117646",
    title="To What Depths Had Our Dynasty Plummeted",
    description="Reach the Necropolis, Melchahim clan territory",
    points=5,
    trigger=event_trigger("Monologue in out1")
)

achievement(
    id=107458,
    badge="117648",
    title="No Laughing Matter [m]",
    description="Hit Melchiah in hand-to-hand combat such that he can't laugh it off",
    points=5,
    trigger=ingame_common_trigger()
            && in_area("skinnr9")
            && raziel_cur_hit__mem != 0
            && inst_is__by_name(raziel_cur_hit__mem, "Melchiah")
            && inst_anim_is(raziel_cur_hit__mem, "Melchiah", "Hit on back")
)

achievement(
    id=107459,
    badge="117647",
    title="Do You Not Recognize Me, Brother?",
    description="Consume the soul of Melchiah, earning the ability to phase through gates",
    points=10,
    trigger=ability_earned_trigger("skinnr9", "Phase through gates")
)

function survive_kain_1_attack() {
    // how it works:
    // - for each instance in the instance pool:
    //   - if it's not Kain, ignore
    //   - otherwise:
    //      - store a hit when Kain launches an attack
    //      - reset the hit if the attack hits Raziel (hp decreases into the spectral range)
    //      - trigger when Kain finishes the attack (if the hit is still there, then Raziel survived)

    p = _InstancePool_field(instance_pool__addr, "instance")
    kain_cond = always_false()
    for i in range(0, 59) {
        kain_cond = kain_cond || (
            once(inst_is_active(p)
                 && inst_was_active(p)  // needed becuase we're using deltas
                 && inst_is__by_name(p, "Kain")
                 && inst_just_changed_anim(p, "Kain", "Charging attack", "Attack part 1"))
            && inst_is_active(p)
            && inst_was_active(p)
            && inst_is__by_name(p, "Kain")
            && inst_just_started_anim(p, "Kain", "Charging attack")
        )
        p = p + _Instance__sizeof
    }
    return kain_cond
           && never(raziel_in_spectral_hp_range())
}

achievement(
    id=107460,
    badge="117650",
    title="Dance With Death [m]",
    description="Avoid a Soul Reaver attack whilst fighting Kain in Sanctuary of the Clans",
    points=5,
    trigger=ingame_common_trigger()
            && never(!in_area("pillars1"))
            && survive_kain_1_attack()
)

achievement(
    id=107461,
    badge="117649",
    title="Soul Reaver and Reaver of Souls",
    description="Defeat Kain in Sanctuary of the Clans, earning the Soul Reaver",
    points=10,
    trigger=ability_earned_trigger("pillars1", "Soul Reaver")
)

achievement(
    id=107462,
    badge="117651",
    title="Stifled Titan in Mute Surrender",
    description="Reach the Silenced Cathedral, Zephonim clan territory",
    points=5,
    trigger=event_trigger("Cathedral monologue")
)

achievement(
    id=107463,
    badge="117653",
    title="It Is You Who Must Succumb to My Will [m]",
    description="Defeat Zephon without taking damage",
    points=10,
    trigger=ingame_common_trigger()
            && never(!in_area("cathy55"))
            && once(event_just_occurred("End of Zephon's intro"))
            && never(raziel_just_took_damage())
            && never(in_spectral_plane())  // unlikely to be needed, but just to be safe...
            && event_just_occurred("Start of Zephon's death")
)

achievement(
    id=107464,
    badge="117652",
    title="Your Visage Becomes You",
    description="Consume the soul of Zephon, earning the ability to scale walls",
    points=10,
    trigger=ability_earned_trigger("cathy55", "Scale walls")
)

achievement(
    id=107465,
    badge="117654",
    title="Know Thyself, Though It May Destroy You",
    description="Uncover your past at the Tomb of the Sarafan",
    points=5,
    trigger=event_trigger("End of exposition at the Tomb of the Sarafan")
)

achievement(
    id=107466,
    badge="117655",
    title="Do You Prosper on the Scraps He Casts You?",
    description="Defeat the Tomb Guardian, earning the ability to shoot telekinetic projectiles",
    points=5,
    trigger=ability_earned_trigger("boss2", "Telekinetic projectile")
)

achievement(
    id=107467,
    badge="117656",
    title="Stagnant Depths",
    description="Reach the Drowned Abbey, Rahabim clan territory",
    points=5,
    trigger=event_trigger("Drowned Abbey intro")
)

achievement(
    id=107468,
    badge="117657",
    title="Telekinetic Sharpshooter [m]",
    description="Defeat Rahab without letting him attack more than twice or entering the spectral plane",
    points=10,
    trigger=ingame_common_trigger()
            && never(!in_area("aluka6"))
            && once(event_just_occurred("Start of Rahab's intro"))
            && never(repeated(3, pool_inst_just_finished_anim("Rahab", "Melee attack")
                                 || pool_inst_just_finished_anim("Rahab", "Ranged attack")))
            && never(in_spectral_plane())
            && event_just_occurred("Start of Rahab's death")
)

achievement(
    id=107469,
    badge="117658",
    title="You Adapted Well, for One so Maladjusted",
    description="Consume the soul of Rahab, earning the ability to swim",
    points=10,
    trigger=ability_earned_trigger("aluka6", "Swimming")
)

achievement(
    id=107470,
    badge="117659",
    title="Complacent in Their Arrogance",
    description="Reach the Ruined City, abandoned Dumahim clan territory",
    points=5,
    trigger=event_trigger("Ruins of Dumahim intro")
)

achievement(
    id=107471,
    badge="117687",
    title="Come to Save My Soul? [m]",
    description="Speak to Dumah before reviving him",
    points=5,
    trigger=event_trigger("Dumah's spectral intro")
)

achievement(
    id=107472,
    badge="117661",
    title="You Are Persistent, Raziel [m]",
    description="Defeat Dumah without getting stunned or entering the spectral plane [retries allowed]",
    points=10,
    trigger=ingame_common_trigger()
            && once(event_just_occurred("Dumah's awakening")
                    || event_just_occurred("Retry Dumah's fight"))
            && never(inst_just_started_anim(raziel_instance__mem, "Raziel", "Stunned"))
            && never(in_spectral_plane())
            && event_just_occurred("Dumah's death")
)

achievement(
    id=107473,
    badge="117660",
    title="Your Thanks Are Premature",
    description="Consume the soul of Dumah, earning the constrict ability",
    points=10,
    trigger=ability_earned_trigger("nighta4", "Constrict")
)

achievement(
    id=107474,
    badge="117662",
    title="An Ancient Enigma",
    description="Gain access to the Oracle's Caves",
    points=5,
    trigger=event_trigger("Open the gates into the Oracle Caves")
)

achievement(
    id=107475,
    badge="117664",
    title="You Cannot Have Foreseen All of This [m]",
    description="Defeat Kain in the Chronoplast without letting him attack",
    points=10,
    trigger=ingame_common_trigger()
            && once(event_just_occurred("Enter Kain 2"))
            && never(!in_area("chrono18") && !in_area("chrono1"))
            && never(pool_inst_just_finished_anim("Kain 2", "Attack part 2"))
            && event_just_occurred("Start of Kain's 2nd defeat")
)

achievement(
    id=107476,
    badge="117663",
    title="Welcome... to Your Destiny",
    description="Defeat Kain in the Chronoplast and follow your destiny",
    points=25,
    trigger=watching_movie("Ending")
)

// -----------------

function all_warpgates_active() {
    // This trigger requires the player to cycle through all the warp targets.
    // Not ideal, but AFAIK the game doesn't ever keep the required information in
    // RAM at the same time.
    // There is an array (WarpRoomArray) that keeps pointers to the stream units of
    // all the target rooms, but the pointers are only set while looking at the
    // corresponding warp target :(

    gates_cond = always_false()
    for idx in warpgate_indexes {
        gates_cond = gates_cond || once(warpgate_active(idx))
    }
    return repeated(n_warpgates - 1, gates_cond)
}

achievement(
    id=107477,
    badge="117667",
    title="Raziel the Space Streamer",
    description="Activate all warp gates (and cycle through them in one session)",
    points=10,
    trigger=ingame_common_trigger()
            && never(!in_game())
            && all_warpgates_active()
)

achievement(
    id=107478,
    badge="117692",
    title="Telekinetic Shockwave",
    description="Claim the Force Glyph from an effigy of Nuprator",
    points=5,
    trigger=event_trigger("Collect the Force Glyph")
)

achievement(
    id=107479,
    badge="117665",
    title="Through the Fallen Skull",
    description="Reach Nupraptor's Retreat",
    points=5,
    // normally this would just be event_trigger("Ruins of Nupraptor's Keep intro").
    // however, this particular event is set on the first frame of the area, making
    // it impossible to detect.
    // as an alternative, we trigger when raziel enters the area and is put into
    // a cutscene within one second
    trigger=ingame_common_trigger()
            && once(just_entered_area("stone1"))
            && never(repeated(60, in_area("stone1")))
            && never(!in_area("stone1"))
            && raziel_in_cutscene()
)

achievement(
    id=107480,
    badge="117666",
    title="Petrifying Earthquake",
    description="Claim the Stone Glyph from an hammer-wielding statue",
    points=5,
    trigger=event_trigger("Collect the Stone Glyph")
)

achievement(
    id=107481,
    badge="117682",
    title="Stunning Sound Wave",
    description="Claim the Sound Glyph from a ringing bell",
    points=5,
    trigger=event_trigger("Collect the Sound Glyph")
)

achievement(
    id=107482,
    badge="117668",
    title="Towering Walls and Deep Moats",
    description="Reach the Human Citadel",
    points=5,
    trigger=event_trigger("Human Citadel intro")
)

achievement(
    id=107483,
    badge="117683",
    title="An Engulfing Water Wave",
    description="Claim the Water Glyph from a winged sculpture",
    points=5,
    trigger=event_trigger("Collect the Water Glyph")
)

achievement(
    id=107484,
    badge="117669",
    title="An Incinerating Fiery Wave",
    description="Claim the Fire Glyph from a four-armed demon figure",
    points=5,
    trigger=event_trigger("Collect the Fire Glyph")
)

achievement(
    id=107485,
    badge="117670",
    title="Defunct Beacon",
    description="Reach the Lighthouse",
    points=5,
    // same problem as the Nupraptor's Retreat achievement. same solution
    trigger=ingame_common_trigger()
            && once(just_entered_area("fill1"))
            && never(repeated(60, in_area("fill1")))
            && never(!in_area("fill1"))
            && raziel_in_cutscene()
)

achievement(
    id=107486,
    badge="117671",
    title="A Burning Flash of Light",
    description="Claim the Sunlight Glyph from a shadowy altar",
    points=5,
    trigger=event_trigger("Collect the Sunlight Glyph")
)

achievement(
    id=107487,
    badge="117688",
    title="Baptized in the Primordial Flame",
    description="Imbue your Wraith Blade with fire, obtaining the Fire Reaver",
    points=5,
    trigger=event_trigger("Obtain the Fire Reaver")
)

achievement(
    id=107488,
    badge="117672",
    title="Eldritch Power-Up",
    description="Collect your first Eldritch energy power-up",
    points=5,
    trigger=ingame_common_trigger()
            && just_changed(raziel_max_eldritch__mem, min_eldritch, min_eldritch + eldritch_powerup_step)
)

achievement(
    id=107489,
    badge="117673",
    title="Maximum Eldritch Energy",
    description="Collect all Eldritch energy power-ups",
    points=10,
    trigger=ingame_common_trigger()
            && just_changed(raziel_max_eldritch__mem, max_eldritch - eldritch_powerup_step, max_eldritch)
)

achievement(
    id=107490,
    badge="117684",
    title="Health Power-Up Piece",
    description="Collect your first health power-up piece",
    points=5,
    trigger=ingame_common_trigger()
            && just_changed(raziel_hp_balls__mem, min_hp_balls, min_hp_balls + 1)
)

achievement(
    id=107491,
    badge="117685",
    title="Health Power-Up Emblem",
    description="Collect five health power-ups pieces, completing an embled and increasing your health coil",
    points=10,
    trigger=ingame_common_trigger()
            && just_changed(raziel_hp_balls__mem, min_hp_balls + hp_scale_balls_step - 1,
                                                  min_hp_balls + hp_scale_balls_step)
)

achievement(
    id=107492,
    badge="117674",
    title="Maximum Health Coil",
    description="Collect all health power-ups, maximizing your material manifestation",
    points=25,
    trigger=ingame_common_trigger()
            && just_changed(raziel_hp_balls__mem, max_hp_balls - 1, max_hp_balls)
)


function just_killed_dumahim_in_lake() {
    // triggers if an Adult Dumahim dies in cliff1 with a z position value below 15000,
    // which is only attainable by falling through the Lake of the Dead's whirlpool
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && inst_was_active(p)
            && inst_is__by_name(p, "Adult Dumahim")
            // unsigned equivalent of: position.z < -15000
            && inst_position_z(p) > 32767 && inst_position_z(p) < 50536
            && mob_inst_just_died(p)
        )
        p = p + _Instance__sizeof
    }
    return cond && in_area("cliff1")
}

achievement(
    id=107493,
    badge="117675",
    title="Cast Him In",
    description="Kill a vampire as you were killed",
    points=5,
    trigger=ingame_common_trigger()
            && just_killed_dumahim_in_lake()
)

achievement(
    id=107494,
    badge="117686",
    title="Hymn of Death",
    description="Recreate the cut conclusion of the story by activating the Sounding Pipes at the top of the Silenced Cathedral",
    points=5,
    trigger=event_trigger("Open the Sounding Pipes")
)

function was_just_worshiped_by_hunter() {
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && inst_is_hunter(p)
            && inst_just_started_anim(p, "hunter", "Worshiping")
        )
        p = p + _Instance__sizeof
    }
    return cond
}

achievement(
    id=107495,
    badge="117676",
    title="A Warm Welcome",
    description="Have the guards at the entrance of the Human Citadel worship you",
    points=5,
    trigger=ingame_common_trigger()
            && in_area("cityout3")
            && was_just_worshiped_by_hunter()
)

function killed_human_without_blame() {
    // human opinion of raziel drops to -40 when raziel kills a human regardless of the
    // previous value. this happens on the same frame that the human instance is marked
    // as dead, which simplifies things :)
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && inst_is__by_qry_func(p, "Human")
            && mob_inst_just_died(p)
            && mob_inst_has_no_enemy(p)
        )
        p = p + _Instance__sizeof
    }
    return cond && positive_human_opinion()
}

achievement(
    id=107496,
    badge="117677",
    title="Victim of the Elements",
    description="Kill a human without getting blamed for it",
    points=5,
    trigger=ingame_common_trigger()
            && killed_human_without_blame()
)

function any_rahabim_cocoons() {
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && inst_is__by_name(p, "Rahabim Cocoon")
        )
        p = p + _Instance__sizeof
    }
    return cond
}

achievement(
    id=107497,
    badge="117678",
    title="Kill It With Fire",
    description="Destroy all 20 Rahabim cocoons near the Fire Forge",
    points=5,
    // this trigger works by resetting on every frame that the conditions are not met.
    // the "positive" version of the trigger would require more alt groups than are
    // possible. by negating it the ORs are turned into ANDs, which have much better
    // toolkit support
    trigger=ingame_common_trigger()
            && never(!in_area("aluka8"))
            && never(once(any_rahabim_cocoons()))
)

achievement(
    id=107498,
    badge="117679",
    title="Room of Constraining Deadlines",
    description="Visit the room past a mural in the Tomb of the Sarafan",
    points=5,
    trigger=ingame_common_trigger()
            && in_area("bonus1")
)

function killed_same_vampire_five_times() {
    inst = attacked_instance()
    return inst != 0
           && (
               inst_is__by_qry_func(inst, "Dumahim + Melchahim + Rahabim + Turelim + Soul")
               || inst_is__by_qry_func(inst, "Zephonim")
           )
           && never(inst_is__by_name(inst, "Soul"))
           && never(!inst_is_active(inst))
           && never(inst_changed(inst))
           && repeated(5, mob_inst_just_died(inst))
}

achievement(
    id=107499,
    badge="117680",
    title="Promethean Torture",
    description="Isolate a vampire and kill it five times in a row",
    points=5,
    trigger=ingame_common_trigger()
            && killed_same_vampire_five_times()
)

achievement(
    id=107500,
    badge="117689",
    title="Otherworldly Art",
    description="Appreciate the mural in Nupraptor's Retreat from as close as possible",
    points=5,
    trigger=ingame_common_trigger()
            && in_area("stone8")
            && in_material_plane()
            && (inst_position_x(raziel_instance__mem) >= 4115
                && inst_position_x(raziel_instance__mem) <= 4615)
            && (inst_position_y(raziel_instance__mem) >= 520
                && inst_position_y(raziel_instance__mem) <= 1400)
            && (word_is_non_negative(inst_position_z(raziel_instance__mem))
                && inst_position_z(raziel_instance__mem) > 2100)
)

function sipped_from_human_soul() {
    inst = attacked_instance()
    sipable_humans = ["Villager A", "Villager B", "Villager C"]

    cond = always_false()
    for human_name in sipable_humans {
        cond = cond || (
            inst != 0
            && inst_is_active(inst)
            && inst_is__by_name(inst, human_name)
            && inst_anim_is(inst, human_name, "Recovering")
        )
    }
    return cond
}

achievement(
    id=108288,
    badge="118039",
    title="Transylvanian Gentleman",
    description="Sip from a human's soul without killing them",
    points=5,
    trigger=ingame_common_trigger()
            && sipped_from_human_soul()
)

function killed_two_vampires_with_same_torch() {
    weapon = raziel_cur_weapon__mem
    target = attacked_instance()

    return (
        // must always be holding a torch
        never(weapon == 0)
        && never(!inst_is_active(weapon))
        && never_inst_is_not__by_name(weapon, "Torch")

        // must kill a vampire by fire twice
        // note: repeated does not support or'd conditions, so we must separate the Zephonim
        //       from the other vampires. this means that the achievement won't work if one
        //       of the killed vampires is a Zephonim but the other is not, which is very
        //       unlikely to happen, so I'll take it
        && (
            repeated(2, 
                target != 0
                && inst_is_active(target)
                && inst_is__by_qry_func(target, "Dumahim + Melchahim + Rahabim + Turelim + Soul")
                && mob_inst_just_killed_by_fire(target)
                && inst_anim_is(raziel_instance__mem, "Raziel", "Using Torch")
            ) || repeated(2,
                target != 0
                && inst_is_active(target)
                && inst_is__by_qry_func(target, "Zephonim")
                && mob_inst_just_killed_by_fire(target)
                && inst_anim_is(raziel_instance__mem, "Raziel", "Using Torch")
            )
        )
    )
}

achievement(
    id=108289,
    badge="118239",
    title="Put Them to the Torch",
    description="Kill two vampires using a single torch (without letting go of it)",
    points=5,
    trigger=ingame_common_trigger()
            && killed_two_vampires_with_same_torch()
)

function vampire_killed_itself_in_sunlight() {
    p = _InstancePool_field(instance_pool__addr, "instance")
    cond = always_false()
    for i in range(0, 59) {
        cond = cond || (
            inst_is_active(p)
            && (inst_is__by_qry_func(p, "Dumahim + Melchahim + Rahabim + Turelim + Soul")
                || inst_is__by_qry_func(p, "Zephonim"))
            // touching sunlight kills by fire...
            && mob_inst_just_killed_by_fire(p)

            // but we have to ignore everything else that kills by fire
            // using the state prior to death:
            //   - kills by torch and fire reaver
            && !mob_inst_prior_state_was(p, "Stunned")
            //   - pushed by the player
            && !mob_inst_prior_state_was(p, "Missile Hit")
            && !mob_inst_prior_state_was(p, "Fall")
            && !mob_inst_prior_state_was(p, "Hit")
            && !mob_inst_prior_state_was(p, "Impact")
            && !mob_inst_prior_state_was(p, "Land on Feet")
            //   - grabbed / thrown by the player
            && !mob_inst_prior_state_was(p, "Grabbed")
            && !mob_inst_prior_state_was(p, "Thrown")
            && !mob_inst_prior_state_was(p, "Break Hold")
            
        )
        p = p + _Instance__sizeof
    }
    return cond
}

achievement(
    id=108290,
    badge="118243",
    title="Lestat's Craving",
    description="Witness a vampire die from voluntarily walking into sunlight",
    points=5,
    trigger=ingame_common_trigger()
            && vampire_killed_itself_in_sunlight()
)

achievement(
    id=108291,
    badge="118437",
    title="Useless Lever [m]",
    description="Collect the health power-up atop a fountain in the Human Citadel without opening the preceding gate",
    points=5,
    trigger=ingame_common_trigger()
            && once(event_has_not_occurred("Open health power-up gate in Human Citadel"))
            && never(event_has_occurred("Open health power-up gate in Human Citadel"))
            && in_area("mrlock8")
            && just_collected_health_power_up()
)


// ============================= //
//                               //
//   R I C H   P R E S E N C E   //
//                               //
// ============================= //

// --------------- //
//   b o s s e s   //
// --------------- //

function fighting_boss(area_name, start_evt, end_evt) {
    return in_game() && in_area(area_name)
           && event_has_occurred(start_evt)
           && event_has_not_occurred(end_evt)
}

normal_bosses = [
    ["Melchia",           "skinnr9",  "Start of Melchia's intro", "End of Melchia's death", "the Necropolis"],
    ["Kain",              "pillars1", "Start of Kain's intro",    "End of Kain's defeat",   "the Sanctuary of the Clans"],
    ["Zephon",            "cathy55",  "Start of Zephon's intro",  "End of Zephon's death",  "the Silenced Cathedral"],
    ["the Tomb Guardian", "boss2",    "Start of Morlock's intro", "End of Morlock's death", "the Tomb of the Sarafan"],
    ["Rahab",             "aluka6",   "Start of Rahab's intro",   "End of Rahab's death",   "the Drowned Abbey"]
]

for boss_def in normal_bosses {
    rich_presence_conditional_display(
        (in_game()
         && in_area(boss_def[1])
         && event_has_occurred(boss_def[2])
         && event_has_not_occurred(boss_def[3])),
        format("Raziel is fighting {0} in {1}", boss_def[0], boss_def[4])
    )
}

// no entry for Dumah, because moving through the rooms puts the events out of reach :(

rich_presence_conditional_display(
    in_game() && in_area("chrono1"),
    "Raziel is fighting Kain in the Chronoplast"
)

// ----------------- //
//   i n - g a m e   //
// ----------------- //

nosgoth_areas = {
  "the Abyss":                  ["under", "train", "clfpil"],
  "the Lake of the Dead":       ["cliff"],
  "Razielim territory":         ["huba", "fire"],
  "the Necropolis":             ["out", "skinnr"],
  "the Sanctuary of the Clans": ["pillars"],
  "the Silenced Cathedral":     ["cathy", "soundg"],
  "the Tomb of the Sarafan":    ["tompil", "add", "tomb", "conect", "boss", "conecta", "pillar", "conectb", "conectc",
                                 "conectd", "conecte", "bonus", "chapel"],
  "the Drowned Abbey":          ["aluka", "conectg"],
  "the Ruined City":            ["clfsubb", "hubb", "nighta", "nightb"],
  "Nupraptor's Retreat":        ["stone"],
  "the Human Citadel":          ["cityout", "city", "tower"],
  "the Lighthouse":             ["fill", "filtuna", "filtunb", "intvaly", "gastuna", "gastunb", "gasrm", "litrnda",
                                 "litrndb", "litein", "litetun", "piston", "pistunl", "pistair", "htotun", "htorm",
                                 "pisaira", "pisairb", "suntnl", "suntnlb", "sunrm"],
  "the Oracle's Caves":         ["mrlock", "oracle"],
  "the Chronoplast":            ["chrono"]
}

function in_nosgoth_area(name) {
    cond = always_false()
    for major_area in nosgoth_areas[name] {
        cond = cond || in_major_area(major_area)
    }
    return cond
}

// there had to be an exception...
rich_presence_conditional_display(
    in_game() && (in_area("mrlock7") || in_area("mrlock8")),
    "Raziel is exploring the Human Citadel"
)

for nosgoth_area_name in nosgoth_areas {
    rich_presence_conditional_display(
        in_game() && in_nosgoth_area(nosgoth_area_name),
        format("Raziel is exploring {0}", nosgoth_area_name)
    )
}

rich_presence_conditional_display(
    in_game(),
    "Raziel is in parts unknown"
)

// --------------- //
//   m o v i e s   //
// --------------- //

rich_presence_conditional_display(
    watching_movie("Ending") || watching_movie("Credits"),
    "Raziel has been welcomed into his destiny"
)

// ------------------------------------------- //
//   m a i n   m e n u   /   f a l l b a c k   //
// ------------------------------------------- //

rich_presence_display("Getting ready to explore Nosgoth")
