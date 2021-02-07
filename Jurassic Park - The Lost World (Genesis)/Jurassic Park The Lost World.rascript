// Lost World, The: Jurassic Park
// #ID = 4320

// ======================= \\
// ======================= \\
//                         \\
//      L I B R A R Y      \\
//                         \\
// ======================= \\
// ======================= \\

//
//   u t i l s
//

function pdp11(val) {
    // 32-bit values on the genesis are stored in PDP-11 endianness, meaning that a 32-bit
    // value is split into 2 16-bit parts. Each 16-bit part is stored in little-endian,
    // but are then joined in big-endian order.
    if (val < 0) return (val % 0x10000) * 65536 + ((val - 2147483648) / 65536) + 32768
    else         return (val % 0x10000) * 65536 + (val / 65536)
}

function byte_swap_2(addr) {
    if (addr % 2 == 0) return addr + 1
    else return addr - 1
}

function error(msg) {
    dummy = {}
    return dummy[msg]
}

function cast_keys_to_enum(enum, dict) {
    new_dict = {}
    for key in dict
        new_dict[enum_value(enum, key)] = dict[key]
    return new_dict
}

function cast_arr_to_enum(enum, arr) {
    new_arr = []
    for el in arr
        array_push(new_arr, enum_value(enum, el))
    return new_arr
}

function in(needle, arr) {
    for el in arr
        if (needle == el) return true
    return false
}

function array_push_front(arr, new_el) {
    new_arr = [new_el]
    for el in arr
        array_push(new_arr, el)
    return new_arr
}

ascii = {
    " ": 0x20,

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

function time_to_60fps(min, sec) =>
    (min * 60 + sec) * 60

//
//   t r i g g e r   u t i l s
//

function mem_in(mem, arr) {
    cond = always_false()
    for el in arr
        cond = cond || (mem == el)
    return cond
}

function mem_changed(mem) => prev(mem) != mem
function mem_changed_to(mem, to) => prev(mem) != to && mem == to
function mem_changed_from(mem, from) => prev(mem) == from && mem != from
function mem_changed_from_to(mem, from, to) => prev(mem) == from && mem == to

function mem_changed_by(mem, amount) {
    //if (amount >= 0) return prev(mem) + amount == mem
    //else             return mem - amount == prev(mem)
    return prev(mem) + amount == mem
}

function is_negative(type, value) {
    if (type["kind"] == "enum")
        type = type["underlying_type"]

    if (type["kind"] == "builtin") {
        bt = type["builtin"]
        if (bt == "dword") return value >= 0x80000000
        if (bt == "word")  return value >= 0x8000
    }

    error(format("unimplemented for type: {0}", type_to_str(type)))
}

function is_positive(type, value) {
    if (type["kind"] == "enum")
        type = type["underlying_type"]

    if (type["kind"] == "builtin") {
        bt = type["builtin"]
        if (bt == "dword") return value > 0 && value < 0x80000000
        if (bt == "word")  return value > 0 && value < 0x8000
    }
    
    error(format("unimplemented for type: {0}", type_to_str(type)))
}

//
//   t y p e   s y s t e m
//

true = 1
false = 0
null = 0

function make_var(type, addr) => {"type": type, "addr": addr}
function var_type(v) => v["type"]
function var_addr(v) => v["addr"]

function cast_var(new_type, var) => make_var(new_type, var_addr(var))

function builtin_t(t) =>
    {"kind": "builtin", "builtin": t}

structs = {}
function struct_t(name, fields, sizeof) {
    structs[name] = {"kind": "struct", "name": name, "fields": fields, "sizeof": sizeof}
    return structs[name]
}

function struct_ref(t_name) =>  // for forward declarations
    { "kind": "struct_ref", "struct_ref": t_name }

function enum_t(name, values, underlying_t) =>
    { "kind": "enum", "name": name, "values": values, "underlying_type": underlying_t }

function array_t(underlying_t, size) =>
    { "kind": "array", "underlying_type": underlying_t, "size": size }

function pointer_t(t) =>
    { "kind": "pointer", "to": t }

function bitflags_t(name, flags, underlying_t) =>
    { "kind": "bitflags", "name": name, "flags": flags, "underlying_type": underlying_t }

function type_to_str(t) {
    tk = t["kind"]
    if (tk == "builtin")    return format("builtin({0})", t["builtin"])
    if (tk == "struct")     return format("struct({0})", t["name"])
    if (tk == "struct_ref") return format("struct_ref({0})", t["struct_ref"])
    if (tk == "enum")       return format("enum({0})", t["name"])
    if (tk == "array")      return format("array({0}, {1})", type_to_str(t["underlying_t"]), t["size"])
    if (tk == "pointer")    return format("pointer({0})", type_to_str(t["to"]))
    if (tk == "bitflags")   return format("bitflags({0})", t["name"])
    return format("unknown({0})", tk)
}


function make_field(offset, type) {
    if (_sizeof(type) == 1)
        offset = byte_swap_2(offset)
    return { "offset": offset, "type": type }
}

function make_bitflag(offset, type) => { "offset": offset, "type": type }

function enum_value(enum, value_name) => enum["values"][value_name]
function enum_values(enum) => enum["values"]

function array_size(arr_t) => arr_t["size"]
function array_var_size(var) => array_size(var_type(var))

dword_t = builtin_t("dword")
word_t  = builtin_t("word")
byte_t  = builtin_t("byte")
bit0_t  = builtin_t("bit0")
bit1_t  = builtin_t("bit1")
bit2_t  = builtin_t("bit2")
bit3_t  = builtin_t("bit3")
bit4_t  = builtin_t("bit4")
bit5_t  = builtin_t("bit5")
bit6_t  = builtin_t("bit6")
bit7_t  = builtin_t("bit7")

function bit_n_t(n) {
    if (n == 0) return bit0_t
    if (n == 1) return bit1_t
    if (n == 2) return bit2_t
    if (n == 3) return bit3_t
    if (n == 4) return bit4_t
    if (n == 5) return bit5_t
    if (n == 6) return bit6_t
    if (n == 7) return bit7_t
    error(format("Bit doesn't exist: {0}", n))
}

function _mem_builtin(addr, type) {
    t = type["builtin"]
    if (t == "dword") return dword(addr)
    if (t == "word")  return word(addr)
    if (t == "byte")  return byte(addr)
    if (t == "bit0")  return bit0(addr)
    if (t == "bit1")  return bit1(addr)
    if (t == "bit2")  return bit2(addr)
    if (t == "bit3")  return bit3(addr)
    if (t == "bit4")  return bit4(addr)
    if (t == "bit5")  return bit5(addr)
    if (t == "bit6")  return bit6(addr)
    if (t == "bit7")  return bit7(addr)
    error(format("Unexpected builtin type: {0}", type))
}

function _mem_pointer(addr) => word(addr + 2)
function _mem_wide_pointer(addr) => dword(addr)

function _sizeof(t) {
    if (t["kind"] == "builtin") {
        if (t["builtin"] == "dword")   return 4
        if (t["builtin"] == "word")    return 2
        if (t["builtin"] == "byte")    return 1
        if (t["builtin"] == "bit0")    return 1
        if (t["builtin"] == "bit1")    return 1
        if (t["builtin"] == "bit2")    return 1
        if (t["builtin"] == "bit3")    return 1
        if (t["builtin"] == "bit4")    return 1
        if (t["builtin"] == "bit5")    return 1
        if (t["builtin"] == "bit6")    return 1
        if (t["builtin"] == "bit7")    return 1
    } else {
        if (t["kind"] == "struct")     return t["sizeof"]
        if (t["kind"] == "struct_ref") return _sizeof(structs[t["struct_ref"]])
        if (t["kind"] == "enum")       return _sizeof(t["underlying_type"])
        if (t["kind"] == "array")      return _sizeof(t["underlying_type"]) * t["size"]
        if (t["kind"] == "pointer")    return 4
        if (t["kind"] == "bitflags")   return _sizeof(t["underlying_type"])
    }
    error(format("unknown sizeof for type: {0}", t))
}

function typeof_struct_field(struct, field) =>
    struct["fields"][field]["type"]

function _addressof_struct_field(struct, addr, field) =>
    make_var(struct["fields"][field]["type"], addr + struct["fields"][field]["offset"])

function _mem_struct_field(struct, addr, field, wide_ptr) {
    field_def = struct["fields"][field]
    field_addr = addr + field_def["offset"]
    t = field_def["type"]
    if (t["kind"] == "enum" || t["kind"] == "bitflags") t = t["underlying_type"]

    if (t["kind"] == "builtin") return _mem_builtin(field_addr, t)
    if (t["kind"] == "pointer") {
        if (wide_ptr == 1)      return _mem_wide_pointer(field_addr)
        else                    return _mem_pointer(field_addr)
    }
    error(format("Can't read type of field '{0}': {1}", field, type_to_str(t)))
}

function _addressof_array_entry(array, addr, entry_idx) =>
    make_var(array["underlying_type"], addr + (entry_idx * _sizeof(array["underlying_type"])))

function _mem_array_entry(array, addr, entry_idx, wide_ptr) {
    t = array["underlying_type"]
    if (t["kind"] == "builtin") return _mem_builtin(addr + (entry_idx * _sizeof(t)), t)
    if (t["kind"] == "pointer") {
        if (wide_ptr != 0)      return _mem_wide_pointer(addr + (entry_idx * _sizeof(t)))
        else                    return _mem_pointer(addr + (entry_idx * _sizeof(t)))
    }
    error(format("Can't read underlying type of array: {0}", type_to_str(t)))
}

function read_bitflag(bitflags, addr, flag) {
    flag_def = bitflags["flags"][flag]
    return _mem_builtin(addr + flag_def["offset"], flag_def["type"])
}

function _mem(var, wide_ptr) {
    tk = var["type"]["kind"]
    if (tk == "builtin")                  return _mem_builtin(var["addr"], var["type"])
    if (tk == "enum" || tk == "bitflags") return _mem_builtin(var["addr"], var["type"]["underlying_type"])
    if (tk == "pointer") {
        if (wide_ptr != 0)                return _mem_wide_pointer(var["addr"])
        else                              return _mem_pointer(var["addr"])
    }
    error(format("Can't directly read variable of type {0}", type_to_str(var["type"])))
}
function mem(var)      => _mem(var, 0)
function mem_wide(var) => _mem(var, 1)

_READ_MODE = 0
_ADDRESSOF_MODE = 1
_TYPEOF_MODE = 2

function _path(var, path, mode, wide_ptr) {
    // if we start at a pointer, introduce an implicit dereference
    if (var["type"]["kind"] == "pointer" && path[0] != "*")
        path = array_push_front(path, "*")

    i = 0
    t = var["type"]
    addr = var["addr"]
    for path_elem in path {
        // replace struct references with the actual strut
        if (t["kind"] == "struct_ref")
            t = structs[t["struct_ref"]]

        if (t["kind"] == "builtin" || t["kind"] == "enum") {
            // these can only show up at the very end of the path as the target of a dereference
            if (i < length(path) - 1 || path_elem != "*")
                error(format("Can't apply {0} to {1}", path_elem, t))
            if (t["kind"] == "builtin") return _mem_builtin(addr, t)
            else                        return _mem_builtin(addr, t["underlying_type"])
        }
        else if (t["kind"] == "pointer") {
            // a pointer can only be here as the target of a dereference
            if (path_elem != "*")
                error(format("Can't apply {0} to {1}", path_elem, type_to_str(t)))
            addr = _mem_pointer(addr)
            t = t["to"]
        }
        else if (t["kind"] == "struct") {
            if (i == length(path) - 1) {
                if (mode == _READ_MODE)           return _mem_struct_field(t, addr, path_elem, wide_ptr)
                else if (mode == _ADDRESSOF_MODE) return _addressof_struct_field(t, addr, path_elem)
                else if (mode == _TYPEOF_MODE)    return typeof_struct_field(t, path_elem)
            } else {
                field_def = t["fields"][path_elem]
                field_t = field_def["type"]
                if (field_t["kind"] == "pointer") {
                    addr = _mem_struct_field(t, addr, path_elem, 0)
                    t = field_t["to"]
                } else if (field_t["kind"] == "struct" || field_t["kind"] == "array" || field_t["kind"] == "bitflags") {
                    addr = addr + field_def["offset"]
                    t = field_t
                } else
                    error(format("Can't apply {0} to {1}", path_elem, t))
            }
        }
        else if (t["kind"] == "array") {
            if (i == length(path) - 1) {
                if (mode == _READ_MODE)           return _mem_array_entry(t, addr, path_elem, wide_ptr)
                else if (mode == _ADDRESSOF_MODE) return _addressof_array_entry(t, addr, path_elem)
                else if (mode == _TYPEOF_MODE)    return t["undelying_type"]
            } else {
                entry_t = t["underlying_type"]
                if (entry_t["kind"] == "pointer") {
                    addr = read_array_entry(t, addr, path_elem, 0)
                    t = entry_t["to"]
                } else if (entry_t["kind"] == "struct" || entry_t["kind"] == "array" || field_t["kind"] == "bitflags") {
                    addr = addr + (path_elem * _sizeof(entry_t))
                    t = entry_t
                } else
                    error(format("Can't apply {0} to {1}", path_elem, t))
            }
        }
        else if (t["kind"] == "bitflags") {
            if (i < length(path) - 1)
                error(format("Can't apply {0} to {1}", path_elem, t))
            else {
                // either get a specific flag, or get the whole thing
                if (path_elem == "*") return _mem_builtin(addr, t["underlying_type"])
                else                  return read_bitflag(t, addr, path_elem)
            }   
        }

        i = i + 1
    }
}

function mem_path(var, path) => _path(var, path, _READ_MODE, 0)

function mem_path_wide(var, path) => _path(var, path, _READ_MODE, 1)

function addressof_path(var, path) => _path(var, path, _ADDRESSOF_MODE, 0)

function typeof_path(var, path) => _path(var, path, _TYPEOF_MODE, 0)


// =================== \\
// =================== \\
//                     \\
//      T Y P E S      \\
//                     \\
// =================== \\
// =================== \\

LEVEL_ID = enum_t("LEVEL_ID", {
    "MOBILE_LAB":      0x1,
    "S2_TRIKE_RESCUE": 0x2,
    "S1_BIKE_RACE":    0x3,
    "S1_STEGOSAURUS":  0x4,
    "S3_SABOTAGE":     0x5,
    "S1":              0x6,
    "S3_RIVER_RAFT":   0x7,
    "S1_SENSORS":      0x8,
    "S1_CAVE_RESCUE":  0x9,
    "S2_TRANSPORT":    0xa,
    "S2_NEST_HUNT":    0xb,
    "S2":              0xc,
    "S3_CAVE_MAZE":    0xd,
    "S3":              0xe,
    "S4":              0xf,
    "S4_EGG_HUNT":     0x10,
    "S4_AMBER_MINE":   0x11,
    "JUNGLE_FIRE":     0x12,
    "S4_PTERANODONS":  0x13,
    "S2_TREX_ESCAPE":  0x14,
    "COUNTDOWN":       0x15,
    "END_SEQUENCE":    0x16,
    "S4_ROUGH_ROAD":   0x17,
    "S3_TREX_CHASE":   0x18,
    "ARENA":           0x19,
    "END_SEQUENCE_2":  0x1a,
    "COMBAT_MODE":     0x1b
}, word_t)

OPTIONS = struct_t("OPTIONS", {
    "two_players":           make_field(0x0, word_t),
    "music_on":              make_field(0x2, word_t),
    "co_op":                 make_field(0x4, word_t),
    "no_auto_equip_weapons": make_field(0x6, word_t),
    "control_1":             make_field(0x8, word_t),
    "password":              make_field(0xa, array_t(byte_t, 8)),
    "level_select_on":       make_field(0x12, word_t),
    "rng_seed":              make_field(0x14, word_t),
    "level_select_level_id": make_field(0x18, word_t),
    "weapon_change_btn":     make_field(0x1a, word_t),
    "fire_btn":              make_field(0x1c, word_t),
    "action_btn":            make_field(0x1e, word_t),
    "debug_mode":            make_field(0x20, word_t),
    "immortal":              make_field(0x22, word_t),
    "infinite_ammo":         make_field(0x24, word_t),
    "no_collision":          make_field(0x26, word_t),
    "red_hunter_skin":       make_field(0x28, word_t),
    "in_COMBAT_MODE":        make_field(0x2a, word_t),
    "n_soft_resets":         make_field(0x30, dword_t)
}, 0x42)

AOE_TYPE = enum_t("AOE_TYPE", {
    "TASER":         0x0,
    "BURN":          0x1,
    "EXPLOSION":     0x2,
    "FALLING_ROCKS": 0x4,
    "POISON_PLANT":  0x6,
    "GAS_GRENADE":   0x7,
    "TREX/TRIKE":    0x8
}, word_t)

WEAPON_TYPE = enum_t("WEAPON_TYPE", {
    "MINES":               0x0,
    "GRENADES":            0x1,
    "TASER":               0x3,
    "DARTS":               0x4,
    "SHOTGUN":             0x6,
    "MACHINE_GUN":         0x7,
    "MISSILES":            0x8,
    "HOMING_MISSILES":     0x9,
    "GAS":                 0xa,
    "VEHICLE_GUN":         0xb,
    "ENEMY_SINGLE":        0xc,
    "ENEMY_ANGLED_SINGLE": 0xd,
    "ENEMY_MACHINE_GUN":   0xe,
    "ENEMY_SINGLE_2":      0xf,
    "ENEMY_GRENADES":      0x10
}, word_t)

SHOT_TYPE = enum_t("SHOT_TYPE", {
    "MINE":                0x0,
    "GRENADE":             0x1,
    "BUNKER_SPREADSHOT":   0x2,
    "TASER":               0x3,
    "DART":                0x4,
    "DILOPHOSAURUS":       0x5,
    "SHOTGUN":             0x6,
    "MISSILE":             0x7,
    "MACHINE_GUN":         0x8,
    "ENEMY_ANGLED_SINGLE": 0x9,
    "GAS_GRENADE":         0xa,
    "VEHICLE_SHOT":        0xb,
    "ENEMY_SINGLE":        0xc,
    "ENEMY_MACHINE_GUN":   0xd,
    "ENEMY_GRENADE":       0xe
}, word_t)

ENTITY_TYPE = enum_t("ENTITY_TYPE", {
    "VEHICLE":              0x0,
    "PLAYER":               0x1,
    "HUNTER_TRUCK":         0x4,
    "PROJECTILE":           0x6,
    "AIR_DROP":             0x9,
    "FX_1":                 0xe,
    "TRIKE_BEACON":         0x11,
    "FX_2":                 0x12,
    "PICKUP":               0x13,
    "STEGOSAURUS":          0x14,
    "TRICERATOPS":          0x15,
    "ENEMY_HUNTER":         0x16,
    "TROODON":              0x18,
    "HUNTER_JEEP":          0x1a,
    "STEGO_CAGE_DOOR":      0x1b,
    "STEGO_CAGE_BARRIER":   0x1c,
    "DILOPHOSAURUS":        0x1d,
    "STEGO_CAGE":           0x1e,
    "ELECTRIC_BARRIER_FX":  0x1f,
    "INVISIBLE_BARRIER_2":  0x20,
    "INVISIBLE_BARRIER_3":  0x21,
    "SENSOR":               0x26,
    "VELOCIRAPTOR":         0x27,
    "ALARM_GENERATOR":      0x28,
    "ALARM":                0x29,
    "TENT":                 0x2a,
    "HUGE_CRATE":           0x2b,
    "CAMPFIRE":             0x2c,
    "BARREL":               0x2d,
    "SIGNPOST":             0x2e,
    "LEVEL_FLAGPOST":       0x2f,
    "ENV_MINE":             0x30,
    "SANDBAG":              0x31,
    "BUNKER":               0x32,
    "LAVA_FISSURE":         0x33,
    "GAS_EMITTER":          0x34,
    "FIRE":                 0x35,
    "LAVA":                 0x36,
    "DOCK_SIGNPOST":        0x37,
    "FALLING_ROCK_SPAWNER": 0x38,
    "DOCK":                 0x39,
    "CAVE_ENTRANCE":        0x3a,
    "SATCOM":               0x3b,
    "BREAKABLE_ROCK":       0x3c,
    "BREAKABLE_ROCK_2":     0x3d,
    "ELECTRIC_POST":        0x3f,
    "ELECTRIC_INV_BARRIER": 0x40,
    "GENERATOR":            0x41,
    "INVISIBLE_BARRIER":    0x43,
    "EGG_NEST":             0x47,
    "RED_HUNTER":           0x48,
    "WATER_MINE":           0x4b,
    "AMBER":                0x4c,
    "TREX_EGG":             0x4d,
    "TREX":                 0x4e,
    "CHECKPOINT":           0x50,
    "SMALL_POISON_PLANT":   0x51,
    "JURASSIC_COIN":        0x52,
    "CHASE_TREX":           0x53,
    "BREAKABLE_ROCK_3":     0x56,
    "MAP_CARD":             0x57,
    "MINE":                 0x5e,
    "CLOCK":                0x61,
    "FX_3":                 0x65,
    "ENEMY_HUNTER_2":       0x66,
    "ENEMY_HUNTER_3":       0x67,
    "CRATE":                0x69,
    "BABY_STEGOSAURUS":     0x6b,
    "ESCORTED_TRUCK":       0x6e
}, byte_t)

MOVEMENT_TYPE = enum_t("MOVEMENT_TYPE", {
    "NORMAL":                   0x0,
    "ENTERING_VEHICLE":         0x1,
    "EXITING_VEHICLE":          0x2,
    "DRIVING_VEHICLE":          0x3,
    "DRIVING_FLOATY_VEHICLE":   0x4,
    "DEAD":                     0x5,
    "EDGE_OF_SCROLLING_CAMERA": 0x7,
    "RESPAWNING":               0x8,
    "THROUGH_STEGO_CAGE":       0x9
}, word_t)

COLLISION_TYPE = enum_t("COLLISION_TYPE", {
    "BASIC_BARRIER":           0x00,
    "BASIC_OBJECT":            0x10,
    "NO_COLLISION":            0x2b,
    "ELECTRIC_BARRIER_ACTIVE": 0x50
}, byte_t)

AMMO = struct_t("AMMO", {
    "mines":           make_field(0x0, word_t),
    "grenades":        make_field(0x2, word_t),
    "machine_gun":     make_field(0xe, word_t),
    "missiles":        make_field(0x10, word_t),
    "homing_missiles": make_field(0x12, word_t),
    "gas_grenades":    make_field(0x14, word_t)
}, 0x20)

PLAYER_STATE = struct_t("PLAYER_STATE", {
    "entity":                 make_field(0x0, pointer_t(struct_ref("ENTITY"))),
    "ammo":                   make_field(0x4, pointer_t(AMMO)),
    "input":                  make_field(0x8, pointer_t(word_t)),
    "buffered_input":         make_field(0xc, pointer_t(word_t)),
    "last_movement_input":    make_field(0x10, word_t),
    "movement_change_delay":  make_field(0x12, word_t),
    "movement_type":          make_field(0x14, MOVEMENT_TYPE),
    "weapon_type":            make_field(0x16, WEAPON_TYPE),
    "pre_vehicle_hp":         make_field(0x1a, word_t),
    "respawn_base_hp":        make_field(0x1c, word_t),
    "respawn_delay":          make_field(0x1e, word_t),
    "last_boost_time":        make_field(0x20, dword_t),
    "COMBAT_MODE_n_kills":    make_field(0x28, word_t),
    "COMBAT_MODE_n_wins":     make_field(0x2a, word_t),
    "pre_vehicle_position_x": make_field(0x2c, dword_t),
    "pre_vehicle_position_y": make_field(0x30, dword_t)
}, 0x34)

ENTITY_RENDER = struct_t("ENTITY_RENDER", {
    "flags":                   make_field(0x0, word_t),
    "screen_position_x":       make_field(0x2, word_t),
    "screen_position_y":       make_field(0x4, word_t),
    "sprite_sheet":            make_field(0x6, dword_t),
    "sprite_sheet_position_i": make_field(0xa, word_t),
    "sprite_sheet_position_j": make_field(0xc, dword_t)
}, 0x10)

ENTITY_FLAGS = bitflags_t("ENTITY_FLAGS", {
    "MOVABLE":         make_bitflag(0x0, bit1_t),
    "MOVABLE_BARRIER": make_bitflag(0x0, bit2_t),
    "TARGETABLE":      make_bitflag(0x0, bit3_t),
    "VISIBLE":         make_bitflag(0x0, bit4_t),
    "IGNORE_DEPTH":    make_bitflag(0x0, bit6_t),
    "NO_COLLISION":    make_bitflag(0x0, bit7_t),
    "COLLIDING":       make_bitflag(0x1, bit0_t),
    "RENDERED":        make_bitflag(0x1, bit1_t),
    "IS_PROJECTILE":   make_bitflag(0x1, bit2_t),
    "HIT_BY_AOE":      make_bitflag(0x1, bit4_t),
    "DOCKED":          make_bitflag(0x1, bit5_t),
    "KNOCKBACK":       make_bitflag(0x1, bit6_t),
    "ACTIVE":          make_bitflag(0x1, bit7_t)
}, word_t)

ENTITY_LINKED_LIST = enum_t("ENTITY_LINKED_LIST", {
    "LIST_1":      0,
    "PROJECTILES": 1,
    "LIST_3":      2,
    "BARRIERS":    3,
    "DEBRIS":      4
}, byte_t)

ENTITY = struct_t("ENTITY", {
    "next":                        make_field(0x0, pointer_t(struct_ref("ENTITY"))),
    "render_next":                 make_field(0x4, pointer_t(struct_ref("ENTITY"))),
    "collider":                    make_field(0x8, pointer_t(struct_ref("ENTITY"))),
    "owner":                       make_field(0xc, pointer_t(struct_ref("ENTITY"))),
    "player_state":                make_field(0xc, pointer_t(PLAYER_STATE)),
    "child":                       make_field(0x10, pointer_t(struct_ref("ENTITY"))),
    "target":                      make_field(0x14, pointer_t(struct_ref("ENTITY"))),
    "update_f":                    make_field(0x18, dword_t),
    "render_f":                    make_field(0x1c, dword_t),
    "flags":                       make_field(0x24, ENTITY_FLAGS),
    "id":                          make_field(0x26, byte_t),
    "type":                        make_field(0x27, ENTITY_TYPE),
    "linked_list":                 make_field(0x28, ENTITY_LINKED_LIST),
    "position_x":                  make_field(0x36, dword_t),
    "position_y":                  make_field(0x3a, dword_t),
    "height":                      make_field(0x3e, dword_t),
    "hitbox.topleft_x":            make_field(0x42, dword_t),
    "hitbox.topleft_y":            make_field(0x46, dword_t),
    "hitbox.bottomright_x":        make_field(0x4a, dword_t),
    "hitbox.bottomright_y":        make_field(0x4e, dword_t),
    "hitbox.center_x":             make_field(0x52, dword_t),
    "hitbox.center_y":             make_field(0x56, dword_t),
    "hitbox.width":                make_field(0x5a, dword_t),
    "hitbox.height":               make_field(0x5e, dword_t),
    "screen_topleft_offset_x":     make_field(0x62, word_t),
    "screen_topleft_offset_y":     make_field(0x64, word_t),
    "knockback_speed_x":           make_field(0x66, dword_t),
    "knockback_speed_y":           make_field(0x6a, dword_t),
    "knockback_speed_height":      make_field(0x6e, dword_t),
    "knockback_deceleration_rate": make_field(0x72, word_t),
    "collision_type":              make_field(0x74, COLLISION_TYPE),
    "state":                       make_field(0x76, word_t),
    "param_1":                     make_field(0x78, word_t),
    "param_2":                     make_field(0x7a, word_t),
    "param_3":                     make_field(0x7c, word_t),
    "param_4":                     make_field(0x7e, word_t),
    "aoe_type":                    make_field(0x80, AOE_TYPE),
    "aoe_strength":                make_field(0x82, word_t),
    "last_shot_time":              make_field(0x88, dword_t),
    "param_N":                     make_field(0x8c, word_t),
    "camera_lookahead":            make_field(0x8e, dword_t),
    "movement_angle":              make_field(0x92, word_t),
    "target_facing_angle":         make_field(0x94, word_t),
    "facing_angle":                make_field(0x96, word_t),
    "vector_speed":                make_field(0x98, dword_t),
    "speed_x":                     make_field(0x9c, dword_t),
    "speed_y":                     make_field(0xa0, dword_t),
    "vertical_speed":              make_field(0xa4, dword_t),
    "main_render":                 make_field(0xa8, ENTITY_RENDER),
    "shadow_render":               make_field(0xb8, ENTITY_RENDER),
    "animation_type":              make_field(0xc8, word_t),
    "animation_end":               make_field(0xce, dword_t),
    "animation_step":              make_field(0xd2, dword_t),
    "explosion_resistance":        make_field(0xd6, word_t),
    "max_hp":                      make_field(0xd8, word_t),
    "hp":                          make_field(0xda, word_t),
    "capture_hp":                  make_field(0xdc, word_t),
    "fall_damage":                 make_field(0xde, word_t),
    "render_on_top":               make_field(0xe0, word_t),
    "weapon_type":                 make_field(0xe2, WEAPON_TYPE)
}, 0xe4)

GAME_STATE = struct_t("GAME_STATE", {
    "S2_TRIKE_RESCUE.n_rescued":             make_field(0x0, word_t),
    "S1_SENSORS.n_remaining":                make_field(0x2, word_t),
    "S1_STEGOSAURUS.n_captured":             make_field(0x4, word_t),
    "S1_STEGOSAURUS.just_captured":          make_field(0x6, word_t),
    "S3_SABOTAGE.n_satcoms_destroyed":       make_field(0xa, word_t),
    "S3_SABOTAGE.alarms_active":             make_field(0xc, word_t),
    "alarm_generator_states":                make_field(0xe, array_t(word_t, 4)),
    "generator_states":                      make_field(0x16, array_t(byte_t, 16)),
    "event_flags":                           make_field(0x26, array_t(byte_t, 10)),
    "S1_STEGOSAURUS.stegosaurus_states":     make_field(0x34, array_t(byte_t, 4)),
    "S2_TRIKE_RESCUE.triceratops_states":    make_field(0x38, array_t(byte_t, 4)),
    "huge_crate_positions":                  make_field(0x3c, array_t(word_t, 4)),
    "S2_NEST_HUNT.n_remaining":              make_field(0x44, word_t),
    "S2_NEST_HUNT.last_announced_remaining": make_field(0x46, word_t),
    "S4_AMBER_MINE.n_amber_remaining":       make_field(0x48, word_t),
    "S4_EGG_HUNT.n_collected_eggs":          make_field(0x4e, word_t),
    "n_jurassic_coins":                      make_field(0x50, word_t),
    "JUNGLE_FIRE.position_x":                make_field(0x52, dword_t),
    "JUNGLE_FIRE.speed_x":                   make_field(0x56, dword_t),
    "p1_ammo":                               make_field(0x5a, AMMO),
    "p2_ammo":                               make_field(0x7a, AMMO),
    "S1_CAVE_RESCUE.red_hunter_position_x":  make_field(0x9a, dword_t),
    "S1_CAVE_RESCUE.red_hunter_position_y":  make_field(0x9e, dword_t)
}, 0xa2)

LEVEL_FLAGS = bitflags_t("LEVEL_FLAGS", {
    "COUNTDOWN_STOPPED":    make_bitflag(0x1, bit4_t),
    "ENTER_FROM_OVERWORLD": make_bitflag(0x1, bit5_t),
    "FAILED":               make_bitflag(0x1, bit6_t),
    "COMPLETED":            make_bitflag(0x1, bit7_t)
}, word_t)

INGAME_TEXT = struct_t("INGAME_TEXT", {
    "text":          make_field(0x0, pointer_t(byte_t)),
    "texts":         make_field(0x4, pointer_t(pointer_t(byte_t))),
    "font_size":     make_field(0xe, word_t),
    "left_offset":   make_field(0x14, word_t),
    "top_offset":    make_field(0x16, word_t),
    "left_offset_2": make_field(0x18, word_t),
    "top_offset_2":  make_field(0x1a, word_t),
    "flags":         make_field(0x1c, word_t),
    "char_spacing":  make_field(0x1e, word_t),
    "delay":         make_field(0x20, word_t),
    "timeout":       make_field(0x22, word_t),
    "delay_2":       make_field(0x24, word_t),
    "timeout_2":     make_field(0x26, word_t),
    "state":         make_field(0x28, word_t)
}, 0x2c)

SCREEN_DEF = struct_t("SCREEN_DEF", {
    // reverse me if necessary
    // clearly contains data related to background, foreground, color palletes, ...
}, 0x3a)

PAUSE_SUB_MENU_DEF = struct_t("PAUSE_SUB_MENU_DEF", {
    // reverse me if necessary
}, 0x20)

DIFFICULTY = enum_t("DIFFICULTY", {
    "EASY":   0,
    "MEDIUM": 1,
    "HARD":   2
}, word_t)

VEHICLE_TYPE = enum_t("VEHICLE_TYPE", {
    "JEEP":  0,
    "TRUCK": 1,
    "BOAT":  2
}, word_t)

SOUND_FX = enum_t("SOUND_FX", {
    "PICKUP_EXPLOSION":     0x0c,
    "BAT_CRY":              0x38,
    "MACHINE_GUN_FIRE":     0x39,
    "MAP_COIN_PICKUP":      0x3c,
    "THUNDEROUS_EXPLOSION": 0xe0,
    "TREX_BITE":            0xe1,
    "BURNING":              0xe5,
    "AMBIENT_DINO_CRY":     0xe7,
    "LAVA_BURNING":         0xea,
    "SMALL_EXPLOSION":      0xed,
    "MEDIUM_EXPLOSION":     0xee,
    "REQUEST_FULFILLED":    0x8000
}, word_t)


//
//   b o s s   1
//

BLIST_ID = bitflags_t("BLIST_ID", {
    // fill if necessary
}, dword_t)

BLIST_NODE = struct_t("BLIST_NODE", {
    "previous":          make_field(0x0, pointer_t(struct_ref("BLIST_NODE"))),
    "next":              make_field(0x4, pointer_t(struct_ref("BLIST_NODE"))),
    "object":            make_field(0x8, pointer_t(struct_ref("BOBJ_HEADER"))),
    "node_on_next_list": make_field(0xc, pointer_t(struct_ref("BLIST_NODE")))
}, 0x10)

BLIST = struct_t("BLIST", {
    "head": make_field(0x0, pointer_t(BLIST_NODE)),
    "tail": make_field(0x4, pointer_t(BLIST_NODE))
}, 0x8)

BOBJ_HEADER = struct_t("BOBJ_HEADER", {
    "node":          make_field(0x0, pointer_t(BLIST_NODE)),
    "lists":         make_field(0x4, BLIST_ID),
    "to_free_node":  make_field(0x8, pointer_t(BLIST_NODE)),
    "to_free_lists": make_field(0xc, BLIST_ID),
    "obj_size":      make_field(0x10, word_t),
    "update_f":      make_field(0x12, dword_t),
    "render_f":      make_field(0x16, dword_t),
    "command_f":     make_field(0x1a, dword_t)
}, 0x1e)

BENT_COMMON = struct_t("BENT_COMMON_HEADER", {
    "header":     make_field(0x0, BOBJ_HEADER),
    "timer":      make_field(0x1e, dword_t),
    "state":      make_field(0x22, word_t),
    "far_away":   make_field(0x42, word_t),
    "position_x": make_field(0x44, dword_t)
}, 0x48)

B1_RAPTOR = struct_t("B1_RAPTOR", {
    "common":       make_field(0x0, BENT_COMMON),
    "invulnerable": make_field(0x66, word_t),
    "hp":           make_field(0x74, dword_t)
}, 0x7b)

B1_SIGHT = struct_t("B1_SIGHT", {
    "common": make_field(0x0, BENT_COMMON)
}, 0x5a)

B1_LEVEL_SCROLL = struct_t("B1_LEVEL_SCROLL", {
    "header":         make_field(0x0, BOBJ_HEADER),
    "nodes":          make_field(0x3a, pointer_t(BLIST_NODE)),
    "n_active_trees": make_field(0x3e, word_t)
}, 0xe8)

B1_PLAYER = struct_t("B1_PLAYER", {
    "common":            make_field(0x0, BENT_COMMON),
    "forwards_position": make_field(0x54, dword_t),
    "forwards_speed":    make_field(0x58, dword_t),
    "scroll":            make_field(0x5c, pointer_t(B1_LEVEL_SCROLL)),
    "hp":                make_field(0x72, dword_t)
}, 0x78)

B1_PLAYER_SHOT = struct_t("B1_PLAYER_SHOT", {
    "common": make_field(0x0, BENT_COMMON),
    "target": make_field(0x54, pointer_t(BOBJ_HEADER))
}, 0x58)

B1_DATA = struct_t("B1_DATA", {
    "raptor": make_field(0x0, pointer_t(B1_RAPTOR)),
    "sight":  make_field(0xa, pointer_t(B1_SIGHT)),
    "player": make_field(0xe, pointer_t(B1_PLAYER)),
    "sCroll": make_field(0x16, pointer_t(B1_LEVEL_SCROLL))
}, 0x1a)

B2_TREX = struct_t("B2_TREX", {
    "common": make_field(0x0, BENT_COMMON),
    "hp":     make_field(0xd0, dword_t)
}, 0x120)

B2_DATA = struct_t("B2_DATA", {
    "trex": make_field(0x4, pointer_t(B2_TREX))
}, 0x1e)

B3_PLAYER = struct_t("B3_PLAYER", {
    "common": make_field(0x0, BENT_COMMON),
    "hp":     make_field(0xa2, dword_t)
}, 0xae)

B3_DATA = struct_t("B3_DATA", {
    "player":      make_field(0x8, pointer_t(B3_PLAYER)),
    "two_players": make_field(0x1c, word_t)
}, 0x2e)

B4_PLAYER = struct_t("B4_PLAYER", {
    "common": make_field(0x0, BENT_COMMON),
    "hp":     make_field(0x54, dword_t)
}, 0xca)

B4_MISSILE = struct_t("B4_MISSILE", {
    "header": make_field(0x0, BOBJ_HEADER)
}, 0x60)


// ===================== \\
// ===================== \\
//                       \\
//      M E M O R Y      \\
//                       \\
// ===================== \\
// ===================== \\

//
//   m e m o r y   m a p
//

entities                      = make_var(array_t(ENTITY, 130), 0x0000)
cur_screen_def                = make_var(pointer_t(SCREEN_DEF), 0xa6dc)
playing_boss_level            = make_var(word_t, 0xa724)
n_lives                       = make_var(word_t, 0xa848)
difficulty                    = make_var(DIFFICULTY, 0xa84a)
sound_fx_1_request            = make_var(SOUND_FX, 0xa84c)
sound_fx_2_request            = make_var(SOUND_FX, 0xa84e)
player_state                  = make_var(PLAYER_STATE, 0xa85c)
p2_player_state               = make_var(PLAYER_STATE, 0xa892)
level_id                      = make_var(LEVEL_ID, 0xa8e4)
ingame_text_mode              = make_var(word_t, 0xa91e)
level_completed_delay         = make_var(word_t, 0xa92a)
level_flags                   = make_var(LEVEL_FLAGS, 0xa9d6)
level_update_f                = make_var(pointer_t(byte_t), 0xa9da)
options_ptr                   = make_var(pointer_t(OPTIONS), 0xa9ee)  // seems to always point at the static options
ingame_timer                  = make_var(dword_t, 0xa9f2)
pause_sub_menu                = make_var(pointer_t(PAUSE_SUB_MENU_DEF), 0xab64)
prev_pause_sub_menu           = make_var(pointer_t(PAUSE_SUB_MENU_DEF), 0xab68)
red_hunter_entity_ptr         = make_var(pointer_t(ENTITY), 0xadc4)
secret_pwd_text_decode_buffer = make_var(array_t(byte_t, 32), 0xaedc)  // 32 is just a guess
ingame_text                   = make_var(INGAME_TEXT, 0xafdc)
scrolling_camera_entity       = make_var(pointer_t(ENTITY), 0xadec)
entities_1                    = make_var(pointer_t(ENTITY), 0xb014)
projectile_entities           = make_var(pointer_t(ENTITY), 0xb018)
entities_3                    = make_var(pointer_t(ENTITY), 0xb01c)
barrier_entities              = make_var(pointer_t(ENTITY), 0xb020)
debris_entities               = make_var(pointer_t(ENTITY), 0xb024)
zombie_entities               = make_var(pointer_t(ENTITY), 0xb028)
n_rendered_entities           = make_var(word_t, 0xb02c)
mid_render_entities           = make_var(pointer_t(ENTITY), 0xb02e)
front_render_entities         = make_var(pointer_t(ENTITY), 0xb032)
back_render_entities          = make_var(pointer_t(ENTITY), 0xb036)
spawn_flags                   = make_var(array_t(byte_t, 320), 0xbf42)
incapacitated_trike_state     = make_var(word_t, 0xc1d2)
game_state                    = make_var(GAME_STATE, 0xc1da)
free_entities                 = make_var(pointer_t(ENTITY), 0xc66c)
boss_object_lists             = make_var(pointer_t(array_t(BLIST, 13)), 0xcf28)
boss3_data                    = make_var(pointer_t(B3_DATA), 0xcfbc)
boss4_player                  = make_var(pointer_t(B4_PLAYER), 0xd024)
boss1_data                    = make_var(pointer_t(B1_DATA), 0xd0d0)
boss2_data                    = make_var(pointer_t(B2_DATA), 0xd100)
options                       = make_var(OPTIONS, 0xfe02)

// -- stack -- //

return_address_to_run_level = make_var(pointer_t(byte_t), 0xfd90)

//
//   g a m e   m o d e
//

screens = {
    "Jungle Levels 1": 0x002b7ee8,
    "Jungle Levels 2": 0x002ebde0,
    "Caves":           0x0033cf40,
    "Scroller Levels": 0x003297cc,
    "Jungle Levels 3": 0x0037d698,
    "T-Rexes":         0x002958ac,
    "Ending":          0x002a49f4,
    "Press Start":     0x002a03e0,
    "Pause":           0x0029bc24,
    "Intro Text":      0x002ab53c,
    "Intro Chopter 2": 0x002ae3bc,
    "Sega Splash":     0x002a2808,
    "Dev Splashes":    0x0029ed28,
    "All Black":       0x003fbc20
}

function in_screen(name) =>
    mem_wide(cur_screen_def) == pdp11(screens[name])

function mk_level_meta(name, init_f, update_f, intro_text) =>
    {"name": name, "init_f": init_f, "update_f": update_f, "intro_text": intro_text}

level_meta = {
    "MOBILE_LAB":      mk_level_meta("Mobile Lab",           0x003bc62c, 0x003bc7de, 0x003bc621),
    "S2_TRIKE_RESCUE": mk_level_meta("Trike Rescue",         0x003bc86c, 0x003bca20, 0x003bc85f),
    "S1_BIKE_RACE":    mk_level_meta("Bike Race",            0x003be27c, 0x003be358, 0x00000000),
    "S1_STEGOSAURUS":  mk_level_meta("Stegos Abduction",     0x003bccae, 0x003bceb6, 0x003bcc9d),
    "S3_SABOTAGE":     mk_level_meta("Hunter Camp Sabotage", 0x003bd026, 0x003bd222, 0x003bd017),
    "S1":              mk_level_meta("Isla Sorna Site 1",    0x003bd2b8, 0x003bd518, 0x003bd2a5),
    "S3_RIVER_RAFT":   mk_level_meta("River Raft Battle",    0x003be43e, 0x003be51a, 0x00000000),
    "S1_SENSORS":      mk_level_meta("Activate Sensors",     0x003bd58a, 0x003bd73c, 0x003bd578),
    "S1_CAVE_RESCUE":  mk_level_meta("Cave Rescue",          0x003d151a, 0x003d16b4, 0x003d150d),
    "S2_TRANSPORT":    mk_level_meta("Defend Transport",     0x003d2146, 0x003d231a, 0x003d2134),
    "S2_NEST_HUNT":    mk_level_meta("Raptor Nest Hunt",     0x003d4b32, 0x003d4cf6, 0x003d4b28),
    "S2":              mk_level_meta("Isla Sorna Site 2",    0x003bd7f6, 0x003bda50, 0x003bd7e3),
    "S3_CAVE_MAZE":    mk_level_meta("Cave Maze",            0x003d50f4, 0x003d5282, 0x003d50e9),
    "S3":              mk_level_meta("Isla Sorna Site 3",    0x003bdabe, 0x003bdd18, 0x003bdaab),
    "S4":              mk_level_meta("Isla Sorna Site 4",    0x003bdd86, 0x003bdfe0, 0x003bdd73),
    "S4_EGG_HUNT":     mk_level_meta("Egg Hunt",             0x003be04a, 0x003be1ce, 0x003be040),
    "S4_AMBER_MINE":   mk_level_meta("Amber Mine",           0x003d5732, 0x003d58e0, 0x003d5726),
    "JUNGLE_FIRE":     mk_level_meta("Jungle Firestorm",     0x003d5e20, 0x003d6138, 0x003d5e0f),
    "S4_PTERANODONS":  mk_level_meta("Pteranodon Attack",    0x003be52a, 0x003be5dc, 0x00000000),
    "S2_TREX_ESCAPE":  mk_level_meta("T-Rex Escape",         0x003be364, 0x003be434, 0x00000000),
    "COUNTDOWN":       mk_level_meta("The Final Countdown",  0x003be884, 0x003bea24, 0x003be874),
    "END_SEQUENCE":    mk_level_meta("End Sequence",         0x003beda2, 0x003bedbc, 0x00000000),
    "S4_ROUGH_ROAD":   mk_level_meta("Rough Road",           0x003be5f0, 0x003be7a2, 0x003be5e5),
    "S3_TREX_CHASE":   mk_level_meta("T-Rex Chase",          0x003d6924, 0x003d6c0a, 0x003d6917),
    "ARENA":           mk_level_meta("Arena",                0x003beb24, 0x003bec88, 0x00000000),
    "END_SEQUENCE_2":  mk_level_meta("End Sequence",         0x003beda2, 0x003bedbc, 0x00000000),
    "COMBAT_MODE":     mk_level_meta("Combat Arena",         0x003bf0f0, 0x003bf280, 0x00000000)
}

levels_with_completion_delay = ["MOBILE_LAB", "S4_ROUGH_ROAD"]

// When a level is completed, the global level_id is set to the next level, possibly
// even before the password screen (looking at you boss levels). Using the level-specific
// init or update functions to identify the current level bypasses this problem, as
// those only change when a new level is loaded.

function in_a_level() =>
    // Even though the run_level loop doesn't reset level_update_f upon breaking, checking it alone
    // works fine for the vast majority of cases, because the only way to return to the main menu
    // is through a soft reset initiated by either the game or the player. In some corner cases,
    // such as exiting the ARENA with START, the run_level loop is exited by setting the level_id
    // to a negative level, thus the extra check.
    !is_negative(var_type(level_id), mem(level_id))
    && mem_wide(level_update_f) != 0

function in_level(level) =>
    !is_negative(var_type(level_id), mem(level_id))
    && mem_wide(level_update_f) == pdp11(level_meta[level]["update_f"])

function never_not_in_level(level) =>
    never(is_negative(var_type(level_id), mem(level_id)))
    && never(mem_wide(level_update_f) != pdp11(level_meta[level]["update_f"]))

function in_a_boss_level() {
    // no alts trick: the update functions for the boss levels are contiguous in relation to those
    // of the other levels. note also that due to PDP-11 endianness we have to handle the 2 16-bit
    // parts of the pointer separately to apply the range check
    return in_a_level()
           && mem(make_var(word_t, var_addr(level_update_f))) == 0x003b
           && mem(make_var(word_t, var_addr(level_update_f) + 2)) >= 0xe358
           && mem(make_var(word_t, var_addr(level_update_f) + 2)) <= 0xe5dc
}

post_boss_level = {
    "S1_BIKE_RACE":   "S2",
    "S2_TREX_ESCAPE": "S3",
    "S3_RIVER_RAFT":  "S4",
    "S4_PTERANODONS": "JUNGLE_FIRE",
}

function completed_boss_level(level) {
    // S4_PTERANODONS doesn't have a password screen, so we consider it completed on the single
    // frame in which the level id changes to FIRE_STORM
    if (level == "S4_PTERANODONS")
        return mem_changed_from_to(mem(level_id), enum_value(LEVEL_ID, "S4_PTERANODONS"), enum_value(LEVEL_ID, "JUNGLE_FIRE"))

    // leverages the fact that, for boss levels only, the level id changes before the password screen is shown
    return in_level(level)
           && mem(level_id) == enum_value(LEVEL_ID, post_boss_level[level])
}

function completed_a_boss_level() {
    cond = always_false()
    for boss_level in post_boss_level
        cond = cond || completed_boss_level(boss_level)
    return cond
}

function in_a_normal_level() {
    blacklist = []
    for level in ["S1_BIKE_RACE", "S2_TREX_ESCAPE", "S3_RIVER_RAFT", "S4_PTERANODONS",
                  "END_SEQUENCE", "END_SEQUENCE_2", "ARENA", "COMBAT_MODE"]
        array_push(blacklist, pdp11(level_meta[level]["update_f"]))

    // no alts trick: blacklist non-normal levels, instead whitelisting the normal ones
    return in_a_level()
          && !mem_in(mem_wide(level_update_f), blacklist)
}

function completed_a_normal_level(with_delay) {
    cond = in_a_normal_level()
           && mem_path(level_flags, ["COMPLETED"]) == 1
    if (with_delay != false)
        cond = cond && mem(level_completed_delay) == 0
    return cond
}

function completed_normal_level(level) =>
    in_level(level)
    && completed_a_normal_level(in(level, levels_with_completion_delay))

function playing_a_normal_level(with_delay) {
    cond = in_a_normal_level()
    if (with_delay != false)
        cond = cond && mem(level_completed_delay) > 0  // delay is set on level init and stays non-zero until completion
    else
        cond = cond && mem_path(level_flags, ["COMPLETED"]) == 0
    return cond
}

function playing_normal_level(level) =>
    in_level(level)
    && playing_a_normal_level(in(level, levels_with_completion_delay))

function just_started_normal_level(level) =>
    started_displaying_ingame_text(level_meta[level]["name"])

function started_boss() =>
    mem_changed_from_to(mem(playing_boss_level), 0, 1)


//
//   p a u s e   m e n u
//

pause_sub_menus = {
    "Main":                   0x00004920,
    "Messages (S3_SABOTAGE)": 0x00004c00,
    "Support":                0x00004a20
}

function pause_sub_menu_changed(from, to) =>
    mem_changed_from_to(mem_wide(pause_sub_menu), pdp11(pause_sub_menus[from]), pdp11(pause_sub_menus[to]))


//
//   m i s c e l l a n e o u s
//

ingame_text_strings = {
    // red hunter
    "ouch!":                0x003f0752,
    "quit it!":             0x003f0758,
    "stop that!":           0x003f0761,
    "hey, don't shoot me!": 0x003f076c,

    // level intros
    "Mobile Lab":           0x003bc621,
    "Trike Rescue":         0x003bc85f,
    "Stegos Abduction":     0x003bcc9d,
    "Hunter Camp Sabotage": 0x003bd017,
    "Isla Sorna Site 1":    0x003bd2a5,
    "Activate Sensors":     0x003bd578,
    "Cave Rescue":          0x003d150d,
    "Defend Transport":     0x003d2134,
    "Raptor Nest Hunt":     0x003d4b28,
    "Isla Sorna Site 2":    0x003bd7e3,
    "Cave Maze":            0x003d50e9,
    "Isla Sorna Site 3":    0x003bdaab,
    "Isla Sorna Site 4":    0x003bdd73,
    "Egg Hunt":             0x003be040,
    "Amber Mine":           0x003d5726,
    "Jungle Firestorm":     0x003d5e0f,
    "The Final Countdown":  0x003be874,
    "Rough Road":           0x003be5e5,
    "T-Rex Chase":          0x003d6917
}

function displaying_ingame_text(str) =>
    mem(ingame_text_mode) != 0
    && mem_path_wide(ingame_text, ["text"]) == pdp11(ingame_text_strings[str])

function started_displaying_ingame_text(str) =>
    mem_changed_from(mem(ingame_text_mode), 0)
    && mem_path_wide(ingame_text, ["text"]) == pdp11(ingame_text_strings[str])

//
//   e n t i t i e s
//

function no_active_entities() =>
    mem_wide(entities_1) == 0
    && mem_wide(projectile_entities) == 0
    && mem_wide(entities_3) == 0
    && mem_wide(barrier_entities) == 0
    && mem_wide(debris_entities) == 0
    && mem_wide(zombie_entities) == 0

function mk_entity_meta(type, group, update_f) =>
    {"type": enum_value(ENTITY_TYPE, type), "group": group, "update_f": update_f}

function entity_update_f(entity_name) => entity_meta[entity_name]["update_f"]
function entity_state_update_f(entity_name, state_name) => entity_meta[entity_name]["update_f"][state_name]

entity_meta = {
    "Supply Drop":       mk_entity_meta("AIR_DROP",          0, 0x003e8ff8),
    "Dilophosaurus":     mk_entity_meta("DILOPHOSAURUS",     0, {"Alive": 0x003e6e7c, "Dead": 0x003e6d48}),
    "Hunter":            mk_entity_meta("ENEMY_HUNTER",      0, {"Alive": 0x003e5774, "Dead": 0x003e55fa}),
    "Hunter Truck":      mk_entity_meta("HUNTER_TRUCK",      0, 0x003e7d76),
    "Invisible Barrier": mk_entity_meta("INVISIBLE_BARRIER", 6, 0x003ba40e),
    "Fire":              mk_entity_meta("FIRE",              2, 0x003d4054),
    "Map Card":          mk_entity_meta("MAP_CARD",          0, 0x003ec398),
    "Red Hunter":        mk_entity_meta("RED_HUNTER",        2, 0x003d423a),
    "Troodon":           mk_entity_meta("TROODON",           0, {"Alive": 0x003e2254, "Dead": 0x003e2118}),
    "Jeep":              mk_entity_meta("VEHICLE",           0, 0x003caff0),
    "Triceratops":       mk_entity_meta("TRICERATOPS",       0, {"Alive": 0x003e4e4c, "Dead": 0x003e4c7c}),
    "T-Rex":             mk_entity_meta("TREX",              0, {"Alive": 0x003eb0c2, "Dead": 0x003eafae}),
    "Velociraptor":      mk_entity_meta("VELOCIRAPTOR",      0, {"Alive": 0x003d0ae2, "Dead": 0x003d131c}),
}

function entity_is_active(ent) =>
    mem_path(ent, ["flags"]) != 0xffff
    && mem_path(ent, ["flags", "ACTIVE"]) == 1

function entity_is_visible(entity) =>
    mem_path(entity, ["screen_topleft_offset_x"]) < 0x140
    && mem_path(entity, ["screen_topleft_offset_y"]) < 0x100

function entity_distance_from_player_le(entity, max_x_dist_hi, max_y_dist_hi) {
    pos_x_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_x"])))
    pos_y_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_y"])))

    ent_pos_x_hi = mem(cast_var(word_t, addressof_path(entity, ["position_x"])))
    ent_pos_y_hi = mem(cast_var(word_t, addressof_path(entity, ["position_y"])))

    return ent_pos_x_hi - pos_x_hi >= (-1 * max_x_dist_hi)
           && ent_pos_x_hi - pos_x_hi <= max_x_dist_hi
           && ent_pos_y_hi - pos_y_hi >= (-1 * max_y_dist_hi)
           && ent_pos_y_hi - pos_y_hi <= max_y_dist_hi
}

function entity_died(entity) =>
    is_positive(typeof_struct_field(ENTITY, "hp"), prev(mem_path(entity, ["hp"])))
    && is_negative(typeof_struct_field(ENTITY, "hp"), mem_path(entity, ["hp"]) - 1)

//
//   l e v e l   e n t i t i e s
//
//   Entities that are spawned statically have a unique id. When they spawn, a corresponding bit
//   is set in the spawned_flags array, determined by the entity's group and id. If the entity
//   despawns due to the player moving away, the bit is unset, and the entity will respawn if
//   the player comes back. On the other hand, if the entity deactivates due to other reasons,
//   such as being collected or destroyed, the bit remains set and it won't respawn anymore.
//

function mk_level_entity(name, id) => {"name": name, "id": id}

level_entities = {
    "MOBILE_LAB": {
        "Map Card": mk_level_entity("Map Card", 0x04)
    },
    "S1_SENSORS": {
        "Map Card": mk_level_entity("Map Card", 0x38)
    },
    "S4_EGG_HUNT": {
        "First T-Rex":       mk_level_entity("T-Rex",       0x67),
        "First Triceratops": mk_level_entity("Triceratops", 0x64)
    },
    "S4_ROUGH_ROAD": {
        "Captive Dilophosaurus": mk_level_entity("Dilophosaurus", 0x1e),
        "Captive Velociraptor":  mk_level_entity("Velociraptor",  0x44)
    },
    "S4_AMBER_MINE": {
        "Trapped Jeep":        mk_level_entity("Jeep", 0x59),
        "Jeep Trap Barrier 1": mk_level_entity("Invisible Barrier", 0x37),
        "Jeep Trap Barrier 2": mk_level_entity("Invisible Barrier", 0x39)
    }
}

function mk_level_entity_group(entity_name, ids) {
    group_entities = []
    for id in ids
        array_push(group_entities, mk_level_entity(entity_name, id))
    return group_entities
}

level_entity_groups = {
    "S2_NEST_HUNT": {
        "Fires": mk_level_entity_group("Fire", [0x39, 0x3a, 0x3c, 0x3d, 0x3f, 0x40, 0x42, 0x43, 0x44, 0x47, 0x48, 0x4e, 0x4f, 0x54, 0x55])
    },
    "S3_SABOTAGE": {
        "Campfires":     mk_level_entity_group("Campfire",     [0x0a, 0x36, 0x62]),
        "Hunter Trucks": mk_level_entity_group("Hunter Truck", [0x0c, 0x5d, 0x5e, 0x6a])
    }
}

function level_entity_id(level, name) =>
    level_entities[level][name]["id"]

function entity_spawn_flag_bit(id) => bit_n_t(id % 8)
function entity_spawn_flag_offset(group, id) => byte_swap_2((group * 0x20) + (id / 8))

function _level_entity_spawned_or_gone(ent) {
    ent_meta = entity_meta[ent["name"]]
    bit_t = entity_spawn_flag_bit(ent["id"])
    offset = entity_spawn_flag_offset(ent_meta["group"], ent["id"])
    return mem_path(cast_var(array_t(bit_t, 320), spawn_flags), [offset]) == 1
}

function level_entity_spawned_or_gone(level, name) =>
    _level_entity_spawned_or_gone(level_entities[level][name])

function level_entity_group_spawned_or_gone(level, name) {
    cond = always_true()
    for level_ent in level_entity_groups[level][name]
        cond = cond && _level_entity_spawned_or_gone(level_ent)
    return cond
}

//
//   e n t i t y - s p e c i f i c
//

function is_enemy_entity(alt, ent) {
    // the lengths we go through to minimize alts...
    //
    // by combining multiple entity properties, we can select enemy entities without
    // having to OR all their types. entities marked with (!!!) can't be excluded by
    // these properties, so they must be excluded explicitly or using some other
    // trick. including the t-rex is the hardest one, because there are many (!!!)
    // between it and the other types of enemies, but most levels don't even have
    // t-rexes, so it can be ignored most of the time.
    //
    //                       type  list      targetable  excluded?
    //                       ----  ----      ----------  -----------------
    // * STEGOSAURUS         0x14  ll_1      yes         no
    // * TRICERATOPS         0x15  ll_1      yes         no
    // * ENEMY_HUNTER        0x16  ll_1      yes         no
    //   ---                 0x17  --        --          yes (!exists)
    // * TROODON             0x18  ll_1      yes         no
    //   ---                 0x19  --        --          yes (!exists)
    // * HUNTER_JEEP         0x1a  ll_1      yes         no
    //   STEGO_CAGE_DOOR     0x1b  debris    --          yes (list)
    //   STEGO_CAGE_BARRIER  0x1c  barriers  --          yes (list)
    // * DILOPHOSAURUS       0x1d  ll_1      yes         no
    //   ---                 0x1e  --        --          yes (!exists)
    //   ---                 0x1f  --        --          yes (!exists)
    //   <inv barriers> 0x20-0x25  barriers  --          yes (list)
    //   SENSOR              0x26  ll_1      no          yes (!targetable)
    // * VELOCIRAPTOR        0x27  ll_1      yes         no
    //   ALARM_GENERATOR     0x28  ll_1      yes         no                  (!!!)
    //   ALARM               0x29  debris    --          yes (list)
    //   TENT                0x2a  ll_1      no          yes (!targetable)
    //   HUGE_CRATE          0x2b  ll_1      no          yes (!targetable)
    //   CAMPFIRE            0x2c  ll_1      no          yes (!targetable)
    //   BARREL              0x2d  ll_1      no          yes (!targetable)
    //   SIGNPOST            0x2e  ll_1      no          yes (!targetable)
    //   LEVEL_FLAGPOST      0x2f  ll_1      no          yes (!targetable)
    //   ENV_MINE            0x30  ll_3      no          yes (!targetable)
    //   SANDBAGS            0x31  ll_1      no          yes (!targetable)
    // * BUNKER              0x32  ll_1      yes         no
    //   LAVA_FISSURE        0x33  ll_3      no          yes (!targetable)
    //   GAS_EMITTER         0x34  ll_3      no          yes (!targetable)
    //   FIRE                0x35  ll_3      no          yes (!targetable)
    //   LAVA                0x36  ll_3      no          yes (!targetable)
    //   DOCK_SIGNPOST       0x37  ll_1      no          yes (!targetable)
    //   FALL_ROCK_SPAWNER   0x38  ll_3      no          yes (!targetable)
    //   DOCK                0x39  barriers  --          yes (list)
    //   CAVE_ENTRANCE       0x3a  debris    --          yes (list)
    //   SATCOM              0x3b  ll_1      no          yes (!targetable)
    //   BREAKABLE_ROCK      0x3c  ll_3      yes         no                  (!!!)
    //   BREAKABLE_ROCK_2    0x3d  ll_3      yes         no                  (!!!)
    //   TRUCK_CHECKPOINT    0x3e  ll_1      no          yes (!targetable)
    //   ELECTRIC_POST       0x3f  ll_1      no          yes (!targetable)
    //   ELEC_INV_BARRIER    0x40  barriers  --          yes (list)
    //   GENERATOR           0x41  ll_1      yes         no                  (!!!)
    //   <inv barriers> 0x42-0x45  barriers  --          yes (list)
    //   ---                 0x46  --        --          yes (!exists)
    //   EGG_NEST            0x47  ll_1      no          yes (!targetable)
    //   RED_HUNTER          0x48  ll_3      yes         no                  (!!!)
    //                       0x49  ll_3      no          yes (!targetable)
    //                       0x4a  debris    --          yes (list)
    //   WATER_MINE          0x4b  ll_1      yes         no                  (!!!)
    //   AMBER               0x4c  ll_1      no          yes (!targetable)
    //   TREX_EGG            0x4d  ll_1      no          yes (!targetable)
    // * TREX                0x4e  ll_1      yes         no

    common = mem_path(ent, ["type"]) >= enum_value(ENTITY_TYPE, "STEGOSAURUS")
             && mem_path(ent, ["linked_list"]) != enum_value(ENTITY_LINKED_LIST, "BARRIERS")
             && mem_path(ent, ["linked_list"]) != enum_value(ENTITY_LINKED_LIST, "DEBRIS")
             && mem_path(ent, ["flags", "TARGETABLE"]) == 1

    // for levels with no t-rexes. no alts required
    if (alt == "NO_TREX")
        return common
               && mem_path(ent, ["type"]) <= enum_value(ENTITY_TYPE, "BUNKER")
               && mem_path(ent, ["type"]) != enum_value(ENTITY_TYPE, "ALARM_GENERATOR")

    // for t-rex only
    if (alt == "TREX")
        return mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TREX")

    // specifically for S4_EGG_HUNT. no alts required
    if (alt == "EGG_HUNT") {
        // note: BREAKABLE_ROCK, BREAKABLE_ROCK_2, GENERATOR and RED_HUNTER are excluded
        // due to not being present in S4_EGG_HUNT
        return common
               && mem_path(ent, ["type"]) <= enum_value(ENTITY_TYPE, "TREX")
               && mem_path(ent, ["type"]) != enum_value(ENTITY_TYPE, "ALARM_GENERATOR")
               && mem_path(ent, ["type"]) != enum_value(ENTITY_TYPE, "WATER_MINE")
    }
}

function is_lethal_projectile(ent) =>
    mem_path(ent, ["flags", "IS_PROJECTILE"]) == 1
    && mem_path(ent, ["param_N"]) != enum_value(SHOT_TYPE, "DART")
    && mem_path_wide(ent, ["owner"]) == mem_path_wide(player_state, ["entity"])


//
//   b o s s   l e v e l   e n t i t i e s
//

nop_command = 0x0003a098

function mk_boss_entity(command_f, update_fs) =>
    {"command_f": command_f, "update_fs": update_fs}

boss_entities = {
    "B1 Raptor":      mk_boss_entity(0x0005878e,  {"Running": 0x00057adc, "Damaged": 0x000584f2}),
    "B1 Player Shot": mk_boss_entity(0x00058b74,  {}),
    "B2 T-Rex":       mk_boss_entity(0x0005cbde,  {"Headbanging": 0x0005b622, "Head Drop": 0x0005b872}),
    "B4 Missile":     mk_boss_entity(nop_command, {"Player": 0x000532cc, "Enemy": 0x05346c})
}

function boss_entity_command_f(name) =>
    boss_entities[name]["command_f"]

function boss_entity_update_f(name, state) =>
    boss_entities[name]["update_fs"][state]


//
//   c h e a t   p r o t e c t i o n
//

function cheat_protection() =>
    mem_path(options, ["two_players"]) == 0
    && mem_path(options, ["immortal"]) == 0
    && mem_path(options, ["infinite_ammo"]) == 0
    && mem_path(options, ["no_collision"]) == 0
    // level select is allowed :)

function boss_cheat_protection() =>
    mem_path(options, ["two_players"]) == 0


// ================================= \\
// ================================= \\
//                                   \\
//      A C H I E V E M E N T S      \\
//                                   \\
// ================================= \\
// ================================= \\

function _pacifist_achievement_trigger(level, alt) {
    no_lethal_damage = always_true()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        no_lethal_damage = no_lethal_damage
            // enemy hit by a player projectile.
            // handles indirect explosion damage, but can be "fooled" if the enemy collides with anything else on the same frame.
            // also handles vehicle shots, because the vehicle entity becomes the current player entity.
            && never(entity_is_active(ent)
                     && is_enemy_entity(alt, ent)
                     && mem_path(ent, ["flags", "COLLIDING"]) == 1
                     && is_lethal_projectile(addressof_path(ent, ["collider"])))

            // a player projectile hit an enemy.
            // can't handle indirect damage, but is harder to "fool" due to multiple collision on the same frame.
            // disabled until it proves necessary: there's really no easy way to exploit the multiple-collisions-on-the-same-frame
            // issue consistently enough to get through the whole level with it
            // && never(entity_is_active(ent)
            //          && _is_lethal_projectile(ent)
            //          && mem_path(ent, ["flags", "COLLIDING"]) == 1
            //          && _is_enemy_entity(alt_n, addressof_path(ent, ["collider"]))
            // )

            // enemy hit by gas grenade aoe damage
            && never(entity_is_active(ent)
                     && is_enemy_entity(alt, ent)
                     && mem_path(ent, ["flags", "HIT_BY_AOE"]) == 1
                     && mem_path(ent, ["aoe_type"]) == enum_value(AOE_TYPE, "GAS_GRENADE"))
    }

    // player vehicle collision damage on enemy
    if (alt != "EGG_HUNT") {
        no_lethal_damage = no_lethal_damage
            && never(entity_is_active(addressof_path(player_state, ["entity"]))
                     && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "VEHICLE")

                     // sometimes the damage doesnt happen until the frame after the collision
                     && (prev(mem_path(player_state, ["entity", "flags", "COLLIDING"]))
                         + mem_path(player_state, ["entity", "flags", "COLLIDING"])) >= 1
                     && !mem_changed(mem_path(player_state, ["entity", "collider"]))

                     // collision damage is only appled to LIST_1 entities.
                     // in addition, it only occurs if the vehicle is going at a certain speed and direction.
                     // because we're using the collider pointer, we can't compare the current and previous hp values of the enemy
                     // to know whether it was damaged by the collision. instead, we look at whether the enemy was knocked back,
                     // which only occurs if the collision caused damage
                     && is_enemy_entity(alt, addressof_path(player_state, ["entity", "collider"]))
                     && mem_path(player_state, ["entity", "collider", "linked_list"]) == enum_value(ENTITY_LINKED_LIST, "LIST_1")
                     && mem_path(player_state, ["entity", "collider", "flags", "KNOCKBACK"]) == 1)
    }

    return cheat_protection()
           && never_not_in_level(level)
           && once(just_started_normal_level(level))
           && never(mem_path(level_flags, ["FAILED"]) == 1)  // no continues
           && no_lethal_damage
           && completed_normal_level(level)
}


//
//   M o b i l e   L a b
//

function _mobile_lab_pacifist_achievement() {
    achievement(
        id=140494,
        badge="156222",
        title="Introduction to the Pacifist Life",
        description="[Mobile Lab] Complete the level using only the Taser or Tranquilizer Darts to damage enemies, without using continues",
        points=5,
        trigger=_pacifist_achievement_trigger("MOBILE_LAB", "NO_TREX")
    )
}


//
//   C a v e   R e s c u e
//

function _friendly_fire_off_achievement() {
    achievement(
        id=140495,
        badge="156223",
        title="Friendly Fire Off",
        description="[Cave Rescue] Listen to all the complaints of the rescued Red Hunter",
        points=2,
        trigger=cheat_protection()
                && in_level("S1_CAVE_RESCUE")
                && once(displaying_ingame_text("ouch!"))
                && once(displaying_ingame_text("quit it!"))
                && once(displaying_ingame_text("stop that!"))
                && once(displaying_ingame_text("hey, don't shoot me!"))
    )
}

function _save_yourself_achievement() {
    achievement(
        id=140496,
        badge="156224",
        title="How a Real Red Hunter Does It",
        description="[Cave Rescue] Complete the level while wearing the Red Hunter skin and in under 5:15 minutes (tap C twice for a nice boost!)",
        points=10,
        trigger=cheat_protection()
                && never_not_in_level("S1_CAVE_RESCUE")
                && once(just_started_normal_level("S1_CAVE_RESCUE"))

                // no timer while paused
                && unless(in_screen("Pause"))
                // reset when the time cutoff is reached
                && never(once(just_started_normal_level("S1_CAVE_RESCUE"))
                         && repeated(time_to_60fps(5, 15) + 1, always_true()))

                // must wear the skin
                && mem_path(options, ["red_hunter_skin"]) == 1

                && completed_normal_level("S1_CAVE_RESCUE")
    )
}

function _cave_rescue_pacifist_achievement() {
    achievement(
        id=140497,
        badge="156225",
        title="Peaceful Cave",
        description="[Cave Rescue] Complete the level using only the Taser or Tranquilizer Darts to damage enemies, without using continues",
        points=5,
        trigger=_pacifist_achievement_trigger("S1_CAVE_RESCUE", "NO_TREX")
    )
}


//
//   A c t i v a t e   S e n s o r s
//

function _cartographer_achievement() {
    achievement(
        id=140498,
        badge="156226",
        title="Cartographer",
        description="[Activate Sensors] Complete the level without picking up the Map Card",
        points=5,
        trigger=cheat_protection()
                && completed_normal_level("S1_SENSORS")
                && !level_entity_spawned_or_gone("S1_SENSORS", "Map Card")
    )
}


//
//   S t e g o s   A b d u c t i o n
//

function _stegos_achievement() {
    never_hit_cond = always_true()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        never_hit_cond = never_hit_cond
            // reset if a stegosaurus is hit with a projectile shot by the player...
            && never(entity_is_active(ent)
                     && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "STEGOSAURUS")
                     && mem_path(ent, ["flags", "COLLIDING"]) == 1
                     && mem_path(ent, ["collider", "flags", "IS_PROJECTILE"]) == 1
                     && mem_path_wide(ent, ["collider", "owner"]) == mem_path_wide(player_state, ["entity"]))
            // ... or hit by the taser
            && never(entity_is_active(ent)
                     && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "STEGOSAURUS")
                     && mem_path(ent, ["flags", "HIT_BY_AOE"]) == 1
                     && mem_path(ent, ["aoe_type"]) == enum_value(AOE_TYPE, "TASER"))
    }

    achievement(
        id=140499,
        badge="156227",
        title="Lock Eyes From Across the Room",
        description="[Stegos Abduction] Complete the level without using any weapons on the Stegosauruses",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S1_STEGOSAURUS")
                && once(just_started_normal_level("S1_STEGOSAURUS"))
                && never_hit_cond
                && completed_normal_level("S1_STEGOSAURUS")
    )
}


//
//   N e s t   H u n t
//

function _nest_extinction_achievement() {
    raptors_present_tally = []
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        array_push(raptors_present_tally,
            mem_changed_by(mem_path(game_state, ["S2_NEST_HUNT.n_remaining"]), -1)
            && entity_is_active(ent)
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "VELOCIRAPTOR")
            && mem_path(ent, ["update_f"]) == pdp11(entity_state_update_f("Velociraptor", "Alive"))
            && entity_is_visible(ent))
    }

    achievement(
        id=140501,
        badge="156228",
        title="Make Sure They Know They're Extinct",
        description="[Raptor Nest Hunt] Force at least 5 live Velociraptors to witness the destruction of a nest (not necessarily the same one)",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S2_NEST_HUNT")
                && tally(5, raptors_present_tally)
    )
}

function _this_is_fine_achievement() {
    never_extinguished_fire = always_true()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        never_extinguished_fire = never_extinguished_fire
            && never(entity_is_active(ent)
                     && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "FIRE")
                     && mem_changed_from_to(mem_path(ent, ["state"]), 1, 2))  // 1 = burning, 2 = hit by gas grenade
    }

    achievement(
        id=140502,
        badge="156229",
        title="This Is Fine",
        description="[Raptor Nest Hunt] Complete the level without extinguishing any fires or using continues",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S2_NEST_HUNT")
                && once(just_started_normal_level("S2_NEST_HUNT"))
                && never_extinguished_fire
                && never(mem_path(level_flags, ["FAILED"]) == 1)
                && completed_normal_level("S2_NEST_HUNT")
    )
}


//
//   T r a n s p o r t
//

function _bipolar_achievement() {
    truck = scrolling_camera_entity

    missile_hits = []
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        array_push(missile_hits,
            // entity is a missile shot by the player
            entity_is_active(ent)
            && mem_path(ent, ["flags", "IS_PROJECTILE"]) == 1
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "PROJECTILE")
            && mem_path(ent, ["param_N"]) == enum_value(SHOT_TYPE, "MISSILE")
            && mem_path_wide(ent, ["owner"]) == mem_path_wide(player_state, ["entity"])

            // ... that has collided with the truck
            && mem_path(ent, ["flags", "COLLIDING"]) == 1
            && mem_path_wide(ent, ["collider"]) == mem_wide(truck)

            // ... and has just exploded (to make sure each missile is only counted once)
            && mem_changed_from_to(mem_path(ent, ["param_3"]), 0, 1))
    }

    achievement(
        id=140503,
        badge="156230",
        title="Bipolar Disorder Is Not a Joke",
        description="[Defend Transport] Complete the level having scored 10 direct missile hits on your own transport",
        points=10,
        trigger=cheat_protection()
                && never_not_in_level("S2_TRANSPORT")
                && never(mem_path(level_flags, ["FAILED"]) == 1)
                && tally(10, missile_hits)
                && completed_normal_level("S2_TRANSPORT")
        )
}


//
//   T r i k e   R e s c u e
//

function _trike_mines_achievement() {
    troodon_killed_by_mine = []
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        array_push(troodon_killed_by_mine,
            entity_is_active(ent)
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "MINE")
            && mem_path_wide(ent, ["owner"]) == mem_path_wide(player_state, ["entity"])
            && mem_path(ent, ["flags", "COLLIDING"]) == 1
            && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "TROODON")
            && mem_path(ent, ["collider", "update_f"]) == pdp11(entity_state_update_f("Troodon", "Alive"))
            && mem_path(ent, ["state"]) == 1
        )
    }

    achievement(
        id=140504,
        badge="156231",
        title="Minesweeping Dinos",
        description="[Trike Rescue] Kill at least 10 Troodons with mines while defending an incapacitated Triceratops",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S2_TRIKE_RESCUE")
                && never(mem(incapacitated_trike_state) != 2)
                && tally(10, troodon_killed_by_mine)
    )
}

function _trike_rescue_pacifist_achievement() {
    achievement(
        id=140505,
        badge="156232",
        title="All Dinosaurs Deserve Rescue",
        description="[Trike Rescue] Complete the level using only the Taser or Tranquilizer Darts to damage enemies, without using continues",
        points=5,
        trigger=_pacifist_achievement_trigger("S2_TRIKE_RESCUE", "NO_TREX")
    )
}


//
//   T - R e x   C h a s e
//

function _chase_achievement() {
    vector_speed_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "vector_speed"])))
    achievement(
        id=140507,
        badge="156233",
        title="Fast & Furious",
        description="[T-Rex Chase] Complete the level without slowing down",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S3_TREX_CHASE")
                && once(just_started_normal_level("S3_TREX_CHASE"))
                && never(mem_path_wide(player_state, ["entity"]) != null
                         && prev(vector_speed_hi) >= 0x4
                         && vector_speed_hi < 0x4)
                && completed_normal_level("S3_TREX_CHASE")
    )
}


//
//   C a m p   S a b o t a g e
//

function _campfire_achievement() {
    pos_x_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_x"])))
    pos_y_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_y"])))

    near_lit_campfire = always_false()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])

        fire_pos_x_hi = mem(cast_var(word_t, addressof_path(ent, ["position_x"])))
        fire_pos_y_hi = mem(cast_var(word_t, addressof_path(ent, ["position_y"])))

        near_lit_campfire = near_lit_campfire
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "CAMPFIRE")
                && mem_path(ent, ["state"]) == 2
                && entity_distance_from_player_le(ent, 0x25, 0x25))
    }
    
    achievement(
        id=140508,
        badge="156234",
        title="Curled Up With a Good Book",
        description="[Hunter Camp Sabotage] Cozy up by a lit campfire and read your mission instructions",
        points=2,
        trigger=cheat_protection()
                && in_level("S3_SABOTAGE")
                && near_lit_campfire
                && in_screen("Pause")
                && pause_sub_menu_changed("Main", "Messages (S3_SABOTAGE)")
    )
}

function _parking_achievement() {
    parked_jeeps = []
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        array_push(parked_jeeps,
            entity_is_active(ent)
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "VEHICLE")
            && mem_path_wide(ent, ["update_f"]) == pdp11(entity_update_f("Jeep"))
            && entity_is_visible(ent)
            // when the jeep makes a full 360 turn, the angle accumulates
            // instead of resetting to 0, thus the cast
            && mem(cast_var(byte_t, addressof_path(ent, ["facing_angle"]))) == 0x40
        )
    }

    achievement(
        id=140509,
        badge="156235",
        title="Jurassic Parking",
        description="[Hunter Camp Sabotage] Park 3 Jeeps next to each other facing south",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S3_SABOTAGE")
                // don't trigger if the player is still driving the last jeep. it must be parked!!
                && mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "NORMAL")
                // there are 3 correctly parked jeeps on screen
                // note: reset every other frame to ensure the 3 tally hits are accumulated on the same frame
                && tally(3, parked_jeeps)
                && never(repeated(2, always_true()))
    )
}

function _sabotage_pacifism() {
    flags = addressof_path(game_state, ["alarm_generator_states"])
    alarm_generators_active = always_true()
    for i in range(0, array_var_size(flags))
        alarm_generators_active = alarm_generators_active
            && mem_path(flags, [i]) == 1

    achievement(
        id=140510,
        badge="156236",
        title="Extreme Pacifism",
        description="[Hunter Camp Sabotage] Complete the level using only the Taser or Tranquilizer Darts to damage enemies, without disabling alarms or using continues",
        points=25,
        trigger=_pacifist_achievement_trigger("S3_SABOTAGE", "NO_TREX")
                && alarm_generators_active
    )
}


//
//   C a v e   M a z e
//

function _lazor_achievement() {
    pos_x_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_x"])))
    pos_y_hi = mem(cast_var(word_t, addressof_path(player_state, ["entity", "position_y"])))

    achievement(
        id=140511,
        badge="156237",
        title="DINO A' FIRIN' ITZ LAZOR!!!",
        description="[Cave Maze] Locate the lava pool in the shape of a dinossaur head, place youself inside its mouth, and fire your taser outwards",
        points=2,
        trigger=cheat_protection()
                && in_level("S3_CAVE_MAZE")
                // player is in the "mouth of the dinosaur"
                // note: checking for aoe damage excludes the lava area
                && pos_x_hi >= 0xb85 && pos_x_hi <= 0xbe0
                && pos_y_hi >= 0x7c5 && pos_y_hi <= 0x7f5
                && mem_path(player_state, ["entity", "flags", "HIT_BY_AOE"]) == 0
                // player is facing east
                && mem_path(player_state, ["entity", "facing_angle"]) == 0x0000
                // player just shot the taser
                && mem_path(player_state, ["weapon_type"]) == enum_value(WEAPON_TYPE, "TASER")
                && mem_path(player_state, ["entity", "last_shot_time"]) == mem(ingame_timer)
    )
}

function _cave_speedrun_achievement() {
    achievement(
        id=140512,
        badge="156238",
        title="Speluncaphobia",
        description="[Cave Maze] Find the exit in 8:15 minutes or less",
        points=10,
        trigger=cheat_protection()
                && never_not_in_level("S3_CAVE_MAZE")
                && once(just_started_normal_level("S3_CAVE_MAZE"))
        
                // no timer while paused
                && unless(in_screen("Pause"))
                // reset when the time cutoff is reached
                && never(once(just_started_normal_level("S3_CAVE_MAZE"))
                         && repeated(time_to_60fps(8, 15) + 1, always_true()))

                && completed_normal_level("S3_CAVE_MAZE")
    )
}


//
//   E g g   H u n t
//

function _dino_battle_achievement() {
    battle_ended = always_false()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        battle_ended = battle_ended
            // either the T-Rex dies
            || (entity_is_active(ent)
                // && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TREX")
                && mem_path(ent, ["id"]) == level_entity_id("S4_EGG_HUNT", "First T-Rex")
                && mem_path(ent, ["update_f"]) == pdp11(entity_state_update_f("T-Rex", "Dead")))
            // ...or the Triceratops does
            || (entity_is_active(ent)
                // && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TRICERATOPS")
                && mem_path(ent, ["id"]) == level_entity_id("S4_EGG_HUNT", "First Triceratops")
                && mem_path(ent, ["update_f"]) == pdp11(entity_state_update_f("Triceratops", "Dead")))
    }

    never_interfered = always_true()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        never_interfered = never_interfered
            // no player projectile is allowed to hit either the T-Rex or the Triceratops
            && never(entity_is_active(ent)
                     && mem_path(ent, ["flags", "IS_PROJECTILE"]) == 1
                     && mem_path_wide(ent, ["owner"]) == mem_path_wide(player_state, ["entity"])
                     && mem_path(ent, ["flags", "COLLIDING"]) == 1
                     && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "TREX")
                     && mem_path(ent, ["collider", "id"]) == level_entity_id("S4_EGG_HUNT", "First T-Rex"))
            && never(entity_is_active(ent)
                     && mem_path(ent, ["flags", "IS_PROJECTILE"]) == 1
                     && mem_path_wide(ent, ["owner"]) == mem_path_wide(player_state, ["entity"])
                     && mem_path(ent, ["flags", "COLLIDING"]) == 1
                     && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "TRICERATOPS")
                     && mem_path(ent, ["collider", "id"]) == level_entity_id("S4_EGG_HUNT", "First Triceratops"))
            // neither the T-Rex nor the Triceratops are allowed to be hit by aoe, unless it's from each other
            // this covers both the Taser and indirect explosions
            && never(entity_is_active(ent)
                     && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TREX")
                     && mem_path(ent, ["id"]) == level_entity_id("S4_EGG_HUNT", "First T-Rex")
                     && mem_path(ent, ["flags", "HIT_BY_AOE"]) == 1
                     && mem_path(ent, ["aoe_type"]) != enum_value(AOE_TYPE, "TREX/TRIKE"))
            && never(entity_is_active(ent)
                     && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TRICERATOPS")
                     && mem_path(ent, ["id"]) == level_entity_id("S4_EGG_HUNT", "First Triceratops")
                     && mem_path(ent, ["flags", "HIT_BY_AOE"]) == 1
                     && mem_path(ent, ["aoe_type"]) != enum_value(AOE_TYPE, "TREX/TRIKE"))
                     
    }

    achievement(
        id=140514,
        badge="156239",
        title="Nature Takes Its Course",
        description="[Egg Hunt] Let the Triceratops and T-Rex on the starting island fight to the death without interfering",
        points=2,
        trigger=cheat_protection()
                && never_not_in_level("S4_EGG_HUNT")
                && once(just_started_normal_level("S4_EGG_HUNT"))

                && battle_ended
    )
}

function _ole_achievement() {
    full_health_trike = []
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        for it in [["EASY", 0x2aa], ["MEDIUM", 0x3ff], ["HARD", 0x5fe]] {
            dif = it[0]
            max_hp = it[1]
            array_push(full_health_trike,
                mem(difficulty) == enum_value(DIFFICULTY, dif)
                && entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TRICERATOPS")
                && mem_path(ent, ["id"]) != 0x67  // the first triceratops is not alone, so ignore it
                && mem_path(ent, ["capture_hp"]) == max_hp
            )
       }
    }

    captured_trike = []
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        array_push(captured_trike,
            entity_is_active(ent)
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TRICERATOPS")
            && mem_path(ent, ["id"]) != 0x67
            && mem_path_wide(ent, ["update_f"]) == pdp11(entity_state_update_f("Triceratops", "Dead"))
            && is_positive(typeof_path(ent, ["hp"]), mem_path(ent, ["hp"]))
        )
    }

    achievement(
        id=140515,
        badge="156240",
        title="Ole!",
        description="[Egg Hunt] Capture a full-health lone Triceratops without taking any hits from it",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S4_EGG_HUNT")
                && tally(1, full_health_trike)
                && never(mem_path(player_state, ["entity", "flags", "HIT_BY_AOE"]) == 1
                         && mem_path(player_state, ["entity", "aoe_type"]) == enum_value(AOE_TYPE, "TREX/TRIKE"))
                && tally(1, captured_trike)
    )
}

function _peace_with_titans_achievement() {
    achievement(
        id=140516,
        badge="156241",
        title="Make Peace With the Titans",
        description="[Egg Hunt] Complete the level using only the Taser or Tranquilizer Darts to damage enemies, without using continues",
        points=5,
        trigger=_pacifist_achievement_trigger("S4_EGG_HUNT", "EGG_HUNT")
    )
}


//
//   R o u g h   R o a d
//

function _barrier_trex_achievement() {
    trex_killed_by_fence = always_false()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        trex_killed_by_fence = trex_killed_by_fence
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TREX")
                // just died
                && !is_positive(typeof_path(ent, ["hp"]), mem_path(ent, ["hp"]))
                // ...while colliding with an active electric fence
                && mem_path(ent, ["flags", "COLLIDING"]) == 1
                && mem_path(ent, ["collider", "collision_type"]) == enum_value(COLLISION_TYPE, "ELECTRIC_BARRIER_ACTIVE")
            )
    }

    achievement(
        id=140517,
        badge="156242",
        title="Sorna Fried Chicken",
        description="[Rough Road] Bait a T-Rex to its death by intermittent electric fence",
        points=3,
        trigger=cheat_protection()
                && in_level("S4_ROUGH_ROAD")
                && trex_killed_by_fence
    )
}

function _captive_dilo_achievement() {
    captured_dilo = always_false()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        captured_dilo = captured_dilo
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "DILOPHOSAURUS")
                && mem_path(ent, ["id"]) == level_entity_id("S4_ROUGH_ROAD", "Captive Dilophosaurus")
                && mem_path_wide(ent, ["update_f"]) == pdp11(entity_state_update_f("Dilophosaurus", "Dead"))
                && is_positive(typeof_path(ent, ["hp"]), mem_path(ent, ["hp"])))
    }

    achievement(
        id=140518,
        badge="156243",
        title="Captureception",
        description="[Rough Road] Capture the already captive Dilophosaurus",
        points=2,
        trigger=cheat_protection()
                && in_level("S4_ROUGH_ROAD")
                && captured_dilo
    )
}


function _blue_achievement() {
    hunter_killed_by_blue = []
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        array_push(hunter_killed_by_blue,
            // a hunter
            entity_is_active(ent)
            && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "ENEMY_HUNTER")
            // ...that just died
            && is_positive(typeof_path(ent, ["hp"]), prev(mem_path(ent, ["hp"])))
            && !is_positive(typeof_path(ent, ["hp"]), mem_path(ent, ["hp"]))
            // ...while colliding with blue
            && mem_path(ent, ["flags", "COLLIDING"]) == 1
            && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "VELOCIRAPTOR")
            && mem_path(ent, ["collider", "id"]) == level_entity_id("S4_ROUGH_ROAD", "Captive Velociraptor")
            // ...who's targeting the hunter
            && mem_path_wide(ent, ["collider", "target"]) == pdp11(0xffff0000 + var_addr(ent))
        )
    }
    
    blue_at_the_mobile_lab = always_false()
    for i in range(0, array_var_size(entities) - 1) {
        ent = addressof_path(entities, [i])
        pos_x_hi = mem(cast_var(word_t, addressof_path(ent, ["position_x"])))
        pos_y_hi = mem(cast_var(word_t, addressof_path(ent, ["position_y"])))
        blue_at_the_mobile_lab = blue_at_the_mobile_lab
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "VELOCIRAPTOR")
                && mem_path(ent, ["id"]) == level_entity_id("S4_ROUGH_ROAD", "Captive Velociraptor")
                && pos_x_hi >= 0x3b0 && pos_x_hi <= 0x4b0
                && pos_y_hi >= 0x8d5 && pos_y_hi <= 0x985)
    }

    achievement(
        id=140519,
        badge="156244",
        title="Blue, Is That You?",
        description="[Rough Road] Get the captive Velociraptor to kill at least two hunters, and then lead it alive to the Mobile Lab",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S4_ROUGH_ROAD")
                && tally(2, hunter_killed_by_blue)
                && blue_at_the_mobile_lab
    )
}

function _scounting_ahead_achievement() {
    achievement(
        id=140520,
        badge="156245",
        title="Scouting Ahead",
        description="[Rough Road] Complete the level having entered and driven the truck exactly once, straight to the end",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("S4_ROUGH_ROAD")
                && once(just_started_normal_level("S4_ROUGH_ROAD"))
                // reset if the player enters the truck twice
                && never(repeated(2, mem_changed_to(mem_path(player_state, ["movement_type"]),
                                                    enum_value(MOVEMENT_TYPE, "DRIVING_FLOATY_VEHICLE"))))  // yep, drives like a boat
                // reset if the mission is failed, to reset the other reset :)
                && never(mem_path(level_flags, ["FAILED"]) == 1)
                && completed_normal_level("S4_ROUGH_ROAD")
    )
}


//
//   A m b e r   M i n e
//

function _trapped_jeep_achievement() {
    hitting_jeep_trap_barrier = []
    for i in range(1, 2) {
        array_push(hitting_jeep_trap_barrier,
            mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "DRIVING_VEHICLE")
            && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "VEHICLE")
            && mem_path(player_state, ["entity", "id"]) == level_entity_id("S4_AMBER_MINE", "Trapped Jeep")
            && mem_path(player_state, ["entity", "flags", "COLLIDING"]) == 1
            && mem_path(player_state, ["entity", "collider", "type"]) == enum_value(ENTITY_TYPE, "INVISIBLE_BARRIER")
            && mem_path(player_state, ["entity", "collider", "id"]) == level_entity_id("S4_AMBER_MINE", format("Jeep Trap Barrier {0}", i))
        )
    }

    achievement(
        id=140521,
        badge="156247",
        title="Jeep in a Bottle",
        description="[Amber Mine] Free the Jeep behind an electric fence, only to then realize the futility of your efforts",
        points=2,
        trigger=cheat_protection()
                && never_not_in_level("S4_AMBER_MINE")
                && tally(10, hitting_jeep_trap_barrier)
    )
}


//
//   F i n a l   C o u n t d o w n
//

function _buy_hovercraft_achievement() {
    achievement(
        id=140523,
        badge="156248",
        title="I Should Buy a Hovercraft",
        description="[The Final Countdown] Complete the level without riding any Jeeps",
        points=5,
        trigger=cheat_protection()
                && never_not_in_level("COUNTDOWN")
                && once(just_started_normal_level("COUNTDOWN"))
                && never(mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "DRIVING_VEHICLE"))
                && completed_normal_level("COUNTDOWN")
    )
}


//
//   N o t   L e v e l   S p e c i f i c
//

function _floor_is_lava_achievement() {
    raptor_killed_by_fissure = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        raptor_killed_by_fissure = raptor_killed_by_fissure
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "LAVA_FISSURE")
                && mem_path(ent, ["flags", "COLLIDING"]) == 1
                && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "VELOCIRAPTOR")
                && !is_positive(typeof_path(ent, ["collider", "hp"]), mem_path(ent, ["collider", "hp"])))
    }

    achievement(
        id=140524,
        badge="156249",
        title="The Floor Is Lava",
        description="Bait a Velociraptor to its death by lava fissure",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && raptor_killed_by_fissure
    )
}

function _poison_plant_achievement() {
    troodon_died_of_poison = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        troodon_died_of_poison = troodon_died_of_poison
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "TROODON")
                && mem_path(ent, ["flags", "HIT_BY_AOE"]) == 1
                && mem_path(ent, ["aoe_type"]) == enum_value(AOE_TYPE, "POISON_PLANT"))
                && entity_died(ent)
    }

    achievement(
        id=140525,
        badge="156250",
        title="Close Your Windows",
        description="While riding a Jeep, bait a Troodon to its death by Poisonous Plants",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "VEHICLE")
                && mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "DRIVING_VEHICLE")
                && troodon_died_of_poison
    )
}

function _parking_sensors_achievement() {
    angle = cast_var(byte_t, addressof_path(player_state, ["entity", "facing_angle"]))
    x = cast_var(word_t, addressof_path(player_state, ["entity", "position_x"]))
    y = cast_var(word_t, addressof_path(player_state, ["entity", "position_y"]))

    collider_x = cast_var(word_t, addressof_path(player_state, ["entity", "collider", "position_x"]))
    collider_y = cast_var(word_t, addressof_path(player_state, ["entity", "collider", "position_y"]))

    achievement(
        id=140526,
        badge="156251",
        title="No Parking Sensors",
        description="Run over a Hunter with the back of your Jeep",
        points=2,
        trigger=cheat_protection()
                && in_a_level()

                // player is driving a jeep
                && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "VEHICLE")
                && mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "DRIVING_VEHICLE")

                // ...and killed a hunter through collision damage
                && mem_path(player_state, ["entity", "collider", "type"]) == enum_value(ENTITY_TYPE, "ENEMY_HUNTER")
                && (prev(mem_path(player_state, ["entity", "flags", "COLLIDING"]))
                    + mem_path(player_state, ["entity", "flags", "COLLIDING"])) >= 1
                && !mem_changed(mem_path(player_state, ["entity", "collider"]))
                && mem_path(player_state, ["entity", "collider", "flags", "KNOCKBACK"]) == 1
                && is_negative(typeof_struct_field(ENTITY, "hp"), mem_path(player_state, ["entity", "collider", "hp"]) - 1)

                // ...and the hunter is behind the jeep
                && (
                    (mem(angle) < 0x10 && mem(collider_x) < mem(x))
                    || (mem(angle) >= 0x10 && mem(angle) < 0x30 && mem(collider_x) < mem(x) && mem(collider_y) < mem(y))
                    || (mem(angle) >= 0x30 && mem(angle) < 0x50 && mem(collider_y) < mem(y))
                    || (mem(angle) >= 0x50 && mem(angle) < 0x70 && mem(collider_x) > mem(x) && mem(collider_y) < mem(y))
                    || (mem(angle) >= 0x70 && mem(angle) < 0x90 && mem(collider_x) > mem(x))
                    || (mem(angle) >= 0x90 && mem(angle) < 0xb0 && mem(collider_x) > mem(x) && mem(collider_y) > mem(y))
                    || (mem(angle) >= 0xb0 && mem(angle) < 0xd0 && mem(collider_y) > mem(y))
                    || (mem(angle) >= 0xd0 && mem(angle) < 0xf0 && mem(collider_x) < mem(x) && mem(collider_y) > mem(y))
                    || (mem(angle) >= 0xf0 && mem(collider_x) < mem(x))
                )
    )
}

function _bunker_ff_achievement() {
    bunker_killed_by_hunter = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        bunker_killed_by_hunter = bunker_killed_by_hunter
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "BUNKER")
                && mem_path(ent, ["flags", "COLLIDING"]) == 1
                && mem_path(ent, ["collider", "flags", "IS_PROJECTILE"]) == 1
                && mem_path_wide(ent, ["collider", "owner"]) != null
                && mem_path(ent, ["collider", "owner", "type"]) == enum_value(ENTITY_TYPE, "ENEMY_HUNTER")
                && entity_died(ent))
    }

    achievement(
        id=140527,
        badge="156252",
        title="Friendly Fire On",
        description="Bait a Hunter into destroying a Bunker",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && bunker_killed_by_hunter
    )
}

function _triassic_sniper_achievement() {
    mine_blown = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        mine_blown = mine_blown
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "WATER_MINE")
                && mem_path(ent, ["flags", "COLLIDING"]) == 1
                && mem_path(ent, ["collider", "flags", "IS_PROJECTILE"]) == 1
                && mem_path_wide(ent, ["collider", "owner"]) == mem_path_wide(player_state, ["entity"]))
    }

    achievement(
        id=140528,
        badge="156253",
        title="Triassic Sniper",
        description="Blow a water mine by shooting it from land while on foot",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "PLAYER")
                && mem_path(player_state, ["movement_type"]) == enum_value(MOVEMENT_TYPE, "NORMAL")
                && mine_blown
    )
}

function _jurassic_sniper_achievement() {
    enemy_killed_by_boat = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        for enemy_alt in ["NO_TREX", "TREX"] {
            enemy_killed_by_boat = enemy_killed_by_boat
                || (entity_is_active(ent)
                    && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "PROJECTILE")
                    && mem_path(ent, ["param_N"]) == enum_value(SHOT_TYPE, "VEHICLE_SHOT")
                    && (prev(mem_path(ent, ["flags", "COLLIDING"])) + mem_path(ent, ["flags", "COLLIDING"])) >= 1
                    && is_enemy_entity(enemy_alt, addressof_path(ent, ["collider"]))
                    && is_negative(typeof_struct_field(ENTITY, "hp"), mem_path(ent, ["collider", "hp"]) - 1))
        }
    }

    achievement(
        id=140529,
        badge="156254",
        title="Jurassic Sniper",
        description="Kill a land dinossaur by shooting it from a hovercraft",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && mem_path(player_state, ["entity", "type"]) == enum_value(ENTITY_TYPE, "VEHICLE")
                && mem_path(player_state, ["entity", "param_N"]) == enum_value(VEHICLE_TYPE, "BOAT")
                && enemy_killed_by_boat
    )
}

function _cretacious_sniper_achievement() {
    dilo_direct_hit = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        dilo_direct_hit = dilo_direct_hit
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "PROJECTILE")
                && mem_path(ent, ["param_N"]) == enum_value(SHOT_TYPE, "MISSILE")
                && mem_path_wide(ent, ["target"]) == null
                && mem_path(ent, ["flags", "COLLIDING"]) == 1
                && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "DILOPHOSAURUS")
                && unless(entity_distance_from_player_le(ent, 0x65, 0x45))
            )
    }

    achievement(
        id=140530,
        badge="156256",
        title="Cretacious Sniper",
        description="Score a direct non-homing missile hit on a Dilophosaurus that is at least half a screen away",
        points=5,
        trigger=cheat_protection()
                && in_a_level()
                && dilo_direct_hit
    )
}

function _scavenger_achievement() {
    // the carcass is actually a reskined huge crate and explodes not based on damaged,
    // but when it moves too far from its spawn. it explodes and deactivates on the same
    // frame, so we detect the resulting debris entities instead
    stego_carcass_exploded = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        stego_carcass_exploded = stego_carcass_exploded
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "FX_1")
                && mem_path(ent, ["main_render", "sprite_sheet"]) == pdp11(0x002846e8)
                && mem_path(ent, ["main_render", "sprite_sheet_position_i"]) == 9
                && entity_is_visible(ent))
    }

    achievement(
        id=140531,
        badge="156257",
        title="Scavengers Need Not Apply",
        description="Dispose of a Stegosaurus carcass",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && stego_carcass_exploded
    )
}

function _dilo_friend_achievement() {
    dilo_opened_crate = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        dilo_opened_crate = dilo_opened_crate
            || (entity_is_active(ent)
                // a dilophosaurus projectile
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "PROJECTILE")
                && mem_path(ent, ["param_N"]) == enum_value(SHOT_TYPE, "DILOPHOSAURUS")
                
                // ...hit a crate with loot
                && (prev(mem_path(ent, ["flags", "COLLIDING"])) + mem_path(ent, ["flags", "COLLIDING"])) >= 1
                && mem_path(ent, ["collider", "type"]) == enum_value(ENTITY_TYPE, "CRATE")
                && mem_path(ent, ["collider", "param_N"]) != 0
            )
    }

    achievement(
        id=140532,
        badge="156258",
        title="Dino Employee of the Month",
        description="Have a Dilophosaurus open a non-air-drop crate for you, exposing its loot",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && dilo_opened_crate
    )
}

function _desperation_achievement() {
    premature_supply_drop = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        premature_supply_drop = premature_supply_drop
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "AIR_DROP")

                // distinguish from player/jeep drop
                && mem_path_wide(ent, ["update_f"]) == pdp11(entity_update_f("Supply Drop"))

                // 5 or less jurassic coins when spawned (set to jurassic_coins - 1)
                && mem_path(ent, ["param_2"]) <= 4

                // trigger when the supplies reach the floor
                && mem_changed_from_to(mem_path(ent, ["state"]), 0, 1)
            )
    }

    achievement(
        id=140533,
        badge="156259",
        title="Desperation Move",
        description="Solicit a premature supply drop",
        points=1,
        trigger=cheat_protection()
                && in_a_level()
                && premature_supply_drop
    )
}

function _huge_explosion_achievement() {
    achievement(
        id=140534,
        badge="156260",
        title="Jurassic Nuke",
        description="Waste perfectly good ammo and listen to the thunderous wrath of God",
        points=2,
        trigger=cheat_protection()
                && in_a_level()
                && mem(sound_fx_2_request) == enum_value(SOUND_FX, "THUNDEROUS_EXPLOSION") + enum_value(SOUND_FX, "REQUEST_FULFILLED")
    )
}

function _marianna_achievement() {
    seeing_secret_text = always_true()
    i = 0
    for c in ["I"," ","H","O","P","E"] {
        seeing_secret_text = seeing_secret_text
            && mem_path(secret_pwd_text_decode_buffer, [byte_swap_2(i)]) == ascii[c]
        i = i + 1
    }
    
    // secret_pwd_text_decode_buffer
    achievement(
        id=140535,
        badge="156261",
        title="I Love You Too",
        description="Enter password MARIANNA. Hopefully they're still together",
        points=1,
        trigger=cheat_protection()
                && in_screen("T-Rexes")
                && seeing_secret_text
    )
}

function _baby_stegosaurus_achievement() {
    baby_stegosaurus_visible = always_false()
    for i in range(0, array_var_size(entities)) {
        ent = addressof_path(entities, [i])
        baby_stegosaurus_visible = baby_stegosaurus_visible
            || (entity_is_active(ent)
                && mem_path(ent, ["type"]) == enum_value(ENTITY_TYPE, "BABY_STEGOSAURUS")
                && entity_is_visible(ent))
    }

    achievement(
        id=140536,
        badge="156262",
        title="Too Cute for This Game",
        description="See the elusive juvenile Stegosaurus in the Arena (available through level select or the demo)",
        points=1,
        trigger=cheat_protection()
                && in_level("ARENA")
                && baby_stegosaurus_visible
    )
}


//
//   B o s s e s
//

function _boss1_achievement() {
    // the obvious solution would be to simply reset when the raptor is damaged. however, it so happens that
    // the raptor can become invulnerable while the shot is airborn, meaning the damage will take place once
    // the raptor is already invulnerable and the achievement has already pause locked.
    // what we do instead is to check whether a player shot targetting the raptor exists.
    never_player_shot_at_raptor = always_true()
    cur_node = addressof_path(boss_object_lists, ["*", 4, "head"])
    cur_node_exists = mem_wide(cur_node) != null
    for _ in range(0, 10) {
        obj = addressof_path(cur_node, ["object"])
        never_player_shot_at_raptor = never_player_shot_at_raptor
            && never(cur_node_exists
                     && mem_path(obj, ["command_f"]) == pdp11(boss_entity_command_f("B1 Player Shot"))
                     && mem_path_wide(cast_var(pointer_t(B1_PLAYER_SHOT), obj), ["target"]) - mem_path_wide(boss1_data, ["raptor"]) == 0)
        cur_node = addressof_path(cur_node, ["next"])
        cur_node_exists = cur_node_exists && mem_wide(cur_node) != null
    }

    update_f = mem_path_wide(boss1_data, ["raptor", "common", "header", "update_f"])
    invulnerable = mem_path(boss1_data, ["raptor", "invulnerable"])

    achievement(
        id=140500,
        badge="156263",
        title="No Running From Fate",
        description="[Bike Race] Complete the level without hitting trees or missing an opportunity to hit the Velociraptor",
        points=10,
        trigger=boss_cheat_protection()
                && completed_boss_level("S1_BIKE_RACE")
                && mem_changed_from_to(mem(playing_boss_level), 1, 0)

                // max hp at the end = hit no trees
                && mem_path(boss1_data, ["player", "hp"]) == pdp11(0x200000)

                // pause lock the achievement for the duration of the current attempt
                // if the raptor isnt hit while invulnerable
                && never(repeated(5, mem(playing_boss_level) == 0))  // need at least one frame to trigger at the end
                && (
                    always_false()
                    || (
                        always_true()
                    
                        // pause lock if the raptor switches from invulnerable to vulnerable and back again
                        // without a reset occurring. checking whether the raptor is in a "running" state when
                        // it becomes vulnerable excludes the similar switch that occurs after it's hit
                        && unless(
                            once(prev(update_f) == pdp11(boss_entity_update_f("B1 Raptor", "Running")) && mem_changed_from_to(invulnerable, 1, 0))
                            && once(mem_changed_from_to(invulnerable, 0, 1))
                        )
                        
                        // reset the hits if the player shoots at the raptor, thus keeping the pause lock from activating
                        && never_player_shot_at_raptor
                    
                        // reset any leftover hits. the prev and the second condition are meant to avoid the reset on the
                        // specific frames in which the invulnerability switches and we have to accumulate hits for the
                        // pause lock
                        && never(prev(invulnerable) == 1 && invulnerable == 1)
                    )
                )
    )
}

function _boss2_achievement() {
    update_f = addressof_path(boss2_data, ["trex", "common", "header", "update_f"])
    state = addressof_path(boss2_data, ["trex", "common", "state"])
    headbang = [
        // while headbanging, state briefly switches to 2 between each bang...
        mem_wide(update_f) == pdp11(boss_entity_update_f("B2 T-Rex", "Headbanging"))
        && mem_changed_to(mem(state), 2),

        // ...and count an additional one to reach the correct number
        mem_changed_from(mem_wide(update_f), pdp11(boss_entity_update_f("B2 T-Rex", "Headbanging"))),
        
        // count single head drops as well
        mem_changed_from(mem_wide(update_f), pdp11(boss_entity_update_f("B2 T-Rex", "Head Drop")))
    ]

    achievement(
        id=140506,
        badge="156264",
        title="Headbanging T-Rex",
        description="[T-Rex Escape] Complete the level after the T-Rex has smashed its head on the floor at least 100 times",
        points=10,
        trigger=boss_cheat_protection()
                && completed_boss_level("S2_TREX_ESCAPE")
        
                // reset any leftover hits at the start and at the end
                && never(started_boss())
                && never(repeated(5, mem(playing_boss_level) == 0))
                
                // count 100 headbangs
                && tally(10, headbang)
                && measured(tally(10, headbang))
    )
}

function _boss3_achievement() {
    achievement(
        id=140513,
        badge="156265",
        title="Life Jacket Required",
        description="[River Raft] Complete the level without taking damage",
        points=10,
        trigger=boss_cheat_protection()
                && completed_boss_level("S3_RIVER_RAFT")
                && mem_path(boss3_data, ["player", "hp"]) == pdp11(0x200000)
    )
}

function _boss4_achievement() {
    never_enemy_missile = always_true()
    cur_node = addressof_path(boss_object_lists, ["*", 6, "head"])
    cur_node_exists = mem_wide(cur_node) != null
    for _ in range(0, 10) {
        obj = addressof_path(cur_node, ["object"])
        never_enemy_missile = never_enemy_missile
            && never(cur_node_exists
                     && mem_path(obj, ["update_f"]) == pdp11(boss_entity_update_f("B4 Missile", "Enemy")))
        cur_node = addressof_path(cur_node, ["next"])
        cur_node_exists = cur_node_exists && mem_wide(cur_node) != null
    }

    achievement(
        id=140522,
        badge="156266",
        title="Synchronized Flight",
        description="[Pteranodons] Complete the level with more than 75% hp left and without letting an enemy vehicle fire a missile",
        points=10,
        trigger=boss_cheat_protection()
                && completed_boss_level("S4_PTERANODONS")

                // 75% hp = 0x180000
                && prev(mem(cast_var(word_t, addressof_path(boss4_player, ["hp"])))) >= 0x18

                // no enemy missiles from start to finish
                && once(started_boss())
                && never_enemy_missile
    )
}


generate_achievements = true
if (generate_achievements != false) {

// Mobile Lab
_mobile_lab_pacifist_achievement()

// Cave Rescue
_friendly_fire_off_achievement()
_save_yourself_achievement()
_cave_rescue_pacifist_achievement()

// Activate Sensors
_cartographer_achievement()

// Stegos Abduction
_stegos_achievement()

// Bike Race
_boss1_achievement()

// Nest Hunt
_nest_extinction_achievement()
_this_is_fine_achievement()

// Transport
_bipolar_achievement()

// Trike Rescue
_trike_mines_achievement()
_trike_rescue_pacifist_achievement()

// T-Rex Escape
_boss2_achievement()

// T-Rex Chase
_chase_achievement()

// Camp Sabotage
_campfire_achievement()
_parking_achievement()
_sabotage_pacifism()

// Cave Maze
_lazor_achievement()
_cave_speedrun_achievement()

// River Raft
_boss3_achievement()

// Egg Hunt
_dino_battle_achievement()
_ole_achievement()
_peace_with_titans_achievement()

// Rough Road
_barrier_trex_achievement()
_captive_dilo_achievement()
_blue_achievement()
_scounting_ahead_achievement()

// Amber Mine
_trapped_jeep_achievement()

// Pteranodons
_boss4_achievement()

// Final Countdown
_buy_hovercraft_achievement()

// Not Level Specific
_floor_is_lava_achievement()
_poison_plant_achievement()
_parking_sensors_achievement()
_bunker_ff_achievement()
_triassic_sniper_achievement()
_jurassic_sniper_achievement()
_cretacious_sniper_achievement()
_scavenger_achievement()
_dilo_friend_achievement()
_desperation_achievement()
_huge_explosion_achievement()
_marianna_achievement()
_baby_stegosaurus_achievement()

}

// ==================================== \\
// ==================================== \\
//                                      \\
//      R I C H   P R E S E N C E       \\
//                                      \\
// ==================================== \\
// ==================================== \\

function _level_id_lookup() {
    lookup_map = {}
    for level_id in level_meta {
        meta = level_meta[level_id]
        lookup_map[pdp11(meta["update_f"])] = meta["name"]
    }
    return rich_presence_lookup("LevelId", mem_wide(level_update_f), lookup_map, "an unknown location")
}
level_id_lookup = _level_id_lookup()

function _boss_rp_lookup() {
    rps = {
        "S1_BIKE_RACE":   "Chasing a raptor through the jungle on a motorcycle",
        "S2_TREX_ESCAPE": "Ramming a T-Rex into an electric fence using a jeep",
        "S3_RIVER_RAFT":  "Fighting off hungry piranhas while sailing on a river raft",
        "S4_PTERANODONS": "Keeping nosy Pteranodons off precious helicopter cargo"
    }

    lookup_map = {}
    for level_id in rps
        lookup_map[pdp11(level_meta[level_id]["update_f"])] = rps[level_id]

    return rich_presence_lookup("BossRP", mem_wide(level_update_f), lookup_map, "Fighting through an unknown boss level")
}
boss_rp_lookup = _boss_rp_lookup()

function _levels_with_completion_delay_update_f() {
    arr = []
    for level in levels_with_completion_delay
        array_push(arr, pdp11(level_meta[level]["update_f"]))
    return arr
}
levels_with_completion_delay_update_f = _levels_with_completion_delay_update_f()

// boss levels (beaten + playing)

rich_presence_conditional_display(completed_a_boss_level(), "Taking a breather after making it through {0}", level_id_lookup)
rich_presence_conditional_display(in_a_boss_level(), "{0}", boss_rp_lookup)

// normal levels beaten

rich_presence_conditional_display(
    mem_in(mem_wide(level_update_f), levels_with_completion_delay_update_f) && completed_a_normal_level(true),
    "Taking a breather after the hunt in {0}", level_id_lookup
)

rich_presence_conditional_display(
    !mem_in(mem_wide(level_update_f), levels_with_completion_delay_update_f) && completed_a_normal_level(false),
    "Taking a breather after the hunt in {0}", level_id_lookup
)

// playing normal levels

rich_presence_conditional_display(
    in_level("ARENA"),
    "Watching humans and dinosaurus duke it out in the Arena"
)

rich_presence_conditional_display(
    in_level("COMBAT_MODE"),
    "Enjoying some not-so-friendly competition in the Arena"
)

rich_presence_conditional_display(
    mem_in(mem_wide(level_update_f), levels_with_completion_delay_update_f) && playing_a_normal_level(true),
    "Hunting dinosaurs in {0}", level_id_lookup
)

rich_presence_conditional_display(
    !mem_in(mem_wide(level_update_f), levels_with_completion_delay_update_f) && playing_a_normal_level(false),
    "Hunting dinosaurs in {0}", level_id_lookup
)

rich_presence_display("Slacking off on some menu. Get going, the dinosaurs won't hunt themselves!")


// ================================== \\
// ================================== \\
//                                    \\
//      L E A D E R B O A R D S       \\
//                                    \\
// ================================== \\
// ================================== \\

function rta_leaderboard_start(level) =>
    cheat_protection()
    && just_started_normal_level(level)

function rta_leaderboard_cancel(level) =>
    !in_level(level)

function rta_leaderboard_submit(level) =>
    completed_normal_level(level)

rta_levels = [
    "MOBILE_LAB",
    "S1_SENSORS", "S1_CAVE_RESCUE", "S1_STEGOSAURUS",
    "S2_TRANSPORT", "S2_NEST_HUNT", "S2_TRIKE_RESCUE",
    "S3_CAVE_MAZE", "S3_SABOTAGE", "S3_TREX_CHASE",
    "S4_AMBER_MINE", "S4_EGG_HUNT", "S4_ROUGH_ROAD",
    "JUNGLE_FIRE", "COUNTDOWN"
]

for rta_level in rta_levels {
    leaderboard(
        title=format("{0} RTA", level_meta[rta_level]["name"]),
        description=format("Complete {0} as fast as possible", level_meta[rta_level]["name"]),
        start=rta_leaderboard_start(rta_level),
        cancel=rta_leaderboard_cancel(rta_level),
        submit=rta_leaderboard_submit(rta_level),
        value=measured(always_true()),
        format="FRAMES"
    )
}


// ================================== \\
// ================================== \\
//                                    \\
//      E X I S T I N G   S E T       \\
//                                    \\
// ================================== \\
// ================================== \\

function completed_normal_level_trigger(level) =>
    cheat_protection()
    && completed_normal_level(level)

function completed_boss_level_trigger(level) =>
    boss_cheat_protection()
    && completed_boss_level(level)

generate_existing = true
if (generate_existing != false) {

achievement(
    id=97141,
    badge="106825",
    title="Further Instructions",
    description="Reach The Mobile Lab",
    points=5,
    trigger=completed_normal_level_trigger("MOBILE_LAB")
)

achievement(
    id=97142,
    badge="106823",
    title="Heavy Surveillance",
    description="Complete Activate The Sensors",
    points=5,
    trigger=completed_normal_level_trigger("S1_SENSORS")
)

achievement(
    id=97143,
    badge="106824",
    title="Left Behind",
    description="Complete Cave Rescue",
    points=5,
    trigger=completed_normal_level_trigger("S1_CAVE_RESCUE")
)

achievement(
    id=97144,
    badge="106827",
    title="Stegos Storage",
    description="Complete Stegos Abduction",
    points=5,
    trigger=completed_normal_level_trigger("S1_STEGOSAURUS")
)

achievement(
    id=97145,
    badge="106828",
    title="Rex Riders",
    description="Complete The Bike Race",
    points=5,
    trigger=completed_boss_level_trigger("S1_BIKE_RACE")
)

achievement(
    id=97147,
    badge="106830",
    title="Truck Escort",
    description="Complete Defend Transport",
    points=5,
    trigger=completed_normal_level_trigger("S2_TRANSPORT")
)

achievement(
    id=97148,
    badge="106831",
    title="Population Control",
    description="Complete Raptor Nest Hunt",
    points=5,
    trigger=completed_normal_level_trigger("S2_NEST_HUNT")
)

achievement(
    id=97149,
    badge="107207",
    title="Conservationist",
    description="Complete Trike Rescue",
    points=5,
    trigger=completed_normal_level_trigger("S2_TRIKE_RESCUE")
)

achievement(
    id=97150,
    badge="107208",
    title="Not Even Close",
    description="Complete T-Rex Escape",
    points=5,
    trigger=completed_boss_level_trigger("S2_TREX_ESCAPE")
)

achievement(
    id=97152,
    badge="107209",
    title="Free At Last?",
    description="Complete The Cave Maze",
    points=5,
    trigger=completed_normal_level_trigger("S3_CAVE_MAZE")
)

achievement(
    id=97153,
    badge="107211",
    title="Interrupted Communications",
    description="Complete Hunter Camp Sabotage",
    points=5,
    trigger=completed_normal_level_trigger("S3_SABOTAGE")
)

achievement(
    id=97154,
    badge="107212",
    title="Don't Look Back",
    description="Complete T-Rex Chase",
    points=5,
    trigger=completed_normal_level_trigger("S3_TREX_CHASE")
)

achievement(
    id=97155,
    badge="107213",
    title="Down The River",
    description="Complete River Raft Battle",
    points=5,
    trigger=completed_boss_level_trigger("S3_RIVER_RAFT")
)

achievement(
    id=97157,
    badge="107216",
    title="Fossilized Treasure",
    description="Complete The Amber Mine",
    points=5,
    trigger=completed_normal_level_trigger("S4_AMBER_MINE")
)

achievement(
    id=97158,
    badge="107217",
    title="Secret Stash",
    description="Complete Egg Hunt",
    points=5,
    trigger=completed_normal_level_trigger("S4_EGG_HUNT")
)

achievement(
    id=97159,
    badge="107218",
    title="Valuable Cargo",
    description="Complete Rough Road",
    points=5,
    trigger=completed_normal_level_trigger("S4_ROUGH_ROAD")
)

achievement(
    id=97160,
    badge="107219",
    title="Safe Transport",
    description="Complete Pteranodon Attack",
    points=5,
    trigger=completed_boss_level_trigger("S4_PTERANODONS")
)

achievement(
    id=97161,
    badge="107221",
    title="Jungle Burning",
    description="Complete Jungle Fire Storm",
    points=5,
    trigger=completed_normal_level_trigger("JUNGLE_FIRE")
)

achievement(
    id=97162,
    badge="107222",
    title="Maybe We'll Come Back",
    description="Complete The Final Countdown",
    points=5,
    trigger=completed_normal_level_trigger("COUNTDOWN")
)

achievement(
    id=97164,
    badge="107223",
    title="Travel Insurance",
    description="Get 9 Lives",
    points=5,
    trigger=cheat_protection()
            && in_a_normal_level()
            // when advancing levels as extra life is given, which is then spent when the player is spawned,
            // thus the extra checks
            && !no_active_entities()
            && prev(mem(n_lives)) == 9
            && mem(n_lives) == 9
)

}  // end generate_existing