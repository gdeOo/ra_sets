// Tomb Raider Chronicles
// #ID = 11377

// Existing sets:
//   * https://www.tombraiderforums.com/showthread.php?t=183119
//   * https://www.tombraiderforums.com/showthread.php?t=167588

// ======================= \\
// ======================= \\
//                         \\
//      L I B R A R Y      \\
//                         \\
// ======================= \\
// ======================= \\

true = 1
false = 0
null = 0

//
//   c o n f i g
//

// frames per second
FPS = 60

// what size should pointers be referenced through in AddAddress conditions?
POINTER_SIZE = 24

// whether 8-bit variables should be byte-swapped as 16-bit (required for genesis)
BYTE_SWAP_2 = false


//
//   u t i l s
//

function error(msg) {
    dummy_ = {}
    return dummy_[msg]
}

function array_push_front(arr, new_el) {
    new_arr_ = [new_el]
    for el_ in arr
        array_push(new_arr_, el_)
    return new_arr_
}

function array_zip(arr_a, arr_b) {
    if (length(arr_a) != length(arr_b))
        error(format("Error: can't zip arrays of different lengths: {0} != {1}", length(arr_a), length(arr_b)))
    new_arr_ = []
    for i_ in range(0, length(arr_a) - 1)
        array_push(new_arr_, [arr_a[i_], arr_b[i_]])
    return new_arr_
}

function array_enumerate(arr) {
    new_arr_ = []
    for i_ in range(0, length(arr) - 1)
        array_push(new_arr_, [i_, arr[i_]])
    return new_arr_
}

function time_to_frames(min, sec) =>
    (min * 60 + sec) * FPS


//
//   t r i g g e r   u t i l s
//

function mem_changed(mem) => prev(mem) != mem
function mem_changed_to(mem, to) => prev(mem) != to && mem == to
function mem_changed_from(mem, from) => prev(mem) == from && mem != from
function mem_changed_from_to(mem, from, to) => prev(mem) == from && mem == to
function mem_increased(mem) => prev(mem) < mem
function mem_decreased(mem) => prev(mem) > mem
function mem_increased_by(mem, delta) => prev(mem) + delta == mem
function mem_decreased_by(mem, delta) => prev(mem) == mem + delta
function mem_didnt_change(mem) => prev(mem) == mem

function mem_in(mem, values) {
    cond_ = always_false()
    for value_ in values
        cond_ = cond_ || mem == value_
    return cond_
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

function or_alts(alts) {
    cond_ = always_false()
    for alt_ in alts
        cond_ = cond_ || alt_
    return cond_
}


//
//   t y p e   s y s t e m
//

function byte_swap_2(addr) {
    if (addr % 2 == 0) return addr + 1
    else return addr - 1
}

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
    if (BYTE_SWAP_2 != false && _sizeof(type) == 1)
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

code_t = pointer_t(byte_t)

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

function _mem_pointer(addr) {
    if (POINTER_SIZE == 16)
        return word(addr + 2)
    if (POINTER_SIZE == 24)
        return tbyte(addr)
}

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
            if (i == length(path) - 1 && mode == _READ_MODE)
                return addr
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
                    error(format("Can't apply {0} to {1}", path_elem, type_to_str(t)))
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
    "TITLE":                0x0,
    "STREETS_OF_ROME":      0x1,
    "TRAJAN_MARKETS":       0x2,
    "COLOSSEUM":            0x3,
    "BASE":                 0x4,
    "SUBMARINE":            0x5,
    "DEEPSEA_DIVE":         0x6,
    "SINKING_SUBMARINE":    0x7,
    "GALLOWS_TREE":         0x8,
    "LABYRINTH":            0x9,
    "OLD_MILL":             0xa,
    "THIRTEENTH_FLOOR":     0xb,
    "ESCAPE_WITH_THE_IRIS": 0xc,
    "SECURITY_BREACH":      0xd,
    "RED_ALERT":            0xe
}, byte_t)

RECT = struct_t("RECT", {
    "x": make_field(0x0, word_t),
    "y": make_field(0x2, word_t),
    "w": make_field(0x4, word_t),
    "h": make_field(0x6, word_t)
}, 0x8)

DISPENV = struct_t("DISPENV", {
    "disp":    make_field(0x00, RECT),
    "screen":  make_field(0x08, RECT),
    "isinter": make_field(0x10, byte_t),
    "isrgb24": make_field(0x11, byte_t)
}, 0x14)

PHD_VECTOR = struct_t("PHD_VECTOR", {
    "x": make_field(0x0, dword_t),
    "y": make_field(0x4, dword_t),
    "z": make_field(0x8, dword_t)
}, 0xc)

PHD_3DPOS = struct_t("PHD_3DPOS", {
    "x_pos": make_field(0x00, dword_t),
    "y_pos": make_field(0x04, dword_t),
    "z_pos": make_field(0x08, dword_t),
    "x_rot": make_field(0x0c, word_t),
    "y_rot": make_field(0x0e, word_t),
    "z_rot": make_field(0x10, word_t)
}, 0x14)

OBJECT_TYPE = enum_t("OBJECT_TYPE", {
    "LARA":                   0x000,
    "PISTOLS_ANIM":           0x001,
    "UZI_ANIM":               0x002,
    "SHOTGUN_ANIM":           0x003,
    "CROSSBOW_ANIM":          0x004,
    "HK_ANIM":                0x005,
    "REVOLVER_ANIM":          0x006,
    "FLARE_ANIM":             0x007,
    "LARA_SKIN":              0x008,
    "LARA_SKIN_JOINTS":       0x009,
    "LARA_SCREAM":            0x00a,
    "LARA_CROSSBOW_LASER":    0x00b,
    "LARA_REVOLVER_LASER":    0x00c,
    "LARA_HOLSTERS":          0x00d,
    "LARA_HOLSTERS_PISTOLS":  0x00e,
    "LARA_HOLSTERS_UZIS":     0x00f,
    "LARA_HOLSTERS_REVOLVER": 0x010,
    "LARA_SPEECH_HEAD1":      0x011,
    "LARA_SPEECH_HEAD2":      0x012,
    "LARA_SPEECH_HEAD3":      0x013,
    "LARA_SPEECH_HEAD4":      0x014,
    "ACTOR1_SPEECH_HEAD1":    0x015,
    "ACTOR1_SPEECH_HEAD2":    0x016,
    "ACTOR2_SPEECH_HEAD1":    0x017,
    "ACTOR2_SPEECH_HEAD2":    0x018,
    "LARA_EXTRA_MESH1":       0x019,
    "LARA_EXTRA_MESH2":       0x01a,
    "LARA_EXTRA_MESH3":       0x01b,
    "CROWBAR_ANIM":           0x01c,
    "TORCH_ANIM":             0x01d,
    "HAIR":                   0x01e,
    "SAS":                    0x01f,
    "SAS_MIP":                0x020,
    "SWAT":                   0x021,
    "SWAT_MIP":               0x022,
    "SWAT_PLUS":              0x023,
    "SWAT_PLUS_MIP":          0x024,
    "BLUE_GUARD":             0x025,
    "BLUE_GUARD_MIP":         0x026,
    "TWOGUN":                 0x027,
    "TWOGUN_MIP":             0x028,
    "DOG":                    0x029,
    "DOG_MIP":                0x02a,
    "CROW":                   0x02b,
    "CROW_MIP":               0x02c,
    "LARSON":                 0x02d,
    "LARSON_MIP":             0x02e,
    "PIERRE":                 0x02f,
    "PIERRE_MIP":             0x030,
    "MAFIA":                  0x031,
    "MAFIA_MIP":              0x032,
    "MAFIA2":                 0x033,
    "MAFIA2_MIP":             0x034,
    "SAILOR":                 0x035,
    "SAILOR_MIP":             0x036,
    "CRANE_GUY":              0x037,
    "CRANE_GUY_MIP":          0x038,
    "LION":                   0x039,
    "LION_MIP":               0x03a,
    "GLADIATOR":              0x03b,
    "GLADIATOR_MIP":          0x03c,
    "ROMAN_GOD":              0x03d,
    "ROMAN_GOD_MIP":          0x03e,
    "HYDRA":                  0x03f,
    "HYDRA_MIP":              0x040,
    "GUARDIAN":               0x041,
    "GUARDIAN_MIP":           0x042,
    "HITMAN":                 0x043,
    "HITMAN_MIP":             0x044,
    "SCIENTIST":              0x045,
    "SCIENTIST_MIP":          0x046,
    "WILLOWISP":              0x047,
    "WILLOWISP_MIP":          0x048,
    "SKELETON":               0x049,
    "SKELETON_MIP":           0x04a,
    "REAPER":                 0x04b,
    "REAPER_MIP":             0x04c,
    "MAZE_MONSTER":           0x04d,
    "MAZE_MONSTER_MIP":       0x04e,
    "GREEN_TEETH":            0x04f,
    "GREEN_TEETH_MIP":        0x050,
    "ATTACK_SUB":             0x051,
    "ATTACK_SUB_MIP":         0x052,
    "SNIPER":                 0x053,
    "SNIPER_MIP":             0x054,
    "HUSKIE":                 0x055,
    "HUSKIE_MIP":             0x056,
    "CHEF":                   0x057,
    "CHEF_MIP":               0x058,
    "IMP":                    0x059,
    "IMP_MIP":                0x05a,
    "GUNSHIP":                0x05b,
    "GUNSHIP_MIP":            0x05c,
    "BAT":                    0x05d,
    "RAT":                    0x05e,
    "SPIDER":                 0x05f,
    "SPIDER_GENERATOR":       0x060,
    "AUTOGUN":                0x061,
    "ELECTRICAL_CABLES":      0x062,
    "DARTS":                  0x063,
    "DART_EMITTER":           0x064,
    "HOMING_DART_EMITTER":    0x065,
    "FALLING_CEILING":        0x066,
    "FALLING_BLOCK":          0x067,
    "FALLING_BLOCK2":         0x068,
    "CRUMBLING_FLOOR":        0x069,
    "TRAPDOOR1":              0x06a,
    "TRAPDOOR2":              0x06b,
    "TRAPDOOR3":              0x06c,
    "FLOOR_TRAPDOOR1":        0x06d,
    "FLOOR_TRAPDOOR2":        0x06e,
    "CEILING_TRAPDOOR1":      0x06f,
    "CEILING_TRAPDOOR2":      0x070,
    "SCALING_TRAPDOOR":       0x071,
    "ROLLINGBALL":            0x072,
    "ROLLINGBARREL":          0x073,
    "SPIKEY_FLOOR":           0x074,
    "TEETH_SPIKES":           0x075,
    "ROME_HAMMER":            0x076,
    "HAMMER2":                0x077,
    "FLAME":                  0x078,
    "FLAME_EMITTER":          0x079,
    "FLAME_EMITTER2":         0x07a,
    "FLAME_EMITTER3":         0x07b,
    "COOKER_FLAME":           0x07c,
    "BURNING_ROOTS":          0x07d,
    "ROPE":                   0x07e,
    "FIREROPE":               0x07f,
    "POLEROPE":               0x080,
    "PROPELLER_H":            0x081,
    "PROPELLER_V":            0x082,
    "GRAPPLING_TARGET":       0x083,
    "ONEBLOCK_PLATFORM":      0x084,
    "TWOBLOCK_PLATFORM":      0x085,
    "RAISING_BLOCK1":         0x086,
    "RAISING_BLOCK2":         0x087,
    "EXPANDING_PLATFORM":     0x088,
    "PUSHABLE_OBJECT1":       0x089,
    "PUSHABLE_OBJECT2":       0x08a,
    "PUSHABLE_OBJECT3":       0x08b,
    "PUSHABLE_OBJECT4":       0x08c,
    "PUSHABLE_OBJECT5":       0x08d,
    "WRECKING_BALL":          0x08e,
    "DEATH_SLIDE":            0x08f,
    "TORPEDO":                0x090,
    "CHAFF":                  0x091,
    "SATCHEL_BOMB":           0x092,
    "ELECTRIC_FENCE":         0x093,
    "LIFT":                   0x094,
    "EXPLOSION":              0x095,
    "IRIS_LIGHTNING":         0x096,
    "MONITOR_SCREEN":         0x097,
    "SECURITY_SCREENS":       0x098,
    "MOTION_SENSORS":         0x099,
    "TIGHT_ROPE":             0x09a,
    "PARALLEL_BARS":          0x09b,
    "XRAY_CONTROLLER":        0x09c,
    "CUTSCENE_ROPE":          0x09d,
    "PORTAL":                 0x09e,
    "GEN_SLOT1":              0x09f,
    "GEN_SLOT2":              0x0a0,
    "GEN_SLOT3":              0x0a1,
    "GEN_SLOT4":              0x0a2,
    "IMP_ROCK":               0x0a3,
    "SEARCH_OBJECT1":         0x0a4,
    "SEARCH_OBJECT1_MIP":     0x0a5,
    "SEARCH_OBJECT2":         0x0a6,
    "SEARCH_OBJECT2_MIP":     0x0a7,
    "SEARCH_OBJECT3":         0x0a8,
    "SEARCH_OBJECT3_MIP":     0x0a9,
    "SEARCH_OBJECT4":         0x0aa,
    "SEARCH_OBJECT4_MIP":     0x0ab,
    "PUZZLE_ITEM1":           0x0ac,
    "PUZZLE_ITEM2":           0x0ad,
    "PUZZLE_ITEM3":           0x0ae,
    "PUZZLE_ITEM4":           0x0af,
    "PUZZLE_ITEM5":           0x0b0,
    "PUZZLE_ITEM6":           0x0b1,
    "PUZZLE_ITEM7":           0x0b2,
    "PUZZLE_ITEM8":           0x0b3,
    "PUZZLE_ITEM1_COMBO1":    0x0b4,
    "PUZZLE_ITEM1_COMBO2":    0x0b5,
    "PUZZLE_ITEM2_COMBO1":    0x0b6,
    "PUZZLE_ITEM2_COMBO2":    0x0b7,
    "PUZZLE_ITEM3_COMBO1":    0x0b8,
    "PUZZLE_ITEM3_COMBO2":    0x0b9,
    "PUZZLE_ITEM4_COMBO1":    0x0ba,
    "PUZZLE_ITEM4_COMBO2":    0x0bb,
    "PUZZLE_ITEM5_COMBO1":    0x0bc,
    "PUZZLE_ITEM5_COMBO2":    0x0bd,
    "PUZZLE_ITEM6_COMBO1":    0x0be,
    "PUZZLE_ITEM6_COMBO2":    0x0bf,
    "PUZZLE_ITEM7_COMBO1":    0x0c0,
    "PUZZLE_ITEM7_COMBO2":    0x0c1,
    "PUZZLE_ITEM8_COMBO1":    0x0c2,
    "PUZZLE_ITEM8_COMBO2":    0x0c3,
    "KEY_ITEM1":              0x0c4,
    "KEY_ITEM2":              0x0c5,
    "KEY_ITEM3":              0x0c6,
    "KEY_ITEM4":              0x0c7,
    "KEY_ITEM5":              0x0c8,
    "KEY_ITEM6":              0x0c9,
    "KEY_ITEM7":              0x0ca,
    "KEY_ITEM8":              0x0cb,
    "KEY_ITEM1_COMBO1":       0x0cc,
    "KEY_ITEM1_COMBO2":       0x0cd,
    "KEY_ITEM2_COMBO1":       0x0ce,
    "KEY_ITEM2_COMBO2":       0x0cf,
    "KEY_ITEM3_COMBO1":       0x0d0,
    "KEY_ITEM3_COMBO2":       0x0d1,
    "KEY_ITEM4_COMBO1":       0x0d2,
    "KEY_ITEM4_COMBO2":       0x0d3,
    "KEY_ITEM5_COMBO1":       0x0d4,
    "KEY_ITEM5_COMBO2":       0x0d5,
    "KEY_ITEM6_COMBO1":       0x0d6,
    "KEY_ITEM6_COMBO2":       0x0d7,
    "KEY_ITEM7_COMBO1":       0x0d8,
    "KEY_ITEM7_COMBO2":       0x0d9,
    "KEY_ITEM8_COMBO1":       0x0da,
    "KEY_ITEM8_COMBO2":       0x0db,
    "PICKUP_ITEM1":           0x0dc,
    "PICKUP_ITEM2":           0x0dd,
    "PICKUP_ITEM3":           0x0de,
    "PICKUP_ITEM4":           0x0df,
    "PICKUP_ITEM1_COMBO1":    0x0e0,
    "PICKUP_ITEM1_COMBO2":    0x0e1,
    "PICKUP_ITEM2_COMBO1":    0x0e2,
    "PICKUP_ITEM2_COMBO2":    0x0e3,
    "PICKUP_ITEM3_COMBO1":    0x0e4,
    "PICKUP_ITEM3_COMBO2":    0x0e5,
    "PICKUP_ITEM4_COMBO1":    0x0e6,
    "PICKUP_ITEM4_COMBO2":    0x0e7,
    "EXAMINE1":               0x0e8,
    "EXAMINE2":               0x0e9,
    "EXAMINE3":               0x0ea,
    "BOTTLE":                 0x0eb,
    "CLOTH":                  0x0ec,
    "WET_CLOTH":              0x0ed,
    "COSH":                   0x0ee,
    "HAMMER_ITEM":            0x0ef,
    "CROWBAR_ITEM":           0x0f0,
    "BURNING_TORCH_ITEM":     0x0f1,
    "PUZZLE_HOLE1":           0x0f2,
    "PUZZLE_HOLE2":           0x0f3,
    "PUZZLE_HOLE3":           0x0f4,
    "PUZZLE_HOLE4":           0x0f5,
    "PUZZLE_HOLE5":           0x0f6,
    "PUZZLE_HOLE6":           0x0f7,
    "PUZZLE_HOLE7":           0x0f8,
    "PUZZLE_HOLE8":           0x0f9,
    "PUZZLE_DONE1":           0x0fa,
    "PUZZLE_DONE2":           0x0fb,
    "PUZZLE_DONE3":           0x0fc,
    "PUZZLE_DONE4":           0x0fd,
    "PUZZLE_DONE5":           0x0fe,
    "PUZZLE_DONE6":           0x0ff,
    "PUZZLE_DONE7":           0x100,
    "PUZZLE_DONE8":           0x101,
    "KEY_HOLE1":              0x102,
    "KEY_HOLE2":              0x103,
    "KEY_HOLE3":              0x104,
    "KEY_HOLE4":              0x105,
    "KEY_HOLE5":              0x106,
    "KEY_HOLE6":              0x107,
    "KEY_HOLE7":              0x108,
    "KEY_HOLE8":              0x109,
    "SWITCH_TYPE1":           0x10a,
    "SWITCH_TYPE2":           0x10b,
    "SWITCH_TYPE3":           0x10c,
    "SWITCH_TYPE4":           0x10d,
    "SWITCH_TYPE5":           0x10e,
    "SWITCH_TYPE6":           0x10f,
    "SWITCH_TYPE7":           0x110,
    "SWITCH_TYPE8":           0x111,
    "AIRLOCK_SWITCH":         0x112,
    "UNDERWATER_SWITCH1":     0x113,
    "UNDERWATER_SWITCH2":     0x114,
    "TURN_SWITCH":            0x115,
    "COG_SWITCH":             0x116,
    "LEVER_SWITCH":           0x117,
    "JUMP_SWITCH":            0x118,
    "CROWBAR_SWITCH":         0x119,
    "PULLEY":                 0x11a,
    "CROWDOVE_SWITCH":        0x11b,
    "DOOR_TYPE1":             0x11c,
    "DOOR_TYPE1_MIP":         0x11d,
    "DOOR_TYPE2":             0x11e,
    "DOOR_TYPE2_MIP":         0x11f,
    "DOOR_TYPE3":             0x120,
    "DOOR_TYPE3_MIP":         0x121,
    "DOOR_TYPE4":             0x122,
    "DOOR_TYPE4_MIP":         0x123,
    "DOOR_TYPE5":             0x124,
    "DOOR_TYPE5_MIP":         0x125,
    "DOOR_TYPE6":             0x126,
    "DOOR_TYPE6_MIP":         0x127,
    "DOOR_TYPE7":             0x128,
    "DOOR_TYPE7_MIP":         0x129,
    "DOOR_TYPE8":             0x12a,
    "DOOR_TYPE8_MIP":         0x12b,
    "CLOSED_DOOR1":           0x12c,
    "CLOSED_DOOR1_MIP":       0x12d,
    "CLOSED_DOOR2":           0x12e,
    "CLOSED_DOOR2_MIP":       0x12f,
    "CLOSED_DOOR3":           0x130,
    "CLOSED_DOOR3_MIP":       0x131,
    "CLOSED_DOOR4":           0x132,
    "CLOSED_DOOR4_MIP":       0x133,
    "CLOSED_DOOR5":           0x134,
    "CLOSED_DOOR5_MIP":       0x135,
    "CLOSED_DOOR6":           0x136,
    "CLOSED_DOOR6_MIP":       0x137,
    "LIFT_DOORS1":            0x138,
    "LIFT_DOORS1_MIP":        0x139,
    "LIFT_DOORS2":            0x13a,
    "LIFT_DOORS2_MIP":        0x13b,
    "PUSHPULL_DOOR1":         0x13c,
    "PUSHPULL_DOOR1_MIP":     0x13d,
    "PUSHPULL_DOOR2":         0x13e,
    "PUSHPULL_DOOR2_MIP":     0x13f,
    "KICK_DOOR1":             0x140,
    "KICK_DOOR1_MIP":         0x141,
    "KICK_DOOR2":             0x142,
    "KICK_DOOR2_MIP":         0x143,
    "UNDERWATER_DOOR":        0x144,
    "UNDERWATER_DOOR_MIP":    0x145,
    "DOUBLE_DOORS":           0x146,
    "DOUBLE_DOORS_MIP":       0x147,
    "SEQUENCE_DOOR1":         0x148,
    "SEQUENCE_SWITCH1":       0x149,
    "SEQUENCE_SWITCH2":       0x14a,
    "SEQUENCE_SWITCH3":       0x14b,
    "STEEL_DOOR":             0x14c,
    "GOD_HEAD":               0x14d,
    "PISTOLS_ITEM":           0x14e,
    "PISTOLS_AMMO_ITEM":      0x14f,
    "UZI_ITEM":               0x150,
    "UZI_AMMO_ITEM":          0x151,
    "SHOTGUN_ITEM":           0x152,
    "SHOTGUN_AMMO1_ITEM":     0x153,
    "SHOTGUN_AMMO2_ITEM":     0x154,
    "CROSSBOW_ITEM":          0x155,
    "CROSSBOW_AMMO1_ITEM":    0x156,
    "CROSSBOW_AMMO2_ITEM":    0x157,
    "CROSSBOW_BOLT":          0x158,
    "HK_ITEM":                0x159,
    "HK_AMMO_ITEM":           0x15a,
    "REVOLVER_ITEM":          0x15b,
    "REVOLVER_AMMO_ITEM":     0x15c,
    "BIGMEDI_ITEM":           0x15d,
    "SMALLMEDI_ITEM":         0x15e,
    "LASERSIGHT_ITEM":        0x15f,
    "BINOCULARS_ITEM":        0x160,
    "SILENCER_ITEM":          0x161,
    "FLARE_ITEM":             0x162,
    "FLARE_INV_ITEM":         0x163,
    "COMPASS_ITEM":           0x164,
    "MEMCARD_LOAD_INV_ITEM":  0x165,
    "MEMCARD_SAVE_INV_ITEM":  0x166,
    "PC_LOAD_INV_ITEM":       0x167,
    "PC_SAVE_INV_ITEM":       0x168,
    "DC_LOAD_INV_ITEM":       0x169,
    "DC_SAVE_INV_ITEM":       0x16a,
    "SMOKE_EMITTER_WHITE":    0x16b,
    "SMOKE_EMITTER_BLACK":    0x16c,
    "STEAM_EMITTER":          0x16d,
    "EARTHQUAKE":             0x16e,
    "BUBBLES":                0x16f,
    "WATERFALLMIST":          0x170,
    "GUNSHELL":               0x171,
    "SHOTGUNSHELL":           0x172,
    "GUN_FLASH":              0x173,
    "COLOURED_LIGHT":         0x174,
    "BLINKING_LIGHT":         0x175,
    "PULSE_LIGHT":            0x176,
    "STROBE_LIGHT":           0x177,
    "ELECTRICAL_LIGHT":       0x178,
    "LENS_FLARE":             0x179,
    "AI_GUARD":               0x17a,
    "AI_AMBUSH":              0x17b,
    "AI_PATROL1":             0x17c,
    "AI_MODIFY":              0x17d,
    "AI_FOLLOW":              0x17e,
    "AI_PATROL2":             0x17f,
    "AI_X1":                  0x180,
    "AI_X2":                  0x181,
    "LARA_START_POS":         0x182,
    "TELEPORTER":             0x183,
    "LIFT_TELEPORTER":        0x184,
    "RAISING_COG":            0x185,
    "LASERS":                 0x186,
    "STEAM_LASERS":           0x187,
    "FLOOR_LASERS":           0x188,
    "KILL_ALL_TRIGGERS":      0x189,
    "TRIGGER_TRIGGERER":      0x18a,
    "HIGH_OBJECT1":           0x18b,
    "HIGH_OBJECT2":           0x18c,
    "SMASH_OBJECT1":          0x18d,
    "SMASH_OBJECT2":          0x18e,
    "SMASH_OBJECT3":          0x18f,
    "SMASH_OBJECT4":          0x190,
    "SMASH_OBJECT5":          0x191,
    "SMASH_OBJECT6":          0x192,
    "SMASH_OBJECT7":          0x193,
    "SMASH_OBJECT8":          0x194,
    "MESHSWAP1":              0x195,
    "MESHSWAP2":              0x196,
    "MESHSWAP3":              0x197,
    "BODY_PART":              0x198,
    "CAMERA_TARGET":          0x199,
    "WATERFALL1":             0x19a,
    "WATERFALL2":             0x19b,
    "WATERFALL3":             0x19c,
    "FISHTANK":               0x19d,
    "WATERFALLSS1":           0x19e,
    "WATERFALLSS2":           0x19f,
    "ANIMATING1":             0x1a0,
    "ANIMATING1_MIP":         0x1a1,
    "ANIMATING2":             0x1a2,
    "ANIMATING2_MIP":         0x1a3,
    "ANIMATING3":             0x1a4,
    "ANIMATING3_MIP":         0x1a5,
    "ANIMATING4":             0x1a6,
    "ANIMATING4_MIP":         0x1a7,
    "ANIMATING5":             0x1a8,
    "ANIMATING5_MIP":         0x1a9,
    "ANIMATING6":             0x1aa,
    "ANIMATING6_MIP":         0x1ab,
    "ANIMATING7":             0x1ac,
    "ANIMATING7_MIP":         0x1ad,
    "ANIMATING8":             0x1ae,
    "ANIMATING8_MIP":         0x1af,
    "ANIMATING9":             0x1b0,
    "ANIMATING9_MIP":         0x1b1,
    "ANIMATING10":            0x1b2,
    "ANIMATING10_MIP":        0x1b3,
    "ANIMATING11":            0x1b4,
    "ANIMATING11_MIP":        0x1b5,
    "ANIMATING12":            0x1b6,
    "ANIMATING12_MIP":        0x1b7,
    "ANIMATING13":            0x1b8,
    "ANIMATING13_MIP":        0x1b9,
    "ANIMATING14":            0x1ba,
    "ANIMATING14_MIP":        0x1bb,
    "ANIMATING15":            0x1bc,
    "ANIMATING15_MIP":        0x1bd,
    "ANIMATING16":            0x1be,
    "ANIMATING16_MIP":        0x1bf,
    "BRIDGE_FLAT":            0x1c0,
    "BRIDGE_FLAT_MIP":        0x1c1,
    "BRIDGE_TILT1":           0x1c2,
    "BRIDGE_TILT1_MIP":       0x1c3,
    "BRIDGE_TILT2":           0x1c4,
    "BRIDGE_TILT2_MIP":       0x1c5,
    "HORIZON":                0x1c6,
    "SKY_GRAPHICS":           0x1c7,
    "BINOCULAR_GRAPHICS":     0x1c8,
    "TARGET_GRAPHICS":        0x1c9,
    "DEFAULT_SPRITES":        0x1ca,
    "MISC_SPRITES":           0x1cb,
    "NUMBER_OBJECTS":         0x1cc
}, word_t)

LARA_GUN_STATUS = enum_t("LARA_GUN_STATUS", {
    "NO_ARMS":     0x0,
    "HANDS_BUSY":  0x1,
    "DRAW_GUNS":   0x2,
    "UNDRAW_GUNS": 0x3,
    "READY":       0x4,
    "FLARE":       0x5
}, word_t)

WEAPON_TYPE = enum_t("WEAPON_TYPE", {
    "NONE":     0x0,
    "PISTOLS":  0x1,
    "REVOLVER": 0x2,
    "UZI":      0x3,
    "SHOTGUN":  0x4,
    "HK":       0x5,
    "CROSSBOW": 0x6,
    "FLARE":    0x7,
    "FLARE_2":  0x8
}, word_t)

LARA_WATER_STATUS = enum_t("LARA_WATER_STATUS", {
    "ABOVE_WATER": 0x0,
    "UNDERWATER":  0x1,
    "SURFACE":     0x2,
    "FLYCHEAT":    0x3,
    "WADE":        0x4
}, word_t)

LARA_FLAGS = bitflags_t("LARA_FLAGS", {
    "LOOK":             make_bitflag(0x0, bit2_t),
    "BURN":             make_bitflag(0x0, bit3_t),
    "IS_MOVING":        make_bitflag(0x0, bit5_t),
    "CAN_MONKEY_SWING": make_bitflag(0x0, bit6_t),
    "GASSED":           make_bitflag(0x1, bit1_t),
    "BURN_SMOKE":       make_bitflag(0x1, bit2_t),
    "IS_DUCKED":        make_bitflag(0x1, bit3_t),
    "HAS_FIRED":        make_bitflag(0x1, bit4_t),
    "BUSY":             make_bitflag(0x1, bit5_t),
    "IS_CLIMBING":      make_bitflag(0x1, bit7_t),
    "FIRED":            make_bitflag(0x2, bit0_t),
}, dword_t)

FX_INFO = struct_t("FX_INFO", {
    "pos":           make_field(0x00, PHD_3DPOS),
    "room_number":   make_field(0x14, word_t),
    "object_number": make_field(0x16, OBJECT_TYPE),
    "next_fx":       make_field(0x18, word_t),
    "next_active":   make_field(0x1a, word_t),
    "speed":         make_field(0x1c, word_t),
    "fallspeed":     make_field(0x1e, word_t),
    "frame_number":  make_field(0x20, word_t),
    "counter":       make_field(0x22, word_t),
    "shade":         make_field(0x24, word_t),
    "flag1":         make_field(0x26, word_t),
    "flag2":         make_field(0x28, word_t)
}, 0x2a)

ITEM_FLAGS = bitflags_t("ITEM_FLAGS", {
    "UNK_40":            make_bitflag(0x0, bit6_t),
    "CLEAR_BODY":        make_bitflag(0x0, bit7_t),
    "INVISIBLE":         make_bitflag(0x1, bit0_t),
    "ACTIVATION_MASK_0": make_bitflag(0x1, bit1_t),
    "ACTIVATION_MASK_1": make_bitflag(0x1, bit2_t),
    "ACTIVATION_MASK_2": make_bitflag(0x1, bit3_t),
    "ACTIVATION_MASK_3": make_bitflag(0x1, bit4_t),
    "ACTIVATION_MASK_4": make_bitflag(0x1, bit5_t),
    "REVERSE":           make_bitflag(0x1, bit6_t),
    "KILLED":            make_bitflag(0x1, bit7_t)
}, word_t)

ILIGHT = struct_t("ILIGHT", {
    "x": make_field(0x0, word_t),
    "y": make_field(0x2, word_t),
    "z": make_field(0x4, word_t),
    "r": make_field(0x8, byte_t),
    "g": make_field(0x9, byte_t),
    "b": make_field(0xa, byte_t)
}, 0xc)

ITEM_LIGHT = struct_t("ITEM_LIGHT", {
    "Light": make_field(0x0, array_t(ILIGHT, 4))
}, 0x30)

ITEM_FLAGS_2 = bitflags_t("ITEM_FLAGS_2", {
    "ACTIVE":         make_bitflag(0x0, bit0_t),
    "ITEM_STATUS_0":  make_bitflag(0x0, bit1_t),
    "ITEM_STATUS_1":  make_bitflag(0x0, bit2_t),
    "GRAVITY_STATUS": make_bitflag(0x0, bit3_t),
    "COLLIDABLE":     make_bitflag(0x0, bit4_t)
}, dword_t)

ITEM_INFO = struct_t("ITEM_INFO", {
    "floor":               make_field(0x00, dword_t),
    "touch_bits":          make_field(0x04, dword_t),
    "mesh_bits":           make_field(0x08, dword_t),
    "object_number":       make_field(0x0c, OBJECT_TYPE),
    "current_anim_state":  make_field(0x0e, word_t),
    "goal_anim_state":     make_field(0x10, word_t),
    "required_anim_state": make_field(0x12, word_t),
    "anim_number":         make_field(0x14, word_t),
    "frame_number":        make_field(0x16, word_t),
    "room_number":         make_field(0x18, word_t),
    "next_item":           make_field(0x1a, word_t),
    "next_active":         make_field(0x1c, word_t),
    "speed":               make_field(0x1e, word_t),
    "fallspeed":           make_field(0x20, word_t),
    "hit_points":          make_field(0x22, word_t),
    "box_number":          make_field(0x24, word_t),
    "timer":               make_field(0x26, word_t),
    "flags":               make_field(0x28, ITEM_FLAGS),
    "shade":               make_field(0x2a, word_t),
    "trigger_flags":       make_field(0x2c, word_t),
    "carried_item":        make_field(0x2e, word_t),
    "after_death":         make_field(0x30, word_t),
    "fired_weapon":        make_field(0x32, word_t),
    "item_flags":          make_field(0x34, array_t(word_t, 4)),
    "data":                make_field(0x3c, pointer_t(byte_t)),
    "pos":                 make_field(0x40, PHD_3DPOS),
    "li":                  make_field(0x54, ITEM_LIGHT),
    "flags2":              make_field(0x84, ITEM_FLAGS_2),
    "meshswap_meshbits":   make_field(0x88, dword_t),
    "draw_room":           make_field(0x8c, word_t),
    "tosspad":             make_field(0x8e, word_t)
}, 0x90)

LARA_ARM = struct_t("LARA_ARM", {
    "frame_base":   make_field(0x00, pointer_t(word_t)),
    "frame_number": make_field(0x04, word_t),
    "anim_number":  make_field(0x06, word_t),
    "lock":         make_field(0x08, word_t),
    "y_rot":        make_field(0x0a, word_t),
    "x_rot":        make_field(0x0c, word_t),
    "z_rot":        make_field(0x0e, word_t),
    "flash_gun":    make_field(0x10, word_t)
}, 0x14)

BOX_NODE = struct_t("BOX_NODE", {
    "exit_box":       make_field(0x0, word_t),
    "search_number":  make_field(0x2, word_t),
    "next_expansion": make_field(0x4, word_t),
    "box_number":     make_field(0x6, word_t)
}, 0x8)

ZONE_TYPE = enum_t("ZONE_TYPE", {
    "SKELLY": 0x0,
    "BASIC":  0x1,
    "CROC":   0x2,
    "HUMAN":  0x3,
    "FLYER":  0x4
}, dword_t)

LOT_INFO = struct_t("LOT_INFO", {
    "node":          make_field(0x00, pointer_t(BOX_NODE)),
    "head":          make_field(0x04, word_t),
    "tail":          make_field(0x06, word_t),
    "search_number": make_field(0x08, word_t),
    "block_mask":    make_field(0x0a, word_t),
    "step":          make_field(0x0c, word_t),
    "drop":          make_field(0x0e, word_t),
    "zone_count":    make_field(0x10, word_t),
    "target_box":    make_field(0x12, word_t),
    "required_box":  make_field(0x14, word_t),
    "fly":           make_field(0x16, word_t),
    "flags":         make_field(0x18, dword_t),
    "target":        make_field(0x1c, PHD_VECTOR),
    "zone":          make_field(0x28, ZONE_TYPE)
}, 0x2c)

MOOD_TYPE = enum_t("MOOD_TYPE", {
    "BORED":  0x0,
    "ATTACK": 0x1,
    "ESCAPE": 0x2,
    "STALK":  0x3
}, dword_t)

CREATURE_FLAGS2 = bitflags_t("CREATURE_FLAGS2", {
    "ALERTED":      make_bitflag(0x0, bit0_t),
    "HEAD_LEFT":    make_bitflag(0x0, bit1_t),
    "HEAD_RIGHT":   make_bitflag(0x0, bit2_t),
    "REACHED_GOAL": make_bitflag(0x0, bit3_t),
    "HURT_BY_LARA": make_bitflag(0x0, bit4_t),
    "PATROL2":      make_bitflag(0x0, bit5_t),
    "JUMP_AHEAD":   make_bitflag(0x0, bit6_t),
    "MONKEY_AHEAD": make_bitflag(0x0, bit7_t)
}, word_t)

CREATURE_INFO = struct_t("CREATURE_INFO", {
    "joint_rotation": make_field(0x00, array_t(word_t, 4)),
    "maximum_turn":   make_field(0x08, word_t),
    "flags":          make_field(0x0a, word_t),
    "flags2":         make_field(0x0c, CREATURE_FLAGS2),
    "mood":           make_field(0x10, MOOD_TYPE),
    "enemy":          make_field(0x14, pointer_t(ITEM_INFO)),
    "ai_target":      make_field(0x18, ITEM_INFO),
    "item_num":       make_field(0xaa, word_t),
    "target":         make_field(0xac, PHD_VECTOR),
    "lot":            make_field(0xb8, LOT_INFO)
}, 0xe4)

WEAPON_TYPE_CARRIED = bitflags_t("WEAPON_TYPE_CARRIED", {
    "PRESENT":    make_bitflag(0x0, bit0_t),
    "SILENCER":   make_bitflag(0x0, bit1_t),
    "LASERSIGHT": make_bitflag(0x0, bit2_t),
    "AMMO_1":     make_bitflag(0x0, bit3_t),
    "AMMO_2":     make_bitflag(0x0, bit4_t),
    "AMMO_3":     make_bitflag(0x0, bit5_t)
}, byte_t)

LARA_INFO = struct_t("LARA_INFO", {
    "item_number":             make_field(0x000, word_t),
    "gun_status":              make_field(0x002, LARA_GUN_STATUS),
    "gun_type":                make_field(0x004, WEAPON_TYPE),
    "request_gun_type":        make_field(0x006, WEAPON_TYPE),
    "last_gun_type":           make_field(0x008, WEAPON_TYPE),
    "calc_fallspeed":          make_field(0x00a, word_t),
    "water_status":            make_field(0x00c, LARA_WATER_STATUS),
    "climb_status":            make_field(0x00e, word_t),
    "pose_count":              make_field(0x010, word_t),
    "hit_frame":               make_field(0x012, word_t),
    "hit_direction":           make_field(0x014, word_t),
    "air":                     make_field(0x016, word_t),
    "dive_count":              make_field(0x018, word_t),
    "death_count":             make_field(0x01a, word_t),
    "current_active":          make_field(0x01c, word_t),
    "current_xvel":            make_field(0x01e, word_t),
    "current_yvel":            make_field(0x020, word_t),
    "current_zvel":            make_field(0x022, word_t),
    "spaz_effect_count":       make_field(0x024, word_t),
    "flare_age":               make_field(0x026, word_t),
    "burn_count":              make_field(0x028, word_t),
    "weapon_item":             make_field(0x02a, word_t),
    "back_gun":                make_field(0x02c, word_t),
    "flare_frame":             make_field(0x02e, word_t),
    "poisoned":                make_field(0x030, word_t),
    "dpoisoned":               make_field(0x032, word_t),
    "anxiety":                 make_field(0x034, byte_t),
    "wet":                     make_field(0x035, array_t(byte_t, 15)),
    "flags":                   make_field(0x044, LARA_FLAGS),
    "water_surface_dist":      make_field(0x048, dword_t),
    "last_pos":                make_field(0x04c, PHD_VECTOR),
    "spaz_effect":             make_field(0x058, pointer_t(FX_INFO)),
    "mesh_effects":            make_field(0x05c, dword_t),
    "mesh_ptrs":               make_field(0x060, array_t(pointer_t(word_t), 15)),
    "target":                  make_field(0x09c, pointer_t(ITEM_INFO)),
    "target_angles":           make_field(0x0a0, array_t(word_t, 2)),
    "turn_rate":               make_field(0x0a4, word_t),
    "move_angle":              make_field(0x0a6, word_t),
    "head_y_rot":              make_field(0x0a8, word_t),
    "head_x_rot":              make_field(0x0aa, word_t),
    "head_z_rot":              make_field(0x0ac, word_t),
    "torso_y_rot":             make_field(0x0ae, word_t),
    "torso_x_rot":             make_field(0x0b0, word_t),
    "torso_z_rot":             make_field(0x0b2, word_t),
    "left_arm":                make_field(0x0b4, LARA_ARM),
    "right_arm":               make_field(0x0c8, LARA_ARM),
    "holster":                 make_field(0x0dc, word_t),
    "creature":                make_field(0x0e0, pointer_t(CREATURE_INFO)),
    "corner_x":                make_field(0x0e4, dword_t),
    "corner_y":                make_field(0x0e8, dword_t),
    "rope_segment":            make_field(0x0ec, byte_t),
    "rope_direction":          make_field(0x0ed, byte_t),
    "rope_arc_front":          make_field(0x0ee, word_t),
    "rope_arc_back":           make_field(0x0f0, word_t),
    "rope_last_x":             make_field(0x0f2, word_t),
    "rope_max_x_forward":      make_field(0x0f4, word_t),
    "rope_max_x_backward":     make_field(0x0f6, word_t),
    "rope_d_frame":            make_field(0x0f8, dword_t),
    "rope_frame":              make_field(0x0fc, dword_t),
    "rope_frame_rate":         make_field(0x100, word_t),
    "rope_y":                  make_field(0x102, word_t),
    "rope_ptr":                make_field(0x104, pointer_t(byte_t)),
    "general_ptr":             make_field(0x108, pointer_t(byte_t)),
    "rope_offset":             make_field(0x10c, dword_t),
    "rope_down_vel":           make_field(0x110, dword_t),
    "rope_flag":               make_field(0x114, byte_t),
    "move_count":              make_field(0x115, byte_t),
    "rope_count":              make_field(0x118, dword_t),
    "skelebob":                make_field(0x11c, byte_t),
    "pistols_type_carried":    make_field(0x11d, WEAPON_TYPE_CARRIED),
    "uzis_type_carried":       make_field(0x11e, WEAPON_TYPE_CARRIED),
    "shotgun_type_carried":    make_field(0x11f, WEAPON_TYPE_CARRIED),
    "crossbow_type_carried":   make_field(0x120, WEAPON_TYPE_CARRIED),
    "hk_type_carried":         make_field(0x121, WEAPON_TYPE_CARRIED),
    "sixshooter_type_carried": make_field(0x122, WEAPON_TYPE_CARRIED),
    "lasersight":              make_field(0x123, byte_t),
    "silencer":                make_field(0x124, byte_t),
    "binoculars":              make_field(0x125, byte_t),
    "crowbar":                 make_field(0x126, byte_t),
    "examine1":                make_field(0x127, byte_t),
    "examine2":                make_field(0x128, byte_t),
    "examine3":                make_field(0x129, byte_t),
    "wetcloth":                make_field(0x12a, byte_t),
    "bottle":                  make_field(0x12b, byte_t),
    "puzzle_items":            make_field(0x12c, array_t(byte_t, 12)),
    "puzzle_items_combo":      make_field(0x138, word_t),
    "key_items":               make_field(0x13a, word_t),
    "key_items_combo":         make_field(0x13c, word_t),
    "pickup_items":            make_field(0x13e, word_t),
    "pickup_items_combo":      make_field(0x140, word_t),
    "num_small_medipack":      make_field(0x142, word_t),
    "num_large_medipack":      make_field(0x144, word_t),
    "num_flares":              make_field(0x146, word_t),
    "num_pistols_ammo":        make_field(0x148, word_t),
    "num_uzi_ammo":            make_field(0x14a, word_t),
    "num_revolver_ammo":       make_field(0x14c, word_t),
    "num_shotgun_ammo1":       make_field(0x14e, word_t),
    "num_shotgun_ammo2":       make_field(0x150, word_t),
    "num_hk_ammo":             make_field(0x152, word_t),
    "num_crossbow_ammo1":      make_field(0x154, word_t),
    "num_crossbow_ammo2":      make_field(0x156, word_t),
    "location":                make_field(0x158, byte_t),
    "highest_location":        make_field(0x159, byte_t),
    "location_pad":            make_field(0x15a, byte_t),
    "tight_rope_on_count":     make_field(0x15b, byte_t),
    "tight_rope_off":          make_field(0x15c, byte_t),
    "tight_rope_fall":         make_field(0x15d, byte_t),
    "chaff_timer":             make_field(0x15e, byte_t)
}, 0x160)

STATS = struct_t("STATS", {
    "timer":       make_field(0x00, dword_t),
    "distance":    make_field(0x04, dword_t),
    "ammo_used":   make_field(0x08, dword_t),
    "ammo_hits":   make_field(0x0c, dword_t),
    "kills":       make_field(0x10, word_t),
    "secrets":     make_field(0x12, byte_t),
    "health_used": make_field(0x13, byte_t)
}, 0x14)

SAVEGAME_INFO = struct_t("SAVEGAME_INFO", {
    "checksum":            make_field(0x000, word_t),
    "volume_cd":           make_field(0x002, word_t),
    "volume_sfx":          make_field(0x004, word_t),
    "screen_x":            make_field(0x006, word_t),
    "screen_y":            make_field(0x008, word_t),
    "control_option":      make_field(0x00a, byte_t),
    "vibrate_on":          make_field(0x00b, byte_t),
    "auto_target":         make_field(0x00c, byte_t),
    "lara":                make_field(0x010, LARA_INFO),
    "level":               make_field(0x170, STATS),
    "game":                make_field(0x184, STATS),
    "weapon_object":       make_field(0x198, word_t),
    "weapon_anim":         make_field(0x19a, word_t),
    "weapon_frame":        make_field(0x19c, word_t),
    "weapon_current":      make_field(0x19e, word_t),
    "weapon_goal":         make_field(0x1a0, word_t),
    "cutscene_triggered1": make_field(0x1a4, dword_t),
    "cutscene_triggered2": make_field(0x1a8, dword_t),
    "game_complete":       make_field(0x1ac, byte_t),
    "current_level":       make_field(0x1ad, LEVEL_ID),
    "campaign_secrets":    make_field(0x1ae, array_t(byte_t, 4)),
    "tl_count":            make_field(0x1b2, byte_t)
}, 0x1b4)

REQUESTER = struct_t("REQUESTER", {}, 0x14)

SWITCH_ANIM_STATE = enum_t("SWITCH_ANIM_STATE", {
    "ON":  0,
    "OFF": 1
}, word_t)

DOOR_ANIM_STATE = enum_t("DOOR_ANIM_STATE", {
    "CLOSED": 0,
    "OPEN":   1
}, word_t)

ITEM_STATUS = enum_t("ITEM_STATUS", {
    "INACTIVE":    0x0,
    "ACTIVE":      0x1,
    "DEACTIVATED": 0x2,
    "INVISIBLE":   0x3
}, byte_t)

LARA_ANIM_STATE = enum_t("LARA_ANIM_STATE", {
    "WALK_FORWARD":              0x000,
    "RUN_FORWARD":               0x001,
    "STOP":                      0x002,
    "JUMP_FORWARD":              0x003,
    "POSE":                      0x004,
    "RUN_BACK":                  0x005,
    "TURN_RIGHT_SLOW":           0x006,
    "TURN_LEFT_SLOW":            0x007,
    "DEATH":                     0x008,
    "FREEFALL":                  0x009,
    "HANG":                      0x00a,
    "REACH":                     0x00b,
    "SPLAT":                     0x00c,
    "UNDERWATER_STOP":           0x00d,
    "GRAB_TO_FALL":              0x00e,
    "JUMP_PREPARE":              0x00f,
    "WALK_BACK":                 0x010,
    "UNDERWATER_FORWARD":        0x011,
    "UNDERWATER_INERTIA":        0x012,
    "GRABBING":                  0x013,
    "TURN_FAST":                 0x014,
    "WALK_RIGHT":                0x015,
    "WALK_LEFT":                 0x016,
    "ROLL_BACKWARD":             0x017,
    "SLIDE_FORWARD":             0x018,
    "JUMP_BACK":                 0x019,
    "JUMP_LEFT":                 0x01a,
    "JUMP_RIGHT":                0x01b,
    "JUMP_UP":                   0x01c,
    "FALL_BACKWARD":             0x01d,
    "SHIMMY_LEFT":               0x01e,
    "SHIMMY_RIGHT":              0x01f,
    "SLIDE_BACK":                0x020,
    "ONWATER_STOP":              0x021,
    "ONWATER_FORWARD":           0x022,
    "UNDERWATER_DIVING":         0x023,
    "PUSHABLE_PUSH":             0x024,
    "PUSHABLE_PULL":             0x025,
    "PUSHABLE_GRAB":             0x026,
    "PICKUP":                    0x027,
    "SWITCH_DOWN":               0x028,
    "SWITCH_UP":                 0x029,
    "INSERT_KEY":                0x02a,
    "INSERT_PUZZLE":             0x02b,
    "WATER_DEATH":               0x02c,
    "ROLL_FORWARD":              0x02d,
    "BOULDER_DEATH":             0x02e,
    "ONWATER_BACK":              0x02f,
    "ONWATER_LEFT":              0x030,
    "ONWATER_RIGHT":             0x031,
    "USE_MIDAS":                 0x032,
    "DIE_MIDAS":                 0x033,
    "SWANDIVE_BEGIN":            0x034,
    "SWANDIVE_END":              0x035,
    "HANDSTAND":                 0x036,
    "ONWATER_EXIT":              0x037,
    "LADDER_IDLE":               0x038,
    "LADDER_UP":                 0x039,
    "LADDER_LEFT":               0x03a,
    "LADDER_END":                0x03b,
    "LADDER_RIGHT":              0x03c,
    "LADDER_DOWN":               0x03d,
    "NULL_62":                   0x03e,
    "NULL_63":                   0x03f,
    "NULL_64":                   0x040,
    "WADE_FORWARD":              0x041,
    "UNDERWATER_TURNAROUND":     0x042,
    "FLARE_PICKUP":              0x043,
    "JUMP_ROLL":                 0x044,
    "NULL_69":                   0x045,
    "ZIPLINE_RIDE":              0x046,
    "CROUCH_IDLE":               0x047,
    "CROUCH_ROLL":               0x048,
    "SPRINT":                    0x049,
    "SPRINT_ROLL":               0x04a,
    "MONKEYSWING_IDLE":          0x04b,
    "MONKEYSWING_FORWARD":       0x04c,
    "MONKEYSWING_LEFT":          0x04d,
    "MONKEYSWING_RIGHT":         0x04e,
    "MONKEYSWING_TURNAROUND":    0x04f,
    "CRAWL_IDLE":                0x050,
    "CRAWL_FORWARD":             0x051,
    "MONKEYSWING_TURN_LEFT":     0x052,
    "MONKEYSWING_TURN_RIGHT":    0x053,
    "CRAWL_TURN_LEFT":           0x054,
    "CRAWL_TURN_RIGHT":          0x055,
    "CRAWL_BACK":                0x056,
    "CLIMB_TO_CRAWL":            0x057,
    "CRAWL_TO_CLIMB":            0x058,
    "MISC_CONTROL":              0x059,
    "ROPE_TURN_LEFT":            0x05a,
    "ROPE_TURN_RIGHT":           0x05b,
    "GIANT_BUTTON_PUSH":         0x05c,
    "TRAPDOOR_FLOOR_OPEN":       0x05d,
    "FREEFALL_BIS":              0x05e,
    "ROUND_HANDLE":              0x05f,
    "COGWHEEL":                  0x060,
    "LEVERSWITCH_PUSH":          0x061,
    "HOLE":                      0x062,
    "POLE_IDLE":                 0x063,
    "POLE_UP":                   0x064,
    "POLE_DOWN":                 0x065,
    "POLE_TURN_LEFT":            0x066,
    "POLE_TURN_RIGHT":           0x067,
    "PULLEY":                    0x068,
    "CROUCH_TURN_LEFT":          0x069,
    "CROUCH_TURN_RIGHT":         0x06a,
    "CLIMB_CORNER_LEFT_OUTER":   0x06b,
    "CLIMB_CORNER_RIGHT_OUTER":  0x06c,
    "CLIMB_CORNER_LEFT_INNER":   0x06d,
    "CLIMB_CORNER_RIGHT_INNER":  0x06e,
    "ROPE_IDLE":                 0x06f,
    "ROPE_CLIMB_UP":             0x070,
    "ROPE_CLIMB_DOWN":           0x071,
    "ROPE_SWING":                0x072,
    "LADDER_TO_HANDS":           0x073,
    "POSITION_CORRECTOR":        0x074,
    "DOUBLEDOORS_PUSH":          0x075,
    "DOZY":                      0x076,
    "TIGHTROPE_IDLE":            0x077,
    "TIGHTROPE_TURNAROUND":      0x078,
    "TIGHTROPE_FORWARD":         0x079,
    "TIGHTROPE_BALANCING_LEFT":  0x07a,
    "TIGHTROPE_BALANCING_RIGHT": 0x07b,
    "TIGHTROPE_ENTER":           0x07c,
    "TIGHTROPE_EXIT":            0x07d,
    "DOVESWITCH":                0x07e,
    "TIGHTROPE_RESTORE_BALANCE": 0x07f,
    "BARS_SWING":                0x080,
    "BARS_JUMP":                 0x081,
    "UNKNOWN_130":               0x082,
    "RADIO_LISTENING":           0x083,
    "RADIO_OFF":                 0x084,
    "UNKNOWN_133":               0x085,
    "UNKNOWN_134":               0x086,
    "UNKNOWN_135":               0x087,
    "UNUSED16":                  0x088,
    "PICKUP_FROM_CHEST":         0x089,
    "UNKNOWN_138":               0x08a
}, word_t)

LARA_ANIM = enum_t("LARA_ANIM", {
    "RUN":                                 0x000,
    "WALK_FORWARD":                        0x001,
    "END_WALK_RIGHT":                      0x002,
    "END_WALK_LEFT":                       0x003,
    "WALK_TO_RUN_RIGHT":                   0x004,
    "WALK_TO_RUN_LEFT":                    0x005,
    "STAY_TO_RUN":                         0x006,
    "RUN_TO_WALK_RIGHT":                   0x007,
    "RUN_TO_STAY_LEFT":                    0x008,
    "RUN_TO_WALK_LEFT":                    0x009,
    "RUN_TO_STAY_RIGHT":                   0x00a,
    "STAY_SOLID":                          0x00b,
    "TURN_RIGHT_SLOW":                     0x00c,
    "TURN_LEFT_SLOW":                      0x00d,
    "LANDING_FORWARD_BOTH":                0x00e,
    "LANDING_FORWARD_BOTH_CONTINUE":       0x00f,
    "JUMPING_FORWARD_RIGHT":               0x010,
    "START_FLY_FORWARD_RIGHT":             0x011,
    "JUMPING_FORWARD_LEFT":                0x012,
    "START_FLY_FORWARD_LEFT":              0x013,
    "WALK_FORWARD_BEGIN":                  0x014,
    "WALK_FORWARD_BEGIN_CONTINUE":         0x015,
    "START_FREE_FALL":                     0x016,
    "FREE_FALL_LONG":                      0x017,
    "LANDING_HARD":                        0x018,
    "LANDING_DEATH":                       0x019,
    "STAY_TO_GRAB":                        0x01a,
    "STAY_TO_GRAB_CONTINUE":               0x01b,
    "TRY_HANG_VERTICAL":                   0x01c,
    "BEGIN_HANGING_VERTICAL":              0x01d,
    "STOP_HANG_VERTICAL":                  0x01e,
    "LANDING_LIGHT":                       0x01f,
    "SMASH_JUMP":                          0x020,
    "SMASH_JUMP_CONTINUE":                 0x021,
    "FREE_FALL_FORWARD":                   0x022,
    "FREE_FALL_MIDDLE":                    0x023,
    "FREE_FALL_LONG_NO_HURT":              0x024,
    "HANG_TO_RELEASE":                     0x025,
    "STOP_WALK_BACK_RIGHT":                0x026,
    "STOP_WALK_BACK_LEFT":                 0x027,
    "WALK_BACK":                           0x028,
    "START_WALK_BACK":                     0x029,
    "CLIMB_3CLICK":                        0x02a,
    "CLIMB_3CLICK_END_RUNNING":            0x02b,
    "ROTATE_RIGHT":                        0x02c,
    "JUMPING_FORWARD_TO_FREEFALL":         0x02d,
    "FLY_FORWARD_TRY_TO_HANG":             0x02e,
    "ROLL_ALTERNATE":                      0x02f,
    "ROLL_END_ALTERNATE":                  0x030,
    "FREE_FALL_NO_HURT":                   0x031,
    "CLIMB_2CLICK":                        0x032,
    "CLIMB_2CLICK_END":                    0x033,
    "CLIMB_2CLICK_END_RUNNING":            0x034,
    "WALL_SMASH_LEFT":                     0x035,
    "WALL_SMASH_RIGHT":                    0x036,
    "RUN_UP_STEP_RIGHT":                   0x037,
    "RUN_UP_STEP_LEFT":                    0x038,
    "WALK_UP_STEP_RIGHT":                  0x039,
    "WALK_UP_STEP_LEFT":                   0x03a,
    "WALK_DOWN_LEFT":                      0x03b,
    "WALK_DOWN_RIGHT":                     0x03c,
    "WALK_DOWN_BACK_LEFT":                 0x03d,
    "WALK_DOWN_BACK_RIGHT":                0x03e,
    "PULL_SWITCH_DOWN":                    0x03f,
    "PULL_SWITCH_UP":                      0x040,
    "WALK_LEFT":                           0x041,
    "WALK_LEFT_END":                       0x042,
    "WALK_RIGHT":                          0x043,
    "WALK_RIGHT_END":                      0x044,
    "ROTATE_LEFT":                         0x045,
    "SLIDE_FORWARD":                       0x046,
    "SLIDE_FORWARD_END":                   0x047,
    "SLIDE_FORWARD_STOP":                  0x048,
    "STAY_JUMP_SIDES":                     0x049,
    "JUMP_BACK_BEGIN":                     0x04a,
    "JUMP_BACK":                           0x04b,
    "JUMP_FORWARD_BEGIN":                  0x04c,
    "CONTINUE_FLY_FORWARD":                0x04d,
    "JUMP_LEFT_BEGIN":                     0x04e,
    "JUMP_LEFT":                           0x04f,
    "JUMP_RIGHT_BEGIN":                    0x050,
    "JUMP_RIGHT":                          0x051,
    "LANDING_MIDDLE":                      0x052,
    "FORWARD_TO_FREE_FALL":                0x053,
    "LEFT_TO_FREE_FALL":                   0x054,
    "RIGHT_TO_FREE_FALL":                  0x055,
    "UNDERWATER_SWIM_FORWARD":             0x056,
    "UNDERWATER_SWIM_SOLID":               0x057,
    "RUN_BACK_BEGIN":                      0x058,
    "RUN_BACK":                            0x059,
    "RUN_BACK_END":                        0x05a,
    "TRY_HANG_VERTICAL_BEGIN":             0x05b,
    "LANDING_FROM_RUN":                    0x05c,
    "FREE_FALL_BACK":                      0x05d,
    "FLY_FORWARD_TRY_HANG":                0x05e,
    "TRY_HANG_SOLID":                      0x05f,
    "HANG_IDLE":                           0x060,
    "CLIMB_ON":                            0x061,
    "FREE_FALL_TO_LONG":                   0x062,
    "FALL_CROUCHING_LANDING":              0x063,
    "FREE_FALL_TO_SIDE_LANDING":           0x064,
    "FREE_FALL_TO_SIDE_LANDING_ALTERNATE": 0x065,
    "CLIMB_ON_END":                        0x066,
    "STAY_IDLE":                           0x067,
    "START_SLIDE_BACKWARD":                0x068,
    "SLIDE_BACKWARD":                      0x069,
    "SLIDE_BACKWARD_END":                  0x06a,
    "UNDERWATER_SWIM_TO_IDLE":             0x06b,
    "UNDERWATER_IDLE":                     0x06c,
    "UNDERWARER_IDLE_TO_SWIM":             0x06d,
    "ONWATER_IDLE":                        0x06e,
    "CLIMB_OUT_OF_WATER":                  0x06f,
    "FREE_FALL_TO_UNDERWATER":             0x070,
    "ONWATER_DIVE_ALTERNATE":              0x071,
    "UNDERWATER_TO_ONWATER":               0x072,
    "ONWATER_DIVE":                        0x073,
    "ONWATER_SWIM_FORWARD":                0x074,
    "ONWATER_SWIM_FORWARD_TO_IDLE":        0x075,
    "ONWATER_IDLE_TO_SWIM":                0x076,
    "FREE_FALL_TO_UNDERWATER_ALTERNATE":   0x077,
    "START_OBJECT_MOVING":                 0x078,
    "STOP_OBJECT_MOVING":                  0x079,
    "OBJECT_PULL":                         0x07a,
    "OBJECT_PUSH":                         0x07b,
    "UNDERWATER_DEATH":                    0x07c,
    "AH_FORWARD":                          0x07d,
    "AH_BACKWARD":                         0x07e,
    "AH_LEFT":                             0x07f,
    "AH_RIGHT":                            0x080,
    "UNDERWATER_SWITCH":                   0x081,
    "UNDERWATER_PICKUP":                   0x082,
    "USE_KEY":                             0x083,
    "ONWATER_DEATH":                       0x084,
    "RUN_TO_DIE":                          0x085,
    "USE_PUZZLE":                          0x086,
    "PICKUP":                              0x087,
    "CLIMB_LEFT":                          0x088,
    "CLIMB_RIGHT":                         0x089,
    "STAY_TO_DEATH":                       0x08a,
    "SQUASH_BOULDER":                      0x08b,
    "ONWATER_IDLE_TO_SWIM_BACK":           0x08c,
    "ONWATER_SWIM_BACK":                   0x08d,
    "ONWATER_SWIM_BACK_TO_IDLE":           0x08e,
    "ONWATER_SWIM_LEFT":                   0x08f,
    "ONWATER_SWIM_RIGHT":                  0x090,
    "JUMP_TO_DEATH":                       0x091,
    "ROLL_BEGIN":                          0x092,
    "ROLL_CONTINUE":                       0x093,
    "ROLL_END":                            0x094,
    "SPIKED":                              0x095,
    "OSCILLATE_HANG_ON":                   0x096,
    "LANDING_ROLL":                        0x097,
    "FISH_TO_UNDERWATER1":                 0x098,
    "FREE_FALL_FISH":                      0x099,
    "FISH_TO_UNDERWATER2":                 0x09a,
    "FREE_FALL_FISH_TO_DEATH":             0x09b,
    "START_FLY_LIKE_FISH_LEFT":            0x09c,
    "START_FLY_LIKE_FISH_RIGHT":           0x09d,
    "FREE_FALL_FISH_START":                0x09e,
    "CLIMB_ON2":                           0x09f,
    "STAND_TO_LADDER":                     0x0a0,
    "LADDER_UP":                           0x0a1,
    "LADDER_UP_STOP_RIGHT":                0x0a2,
    "LADDER_UP_STOP_LEFT":                 0x0a3,
    "LADDER_IDLE":                         0x0a4,
    "LADDER_UP_START":                     0x0a5,
    "LADDER_DOWN_STOP_LEFT":               0x0a6,
    "LADDER_DOWN_STOP_RIGHT":              0x0a7,
    "LADDER_DOWN":                         0x0a8,
    "LADDER_DOWN_START":                   0x0a9,
    "LADDER_RIGHT":                        0x0aa,
    "LADDER_LEFT":                         0x0ab,
    "LADDER_HANG":                         0x0ac,
    "LADDER_HANG_TO_IDLE":                 0x0ad,
    "LADDER_TO_STAND":                     0x0ae,
    "UNKNOWN_175":                         0x0af,
    "ONWATER_TO_WADE_SHALLOW":             0x0b0,
    "WADE":                                0x0b1,
    "RUN_TO_WADE_LEFT":                    0x0b2,
    "RUN_TO_WADE_RIGHT":                   0x0b3,
    "WADE_TO_RUN_LEFT":                    0x0b4,
    "WADE_TO_RUN_RIGHT":                   0x0b5,
    "LADDER_BACKFLIP_START":               0x0b6,
    "LADDER_BACKFLIP_END":                 0x0b7,
    "WADE_TO_STAY_RIGHT":                  0x0b8,
    "WADE_TO_STAY_LEFT":                   0x0b9,
    "STAY_TO_WADE":                        0x0ba,
    "LADDER_UP_HANDS":                     0x0bb,
    "LADDER_DOWN_HANDS":                   0x0bc,
    "FLARE_THROW":                         0x0bd,
    "ONWATER_TO_WADE_DEEP":                0x0be,
    "ONWATER_TO_LAND_LOW":                 0x0bf,
    "UNDERWATER_TO_WADE":                  0x0c0,
    "ONWATER_TO_WADE":                     0x0c1,
    "LADDER_TO_HANDS_DOWN":                0x0c2,
    "SWITCH_SMALL_DOWN":                   0x0c3,
    "SWITCH_SMALL_UP":                     0x0c4,
    "BUTTON_PUSH":                         0x0c5,
    "UNDERWATER_SWIM_TO_STILL_HUDDLE":     0x0c6,
    "UNDERWATER_SWIM_TO_STILL_SPRAWL":     0x0c7,
    "UNDERWATER_SWIM_TO_STILL_MEDIUM":     0x0c8,
    "LADDER_TO_HANDS_RIGHT":               0x0c9,
    "LADDER_TO_HANDS_LEFT":                0x0ca,
    "UNDERWATER_ROLL_BEGIN":               0x0cb,
    "FLARE_PICKUP":                        0x0cc,
    "UNDERWATER_ROLL_END":                 0x0cd,
    "UNDERWATER_FLARE_PICKUP":             0x0ce,
    "RUNNING_JUMP_ROLL_BEGIN":             0x0cf,
    "SOMERSAULT":                          0x0d0,
    "RUNNING_JUMP_ROLL_END":               0x0d1,
    "STANDING_JUMP_ROLL_BEGIN":            0x0d2,
    "STANDING_JUMP_ROLL_END":              0x0d3,
    "BACKWARDS_JUMP_ROLL_BEGIN":           0x0d4,
    "BACKWARDS_JUMP_ROLL_END":             0x0d5,
    "TR345_ZIPLINE_GRAB":                  0x0d6,
    "TR345_ZIPLINE_RIDE":                  0x0d7,
    "TR345_ZIPLINE_FALL":                  0x0d8,
    "TR345_STAND_TO_CROUCH":               0x0d9,
    "CROUCH_ROLL_FORWARD_BEGIN":           0x0da,
    "CROUCH_ROLL_FORWARD_CONTINUE":        0x0db,
    "CROUCH_ROLL_FORWARD_END":             0x0dc,
    "CROUCH_TO_STAND":                     0x0dd,
    "CROUCH_IDLE":                         0x0de,
    "SPRINT":                              0x0df,
    "RUN_TO_SPRINT_LEFT":                  0x0e0,
    "RUN_TO_SPRINT_RIGHT":                 0x0e1,
    "SPRINT_SLIDE_STAND_RIGHT":            0x0e2,
    "SPRINT_SLIDE_STAND_RIGHT_BETA":       0x0e3,
    "SPRINT_SLIDE_STAND_LEFT":             0x0e4,
    "SPRINT_SLIDE_STAND_LEFT_BETA":        0x0e5,
    "SPRINT_TO_ROLL_LEFT":                 0x0e6,
    "SPRINT_TO_ROLL_LEFT_BETA":            0x0e7,
    "SPRINT_ROLL_LEFT_TO_RUN":             0x0e8,
    "MONKEY_GRAB":                         0x0e9,
    "MONKEY_IDLE":                         0x0ea,
    "MONKEY_FALL":                         0x0eb,
    "MONKEY_FORWARD":                      0x0ec,
    "MONKEY_STOP_LEFT":                    0x0ed,
    "MONKEY_STOP_RIGHT":                   0x0ee,
    "MONKEY_IDLE_TO_FORWARD_LEFT":         0x0ef,
    "SPRINT_TO_ROLL_ALTERNATE_BEGIN":      0x0f0,
    "SPRINT_TO_ROLL_ALTERNATE_CONTINUE":   0x0f1,
    "SPRINT_TO_ROLL_ALTERNATE_END":        0x0f2,
    "SPRINT_TO_RUN_LEFT":                  0x0f3,
    "SPRINT_TO_RUN_RIGHT":                 0x0f4,
    "CROUCH_PREPARE":                      0x0f5,
    "SLIDE_FORWARD_TO_RUN":                0x0f6,
    "CROUCH_ROLL_FORWARD_BEGIN_ALTERNATE": 0x0f7,
    "JUMP_FORWARD_BEGIN_TO_GRAB":          0x0f8,
    "JUMP_FORWARD_END_TO_GRAB":            0x0f9,
    "RUN_TO_GRAB_RIGHT":                   0x0fa,
    "RUN_TO_GRAB_LEFT":                    0x0fb,
    "MONKEY_IDLE_TO_FORWARD_RIGHT":        0x0fc,
    "MONKEY_STRAFE_LEFT":                  0x0fd,
    "MONKEY_STRAFE_LEFT_END":              0x0fe,
    "MONKEY_STRAFE_RIGHT":                 0x0ff,
    "MONKEY_STRAFE_RIGHT_END":             0x100,
    "MONKEY_TURN_AROUND":                  0x101,
    "CROUCH_TO_CRAWL_BEGIN":               0x102,
    "CRAWL_TO_CROUCH_BEGIN":               0x103,
    "CRAWL_FORWARD":                       0x104,
    "CRAWL_IDLE_TO_FORWARD":               0x105,
    "CRAWL_FORWARD_TO_IDLE_BEGIN_RIGHT":   0x106,
    "CRAWL_IDLE":                          0x107,
    "CROUCH_TO_CRAWL_END":                 0x108,
    "CROUCH_IDLE_SMASH":                   0x109,
    "CRAWL_FORWARD_TO_IDLE_END_RIGHT":     0x10a,
    "CRAWL_FORWARD_TO_IDLE_BEGIN_LEFT":    0x10b,
    "CRAWL_FORWARD_TO_IDLE_END_LEFT":      0x10c,
    "CRAWL_TURN_LEFT":                     0x10d,
    "CRAWL_TURN_RIGHT":                    0x10e,
    "MONKEY_TURN_LEFT":                    0x10f,
    "MONKEY_TURN_RIGHT":                   0x110,
    "CROUCH_TO_CRAWL_CONTINUE":            0x111,
    "CRAWL_TO_CROUCH_END":                 0x112,
    "CRAWL_IDLE_TO_BACKWARD":              0x113,
    "CRAWL_BACKWARD":                      0x114,
    "CRAWL_BACKWARD_TO_IDLE_BEGIN_RIGHT":  0x115,
    "CRAWL_BACKWARD_TO_IDLE_END_RIGHT":    0x116,
    "CRAWL_BACKWARD_TO_IDLE_BEGIN_LEFT":   0x117,
    "CRAWL_BACKWARD_TO_IDLE_END_LEFT":     0x118,
    "CRAWL_TURN_LEFT_END":                 0x119,
    "CRAWL_TURN_RIGHT_END":                0x11a,
    "MONKEY_TURN_LEFT_EARLY_END":          0x11b,
    "MONKEY_TURN_LEFT_LATE_END":           0x11c,
    "MONKEY_TURN_RIGHT_EARLY_END":         0x11d,
    "MONKEY_TURN_RIGHT_LATE_END":          0x11e,
    "HANG_TO_CROUCH_BEGIN":                0x11f,
    "HANG_TO_CROUCH_END":                  0x120,
    "CRAWL_TO_HANG_BEGIN":                 0x121,
    "CRAWL_TO_HANG_CONTINUE":              0x122,
    "CROUCH_PICKUP":                       0x123,
    "CRAWL_PICKUP":                        0x124,
    "CROUCH_SMASH_FORWARD":                0x125,
    "CROUCH_SMASH_BACKWARD":               0x126,
    "CROUCH_SMASH_RIGHT":                  0x127,
    "CROUCH_SMASH_LEFT":                   0x128,
    "CRAWL_SMASH_FORWARD":                 0x129,
    "CRAWL_SMASH_BACKWARD":                0x12a,
    "CRAWL_SMASH_RIGHT":                   0x12b,
    "CRAWL_SMASH_LEFT":                    0x12c,
    "CRAWL_DEATH":                         0x12d,
    "CRAWL_TO_HANG_END":                   0x12e,
    "CROUCH_ABORT":                        0x12f,
    "RUN_TO_CROUCH_LEFT_BEGIN":            0x130,
    "RUN_TO_CROUCH_RIGHT_BEGIN":           0x131,
    "RUN_TO_CROUCH_LEFT_END":              0x132,
    "RUN_TO_CROUCH_RIGHT_END":             0x133,
    "SPRINT_TO_ROLL_RIGHT":                0x134,
    "SPRINT_ROLL_RIGHT_TO_RUN":            0x135,
    "SPRINT_TO_CROUCH_LEFT":               0x136,
    "SPRINT_TO_CROUCH_RIGHT":              0x137,
    "CROUCH_PICKUP_FLARE":                 0x138,
    "DOOR_OPEN_FORWARD":                   0x139,
    "DOOR_OPEN_BACK":                      0x13a,
    "DOOR_KICK":                           0x13b,
    "GIANT_BUTTON_PUSH":                   0x13c,
    "FLOOR_TRAPDOOR_OPEN":                 0x13d,
    "CEILING_TRAPDOOR_OPEN":               0x13e,
    "ROUND_HANDLE_GRAB_CLOCKWISE":         0x13f,
    "ROUND_HANDLE_GRAB_COUNTERCLOCKWISE":  0x140,
    "COGWHEEL_PULL":                       0x141,
    "COGWHEEL_GRAB":                       0x142,
    "COGWHEEL_UNGRAB":                     0x143,
    "LEVERSWITCH_PUSH":                    0x144,
    "HOLE_GRAB":                           0x145,
    "STAY_TO_POLE_GRAB":                   0x146,
    "POLE_JUMP":                           0x147,
    "POLE_IDLE":                           0x148,
    "POLE_CLIMB_UP":                       0x149,
    "POLE_FALL":                           0x14a,
    "JUMP_FORWARD_TO_POLE_GRAB":           0x14b,
    "POLE_TURN_LEFT_BEGIN":                0x14c,
    "POLE_TURN_RIGHT_BEGIN":               0x14d,
    "POLE_IDLE_TO_CLIMB_DOWN":             0x14e,
    "POLE_CLIMB_DOWN":                     0x14f,
    "POLE_CLIMB_DOWN_TO_IDLE":             0x150,
    "JUMP_UP_TO_POLE_GRAB":                0x151,
    "POLE_CLIMB_UP_INBETWEEN":             0x152,
    "PULLEY_GRAB":                         0x153,
    "PULLEY_PULL":                         0x154,
    "PULLEY_UNGRAB":                       0x155,
    "POLE_GRAB_TO_STAY":                   0x156,
    "POLE_TURN_LEFT":                      0x157,
    "POLE_TURN_LEFT_END":                  0x158,
    "POLE_TURN_RIGHT":                     0x159,
    "POLE_TURN_RIGHT_END":                 0x15a,
    "ROUND_HANDLE_PUSH_RIGHT_BEGIN":       0x15b,
    "ROUND_HANDLE_PUSH_RIGHT_CONTINUE":    0x15c,
    "ROUND_HANDLE_PUSH_RIGHT_END":         0x15d,
    "ROUND_HANDLE_PUSH_LEFT_BEGIN":        0x15e,
    "ROUND_HANDLE_PUSH_LEFT_CONTINUE":     0x15f,
    "ROUND_HANDLE_PUSH_LEFT_END":          0x160,
    "CROUCH_TURN_LEFT":                    0x161,
    "CROUCH_TURN_RIGHT":                   0x162,
    "HANG_AROUND_LEFT_OUTER_BEGIN":        0x163,
    "HANG_AROUND_LEFT_OUTER_END":          0x164,
    "HANG_AROUND_RIGHT_OUTER_BEGIN":       0x165,
    "HANG_AROUND_RIGHT_OUTER_END":         0x166,
    "HANG_AROUND_LEFT_INNER_BEGIN":        0x167,
    "HANG_AROUND_LEFT_INNER_END":          0x168,
    "HANG_AROUND_RIGHT_INNER_BEGIN":       0x169,
    "HANG_AROUND_RIGHT_INNER_END":         0x16a,
    "LADDER_AROUND_LEFT_OUTER_BEGIN":      0x16b,
    "LADDER_AROUND_LEFT_OUTER_END":        0x16c,
    "LADDER_AROUND_RIGHT_OUTER_BEGIN":     0x16d,
    "LADDER_AROUND_RIGHT_OUTER_END":       0x16e,
    "LADDER_AROUND_LEFT_INNER_BEGIN":      0x16f,
    "LADDER_AROUND_LEFT_INNER_END":        0x170,
    "LADDER_AROUND_RIGHT_INNER_BEGIN":     0x171,
    "LADDER_AROUND_RIGHT_INNER_END":       0x172,
    "MONKEY_TO_ROPE_BEGIN":                0x173,
    "TRAIN_DEATH":                         0x174,
    "MONKEY_TO_ROPE_END":                  0x175,
    "ROPE_IDLE":                           0x176,
    "ROPE_DOWN_BEGIN":                     0x177,
    "ROPE_UP":                             0x178,
    "ROPE_IDLE_TO_SWING_SOFT":             0x179,
    "ROPE_GRAB_TO_FALL":                   0x17a,
    "ROPE_JUMP_TO_GRAB":                   0x17b,
    "ROPE_IDLE_TO_BACKFLIP":               0x17c,
    "ROPE_SWING_TO_FALL_SEMIFRONT":        0x17d,
    "ROPE_SWING_TO_FALL_MIDDLE":           0x17e,
    "ROPE_SWING_TO_FALL_BACK":             0x17f,
    "ROPE_DOWN":                           0x180,
    "ROPE_DOWN_TO_IDLE":                   0x181,
    "ROPE_SWING_TO_TRY_HANG_BACK":         0x182,
    "ROPE_IDLE_TO_SWING":                  0x183,
    "ROPE_IDLE_TO_SWING_SEMIMIDDLE":       0x184,
    "ROPE_IDLE_TO_SWING_HALFMIDDLE":       0x185,
    "ROPE_SWING_TO_FALL_FRONT":            0x186,
    "ROPE_GRAB_TO_FALL_ALTERNATE":         0x187,
    "ROPE_TURN_CLOCKWISE":                 0x188,
    "ROPE_TURN_COUNTER_CLOCKWISE":         0x189,
    "ROPE_SWING_FORWARD_SEMIHARD":         0x18a,
    "ROPE_LADDER_TO_HANDS_DOWN_ALTERNATE": 0x18b,
    "ROPE_SWING_BACK_CONTINUE":            0x18c,
    "ROPE_SWING_BACK_END":                 0x18d,
    "ROPE_SWING_BACK_BEGIN":               0x18e,
    "ROPE_SWING_FORWARD_SOFT":             0x18f,
    "WATERSKIN_EMPTY":                     0x190,
    "WATERSKIN_FILL":                      0x191,
    "WATERSKIN_POUR_ON_SCALE":             0x192,
    "DOOR_OPEN_CROWBAR":                   0x193,
    "ROPE_SWING_FORWARD_HARD":             0x194,
    "ROPE_CHANGE_ROPE":                    0x195,
    "ROPE_SWING_TO_TRY_HANG_FRONT2":       0x196,
    "ROPE_SWING_TO_TRY_HANG_MIDDLE":       0x197,
    "ROPE_SWING_BLOCK":                    0x198,
    "ROPE_SWING_TO_TRY_HANG_SEMIMIDDLE":   0x199,
    "ROPE_SWING_TO_TRY_HANG_FRONT3":       0x19a,
    "ROPE_SWING_TO_TRY_HANG_FRONT1":       0x19b,
    "DOUBLEDOORS_PUSH":                    0x19c,
    "BIG_BUTTON_PUSH":                     0x19d,
    "JUMPSWITCH":                          0x19e,
    "UNDERWATER_PULLEY":                   0x19f,
    "UNDERWATER_DOOR_OPEN":                0x1a0,
    "PUSHABLE_PUSH_TO_STAND":              0x1a1,
    "PUSHABLE_PULL_TO_STAND":              0x1a2,
    "CROWBAR_USE_ON_WALL":                 0x1a3,
    "CROWBAR_USE_ON_FLOOR":                0x1a4,
    "CRAWL_JUMP_DOWN":                     0x1a5,
    "HARP_PLAY":                           0x1a6,
    "PUT_TRIDENT":                         0x1a7,
    "PICKUP_PEDESTAL_HIGH":                0x1a8,
    "PICKUP_PEDESTAL_LOW":                 0x1a9,
    "ROTATE_SENET":                        0x1aa,
    "TORCH_LIGHT_1":                       0x1ab,
    "TORCH_LIGHT_2":                       0x1ac,
    "TORCH_LIGHT_3":                       0x1ad,
    "TORCH_LIGHT_4":                       0x1ae,
    "TORCH_LIGHT_5":                       0x1af,
    "DETONATOR_USE":                       0x1b0,
    "CORRECT_POSITION_FRONT":              0x1b1,
    "CORRECT_POSITION_LEFT":               0x1b2,
    "CORRECT_POSITION_RIGHT":              0x1b3,
    "CROWBAR_USE_ON_FLOOR_FAIL":           0x1b4,
    "USE_KEYCARD":                         0x1b5,
    "DEATH_BLOWUP":                        0x1b6,
    "PICKUP_SARCOPHAGUS":                  0x1b7,
    "DRAG":                                0x1b8,
    "BINOCULARS":                          0x1b9,
    "DEATH_BIG_SCORPION":                  0x1ba,
    "ELEVATOR_RECOVER":                    0x1bb,
    "BEETLE_PUT":                          0x1bc,
    "DOZY":                                0x1bd,
    "TIGHTROPE_WALK":                      0x1be,
    "TIGHTROPE_WALK_TO_STAND":             0x1bf,
    "TIGHTROPE_STAND":                     0x1c0,
    "TIGHTROPE_WALK_TO_STAND_CAREFUL":     0x1c1,
    "TIGHTROPE_STAND_TO_WALK":             0x1c2,
    "TIGHTROPE_TURN":                      0x1c3,
    "TIGHTROPE_LOOSE_LEFT":                0x1c4,
    "TIGHTROPE_RECOVER_LEFT":              0x1c5,
    "TIGHTROPE_FALL_LEFT":                 0x1c6,
    "TIGHTROPE_LOOSE_RIGHT":               0x1c7,
    "TIGHTROPE_RECOVER_RIGHT":             0x1c8,
    "TIGHTROPE_FALL_RIGHT":                0x1c9,
    "TIGHTROPE_START":                     0x1ca,
    "TIGHTROPE_FINISH":                    0x1cb,
    "DOVESWITCH_TURN":                     0x1cc,
    "BARS_GRAB":                           0x1cd,
    "BARS_SWING":                          0x1ce,
    "BARS_JUMP":                           0x1cf,
    "LOOT_CABINET":                        0x1d0,
    "LOOT_DRAWER":                         0x1d1,
    "LOOT_SHELF":                          0x1d2,
    "RADIO_BEGIN":                         0x1d3,
    "RADIO_IDLE":                          0x1d4,
    "RADIO_END":                           0x1d5,
    "VALVE_TURN":                          0x1d6,
    "CROWBAR_USE_ON_WALL2":                0x1d7,
    "LOOT_CHEST":                          0x1d8,
    "LADDER_TO_CROUCH":                    0x1d9
}, word_t)

CUTSCENE_ACTOR = struct_t("CUTSCENE_ACTOR", {
    "offset":   make_field(0x0, dword_t),
    "obj_slot": make_field(0x4, word_t),
    "nodes":    make_field(0x6, word_t)
}, 0x8)

CUTSCENE = struct_t("CUTSCENE", {
    "num_actors":    make_field(0x00, word_t),
    "num_frames":    make_field(0x02, word_t),
    "org_x":         make_field(0x04, dword_t),
    "org_y":         make_field(0x08, dword_t),
    "org_z":         make_field(0x0c, dword_t),
    "audio_track":   make_field(0x10, dword_t),
    "camera_offset": make_field(0x14, dword_t),
    "actor_data":    make_field(0x18, array_t(CUTSCENE_ACTOR, 10))
}, 0x68)

SNIPER_ANIM_STATE = enum_t("SNIPER_ANIM_STATE", {
    "HIDDEN":   0x1,
    "UNHIDING": 0x2,
    "READY":    0x3,
    "SHOOTING": 0x4,
    "HIDING":   0x5
}, word_t)

SOUND_SLOT = struct_t("SOUND_SLOT", {
    "orig_volume":   make_field(0x00, dword_t),
    "n_volume":      make_field(0x04, dword_t),
    "n_pan":         make_field(0x08, dword_t),
    "n_pitch":       make_field(0x0c, dword_t),
    "n_sample_info": make_field(0x10, dword_t),
    "distance":      make_field(0x14, dword_t),
    "pos":           make_field(0x18, PHD_VECTOR)
}, 0x24)

SOUND_FX = enum_t("SOUND_FX", {
    "LARA_FEET":              0x000,
    "LARA_CLIMB2":            0x001,
    "LARA_NO":                0x002,
    "LARA_SLIPPING":          0x003,
    "LARA_LAND":              0x004,
    "LARA_CLIMB1":            0x005,
    "LARA_HOLSTER_DRAW":      0x006,
    "LARA_HOLSTER_AWAY":      0x007,
    "LARA_FIRE":              0x008,
    "LARA_RELOAD":            0x009,
    "LARA_RICOCHET":          0x00a,
    "PUSH_BLOCK_END":         0x00b,
    "SMASH_GLASS":            0x00c,
    "LARA_CLIMB_WALL_GRUNT":  0x00d,
    "HK_SILENCED":            0x00e,
    "OFFICE_DOOR_OPEN":       0x00f,
    "OFFICE_DOOR_CLSE":       0x010,
    "LARA_WET_FEET":          0x011,
    "LARA_WADE":              0x012,
    "SMASH_WOOD":             0x013,
    "LARA_INJURY_NONRND":     0x014,
    "CRICKET_LOOP":           0x015,
    "PHILOSPHER_STONE":       0x016,
    "LARA_JUMP_NONRND":       0x017,
    "LARA_KNEES_SHUFFLE":     0x018,
    "LARA_HIDDEN_SWITCH":     0x019,
    "LARA_CLIMB3":            0x01a,
    "LARA_BODYSL":            0x01b,
    "LARA_SHIMMY2":           0x01c,
    "LARA_JUMP_RND":          0x01d,
    "LARA_FALL":              0x01e,
    "LARA_INJURY_RND":        0x01f,
    "LARA_ROLL":              0x020,
    "LARA_SPLASH":            0x021,
    "LARA_GETOUT":            0x022,
    "LARA_SWIM":              0x023,
    "LARA_BREATH":            0x024,
    "LARA_BUBBLES":           0x025,
    "CREATURE_SWIM":          0x026,
    "LARA_USE_KEY":           0x027,
    "LARA_PUSH2_NONRND":      0x028,
    "LARA_GENERAL_DEATH":     0x029,
    "LARA_KNEES_DEATH":       0x02a,
    "LARA_UZI_FIRE":          0x02b,
    "LARA_UZI_STOP":          0x02c,
    "LARA_SHOTGUN":           0x02d,
    "LARA_PUSH1":             0x02e,
    "LARA_PUSH2_RND":         0x02f,
    "LARA_RANDOM_PUSHFX":     0x030,
    "LARA_SHOTGUN_SHELL":     0x031,
    "UNDERWATER_DOOR":        0x032,
    "LARA_PULL":              0x033,
    "LARA_FLOATING":          0x034,
    "LARA_FALLDETH":          0x035,
    "LARA_GRABHAND":          0x036,
    "LARA_GRABBODY":          0x037,
    "LARA_GRABFEET":          0x038,
    "OFFICE_DOOR_SQUEAK":     0x039,
    "WATER_LAPS_LOOP":        0x03a,
    "WATER_SPOUT_LOOP":       0x03b,
    "UNDERWATER":             0x03c,
    "UNDERWATER_SWITCH":      0x03d,
    "LARA_PICKUP":            0x03e,
    "PUSHABLE_SOUND":         0x03f,
    "SNIPER_RIFLE":           0x040,
    "HELICOPTER_LOOP":        0x041,
    "ROCK_FALL_CRUMBLE":      0x042,
    "ROCK_FALL_LAND":         0x043,
    "HK_FIRE":                0x044,
    "HK_STOP":                0x045,
    "LARA_THUD":              0x046,
    "GENERIC_SWOOSH":         0x047,
    "BLUEGUARD_CHAIR":        0x048,
    "NEWBOX_SHUT":            0x049,
    "BLUE_SCIEN_DONT_SHOOT":  0x04a,
    "BLUEGUARD_CONSOLE":      0x04b,
    "SHOWER_LOOP":            0x04c,
    "WATER_LOOP":             0x04d,
    "FOUNTAIN_LOOP":          0x04e,
    "WATERFALL_LOOP":         0x04f,
    "SERVO_02":               0x050,
    "SERVO_01":               0x051,
    "BLUEG_GETUP_HOY":        0x052,
    "BLUEG_MAFIA_GUNS":       0x053,
    "BLUEG_HIT_DIE":          0x054,
    "BLUEG_JUMP":             0x055,
    "BLUEG_CHAIR_HIT":        0x056,
    "RICH_IRIS_ELEC":         0x057,
    "BIO_BREATHE_OUT":        0x058,
    "GENERIC_BOOT_STEPS":     0x059,
    "PIERRE_GUNS":            0x05a,
    "PIERRE_FINAL_BREATH":    0x05b,
    "PIERRE_HIT":             0x05c,
    "GENERIC_KNEES_FALL":     0x05d,
    "LION_HIT_FLOOR":         0x05e,
    "AGENT_HITMAN_FEET":      0x05f,
    "LARSON_ARGGHH":          0x060,
    "LARSON_GUNS":            0x061,
    "LARSON_GROAN":           0x062,
    "AGENT_HITMAN_LAND":      0x063,
    "LION_FEET":              0x064,
    "LION_GROWL":             0x065,
    "LION_ATTACK":            0x066,
    "LION_DIE":               0x067,
    "RAVENSWITCH_EXP":        0x068,
    "EXPLOSION1":             0x069,
    "EXPLOSION2":             0x06a,
    "EARTHQUAKE_LOOP":        0x06b,
    "MENU_ROTATE":            0x06c,
    "MENU_SELECT":            0x06d,
    "MENU_EMPTY":             0x06e,
    "MENU_CHOOSE":            0x06f,
    "TICK_TOCK":              0x070,
    "MENU_EMPTY_BIS":         0x071,
    "MENU_COMBINE":           0x072,
    "MENU_EMPTY_BIS_BIS":     0x073,
    "MENU_MEDI":              0x074,
    "LARA_CLIMB_WALLS_NOISE": 0x075,
    "2GUNTEX_FALL_END":       0x076,
    "AGENT_HITMAN_JUMP":      0x077,
    "MAFIA_HOLSTER_DRAW":     0x078,
    "REVOLVER":               0x079,
    "HITMAN_CHOKE":           0x07a,
    "MAFIA2_DIE":             0x07b,
    "MAFIA2_JUMP_UP":         0x07c,
    "MAFIA2_GETDOWN":         0x07d,
    "MAFIA2_HIT":             0x07e,
    "LARA_ELECTRIC_LOOP":     0x07f,
    "LARA_ELECTRIC_CRACKLES": 0x080,
    "HANGMAN_LAUGH_OFFCAM":   0x081,
    "ELEC_LIGHT_CRACKLES":    0x082,
    "LOUD_WIND_LOOP":         0x083,
    "KEYPAD_ENTRY_NO":        0x084,
    "KEYPAD_ENTRY_YES":       0x085,
    "RICH_TELEPORT":          0x086,
    "JOBY_PUZZLE_HATCH":      0x087,
    "SOFT_WIND_LOOP":         0x088,
    "GLADIATOR_FEET":         0x089,
    "GLADIATOR_ATTACK":       0x08a,
    "GLADIATOR_DIE":          0x08b,
    "GLADIATOR_SWORD":        0x08c,
    "GLADIATOR_SHIELD1":      0x08d,
    "GLADIATOR_SHIELD2":      0x08e,
    "GENERIC_BODY_FALL":      0x08f,
    "2GUNTEX_DIE":            0x090,
    "LARA_SPIKE_DEATH":       0x091,
    "LARA_DEATH3":            0x092,
    "ROLLING_BALL":           0x093,
    "BLK_PLAT_RAISE_LOW":     0x094,
    "2GUNTEX_FALL_BIG":       0x095,
    "LOOP_FOR_SMALL_FIRES":   0x096,
    "XRAY_SCAN":              0x097,
    "R_XRAY_ROOM_LP":         0x098,
    "R_HITECH_ROOM_LP":       0x099,
    "JOBY_WATERFALL_SMALL":   0x09a,
    "JOBY_WATERFALL_BIG":     0x09b,
    "RATS_1":                 0x09c,
    "BATS_1":                 0x09d,
    "H_GOD_HAMMER_QT":        0x09e,
    "H_GOD_HAMMER_MED":       0x09f,
    "H_GOD_HAMMER_LD":        0x0a0,
    "TRAPDOOR_OPEN":          0x0a1,
    "TRAPDOOR_CLOSE":         0x0a2,
    "RICH_DOOR_BEAM":         0x0a3,
    "WALLSUIT_OUT":           0x0a4,
    "AUTOGUN_UNFOLD":         0x0a5,
    "AUTOGUN_DOOR":           0x0a6,
    "SMASH_ROCK":             0x0a7,
    "SMASH_METAL":            0x0a8,
    "D_ALIEN":                0x0a9,
    "RICH_VENT_IMPACT":       0x0aa,
    "SWITCH_ELEC_SWAP":       0x0ab,
    "ELECTRIC_WIRES":         0x0ac,
    "LAVA_LOOP":              0x0ad,
    "DOG_DOBER_GROWL":        0x0ae,
    "DOG_HOWL":               0x0af,
    "DOG_ATTACK_1":           0x0b0,
    "DOG_AWARE":              0x0b1,
    "DOG_FOOT_1":             0x0b2,
    "DOG_JUMP":               0x0b3,
    "DOG_LONG_GROWL":         0x0b4,
    "DOG_DEATH":              0x0b5,
    "THUNDER_RUMBLE":         0x0b6,
    "HAMMER_GOD_PULSE":       0x0b7,
    "SWORD_GOD_CHARGE":       0x0b8,
    "SWORD_GOD_LASER":        0x0b9,
    "SKELETON_APPEAR":        0x0ba,
    "CHEF_KNIFE_SWOOSH":      0x0bb,
    "SKELETON_ATTACK":        0x0bc,
    "GEN_SWORD_SWOOSH_NORM":  0x0bd,
    "CHEF_ATTACK_ARGHH":      0x0be,
    "2GUNTEX_FEET_LD":        0x0bf,
    "2GUNTEX_FEET_QT":        0x0c0,
    "2GUNTEX_LASER_FIRE":     0x0c1,
    "2GUNTEX_LASER_FIRE_2":   0x0c2,
    "2GUNTEX_LASER_START":    0x0c3,
    "2GUNTEX_LASER_MISFIRE":  0x0c4,
    "2GUNTEX_HIT_GUNS":       0x0c5,
    "IMP_DIE":                0x0c6,
    "IMP_FALL":               0x0c7,
    "IMP_FEET":               0x0c8,
    "IMP_ATTACK":             0x0c9,
    "IMP_LAUGH":              0x0ca,
    "IMP_RUNAWAY":            0x0cb,
    "SGOD_SWD_DIE1_Q":        0x0cc,
    "SGOD_SWD_DIE2_VQ":       0x0cd,
    "HITMAN_GUNS_FIRE":       0x0ce,
    "HITMAN_GUNS_END":        0x0cf,
    "FIRE_EXTING_RICO":       0x0d0,
    "LARA_UNDERWATER_ENGINE": 0x0d1,
    "CABINET_CLOSE_WOOD":     0x0d2,
    "CABINET_OPEN_WOOD":      0x0d3,
    "SWORD_GOD_FEET_LD":      0x0d4,
    "SWORD_GOD_FEET_QT":      0x0d5,
    "SWORD_GOD_FEET_VQT":     0x0d6,
    "SWORD_GOD_SWORD":        0x0d7,
    "GEN_SWORD_SWOOSH_LOW":   0x0d8,
    "SWORD_GOD_FALL":         0x0d9,
    "SWORD_GOD_HITMET":       0x0da,
    "SWORD_GOD_SCREAM":       0x0db,
    "KITCHEN_HOB_LOOP":       0x0dc,
    "KEYPAD_STAR":            0x0dd,
    "KEYPAD_HASH":            0x0de,
    "KEYPAD_0":               0x0df,
    "KEYPAD_1":               0x0e0,
    "KEYPAD_2":               0x0e1,
    "KEYPAD_3":               0x0e2,
    "KEYPAD_4":               0x0e3,
    "KEYPAD_5":               0x0e4,
    "KEYPAD_6":               0x0e5,
    "KEYPAD_7":               0x0e6,
    "KEYPAD_8":               0x0e7,
    "KEYPAD_9":               0x0e8,
    "SMALL_FAN":              0x0e9,
    "KLAXON":                 0x0ea,
    "LARA_CROSSBOW":          0x0eb,
    "ANDY_FLOOR_DOOR_B":      0x0ec,
    "ANDY_FLOOR_DOOR_A":      0x0ed,
    "J_GRAB_OPEN":            0x0ee,
    "WILLOWISP_LOOP":         0x0ef,
    "LEAP_SWITCH":            0x0f0,
    "LARGE_SWITCH":           0x0f1,
    "GENERIC_HEAVY_THUD":     0x0f2,
    "GENERIC_HEAVY_FEET":     0x0f3,
    "SWIMSUIT_METAL_CLASH":   0x0f4,
    "CROW_WALL_ITEM_DROP":    0x0f5,
    "LARA_SUB_BREATHE":       0x0f6,
    "HITMAN_ELEC_SHORT":      0x0f7,
    "WELD_THRU_DOOR_LOOP":    0x0f8,
    "IMP_BARREL_DROP":        0x0f9,
    "IMP_BARREL_ROLL":        0x0fa,
    "IMP_STONE_HIT":          0x0fb,
    "POUR_DUST_INSERTANIM":   0x0fc,
    "J_GRAB_TOP_IMPACT":      0x0fd,
    "COG_ANDY2":              0x0fe,
    "J_GRAB_IMPACT":          0x0ff,
    "J_GRAB_MOTOR_C":         0x100,
    "J_GRAB_MOTOR_B_LP":      0x101,
    "J_GRAB_MOTOR_A":         0x102,
    "J_GRAB_DROP":            0x103,
    "J_GRAB_WINCH_UP_LP":     0x104,
    "FOOTSTEPS_WOOD_CAB":     0x105,
    "FOOTSTEPS_METAL_CAB":    0x106,
    "D_FLOOR_METAL":          0x107,
    "DRAWERS_METAL_OPEN":     0x108,
    "DRAWERS_METAL_CLOSE":    0x109,
    "SHOCKWAVE_RUMB":         0x10a,
    "ANDY_BOAT_MILL_2":       0x10b,
    "ANDY_BOAT_MILL_1":       0x10c,
    "SMALL_STONE_SWITCH":     0x10d,
    "TV_WHITENOISE_LOOP":     0x10e,
    "LIFT_MOVE":              0x10f,
    "ALARM":                  0x110,
    "GENERIC_SQKS_LOW":       0x111,
    "RICH_LOWER_BEAMX":       0x112,
    "RICH_NRG_BEAM":          0x113,
    "BEETLES":                0x114,
    "GOD_HEAD_TESTICLES":     0x115,
    "GOD_HEAD_CHARGE":        0x116,
    "GOD_HEAD_BLAST":         0x117,
    "GOD_HEAD_LASER_LOOPS":   0x118,
    "COGS_ROME":              0x119,
    "LOW_RUMBLE_LOWER":       0x11a,
    "GEN_STONE_DOOR_LOW":     0x11b,
    "GENERIC_SQKS_NONRND":    0x11c,
    "UNDERWATER_FAN_ON":      0x11d,
    "SUB_CONTROLROOM_LOOP":   0x11e,
    "D_MANHOLE_METAL":        0x11f,
    "FOOTSTEPS_MUD":          0x120,
    "FOOTSTEPS_ICE":          0x121,
    "FOOTSTEPS_GRAVEL":       0x122,
    "FOOTSTEPS_SAND_GRASS":   0x123,
    "FOOTSTEPS_WOOD":         0x124,
    "FOOTSTEPS_SNOW":         0x125,
    "FOOTSTEPS_METAL":        0x126,
    "TIGHTROPE_CREAK":        0x127,
    "TIGHTROPE_WALK":         0x128,
    "DRAWERS_WOOD_CLSE":      0x129,
    "DRAWERS_WOOD_OPEN":      0x12a,
    "SWAMPY_ATTACK":          0x12b,
    "BELL":                   0x12c,
    "JOBY2_GRILL_2A":         0x12d,
    "HISS_LOOP_SMALL":        0x12e,
    "JOBY2_CRANE_END":        0x12f,
    "GENERATOR_HUM_LOOP":     0x130,
    "COMPUTER_BEEPIES":       0x131,
    "MODEM_LOOP":             0x132,
    "AIRCON_LOOP":            0x133,
    "GEN_STONE_DOOR":         0x134,
    "LOW_RUMBLE":             0x135,
    "SEARCHER":               0x136,
    "STAIR_SNAP_01":          0x137,
    "RICH_GEN_LOOP":          0x138,
    "ZOOM_VIEW_WHIRR":        0x139,
    "RICH_VENT_STRESS":       0x13a,
    "INDUSTRY_AMBIENCE_LOOP": 0x13b,
    "D_SWIPECARD_SFX":        0x13c,
    "RICH_TARGET_RISE":       0x13d,
    "STAIR_BANISTER_BEND":    0x13e,
    "JOBY2_GRILL_1":          0x13f,
    "JOBY2_GRILL_3":          0x140,
    "D_LARA_LOCKER_C":        0x141,
    "D_LARA_LOCKER_O":        0x142,
    "STONE_SCRAPE_FAST":      0x143,
    "JOBY2_GRILL_2":          0x144,
    "LIFT_DOORS":             0x145,
    "LARA_CROWBAR_ITEM":      0x146,
    "JOBY2_CRANE":            0x147,
    "GENERIC_SQKS_RND":       0x148,
    "D_SLIDEDOOR_JOBY":       0x149,
    "D_FIREDOOR_JOBY":        0x14a,
    "D_METAL_CLS_P1":         0x14b,
    "D_METAL_CLS_P2":         0x14c,
    "D_SCIFI_CLOSE":          0x14d,
    "D_SCIFI_OPEN":           0x14e,
    "TEETH_SPIKES":           0x14f,
    "BAT_RAM_CREAK1":         0x150,
    "LARA_LEVER_PART1":       0x151,
    "LARA_LEVER_PART2":       0x152,
    "LARA_POLE_SQUEAKS":      0x153,
    "LARA_ROPEDOWN_LOOP":     0x154,
    "D_METAL_OPEN":           0x155,
    "LARA_PULLEY":            0x156,
    "D_METAL_OPEN_PUSH":      0x157,
    "D_METAL_KICKOPEN":       0x158,
    "LARA_USE_OBJECT":        0x159,
    "D_GATE_BIG_METAL":       0x15a,
    "D_MOTOR_WHIRR":          0x15b,
    "LARA_NO_FRENCH":         0x15c,
    "LARA_NO_JAPANESE":       0x15d,
    "LARA_CROW_WRENCH":       0x15e,
    "LARA_ROPE_CREAK":        0x15f,
    "LARA_TROPE_FALL":        0x160,
    "D_METAL_CAGE_CLS2":      0x161,
    "D_METAL_CAGE_CLS1":      0x162,
    "GENERIC_STONE_GRIND":    0x163,
    "D_STONEMETAL_MAIN":      0x164,
    "D_PORTCULLIS_UP":        0x165,
    "D_PORTCULLIS_DOWN":      0x166,
    "D_WOODEN_GATE_CREAK":    0x167,
    "D_PADLOCK_BREAK":        0x168,
    "D_BIG_THUD_GEN_2":       0x169,
    "D_BIG_THUD_GEN_1":       0x16a,
    "D_DOUBLE_BANG":          0x16b,
    "D_DOUBLE_CREAK":         0x16c,
    "D_CROWBAR_WOOD":         0x16d,
    "D_METAL_LOCKUP_CROW":    0x16e,
    "D_METAL_LOCKUP_OPEN":    0x16f,
    "D_METAL_CAGE_OPEN":      0x170,
    "SMALL_CLICK_SWITCH":     0x171,
    "WEREWOLF_FEET_F":        0x172,
    "WEREWOLF_FEET_B":        0x173,
    "WEREWOLF_ATTACK1":       0x174,
    "WEREWOLF_ATTACK2":       0x175,
    "WEREWOLF_DROP":          0x176,
    "WEREWOLF_DIE":           0x177,
    "WEREWOLF_JUMP":          0x178,
    "SWAT_DIE":               0x179,
    "ANDY_WHEEL":             0x17a,
    "BARN_DOOR_NORMAL":       0x17b,
    "BARN_DOOR_SLAM":         0x17c,
    "RATCHET_3SHOT":          0x17d,
    "ANDY_WATERWHEEL":        0x17e,
    "ANDY_INSIDEMILL":        0x17f,
    "ANDREA_COIN_PUZZ":       0x180,
    "MINI_SUB_LOOP":          0x181,
    "LIFT_BRAKE_SQUEAL":      0x182,
    "RATSPLASH":              0x183,
    "SNORE_IN":               0x184,
    "SNORE_OUT":              0x185,
    "D_SMALL_VENT_O_C":       0x186,
    "RICH_HOLOGRAM":          0x187,
    "HISS_LOOP_BIG":          0x188,
    "LIFT_MOVE_KNACKED":      0x189,
    "LIFT_HIT_FLOOR1":        0x18a,
    "LIFT_HIT_FLOOR2":        0x18b,
    "LAZER_LOOP":             0x18c,
    "UNDERWATER_EXPLOSION":   0x18d,
    "UNDERWATER_TORPEDO":     0x18e,
    "TELEPORT_CRACKLES":      0x18f,
    "TELEPORT_FLASH":         0x190,
    "LARA_UNDERWATER_HIT":    0x191,
    "RAVESTICK":              0x192,
    "UNDERWATER_CHAFF":       0x193,
    "FISHTANK_WATER":         0x194,
    "2GUNTEX_STAIR_FALL":     0x195,
    "GGOD_BREATHE_IN":        0x196,
    "GGOD_BREATHE_OUT":       0x197,
    "GGOD_FIRE":              0x198,
    "GGOD_ATTACK":            0x199,
    "PORTAL_LOOP":            0x19a,
    "NUM_SFX":                0x19b
}, dword_t)

CHEF_ANIM_STATE = enum_t("CHEF_ANIM_STATE", {
    "COOKING":         0x1,
    "TURNING":         0x2,
    "ATTACK":          0x3,
    "ATTACK_COOLDOWN": 0x4,
    "STALKING":        0x5,
    "INCAPACITATED":   0x6
}, word_t)

GAME_MODE = enum_t("GAME_MODE", {
    "IN_LEVEL":     0x0,
    "IN_TITLE":     0x1,
    "LOADING_GAME": 0x4
}, byte_t)

CHANGELING_ANIM_STATE = enum_t("CHANGELING_ANIM_STATE", {
    "DISTRACTED": 0x6
}, word_t)

BLUE_GUARD_ANIM_STATE = enum_t("BLUE_GUARD_ANIM_STATE", {
    "SLEEPING":     0x11,
    "USING_KEYPAD": 0x25
}, word_t)

GAME_VECTOR = struct_t("GAME_VECTOR", {
    "x":           make_field(0x0, dword_t),
    "y":           make_field(0x4, dword_t),
    "z":           make_field(0x8, dword_t),
    "room_number": make_field(0xc, word_t),
    "box_number":  make_field(0xe, word_t)
}, 0x10)

CAMERA_TYPE = enum_t("CAMERA_TYPE", {
    "CHASE":     0x0,
    "FIXED":     0x1,
    "LOOK":      0x2,
    "COMBAT":    0x3,
    "CINEMATIC": 0x4,
    "HEAVY":     0x5
}, dword_t)

OBJECT_VECTOR = struct_t("OBJECT_VECTOR", {
    "x":     make_field(0x0, dword_t),
    "y":     make_field(0x4, dword_t),
    "z":     make_field(0x8, dword_t),
    "data":  make_field(0xc, word_t),
    "flags": make_field(0xe, word_t)
}, 0x10)

CAMERA_INFO = struct_t("CAMERA_INFO", {
    "pos":              make_field(0x00, GAME_VECTOR),
    "target":           make_field(0x10, GAME_VECTOR),
    "type":             make_field(0x20, CAMERA_TYPE),
    "old_type":         make_field(0x24, CAMERA_TYPE),
    "shift":            make_field(0x28, dword_t),
    "flags":            make_field(0x2c, dword_t),
    "fixed_camera":     make_field(0x30, dword_t),
    "number_frames":    make_field(0x34, dword_t),
    "bounce":           make_field(0x38, dword_t),
    "underwater":       make_field(0x3c, dword_t),
    "target_distance":  make_field(0x40, dword_t),
    "target_angle":     make_field(0x44, word_t),
    "target_elevation": make_field(0x46, word_t),
    "actual_elevation": make_field(0x48, word_t),
    "actual_angle":     make_field(0x4a, word_t),
    "lara_node":        make_field(0x4c, word_t),
    "box":              make_field(0x4e, word_t),
    "number":           make_field(0x50, word_t),
    "last":             make_field(0x52, word_t),
    "timer":            make_field(0x54, word_t),
    "speed":            make_field(0x56, word_t),
    "target_speed":     make_field(0x58, word_t),
    "item":             make_field(0x5c, pointer_t(ITEM_INFO)),
    "last_item":        make_field(0x60, pointer_t(ITEM_INFO)),
    "fixed":            make_field(0x64, pointer_t(OBJECT_VECTOR)),
    "mike_at_lara":     make_field(0x68, dword_t),
    "mike_pos":         make_field(0x6c, PHD_VECTOR)
}, 0x78)

KICK_DOOR_ANIM_STATE = enum_t("KICK_DOOR_ANIM_STATE", {
    "OPEN":    0x0,
    "CLOSED":  0x1,
    "OPENING": 0x2
}, word_t)

FLOOR_INFO = struct_t("FLOOR_INFO", {
    "index":    make_field(0x0, word_t),
    "bitfield": make_field(0x2, word_t),
    "pit_room": make_field(0x4, byte_t),
    "floor":    make_field(0x5, byte_t),
    "sky_room": make_field(0x6, byte_t),
    "ceiling":  make_field(0x7, byte_t)
}, 0x8)

LIGHT_INFO = struct_t("LIGHT_INFO", {
    "x":             make_field(0x00, dword_t),
    "y":             make_field(0x04, dword_t),
    "z":             make_field(0x08, dword_t),
    "type":          make_field(0x0c, byte_t),
    "r":             make_field(0x0d, byte_t),
    "g":             make_field(0x0e, byte_t),
    "b":             make_field(0x0f, byte_t),
    "nx":            make_field(0x10, word_t),
    "ny":            make_field(0x12, word_t),
    "nz":            make_field(0x14, word_t),
    "intensity":     make_field(0x16, word_t),
    "inner":         make_field(0x18, byte_t),
    "outer":         make_field(0x19, byte_t),
    "falloff_scale": make_field(0x1a, word_t),
    "length":        make_field(0x1c, word_t),
    "cutoff":        make_field(0x1e, word_t)
}, 0x20)

MESH_FLAGS = bitflags_t("MESH_FLAGS", {
    "ACTIVE": make_bitflag(0x0, bit0_t)
}, word_t)

MESH_INFO = struct_t("MESH_INFO", {
    "x":             make_field(0x00, dword_t),
    "y":             make_field(0x04, dword_t),
    "z":             make_field(0x08, dword_t),
    "y_rot":         make_field(0x0c, word_t),
    "shade":         make_field(0x0e, word_t),
    "flags":         make_field(0x10, MESH_FLAGS),
    "static_number": make_field(0x12, word_t),
}, 0x14)

CVECTOR = struct_t("CVECTOR", {
    "b":  make_field(0x0, byte_t),
    "g":  make_field(0x1, byte_t),
    "r":  make_field(0x2, byte_t),
    "cd": make_field(0x3, byte_t)
}, 0x4)

ROOM_INFO = struct_t("ROOM_INFO", {
    "data":         make_field(0x00, pointer_t(word_t)),
    "door":         make_field(0x04, pointer_t(word_t)),
    "floor":        make_field(0x08, pointer_t(FLOOR_INFO)),
    "lights":       make_field(0x0c, pointer_t(LIGHT_INFO)),
    "meshes":       make_field(0x10, pointer_t(MESH_INFO)),
    "x":            make_field(0x14, dword_t),
    "y":            make_field(0x18, dword_t),
    "z":            make_field(0x1c, dword_t),
    "min_floor":    make_field(0x20, dword_t),
    "max_ceiling":  make_field(0x24, dword_t),
    "x_size":       make_field(0x28, word_t),
    "y_size":       make_field(0x2a, word_t),
    "ambient":      make_field(0x2c, CVECTOR),
    "num_lights":   make_field(0x30, word_t),
    "num_meshes":   make_field(0x32, word_t),
    "reverb_type":  make_field(0x34, byte_t),
    "flip_number":  make_field(0x35, byte_t),
    "mesh_effect":  make_field(0x36, byte_t),
    "bound_active": make_field(0x37, byte_t),
    "left":         make_field(0x38, word_t),
    "right":        make_field(0x3a, word_t),
    "top":          make_field(0x3c, word_t),
    "bottom":       make_field(0x3e, word_t),
    "test_left":    make_field(0x40, word_t),
    "test_right":   make_field(0x42, word_t),
    "test_top":     make_field(0x44, word_t),
    "test_bottom":  make_field(0x46, word_t),
    "item_number":  make_field(0x48, word_t),
    "fx_number":    make_field(0x4a, word_t),
    "flipped_room": make_field(0x4c, word_t),
    "flags":        make_field(0x4e, word_t)
}, 0x50)

GAMEFLOW_STATUS = enum_t("GAMEFLOW_STATUS", {
    "IN_LEVEL":        0,
    "RETURN_TO_TITLE": 1,
    "LOAD_SAVE":       2,
    "LOAD_LEVEL":      3
}, dword_t)

TITLE_SUBMENU = enum_t("TITLE_SUBMENU", {
    "MAIN":             0,
    "LOAD":             1,
    "LEVEL_SELECT":     2,
    "SPECIAL_FEATURES": 3
}, byte_t)

ACT_ID = enum_t("ACT_ID", {
    "ROME":    0,
    "RUSSIA":  1,
    "IRELAND": 2,
    "VCI":     3
}, word_t)


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

                                                                             // name in decompilation:
active_disp_env       = make_var(                        DISPENV, 0x09cd10)  // activeDispEnv
title_submenu         = make_var(                  TITLE_SUBMENU, 0x0a2826)  // Chris_Menu
game_mode             = make_var(                      GAME_MODE, 0x0a2827)  // gfGameMode
in_credits            = make_var(                         byte_t, 0x0a2829)  // bDoCredits
look_zoom             = make_var(                        dword_t, 0x0a29b8)  // BinocularRange
lasersight_active     = make_var(                        dword_t, 0x0a29c4)  // LaserSight
infrared_active       = make_var(                        dword_t, 0x0a29c8)  // InfraRed
disable_lara_control  = make_var(                        dword_t, 0x0a2d10)  // bDisableLaraControl
cutscene_num          = make_var(                        dword_t, 0x0a2c08)  // cutseq_num
playing_cutscene      = make_var(                        dword_t, 0x0a2c10)  // GLOBAL_playing_cutseq
screen_fading         = make_var(                         word_t, 0x0a2c4e)  // ScreenFading
spotcam_active        = make_var(                        dword_t, 0x0a2d0c)  // bUseSpotCam
using_keypad          = make_var(                        dword_t, 0x0a2d74)  // GLOBAL_invkeypadmode
keypad_combination    = make_var(                        dword_t, 0x0a2d78)  // GLOBAL_invkeypadcombination
keypad_n_inputs       = make_var(                         byte_t, 0x0a2d7e)  // keypadnuminputs
sound_active          = make_var(                        dword_t, 0x0a3050)
xa_fade_rate          = make_var(                         word_t, 0x0a32f0)  // XAFadeRate
loading_level         = make_var(                         byte_t, 0x0a33f5)  // LoadingBarEnabled
load_ok_dialog        = make_var(                      REQUESTER, 0x0a38f0)  // LoadOkReq
gameflow_status       = make_var(                GAMEFLOW_STATUS, 0x0a39cc)  // gfStatus
completed_level_id    = make_var(                       LEVEL_ID, 0x0a39d4)  // gfLevelComplete
level_id              = make_var(                       LEVEL_ID, 0x0a3a88)  // gfCurrentLevel
lara_item             = make_var(           pointer_t(ITEM_INFO), 0x0a3aa4)
cd_flags              = make_var(           array_t(byte_t, 136), 0x0a3c60)
triggered_cutscenes_1 = make_var(                        dword_t, 0x0a3ce8)  // _CutsceneTriggered1
triggered_cutscenes_2 = make_var(                        dword_t, 0x0a3cec)  // _CutsceneTriggered2
camera                = make_var(                    CAMERA_INFO, 0x0a3dd0)
rooms                 = make_var(           pointer_t(ROOM_INFO), 0x0a4088)  // room
cutscene              = make_var(            pointer_t(CUTSCENE), 0x0a40d8)  // GLOBAL_cutme
current_spotcam_num   = make_var(                         word_t, 0x0a4f4a)  // current_sequence
keypad_inputs         = make_var(             array_t(byte_t, 4), 0x0a51c4)  // keypadinputs
sound_sample_table    = make_var(pointer_t(array_t(word_t, 450)), 0x0a5370)  // sample_lut
cd_track_id           = make_var(                         word_t, 0x0a562c)  // XATrack
menu_dialog           = make_var(           pointer_t(REQUESTER), 0x0a6f18)  // AutoRequester
lara                  = make_var(                      LARA_INFO, 0x0a71e8)
savegame              = make_var(                  SAVEGAME_INFO, 0x0acde8)
sound_slots           = make_var(        array_t(SOUND_SLOT, 24), 0x0acfa0)  // LaSlot
title_submenu_row     = make_var(                         byte_t, 0x1bdba0)  // titseqData[0]

// --- stack --- //

storyboard_page            = make_var(dword_t, 0x1ffedc)  // TITSEQ_StoryBoardMenuControl.currentlySelectedImage

DoLevel_ret                = make_var(code_t,  0x1fff90)  // DoLevel -> S_CallInventory2 | QuickControlPhase
S_CallInventory2_ret_addr  = make_var(code_t,  0x010e34)
QuickControlPhase_ret_addr = make_var(code_t,  0x010e44)

DoGameFlow_ret             = make_var(code_t,  0x1fffc0)  // DoGameFlow -> DoLevel | DoTitle
DoLevel_ret_addr           = make_var(code_t,  0x0113a4)
DoTitle_ret_addr           = make_var(code_t,  0x0114ac)


//
//   g a m e   m o d e
//

// cutscenes:
// disable_lara_control is used for small cutscenes, such as showing something open,
// whilst playing_cutscene is used for major cutscenes, such as larson getting killed

function in_a_fmv() => mem_path(active_disp_env, ["isrgb24"]) == 1
function in_title() => mem_wide(DoGameFlow_ret) == var_addr(DoTitle_ret_addr)
function in_a_cutscene() => mem(playing_cutscene) == true
function in_credits() => mem(in_credits) == true

function loading_level() =>
    // loading_level is mostly active while loading, but still leaves a few frames at the end during which the
    // level isnt ready yet. in theory the gameflow_status checks supersede this one, but I'm leaving it here
    // in case there are values for gameflow_status I'm unaware of
    mem(loading_level) == 1
    || mem(gameflow_status) == enum_value(GAMEFLOW_STATUS, "RETURN_TO_TITLE")
    || mem(gameflow_status) == enum_value(GAMEFLOW_STATUS, "LOAD_SAVE")
    || mem(gameflow_status) == enum_value(GAMEFLOW_STATUS, "LOAD_LEVEL")

function in_demo() =>
    in_title()
    && in_a_cutscene()
    && !in_credits()

function in_special_features() =>
    in_title()
    && mem(title_submenu) == enum_value(TITLE_SUBMENU, "SPECIAL_FEATURES")


function in_a_level() =>
    mem_wide(DoGameFlow_ret) == var_addr(DoLevel_ret_addr)
    && mem(gameflow_status) == enum_value(GAMEFLOW_STATUS, "IN_LEVEL")

function never_not_in_a_level() =>
    never(mem_wide(DoGameFlow_ret) != var_addr(DoLevel_ret_addr))
    && never(mem(gameflow_status) != enum_value(GAMEFLOW_STATUS, "IN_LEVEL"))

function in_or_loading_a_level() =>
    mem_wide(DoGameFlow_ret) == var_addr(DoLevel_ret_addr)

function never_not_in_or_loading_a_level() =>
    never(mem_wide(DoGameFlow_ret) != var_addr(DoLevel_ret_addr))


function level_start(level) =>
    mem_wide(DoGameFlow_ret) == var_addr(DoLevel_ret_addr)
    && mem(level_id) == enum_value(LEVEL_ID, level)
    && mem_changed_from_to(mem(gameflow_status), enum_value(GAMEFLOW_STATUS, "LOAD_LEVEL"),
                                                 enum_value(GAMEFLOW_STATUS, "IN_LEVEL"))


function playing_a_level() =>
    in_a_level()
    && !in_a_fmv()

function never_not_playing_a_level() =>
    never_not_in_a_level()
    && never(in_a_fmv())


function in_level(level) =>
    in_a_level()
    && mem(level_id) == enum_value(LEVEL_ID, level)

function never_not_in_level(level) =>
    never_not_in_a_level()
    && never(mem(level_id) != enum_value(LEVEL_ID, level))

function never_not_in_or_loading_level(level) =>
    never_not_in_or_loading_a_level()
    && never(mem(level_id) != enum_value(LEVEL_ID, level))


function playing_level(level) =>
    in_level(level)
    && !in_a_fmv()

function never_not_playing_level(level) =>
    never_not_in_level(level)
    && never(in_a_fmv())

function never_not_playing_or_loading_level(level) =>
    never_not_in_or_loading_level(level)
    && never(in_a_fmv())


function completed_level(level) =>
    prev(mem_wide(DoGameFlow_ret)) == var_addr(DoLevel_ret_addr)
    && prev(mem(level_id)) == enum_value(LEVEL_ID, level)
    && mem_changed_from_to(mem(completed_level_id), 0, enum_value(LEVEL_ID, level) + 1)

function savegame_load_frame() =>
    mem_changed_to(mem_wide(menu_dialog), var_addr(load_ok_dialog))


function in_inventory() =>
    // DoLevel > S_CallInventory2
    // but exclude keypad mode
    mem_wide(DoLevel_ret) == var_addr(S_CallInventory2_ret_addr)
    && mem(using_keypad) == 0

function paused() =>
    // DoLevel > QuickControlPhase > ControlPhase > pause_menu
    // QuickControlPhase uses a different stack that is in inaccessible memory.
    // xa_fade_rate is only 32 inside the inventory and the pause menu, so use that
    // instead to narrow things down.
    mem_wide(DoLevel_ret) == var_addr(QuickControlPhase_ret_addr)
    && mem(xa_fade_rate) == 32

function not_paused_no_alts() =>
    // can't have ors in a leaderboard value, thus this approximation.
    // a false positive should be extremely unlikely
    mem_wide(DoLevel_ret) + mem(xa_fade_rate) != var_addr(QuickControlPhase_ret_addr) + 32

//
//   L e v e l s
//

playable_levels = ["STREETS_OF_ROME", "TRAJAN_MARKETS", "COLOSSEUM",
                   "BASE", "SUBMARINE", "DEEPSEA_DIVE", "SINKING_SUBMARINE",
                   "GALLOWS_TREE", "LABYRINTH", "OLD_MILL",
                   "THIRTEENTH_FLOOR", "ESCAPE_WITH_THE_IRIS", "RED_ALERT"]

function make_level_meta(name, secrets, items, n_items, n_rooms) =>
    {"name": name, "secrets": secrets, "items": items, "n_items": n_items, "n_rooms": n_rooms}

level_meta = {
    "TITLE":                make_level_meta("Title",                0, 0x1aa660,  38, 116),
    "STREETS_OF_ROME":      make_level_meta("Streets of Rome",      3, 0x1cb790, 151, 242),
    "TRAJAN_MARKETS":       make_level_meta("Trajan's Markets",     3, 0x1d0d54, 150, 252),
    "COLOSSEUM":            make_level_meta("Colosseum",            3, 0x1bb850, 110, 130),
    "BASE":                 make_level_meta("The Base",             3, 0x1d0bdc, 177, 169),
    "SUBMARINE":            make_level_meta("The Submarine",        3, 0x1d1480, 244, 195),
    "DEEPSEA_DIVE":         make_level_meta("Deepsea Dive",         1, 0x183e00,  31, 137),
    "SINKING_SUBMARINE":    make_level_meta("Sinking Submarine",    2, 0x1d611c, 216, 191),
    "GALLOWS_TREE":         make_level_meta("Gallows Tree",         3, 0x1c3254,  63, 243),
    "LABYRINTH":            make_level_meta("Labyrinth",            3, 0x1d2864, 158, 254),
    "OLD_MILL":             make_level_meta("Old Mill",             3, 0x1c7748,  60, 211),
    "THIRTEENTH_FLOOR":     make_level_meta("The 13th Floor",       3, 0x1cdd70, 211, 165),
    "ESCAPE_WITH_THE_IRIS": make_level_meta("Escape With the Iris", 3, 0x1c5844, 248, 179),
    "RED_ALERT":            make_level_meta("Red Alert",            3, 0x1c43cc, 225, 218)
}

function level_name(level) => level_meta[level]["name"]
function level_secrets(level) => level_meta[level]["secrets"]
function level_items(level) => make_var(array_t(ITEM_INFO, level_meta[level]["n_items"]), level_meta[level]["items"])

function level_all_items(level) =>
    make_var(array_t(ITEM_INFO, 256), level_meta[level]["items"])

function level_dyn_items(level) {
    all_ = level_all_items(level)
    return make_var(array_t(ITEM_INFO, array_var_size(all_) - level_meta[level]["n_items"]),
                    var_addr(addressof_path(all_, [level_meta[level]["n_items"]])))
}

function level_rooms(level) {
    // note: only works when in the level
    make_var(array_t(ROOM_INFO, level_meta[level]["n_rooms"]), mem_path(rooms, ["*"]))
}

function make_act_meta(name, levels, secrets_idx) =>
    {"name": name, "levels": levels, "secrets_idx": secrets_idx}

act_meta = {
    "ROME":    make_act_meta("Rome",              ["STREETS_OF_ROME", "TRAJAN_MARKETS", "COLOSSEUM"],         0),
    "RUSSIA":  make_act_meta("Russian Submarine", ["BASE", "SUBMARINE", "DEEPSEA_DIVE", "SINKING_SUBMARINE"], 2),
    "IRELAND": make_act_meta("Black Isle",        ["GALLOWS_TREE", "LABYRINTH", "OLD_MILL"],                  1),
    "VCI":     make_act_meta("VCI Headquarters",  ["THIRTEENTH_FLOOR", "ESCAPE_WITH_THE_IRIS", "RED_ALERT"],  3)
}

function act_name(act) => act_meta[act]["name"]
function act_levels(act) => act_meta[act]["levels"]
function act_secrets_var(act) => addressof_path(savegame, ["campaign_secrets", act_meta[act]["secrets_idx"]])


//
//   l a r a
//

function doing_normal_movement(lara_item) =>
    mem_path(lara_item, ["current_anim_state"]) <= enum_value(LARA_ANIM_STATE, "STOP")

function took_damage(lara_item) =>
    prev(mem_path(lara_item, ["hit_points"])) > mem_path(lara_item, ["hit_points"])
    || (!is_negative(word_t, prev(mem_path(lara_item, ["hit_points"])))
        && is_negative(word_t, mem_path(lara_item, ["hit_points"])))

function started_jump_alts(lara_item) => [
    // jumps started while stopped go through JUMP_PREPARE regardless of direction
    mem_changed_to(mem_path(lara_item, ["current_anim_state"]), enum_value(LARA_ANIM_STATE, "JUMP_PREPARE")),

    // forward jumps started while running go directly to JUMP_FORWARD. however, falling from platforms while
    // running has the same effect. we can distinguish these cases by whether gravity is acting on lara when
    // her anim state changes to JUMP_FORWARD: a purposeful jump won't be affected by gravity right away,
    // whilst a "jump" caused by falling off something will
    mem_changed_to(mem_path(lara_item, ["current_anim_state"]), enum_value(LARA_ANIM_STATE, "JUMP_FORWARD"))
    && prev(mem_path(lara_item, ["current_anim_state"])) != enum_value(LARA_ANIM_STATE, "JUMP_PREPARE")
    && mem_path(lara_item, ["flags2", "GRAVITY_STATUS"]) == 0
]


//
//   I t e m s
//
//   Each level has its own array of items, which include almost anything that's in the level: lara,
//   pickups, enemies, doors, buttons, etc... Static items, i.e, items that are part of the level
//   definition/model come at the start and are always in the same slot of the array. However, some
//   items such as active flares, are created dynamically when a specific event occurs. These are placed
//   after the static items on one of the empty slots of the array.
//

function item_def(num, object_type) =>
    {"type": "single", "num": num, "object_type": object_type}

function item_group_def(item_defs) =>
    {"type": "group", "items": item_defs}

items = {
    "STREETS_OF_ROME": {
        "Lara":                   item_def(  0, "LARA"),
        "Training Area Door":     item_def(128, "DOOR_TYPE1"),
        "Golden Key":             item_def(107, "KEY_ITEM1"),
        "Padlock":                item_def( 72, "SWITCH_TYPE7"),
        "Tower Revolver Ammo":    item_def(100, "REVOLVER_AMMO_ITEM"),
        "Tower Large Medipack":   item_def(101, "BIGMEDI_ITEM"),
        "Saturn Symbol":          item_def( 94, "PICKUP_ITEM2"),
        "Garden Keys":            item_group_def([item_def( 36, "PUZZLE_ITEM1"), item_def( 92, "PUZZLE_ITEM1")]),
        "Mouths of Truth":        item_group_def([item_def(103, "SWITCH_TYPE2"), item_def(105, "SWITCH_TYPE2")]),
        "Square Gates":           item_group_def([item_def(24, "DOOR_TYPE2"), item_def(46, "DOOR_TYPE2"), item_def(104, "DOOR_TYPE3")])
    },
    "TRAJAN_MARKETS": {
        "Lara":                   item_def( 35, "LARA"),
        "Pulley 1":               item_def( 36, "PULLEY"),
        "Pulley 2":               item_def( 27, "PULLEY"),
        "Mechanical Head":        item_def( 52, "GUARDIAN"),
        "Centurion":              item_def(109, "ROMAN_GOD"),
        "Larson":                 item_def( 77, "LARSON"),
        "Valve Wheel":            item_def(129, "PUZZLE_ITEM1"),
        "Golden Coin":            item_def(122, "PUZZLE_ITEM3"),
        "Mars Symbol":            item_def( 63, "PUZZLE_ITEM4"),
        "Venus Symbol":           item_def( 49, "PUZZLE_ITEM5"),
        "Gargoyles":              item_group_def([item_def(92, "HYDRA"), item_def(93, "HYDRA"), item_def(94, "HYDRA")])
    },
    "COLOSSEUM": {
        "Lara":                   item_def(  2, "LARA"),
        "Pedestal":               item_def( 46, "HIGH_OBJECT1"),
        "Gemstone Piece 1":       item_def( 62, "PUZZLE_ITEM4_COMBO1"),
        "Gemstone Piece 2":       item_def( 49, "PUZZLE_ITEM4_COMBO2"),
        "Centurion":              item_def( 79, "ROMAN_GOD"),
        "Colosseum Key 1":        item_def( 28, "KEY_ITEM1"),
        "Colosseum Key 2":        item_def(101, "KEY_ITEM2"),
        "Philosophers Stone":     item_def( 68, "PICKUP_ITEM1")
    },
    "BASE": {
        "Lara":                   item_def( 64, "LARA"),
        "Crate Small Medipack":   item_def(116, "SMALLMEDI_ITEM"),
        "Crate Uzi Ammo":         item_def(117, "UZI_AMMO_ITEM"),
        "Fuse":                   item_def( 24, "PUZZLE_ITEM1"),
        "Swipe Card":             item_def( 76, "KEY_ITEM8"),
        "Silver Keys":            item_group_def([item_def(59, "KEY_ITEM7"), item_def(161, "KEY_ITEM7")]),
        "Showers":                item_group_def([item_def(98, "WATERFALL1"), item_def(99, "WATERFALL1"), item_def(100, "WATERFALL1")]),
        "Snipers":                item_group_def([item_def(20, "SNIPER"), item_def(21, "SNIPER")])
    },
    "SUBMARINE": {
        "Lara":                   item_def( 51, "LARA"),
        "Chef":                   item_def(186, "CHEF"),
        "Aqualung":               item_def( 28, "PUZZLE_ITEM3_COMBO1"),
        "Suit Console":           item_def( 71, "PUZZLE_ITEM3_COMBO2"),
        "Battery (+)":            item_def(228, "PUZZLE_ITEM4_COMBO1"),
        "Battery (-)":            item_def(207, "PUZZLE_ITEM4_COMBO2"),
        "Bronze Key":             item_def(187, "KEY_ITEM6"),
        "Silver Key":             item_def(182, "KEY_ITEM7"),
        "Medipacks":              item_group_def([item_def(27, "BIGMEDI_ITEM"),
                                                  item_def(118, "SMALL_MEDI_ITEM"), item_def(209, "SMALL_MEDI_ITEM")])
    },
    "DEEPSEA_DIVE": {
        "Lara":                   item_def( 26, "LARA"),
        "Attack Submarines":      item_group_def([item_def(0, "ATTACK_SUB"), item_def(13, "ATTACK_SUB"), item_def(15, "ATTACK_SUB")])
    },
    "SINKING_SUBMARINE": {
        "Lara":                   item_def( 75, "LARA"),
        "Nitrogen Canister":      item_def(213, "PUZZLE_ITEM1"),
        "Oxygen Canister":        item_def(143, "PUZZLE_ITEM2"),
        "Bronze Key":             item_def(156, "KEY_ITEM6"),
        "Swipe Card":             item_def(118, "KEY_ITEM8"),
        "Electricity Switch":     item_def(190, "JUMP_SWITCH"),
        "Desert Eagle":           item_def(203, "REVOLVER_ITEM"),
        "Enemies":                item_group_def([item_def(43, "MAFIA"), item_def(155, "MAFIA"), // item_def(185, "MAFIA"),
                                                  item_def(16, "MAFIA2"), item_def(44, "MAFIA2"), item_def(119, "MAFIA2")])
    },
    "GALLOWS_TREE": {
        "Lara":                   item_def( 14, "LARA"),
        "Changeling 1":           item_def( 26, "IMP"),
        "Heart":                  item_def(  8, "PUZZLE_ITEM1"),
        "Rubber Tube":            item_def( 18, "PUZZLE_ITEM2_COMBO1"),
        "Slingshot":              item_def( 39, "PUZZLE_ITEM2_COMBO2"),
        "Iron Clapper":           item_def(  6, "PUZZLE_ITEM3")
    },
    "LABYRINTH": {
        "Lara":                   item_def(  6, "LARA"),
        "Will-O'-Wisp":           item_def(143, "WILLOWISP"),
        "Bestiary":               item_def( 29, "PICKUP_ITEM1")
    },
    "OLD_MILL": {
        "Lara":                   item_def( 12, "LARA"),
        "Chalk":                  item_def( 26, "PUZZLE_ITEM1"),
        "Silver Coin":            item_def( 19, "PUZZLE_ITEM2"),
        "Chasm Medipack":         item_def( 17, "BIGMEDI_ITEM"),
        "Secret 2":               item_def( 54, "PICKUP_ITEM4"),
        "Changelings":            item_group_def([item_def(2, "IMP"), item_def(3, "IMP")]),
        "Secret 2 Flames":        item_group_def([item_def(55, "FLAME_EMITTER"), item_def(56, "FLAME_EMITTER")])
    },
    "THIRTEENTH_FLOOR": {
        "Lara":                   item_def(  1, "LARA"),
        "Duct Explosion 1":       item_def(154, "EXPLOSION"),
        "Sleeping Guard":         item_def(110, "BLUE_GUARD"),
        "Hidden Armored Guard":   item_def(125, "TWOGUN"),
        "Access Code Disc":       item_def( 27, "PUZZLE_ITEM3"),
        "Iris Lab Access":        item_def(204, "PUZZLE_ITEM4"),
        "Iris Artifact":          item_def( 14, "PICKUP_ITEM2"),
        "Hammer":                 item_def( 35, "KEY_ITEM7"),
        "High Level Access Card": item_def(109, "KEY_ITEM8"),
        "Iris Lab Scientist":     item_def( 85, "SCIENTIST"),
        "Turrets":                item_group_def([item_def(79, "AUTOGUN"), item_def(86, "AUTOGUN"),
                                                  item_def(97, "AUTOGUN"), item_def(111, "AUTOGUN")]),
        "Killable People":        item_group_def([item_def( 44, "BLUE_GUARD"), item_def( 80, "BLUE_GUARD"), item_def( 99, "BLUE_GUARD"),
                                                  item_def(110, "BLUE_GUARD"), item_def(146, "BLUE_GUARD"), item_def(147, "BLUE_GUARD"),
                                                  item_def(187, "BLUE_GUARD"), item_def(188, "BLUE_GUARD"), item_def(189, "BLUE_GUARD"),
                                                  item_def(190, "BLUE_GUARD"), item_def(207, "BLUE_GUARD"),
                                                  item_def(28, "SCIENTIST"), item_def( 76, "SCIENTIST"), item_def(77, "SCIENTIST"),
                                                  item_def(85, "SCIENTIST"),
                                                  item_def( 29, "TWOGUN"), item_def(120, "TWOGUN"), item_def(125, "TWOGUN"),
                                                  item_def(203, "TWOGUN")]),
        "Killable Guards":        item_group_def([item_def( 44, "BLUE_GUARD"), item_def( 80, "BLUE_GUARD"), item_def( 99, "BLUE_GUARD"),
                                                  item_def(110, "BLUE_GUARD"), item_def(146, "BLUE_GUARD"), item_def(147, "BLUE_GUARD"),
                                                  item_def(187, "BLUE_GUARD"), item_def(188, "BLUE_GUARD"), item_def(189, "BLUE_GUARD"),
                                                  item_def(190, "BLUE_GUARD"), item_def(207, "BLUE_GUARD"),
                                                  item_def( 29, "TWOGUN"), item_def(120, "TWOGUN"), item_def(125, "TWOGUN"),
                                                  item_def(203, "TWOGUN")])
    },
    "ESCAPE_WITH_THE_IRIS": {
        "Lara":                   item_def(187, "LARA"),
        "Restroom Card":          item_def(161, "PICKUP_ITEM2"),
        "X-Ray Button 1":         item_def( 28, "SWITCH_TYPE2"),
        "Teleporter Disc":        item_def(234, "PUZZLE_ITEM3"),
        "Last Guard":             item_def(219, "BLUE_GUARD"),
        "X-Ray Button 2":         item_def(  0, "SWITCH_TYPE2"),
        "Backtrack Medipack":     item_def( 42, "BIGMEDI_ITEM"),
        "Restroom Stall Doors":   item_group_def([item_def(189, "KICK_DOOR1"), item_def(190, "KICK_DOOR1"), item_def(192, "KICK_DOOR1"),
                                                  item_def(199, "KICK_DOOR1"), item_def(200, "KICK_DOOR1"), item_def(202, "KICK_DOOR1")]),
        "Ambush Medipacks":       item_group_def([item_def(70, "BIGMEDI_ITEM"), item_def(71, "BIGMEDI_ITEM")])
    },
    "RED_ALERT": {
        "Lara":                   item_def( 17, "LARA"),
        "Steam Valve":            item_def(  3, "SWITCH_TYPE7"),
        "Range 1 Switch":         item_def( 64, "SWITCH_TYPE6"),
        "Range 2 Switch":         item_def( 98, "SWITCH_TYPE6"),
        "Range 2 Door":           item_def(216, "DOOR_TYPE1"),
        "Cyborg 1":               item_def(200, "HITMAN"),
        "Bar Switch":             item_def( 39, "SWITCH_TYPE2"),
        "Cyborg 2":               item_def(183, "HITMAN"),
        "Trap Room Door":         item_def(180, "CLOSED_DOOR1"),
        "Key Bit (Left)":         item_def(201, "PUZZLE_ITEM1_COMBO1"),
        "Key Bit (Right)":        item_def(184, "PUZZLE_ITEM1_COMBO2")
    }
}

function item_num(level, name) => items[level][name]["num"]
function item_object_type(level, name) => items[level][name]["object_type"]
function item_var(level, name) => addressof_path(level_items(level), [item_num(level, name)])

function item_group_nums(level, name) {
    nums_ = []
    for item_ in items[level][name]["items"]
        array_push(nums_, item_["num"])
    return nums_
}

function item_group_vars(level, name) {
    vars_ = []
    for item_ in items[level][name]["items"]
        array_push(vars_, addressof_path(level_items(level), [item_["num"]]))
    return vars_
}

function item_group_object_types(level, name) {
    obj_types_ = []
    for item_ in items[level][name]["items"]
        array_push(obj_types_, item_["object_type"])
    return obj_types_
}

function _item_status_aux(hi, lo, status) {
    if (status == "INACTIVE")    return hi == 0 && lo == 0
    if (status == "ACTIVE")      return hi == 0 && lo == 1
    if (status == "DEACTIVATED") return hi == 1 && lo == 0
    if (status == "INVISIBLE")   return hi == 1 && lo == 1
}

function item_status_was(item, status) =>
    _item_status_aux(prev(mem_path(item, ["flags2", "ITEM_STATUS_1"])),
                     prev(mem_path(item, ["flags2", "ITEM_STATUS_0"])), status)

function item_status_is(item, status) =>
    _item_status_aux(mem_path(item, ["flags2", "ITEM_STATUS_1"]),
                     mem_path(item, ["flags2", "ITEM_STATUS_0"]), status)

function _dimension_within(t, a, b, threshold) => [
    is_negative(t, a) && is_negative(t, b) && b >= a && (b - a <= threshold),
    is_negative(t, a) && is_negative(t, b) && b < a && (a - b <= threshold),
    is_negative(t, a) && !is_negative(t, b) && (b + (0xffffffff - a + 1) <= threshold),
    !is_negative(t, a) && is_negative(t, b) && (a + (0xffffffff - b + 1) <= threshold),
    !is_negative(t, a) && !is_negative(t, b) && b <= a && (a - b <= threshold),
    !is_negative(t, a) && !is_negative(t, b) && b > a && (b - a <= threshold)
]

function items_within(item_a, item_b, threshold) {
    t_ = typeof_path(item_a, ["pos", "x_pos"])
    alts_x_ = _dimension_within(t_, mem_path(item_a, ["pos", "x_pos"]), mem_path(item_b, ["pos", "x_pos"]), threshold)
    alts_z_ = _dimension_within(t_, mem_path(item_a, ["pos", "z_pos"]), mem_path(item_b, ["pos", "z_pos"]), threshold)

    alts_ = []
    for alt_x_ in alts_x_
        for alt_z_ in alts_z_
            array_push(alts_, alt_x_ && alt_z_)
    
    return alts_
}

function item_in_positive_2d_box(item, x_min, x_max, z_min, z_max) {
    x_ = mem_path(item, ["pos", "x_pos"])
    z_ = mem_path(item, ["pos", "z_pos"])
    return x_ >= x_min && x_ <= x_max
           && z_ >= z_min && z_ <= z_max
}

function item_activation_mask_bitcount(item) {
    mask_bitcount_ = 0
    for i_ in range(0, 4)
        mask_bitcount_ = mask_bitcount_
            + mem_path(item, ["flags", format("ACTIVATION_MASK_{0}", i_)])
    return mask_bitcount_
}


//
//   L e v e l   S t a r t s
//
//   Tomb Raider Chornicles does not allow levels to be replayed from the start, which is a problem
//   for leaderboards and whole-level achievements, such as NLNMAS. Using the actual level start as
//   the starting point would require players to save _before_ ending the previous level. In addition,
//   all cutscenes between the end of the last level and the start of the current one would have to
//   be viewed on every attempt.
//
//   The solution I'm going with is to use the moment in which Lara gains control for the first time
//   after entering the level and coming to a full stop as the starting point. Some levels start
//   with a spotcam sequence or a cutscene, and the starting point only comes when they end. Other
//   levels have lara sliding down a slope, but control is lost immediately upon landing, in which
//   case the player must allow lara to slide without interference, so that she lands at a specific
//   spot.
//
//   With this approach players can save when a level starts, as long as they don't move before
//   saving. That save can then be reloaded to attempt achievements or restart the leaderboard.
//

function make_level_start_meta(x, y, z, y_rot, spotcam, cutscene, lara_control) =>
    {"x": x, "y": y, "z": z, "y_rot": y_rot, "spotcam": spotcam, "cutscene": cutscene, "lara_control": lara_control}

level_start_meta = {
    "STREETS_OF_ROME":      make_level_start_meta(0x0b600, 0x00000000, 0x07a00, 0x0000, true,  false, false),
    "TRAJAN_MARKETS":       make_level_start_meta(0x16600, 0x00000000, 0x0a600, 0xc000, false, false, false),
    "COLOSSEUM":            make_level_start_meta(0x16212, 0x00001200, 0x0ce00, 0xc000, true,  false, false),
    "BASE":                 make_level_start_meta(0x08a00, 0xfffff000, 0x0739c, 0x0000, false, false, false),
    "SUBMARINE":            make_level_start_meta(0x0e25e, 0x00002300, 0x0d200, 0x4000, false, true,  false),
    "DEEPSEA_DIVE":         make_level_start_meta(0x06200, 0x000037b8, 0x0c600, 0x0000, false, false, false),
    "SINKING_SUBMARINE":    make_level_start_meta(0x0e600, 0x00001400, 0x12a00, 0x0000, false, true,  false),
    "GALLOWS_TREE":         make_level_start_meta(0x0e600, 0x00000080, 0x07e00, 0x0000, false, false, false),
    "LABYRINTH":            make_level_start_meta(0x0be00, 0x00001e00, 0x06e00, 0x0000, false, false, false),
    "OLD_MILL":             make_level_start_meta(0x13200, 0x0000157f, 0x0a2ba, 0x0000, false, true,  false),
    "THIRTEENTH_FLOOR":     make_level_start_meta(0x09a0a, 0x00000000, 0x09600, 0xc000, false, false, true),
    "ESCAPE_WITH_THE_IRIS": make_level_start_meta(0x07200, 0xffffa200, 0x0b600, 0x4000, false, false, false),
    "RED_ALERT":            make_level_start_meta(0x0d200, 0x00002700, 0x12e00, 0x8000, true,  false, false)
}

function loadable_level_start(level) {
    lara_ = item_var(level, "Lara")
    meta_ = level_start_meta[level]

    cond_ = mem_path(lara_, ["pos", "x_pos"]) == meta_["x"]
            && mem_path(lara_, ["pos", "y_pos"]) == meta_["y"]
            && mem_path(lara_, ["pos", "z_pos"]) == meta_["z"]
            && mem_path(lara_, ["pos", "y_rot"]) == meta_["y_rot"]

    if (meta_["spotcam"] == true)
        cond_ = cond_ && mem(spotcam_active) == 0

    if (meta_["cutscene"] == true)
        cond_ = cond_ && mem(playing_cutscene) == 0

    if (meta_["lara_control"] == true)
        cond_ = cond_ && mem(disable_lara_control) == 0

    return cond_
}
    

//
//   C u t s c e n e s
//
//   There are two types of cutscenes in the game: major cutscenes and spotcam cutscenes. The former
//   usually occur when characters are animated, whilst the latter are mostly made up of camera
//   flybys. We try to abstract that difference away.
//

// good cutscenes set their number in a global variable that we can check, but the bad ones don't
// and we're forced to check other properties of the cutscene
function good_cutscene_def(num) =>
    {"type": "good", "num": num}
function bad_cutscene_def(num, n_actors, n_frames, lara_x, lara_y, lara_z) =>
    {"type": "bad", "num": num, "n_actors": n_actors, "n_frames": n_frames, "lara_x": lara_x, "lara_y": lara_y, "lara_z": lara_z}

// spotcam cutscenes work in a completely different way, but I'm considering them cutscenes still
function spotcam_cutscene_def(num) =>
    {"type": "spotcam", "num": num}

cutscenes = {
    "TRAJAN_MARKETS": {
        "Open Circular Door":      spotcam_cutscene_def(0x01),
        "Gargoyles":               bad_cutscene_def(0x07, 5, 0x592, 0xda00, 0x0000, 0x7600)
    },
    "BASE": {
        "Disable Mechanical Claw": good_cutscene_def(0x1b),
        "Board Submarine":         good_cutscene_def(0x16)
    },
    "DEEPSEA_DIVE": {
        "Get Spear":               good_cutscene_def(0x28),
    },
    "SINKING_SUBMARINE": {
        "Meet Admiral":            good_cutscene_def(0x0d)
    },
    "GALLOWS_TREE": {
        "Good Ending":             good_cutscene_def(0x09),
        "Bad Ending":              good_cutscene_def(0x0a)
    },
    "LABYRINTH": {
        "Reveal Skeletons":        spotcam_cutscene_def(0x00),
        "Kill Skeletons":          spotcam_cutscene_def(0x01),
        "Get Bone Dust":           good_cutscene_def(0x22)
    },
    "THIRTEENTH_FLOOR": {
        "Chloroform Armor Guard":  good_cutscene_def(0x04),
        "Scientist Tag Team":      good_cutscene_def(0x18)
    },
    "ESCAPE_WITH_THE_IRIS": {
        "Elevator Fall":           spotcam_cutscene_def(0x04),
        "Iris Lab Plan":           spotcam_cutscene_def(0x0c)
    }
}

function _bad_cutscene_active(cut_def) =>
    mem_path(cutscene, ["num_actors"]) == cut_def["n_actors"]
    && mem_path(cutscene, ["num_frames"]) == cut_def["n_frames"]
    && mem_path(cutscene, ["org_x"]) == cut_def["lara_x"]
    && mem_path(cutscene, ["org_y"]) == cut_def["lara_y"]
    && mem_path(cutscene, ["org_z"]) == cut_def["lara_z"]

function cutscene_started(level, name) {
    cut_def_ = cutscenes[level][name]

    if (cut_def_["type"] == "good")
        return mem(cutscene_num) == cut_def_["num"]
               && mem_changed_from_to(mem(playing_cutscene), 0, 1)

    if (cut_def_["type"] == "bad")
        return _bad_cutscene_active(cut_def_)
               && mem_changed_from_to(mem(playing_cutscene), 0, 1)

    if (cut_def_["type"] == "spotcam")
        return mem(current_spotcam_num) == cut_def_["num"]
               && mem_changed_from_to(mem(spotcam_active), 0, 1)
}

function cutscene_ended(level, name) {
    cut_def_ = cutscenes[level][name]

    if (cut_def_["type"] == "good")
        return mem_changed_from_to(mem(cutscene_num), cut_def_["num"], 0)

    if (cut_def_["type"] == "bad")
        return _bad_cutscene_active(cut_def_)
               && mem_changed_from_to(mem(playing_cutscene), 1, 0)

    if (cut_def_["type"] == "spotcam")
        return mem(current_spotcam_num) == cut_def_["num"]
               && mem_changed_from_to(mem(spotcam_active), 1, 0)
}

function cutscene_played_mem(level, name) {
    cut_def_ = cutscenes[level][name]
    if (cut_def_["type"] != "good" && cut_def_["type"] != "bad")
        error(format("unsuported cutscene type: {0}", cut_def_["type"]))

    num_ = cut_def_["num"]
    if (num_ <= 0x1f)
        var_ = triggered_cutscenes_1
    else {
        num_ = num_ - 0x20
        var_ = triggered_cutscenes_2
    }

    addr_ = var_addr(var_) + (num_ / 8)

    bit_offset_ = num_ % 8
    if (bit_offset_ == 0) return mem(make_var(bit0_t, addr_))
    if (bit_offset_ == 1) return mem(make_var(bit1_t, addr_))
    if (bit_offset_ == 2) return mem(make_var(bit2_t, addr_))
    if (bit_offset_ == 3) return mem(make_var(bit3_t, addr_))
    if (bit_offset_ == 4) return mem(make_var(bit4_t, addr_))
    if (bit_offset_ == 5) return mem(make_var(bit5_t, addr_))
    if (bit_offset_ == 6) return mem(make_var(bit6_t, addr_))
    if (bit_offset_ == 7) return mem(make_var(bit7_t, addr_))
}


//
//   S o u n d s
//
//   Sound effects are played by placing a request on a fixed-size array, specifying, among other things,
//   which sound effect is to be played. This effect doesn't identify which exact sound sample will play,
//   however, as many effects have more than one sample for variety.
//

function sound_playing(fx_name) {
    in_slot_ = always_false()
    for i in range(0, array_var_size(sound_slots) - 1)
        in_slot_ = in_slot_
            || mem_path(sound_slots, [i, "n_sample_info"]) == enum_value(SOUND_FX, fx_name)

    return mem(sound_active) == 1
           && in_slot_
}


//
//   S t a t i c   M e s h e s
//
//   Even though almost everything in a level is an item, there are some objects that are actually
//   just made up of level geometry that can be interacted with / destroyed. It's unclear why this
//   distinction exists.
//

function static_mesh_def(room_num, num) =>
    {"room_num": room_num, "num": num}

static_meshes = {
    "TRAJAN_MARKETS": {
        "Crowbar Box": static_mesh_def(1, 0)
    }
}

function static_mesh_var(level, name) {
    mesh_def_ = static_meshes[level][name]
    meshes_ = make_var(array_t(MESH_INFO, mesh_def_["num"] + 1),
                       mem_path(level_rooms(level), [mesh_def_["room_num"], "meshes"]))
    return addressof_path(meshes_, [mesh_def_["num"]])
}


//
//   k e y p a d
//

function keypad_success(combination) =>
    mem(keypad_combination) == (combination[0] * 1000 + combination[1] * 100 + combination[2] * 10 + combination[3])
    && mem(keypad_n_inputs) == 4
    && mem_path(keypad_inputs, [0]) == combination[0]
    && mem_path(keypad_inputs, [1]) == combination[1]
    && mem_path(keypad_inputs, [2]) == combination[2]
    && mem_path(keypad_inputs, [3]) == combination[3]
    && mem_changed_from_to(mem(using_keypad), 1, 0)


//
//   C h e a t   P r o t e c t i o n
//
//   The *all-guns-max-ammo cheat* is easy to detect because item quantities are set to -1, which
//   is impossible to achieve legit.
//
//   The *all-items cheat* doesn't leave permanent evidence behind; it simply gives Lara 1 of each
//   key, puzzle and pickup item. Protection works by activating a pause lock if at any point Lara
//   has these items in the inventory whilst the corresponding items on the level still haven't
//   been picked up.
//
//   The all-items cheat also unlocks the special features, but there's not much that can be done
//   to protect against that.
//

function all_guns_cheat() =>
    // no need to check anything else...
    mem_path(lara, ["num_small_medipack"]) == 0xffff

// - items: level items that must be collected before having the corresponding inventory items
// - groups: level item groups of which Lara must collect at least one before having the corresponding inventory items
// - combos: combos whose two level items must be collected before having the corresponding merged inventory items
// - cutscene_items: cutscenes that must have played before having specific inventory items
// - impossible_items: inventory items that can only be obtained through the cheat
function make_items_cheat_meta(items, groups, combos, cutscene_items, impossible_items) =>
    {"items": items, "groups": groups, "combos": combos, "cutscene_items": cutscene_items, "impossible_items": impossible_items}

items_cheat_meta = {
    "STREETS_OF_ROME": make_items_cheat_meta(
        ["Golden Key", "Saturn Symbol"], ["Garden Keys"], [], [], []
    ),
    "TRAJAN_MARKETS": make_items_cheat_meta(
        ["Valve Wheel", "Golden Coin", "Mars Symbol", "Venus Symbol"], [], [], [], []
    ),
    "COLOSSEUM": make_items_cheat_meta(
        // "Philosophers Stone" is ignored because there's a cutscene skip in Streets of Rome that causes Lara to keep the
        // Saturn Symbol. When she reaches Colosseum, the item becomes the Philosophers Stone due to having the same id,
        // triggering the all-items cheat protection. There's really not much downside to ignoring the Philosophers Stone
        // since it's only used at the very end of the level anyway.
        ["Colosseum Key 1", "Colosseum Key 2"], [], [["Gemstone Piece 1", "Gemstone Piece 2"]], [], []
    ),
    "BASE": make_items_cheat_meta(
        ["Fuse", "Swipe Card"], ["Silver Keys"], [], [], []
    ),
    "SUBMARINE": make_items_cheat_meta(
        ["Bronze Key", "Silver Key"], [], [["Aqualung", "Suit Console"], ["Battery (+)", "Battery (-)"]], [], []
    ),
    "DEEPSEA_DIVE": make_items_cheat_meta(
        [], [], [], [["PICKUP_ITEM1", "Get Spear"]], []
    ),
    "SINKING_SUBMARINE": make_items_cheat_meta(
        ["Nitrogen Canister", "Oxygen Canister", "Bronze Key", "Swipe Card"], [], [], [["KEY_ITEM7", "Meet Admiral"]], []
    ),
    "GALLOWS_TREE": make_items_cheat_meta(
        ["Heart", "Iron Clapper"], [], [["Rubber Tube", "Slingshot"]], [], []
    ),
    "LABYRINTH": make_items_cheat_meta(
        ["Bestiary"], [], [], [["PUZZLE_ITEM1", "Get Bone Dust"]], []
    ),
    "OLD_MILL": make_items_cheat_meta(
        ["Chalk", "Silver Coin"], [], [], [], []
    ),
    "THIRTEENTH_FLOOR": make_items_cheat_meta(
        ["Access Code Disc", "Iris Lab Access", "Iris Artifact", "Hammer", "High Level Access Card"], [], [], [], ["PICKUP_ITEM1"]
    ),
    "ESCAPE_WITH_THE_IRIS": make_items_cheat_meta(
        ["Restroom Card", "Teleporter Disc"], [], [], [], ["PICKUP_ITEM1"]
    ),
    "RED_ALERT": make_items_cheat_meta(
        [], [], [["Key Bit (Left)", "Key Bit (Right)"]], [], []
    )
}

function _object_type_to_lara_mem(obj_type) {
    obj_type_ = enum_value(OBJECT_TYPE, obj_type)
    if (obj_type_ >= enum_value(OBJECT_TYPE, "KEY_ITEM1") && obj_type_ <= enum_value(OBJECT_TYPE, "KEY_ITEM8")) {
        n_ = obj_type_ - enum_value(OBJECT_TYPE, "KEY_ITEM1")
        lara_mem_ = mem(cast_var(bit_n_t(n_), addressof_path(lara, ["key_items"])))
    } else if (obj_type_ >= enum_value(OBJECT_TYPE, "PICKUP_ITEM1") && obj_type_ <= enum_value(OBJECT_TYPE, "PICKUP_ITEM4")) {
        n_ = obj_type_ - enum_value(OBJECT_TYPE, "PICKUP_ITEM1")
        lara_mem_ = mem(cast_var(bit_n_t(n_), addressof_path(lara, ["pickup_items"])))
    } else if (obj_type_ >= enum_value(OBJECT_TYPE, "PUZZLE_ITEM1") && obj_type_ <= enum_value(OBJECT_TYPE, "PUZZLE_ITEM8")) {
        n_ = obj_type_ - enum_value(OBJECT_TYPE, "PUZZLE_ITEM1")
        lara_mem_ = mem_path(lara, ["puzzle_items", n_])
    } else {
        error(format("unsupported object type: {0}", obj_type))
    }
    return lara_mem_
}

function _cheated_item(level, name) {
    // some items aren't KILLED, they're set to INVISIBLE
    if (level == "GALLOWS_TREE" && name == "Iron Clapper")
        item_uncollected_ = (mem_path(item_var(level, name), ["flags2", "ITEM_STATUS_1"])
                             + mem_path(item_var(level, name), ["flags2", "ITEM_STATUS_0"])) < 2
    // still others are just removed from the drawing linked list
    else if (level == "ESCAPE_WITH_THE_IRIS" && name == "Teleporter Disc")
        item_uncollected_ = mem_path(item_var(level, name), ["next_item"]) == 0xe9
    else
        item_uncollected_ = mem_path(item_var(level, name), ["flags", "KILLED"]) == 0

    return item_uncollected_
           && _object_type_to_lara_mem(item_object_type(level, name)) == 1
}

function _cheated_item_group(level, name) {
    obj_types_ = item_group_object_types(level, name)

    items_uncollected_ = always_true()
    for item_ in item_group_vars(level, name)
        items_uncollected_  = items_uncollected_ && mem_path(item_, ["flags", "KILLED"]) == 0

    // note: the cheat always sets the number of items to 1
    return items_uncollected_
           && _object_type_to_lara_mem(obj_types_[0]) > 0
}

function _cheated_item_combo(level, combo1, combo2) {
    obj_type_ = enum_value(OBJECT_TYPE, item_object_type(level, combo1))

    if (obj_type_ >= enum_value(OBJECT_TYPE, "PUZZLE_ITEM1_COMBO1") && obj_type_ <= enum_value(OBJECT_TYPE, "PUZZLE_ITEM8_COMBO2")) {
        n_ = (obj_type_ - enum_value(OBJECT_TYPE, "PUZZLE_ITEM1_COMBO1")) / 2
        lara_mem_ = mem_path(lara, ["puzzle_items", n_])
    } else {
        error(format("unsupported object type: {0}", item_object_type(level, combo1)))
    }

    return (mem_path(item_var(level, combo1), ["flags", "KILLED"])
            + mem_path(item_var(level, combo2), ["flags", "KILLED"])) < 2
           && lara_mem_ == 1
}

function _cheated_cutscene_item(level, obj_type, cutscene) {
    cond_ = cutscene_played_mem(level, cutscene) == 0
            && _object_type_to_lara_mem(obj_type) == 1

    // some cutscenes give the item before being set as played
    if (level == "LABYRINTH" && cutscene == "Get Bone Dust")
        cond_ = cond_ && mem(cutscene_num) != cutscenes[level][cutscene]["num"]

    return cond_
}

function _cheated_impossible_item(level, obj_type) =>
    _object_type_to_lara_mem(obj_type) == 1

function all_items_cheat_alts(level) {
    meta_ = items_cheat_meta[level]
    alts_ = []
    for item_ in meta_["items"]
        array_push(alts_, _cheated_item(level, item_))
    for group_ in meta_["groups"]
        array_push(alts_, _cheated_item_group(level, group_))
    for combo_ in meta_["combos"]
        array_push(alts_, _cheated_item_combo(level, combo_[0], combo_[1]))
    for it_ in meta_["cutscene_items"]
        array_push(alts_, _cheated_cutscene_item(level, it_[0], it_[1]))
    for item_ in meta_["impossible_items"]
        array_push(alts_, _cheated_impossible_item(level, item_))
    return alts_
}


// =============================== //
// =============================== //
//                                 //
//      P A U S E   L O C K S      //
//                                 //
// =============================== //
// =============================== //

function level_pause_lock_placeholder(level) =>
    byte(0x555) == enum_value(LEVEL_ID, level)

function act_pause_lock_placeholder(act) {
    levels_ = act_levels(act)
    return byte(0x555) == 100 + enum_value(LEVEL_ID, levels_[0])
}

function any_level_pause_lock_placeholder() =>
    byte(0x555) == 0xff

gen_pause_locks = false
if (gen_pause_locks == true) {

    function _level_pause_lock(level) {
        alts_ = []
        for alt_ in all_items_cheat_alts(level)
            array_push(alts_, playing_level(level) && alt_)

        achievement(
            title=format("[{0}] Pause Lock", level_name(level)),
            description=format("Pause lock for {0}", level_name(level)),
            points=0,
            trigger=level_pause_lock_placeholder(level)
                    && unless(tally(1, alts_))
        )
    }
    for level_ in playable_levels
        _level_pause_lock(level_)

    function _act_pause_lock(act) {
        alts_ = []
        for level_ in act_levels(act)
            for alt_ in all_items_cheat_alts(level_)
                array_push(alts_, playing_level(level_) && alt_)

        achievement(
            title=format("[{0}] Pause Lock", act_name(act)),
            description=format("Pause lock for the {0} act", act_name(act)),
            points=0,
            trigger=act_pause_lock_placeholder(act)
                    && unless(tally(1, alts_))
        )
    }
    for act_ in ["ROME", "RUSSIA", "IRELAND"]
        _act_pause_lock(act_)

    function _any_level_pause_lock() {
        alts_ = []
        for level_ in playable_levels
            for alt_ in all_items_cheat_alts(level_)
                array_push(alts_, playing_level(level_) && alt_)

        achievement(
            title="[Any Level] Pause Lock",
            description="Pause lock for non-level-specific achievements",
            points=0,
            trigger=any_level_pause_lock_placeholder()
                    && unless(tally(1, alts_))
        )
    }
    _any_level_pause_lock()
    
    achievement(
        title="Pause Lock Title Reset",
        description="Reset when in title",
        points=0,
        trigger=once(byte(1) == 1)
                && never(in_title())
    )
}


// ================================ //
// ================================ //
//                                  //
//      A C H I E V E M E N T S     //
//                                  //
// ================================ //
// ================================ //

//
//   C H E A T   P R O T E C T I O N
//

function level_cheat_protection(level) =>
    level_pause_lock_placeholder(level)
    && !all_guns_cheat()

function act_cheat_protection(act) =>
    act_pause_lock_placeholder(act)
    && !all_guns_cheat()

function any_level_cheat_protection() =>
    any_level_pause_lock_placeholder()
    && !all_guns_cheat()


//
//   P R O G R E S S I O N
//

function beat_level_achievement(level, id, badge, points) {
    achievement(
        id=id,
        badge=badge,
        title=format("{0}", level_name(level)),
        description=format("Complete {0}", level_name(level)),
        points=points,
        trigger=level_cheat_protection(level)
                && completed_level(level)
    )
}

//
//   S E C R E T S
//

function secrets_achievement(level, id, badge, points) {
    secrets = level_secrets(level)
    if (secrets == 1) {
        title = format("Secret of {0}", level_name(level))
        description = format("Collect the secret of {0}", level_name(level))
    } else {
        title = format("Secrets of {0}", level_name(level))
        description = format("Collect the {0} secrets of {1}", secrets, level_name(level))
    }

    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=level_cheat_protection(level)
                && playing_level(level)
                && mem_changed_from_to(mem_path(savegame, ["level", "secrets"]), secrets - 1, secrets)

                // exclude the exact frame in which the savegame structure is overwritten by a game load
                // to avoid triggering the achievement if a n-secret savegame is loaded while having
                // n-1 secrets
                && unless(savegame_load_frame())
    )
}

//
//   N L N M A S
//

function level_nlnmas_achievement(level, id, badge, points) {
    n_secrets_ = level_secrets(level)

    achievement(
        id=id,
        badge=badge,
        title=format("{0} NLNMAS", level_name(level)),
        description=format("Complete {0} without loading, using medipacks, and having found all secrets", level_name(level)),
        points=points,
        trigger=level_cheat_protection(level)
                && never_not_playing_level(level)
                && once(level_start(level))
                && never(mem_increased(mem_path(savegame, ["game", "health_used"])))
                && mem_path(savegame, ["level", "secrets"]) == n_secrets_
                && completed_level(level)
    )
}

function act_nlnmas_achievement(act, id, badge, points) {
    levels_ = act_levels(act)

    in_act_level_ = always_false()
    for level_ in levels_
        in_act_level_ = in_act_level_ || mem(level_id) == enum_value(LEVEL_ID, level_)

    achievement(
        id=id,
        badge=badge,
        title=format("{0} NLNMAS", act_name(act)),
        description=format("Complete the {0} arc without loading, using medipacks, and having found all secrets", act_name(act)),
        points=points,
        trigger=act_cheat_protection(act)
        
                // allow loads to get from one level to another, but not loads of saved games
                && never_not_in_or_loading_a_level()
                && never(mem(gameflow_status) == enum_value(GAMEFLOW_STATUS, "LOAD_SAVE"))
                && never(!in_act_level_)

                // store a hit when the first level of the act starts
                && once(level_start(levels_[0]))

                // reset if a medipack is used
                && never(mem_increased(mem_path(savegame, ["game", "health_used"])))
                
                // trigger upon completion of the last level of the act...
                && completed_level(levels_[length(levels_) - 1])
                
                // ... iff all secrets were collected
                && mem(act_secrets_var(act)) == 9
    )
}


//
//   S T R E E T S   O F   R O M E
//

gen_achievements = true
if (gen_achievements == true) {

beat_level_achievement("STREETS_OF_ROME", 147329, "163913", 5)

secrets_achievement("STREETS_OF_ROME", 147330, "163915", 3)

function _truth_achievement() {
    switches_off_ = always_true()
    for switch_ in item_group_vars("STREETS_OF_ROME", "Mouths of Truth")
        switches_off_ = switches_off_
            && mem_path(switch_, ["current_anim_state"]) == enum_value(SWITCH_ANIM_STATE, "OFF")

    achievement(
        id=147331,
        badge="163916",
        title="Afraid of the Truth",
        description=format("[{0}] Collect the Golden Key without triggering the switches inside the Mouth of Truth carvings", level_name("STREETS_OF_ROME")),
        points=5,
        trigger=level_cheat_protection("STREETS_OF_ROME")
                && playing_level("STREETS_OF_ROME")
                && switches_off_
                && mem_changed_from_to(mem_path(item_var("STREETS_OF_ROME", "Golden Key"), ["flags", "KILLED"]), 0, 1)
    )
}
_truth_achievement()

function _square_achievement() {
    gates_open_ = always_true()
    last_opened_now_ = always_false()
    for gate_ in item_group_vars("STREETS_OF_ROME", "Square Gates") {
        gates_open_ = gates_open_
            && mem_path(gate_, ["current_anim_state"]) == enum_value(DOOR_ANIM_STATE, "OPEN")
        last_opened_now_ = last_opened_now_
            || mem_changed_from_to(mem_path(gate_, ["current_anim_state"]),
                                   enum_value(DOOR_ANIM_STATE, "CLOSED"), enum_value(DOOR_ANIM_STATE, "OPEN"))
    }

    achievement(
        id=147332,
        badge="163917",
        title="Public Square",
        description=format("[{0}] Open every gate leading out of the fountain square", level_name("STREETS_OF_ROME")),
        points=3,
        trigger=level_cheat_protection("STREETS_OF_ROME")
                && playing_level("STREETS_OF_ROME")
                && gates_open_
                && last_opened_now_
    )
}
_square_achievement()

function _padlock_achievement() {
    padlock_ = item_var("STREETS_OF_ROME", "Padlock")
    achievement(
        id=147333,
        badge="163918",
        title="Noscope is the Key",
        description=format("[{0}] Shoot the padlock in the winery without using the laser sight", level_name("STREETS_OF_ROME")),
        points=3,
        trigger=level_cheat_protection("STREETS_OF_ROME")
                && never_not_playing_level("STREETS_OF_ROME")
                && once(mem_path(padlock_, ["flags2", "ACTIVE"]) == 0)
                && never(mem(lasersight_active) == 1)
                && mem_changed_from_to(mem_path(padlock_, ["flags2", "ACTIVE"]), 0, 1)
    )
}
_padlock_achievement()

function _idiot_achievement() {
    ammo_ = item_var("STREETS_OF_ROME", "Tower Revolver Ammo")
    medi_ = item_var("STREETS_OF_ROME", "Tower Large Medipack")
    achievement(
        id=147334,
        badge="163919",
        title="Idiot! Idiot!",
        description=format("[{0}] Collect the items past the roof where you first saw Larson and Pierre", level_name("STREETS_OF_ROME")),
        points=3,
        trigger=level_cheat_protection("STREETS_OF_ROME")
                && playing_level("STREETS_OF_ROME")
                && item_status_is(ammo_, "INVISIBLE")
                && mem_path(medi_, ["flags", "KILLED"]) == 1
                && (item_status_was(ammo_, "INACTIVE")
                    || prev(mem_path(medi_, ["flags", "KILLED"])) == 0)
    )
}
_idiot_achievement()

function _ram_achievement() {
    lara_ = item_var("STREETS_OF_ROME", "Lara")
    achievement(
        id=147335,
        badge="163920",
        title="Take the Ram by the Horns",
        description=format("[{0}] Get past the battering ram without using the side ledge", level_name("STREETS_OF_ROME")),
        points=3,
        trigger=level_cheat_protection("STREETS_OF_ROME")
                && never_not_playing_level("STREETS_OF_ROME")
                && once(mem_path(lara_, ["room_number"]) == 157)
                && never(mem_path(lara_, ["room_number"]) == 165
                         && mem_path(lara_, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, "CLIMB_CORNER_RIGHT_OUTER")
                         && mem_path(lara_, ["pos", "x_pos"]) >= 59400)
                && mem_path(lara_, ["room_number"]) == 186
                && doing_normal_movement(lara_)
    )
}
_ram_achievement()


//
//   T R A J A N ' S   M A R K E T S
//

beat_level_achievement("TRAJAN_MARKETS", 147336, "163921", 5)

secrets_achievement("TRAJAN_MARKETS", 147337, "163922", 3)

function _weird_swan_achievement() {
    lara_ = item_var("TRAJAN_MARKETS", "Lara")
    box_ = static_mesh_var("TRAJAN_MARKETS", "Crowbar Box")

    swan_diving_ = always_false()
    for anim_state_ in ["SWANDIVE_BEGIN", "SWANDIVE_END", "ROLL_FORWARD"]
        swan_diving_ = swan_diving_
            || mem_path(lara_, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, anim_state_)

    achievement(
        id=147338,
        badge="163923",
        title="WeirdSwan",
        description=format("[{0}] Open the box containing the crowbar while swan diving", level_name("TRAJAN_MARKETS")),
        points=3,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && playing_level("TRAJAN_MARKETS")
                && swan_diving_
                && mem_changed_from_to(mem_path(box_, ["flags", "ACTIVE"]), 1, 0)
    )
}
_weird_swan_achievement()

function _ladder_skip_achievement() {
    lara_ = item_var("TRAJAN_MARKETS", "Lara")
    pulley1_ = item_var("TRAJAN_MARKETS", "Pulley 1")

    achievement(
        id=147339,
        badge="163924",
        title="Ladders Are Dangerous",
        description=format("[{0}] Open the circular gate without using the ladder to reach the gear-controlling pulleys", level_name("TRAJAN_MARKETS")),
        points=5,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && never_not_playing_level("TRAJAN_MARKETS")

                // first pulley has not been pulled yet (item_flags[2] set to 1 on the first pull)
                && once(mem_path(lara_, ["room_number"]) == 225
                        && mem_path(pulley1_, ["item_flags", 2]) == 0)
                
                && never(mem_path(lara_, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, "LADDER_UP"))
                && cutscene_ended("TRAJAN_MARKETS", "Open Circular Door")
    )
}
_ladder_skip_achievement()

function _head_achievement() {
    lara_ = item_var("TRAJAN_MARKETS", "Lara")
    head_ = item_var("TRAJAN_MARKETS", "Mechanical Head")
    
    left_eye_ = mem(cast_var(bit1_t, addressof_path(head_, ["mesh_bits"])))
    right_eye_ = mem(cast_var(bit2_t, addressof_path(head_, ["mesh_bits"])))
    eye_destroyed_cond = prev(left_eye_) + prev(right_eye_) - left_eye_ - right_eye_ == 1

    charge_timer_ = mem_path(head_, ["item_flags", 3])
    charging_cond_ = charge_timer_ - prev(charge_timer_) >= 1
                    && charge_timer_ - prev(charge_timer_) <= 2
    beam_shot_cond_ = prev(charge_timer_) == 0x5b
                     && charge_timer_ == 0x5b

    achievement(
        id=147340,
        badge="163925",
        title="Fastest Gun in Rome",
        description=format("[{0}] Standing on rails, and without zooming in, shoot both eyes of the Mechanical Head whilst it charges a single attack", level_name("TRAJAN_MARKETS")),
        points=5,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && never_not_playing_level("TRAJAN_MARKETS")
        
                // must always be on the rails. room 245 is the tunnel leading to the head's room,
                // but it's possible to go into it while in the rail, so it must be account for in
                // a special way
                && never(mem_path(lara_, ["room_number"]) != 66
                         && mem_path(lara_, ["room_number"]) != 68
                         && mem_path(lara_, ["room_number"]) != 251
                         && mem_path(lara_, ["room_number"]) != 245)
                && never(mem_path(lara_, ["room_number"]) == 245
                         && mem_path(lara_, ["pos", "x_pos"]) > 50250)

                // must never zoom in
                && never(mem(look_zoom) > 0x80)

                // store a hit when the first eye is destroyed iif the head is charging its beam
                && once(charging_cond_
                        && prev(left_eye_) + prev(right_eye_) == 2
                        && left_eye_ + right_eye_ == 1)

                // reset if the head shoots its beam before the second eye is destroyed
                && never(beam_shot_cond_)

                // trigger when the second eye is destroyed
                && prev(left_eye_) + prev(right_eye_) == 1
                && left_eye_ + right_eye_ == 0
    )
}
_head_achievement()

function _green_centurion_achievement() {
    lara_ = item_var("TRAJAN_MARKETS", "Lara")
    centurion_ = item_var("TRAJAN_MARKETS", "Centurion")
    achievement(
        id=147341,
        badge="163926",
        title="When in Rome",
        description=format("[{0}] Defeat the Centurion using only your pistols and without taking damage", level_name("TRAJAN_MARKETS")),
        points=5,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && never_not_playing_level("TRAJAN_MARKETS")

                // max hp as the starting point in case players save after the cutscene plays
                && once(mem_path(centurion_, ["hit_points"]) == 0x12c)

                // reset if lara fires something other than the pistols or loses health
                && never(mem_path(lara, ["gun_type"]) != enum_value(WEAPON_TYPE, "PISTOLS")
                         && mem_path(lara, ["flags", "HAS_FIRED"]) == 1)
                && never(took_damage(lara_))

                // trigger upon death of the centurion
                && mem_path(centurion_, ["hit_points"]) == 0xc000
    )
}
_green_centurion_achievement()

function _larson_skip_achievement() {
    larson_ = item_var("TRAJAN_MARKETS", "Larson")
    achievement(
        id=147342,
        badge="163927",
        title="Damn Mosquitoes",
        description=format("[{0}] Complete the level without defeating Larson or the Gargoyle Guardians", level_name("TRAJAN_MARKETS")),
        points=5,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && completed_level("TRAJAN_MARKETS")
                && is_positive(typeof_path(larson_, ["hit_points"]), mem_path(larson_, ["hit_points"]))
    )
}
_larson_skip_achievement()

function _gargoyles_achievement() {
    gargoyles_ = item_group_vars("TRAJAN_MARKETS", "Gargoyles")

    gargoyles_killed_ = always_true()
    for gargoyle_ in gargoyles_
        gargoyles_killed_ = gargoyles_killed_
            && mem_path(gargoyle_, ["hit_points"]) == 0xc000

    achievement(
        id=147343,
        badge="163928",
        title="Up Close and Personal",
        description=format("[{0}] Defeat the Gargoyle Guardians in 1 minute or less", level_name("TRAJAN_MARKETS")),
        points=5,
        trigger=level_cheat_protection("TRAJAN_MARKETS")
                && never_not_playing_level("TRAJAN_MARKETS")

                // store a hit when the gargoyles activate
                && once(item_status_was(gargoyles_[0], "INVISIBLE")
                        && item_status_is(gargoyles_[0], "ACTIVE"))

                // reset if 1 minute elapses, but...
                // only start counting frames when the screen fades from black after the cutscene, because that's when
                // the player regains control (the cutscene ends slightly earlier)
                && never(repeated(time_to_frames(1, 0),
                                  once(item_status_is(gargoyles_[0], "ACTIVE")
                                       && mem_changed_from_to(mem(screen_fading), 1, 0))
                                  && always_true()))

                // trigger when all gargoyles are dead
                && gargoyles_killed_
    )
}
_gargoyles_achievement()


//
//   C O L O S S E U M
//

beat_level_achievement("COLOSSEUM", 147344, "163929", 5)

secrets_achievement("COLOSSEUM", 147345, "163930", 3)

act_nlnmas_achievement("ROME", 147346, "163931", 25)

function _three_jump_achievement() {
    lara_ = item_var("COLOSSEUM", "Lara")
    pedestal_ = item_var("COLOSSEUM", "Pedestal")
    piece_ = item_var("COLOSSEUM", "Gemstone Piece 2")

    jump_alts_ = []
    for jump_alt_ in started_jump_alts(lara_)
        array_push(jump_alts_, mem_path(pedestal_, ["item_flags", 0]) == 4 && jump_alt_)

    achievement(
        id=147347,
        badge="163932",
        title="Laziness is a Virtue",
        description=format("[{0}] Complete the timed run for the Gemstone Piece using no more than 3 jumps", level_name("COLOSSEUM")),
        points=3,
        trigger=level_cheat_protection("COLOSSEUM")
                && never_not_playing_level("COLOSSEUM")
        
                // store a hit when the pedestal is raised all the way
                && once(mem_changed_to(mem_path(pedestal_, ["item_flags", 0]), 4))

                // reset if the player jumps 4 times while the pedestal is raised
                && never(tally(4, jump_alts_))

                // reset if time runs out and the pedestal lowers (to get rid of leftover jump hits)
                && never(mem_path(pedestal_, ["item_flags", 0]) == 0)

                // trigger when the gemstone piece is collected
                && mem_changed_from_to(mem_path(piece_, ["flags", "KILLED"]), 0, 1)
    )
}
_three_jump_achievement()


function _blue_centurion_achievement() {
    lara_ = item_var("COLOSSEUM", "Lara")
    centurion_ = item_var("COLOSSEUM", "Centurion")

    achievement(
        id=147348,
        badge="163933",
        title="Are You Not Entertained?!",
        description=format("[{0}] Defeat the Centurion using only your pistols, without jumping, taking damage, or leaving its room", level_name("COLOSSEUM")),
        points=5,
        trigger=level_cheat_protection("COLOSSEUM")
                && never_not_playing_level("COLOSSEUM")

                // max hp as the starting point in case players save after the cutscene plays
                && once(mem_path(centurion_, ["hit_points"]) == 0x12c)

                // reset if lara fires something other than the pistols or loses health
                && never(mem_path(lara, ["gun_type"]) != enum_value(WEAPON_TYPE, "PISTOLS")
                         && mem_path(lara, ["flags", "HAS_FIRED"]) == 1)
                && never(took_damage(lara_))
                && never(or_alts(started_jump_alts(lara_)))
                && never(mem_path(lara_, ["pos", "z_pos"]) <= 58385)

                // trigger upon death of the centurion
                && mem_path(centurion_, ["hit_points"]) == 0xc000
    )
}
_blue_centurion_achievement()


//
//   T H E   B A S E
//

beat_level_achievement("BASE", 147349, "163934", 5)

secrets_achievement("BASE", 147350, "163935", 3)

function _claw_pickups_achievement() {
    medi_ = item_var("BASE", "Crate Small Medipack")
    ammo_ = item_var("BASE", "Crate Uzi Ammo")

    achievement(
        id=147351,
        badge="163936",
        title="Claw Machine Hacking",
        description=format("[{0}] Collect the pickups on top of the storage crates before disabling the mechanical claw", level_name("BASE")),
        points=5,
        trigger=level_cheat_protection("BASE")
                && playing_level("BASE")
        
                // the cutscene in which the mechanical claw is disabled hasn't played yet
                && cutscene_played_mem("BASE", "Disable Mechanical Claw") == 0

                // both items on top of the crates have been collected
                && mem_path(ammo_, ["flags", "KILLED"]) == 1
                && mem_path(medi_, ["flags", "KILLED"]) == 1
                && (prev(mem_path(ammo_, ["flags", "KILLED"]))
                    + prev(mem_path(medi_, ["flags", "KILLED"]))) == 1
    )
}
_claw_pickups_achievement()

function _shower_achievement() {
    lara_ = item_var("BASE", "Lara")

    showers_cond_ = always_false()
    shower_positions_ = [[0x8600, 0xb600], [0x8e00, 0xb600], [0x9200, 0xaa00]]
    shower_positions_ = [[34295, 46650], [36350, 46650], [37375, 43435]]
    for shower_pos_ in shower_positions_ {
        x_ = shower_pos_[0]
        z_ = shower_pos_[1]
        showers_cond_ = showers_cond_
            || repeated(time_to_frames(0, 5),
                        is_negative(typeof_path(lara_, ["pos", "y_pos"]), mem_path(lara_, ["pos", "y_pos"]))
                        && item_in_positive_2d_box(lara_, x_ - 125, x_ + 125, z_ - 125, z_ + 125))
    }

    achievement(
        id=147352,
        badge="163937",
        title="Don't You Think You've Seen Enough?",
        description=format("[{0}] Take a shower", level_name("BASE")),
        points=2,
        trigger=level_cheat_protection("BASE")
                && never_not_playing_level("BASE")
                && showers_cond_
    )
}
_shower_achievement()

function _sniper_swan_achievement() {
    lara_ = item_var("BASE", "Lara")
    snipers_ = item_group_vars("BASE", "Snipers")

    swan_dive_under_fire_ = []
    for sniper_ in snipers_
        array_push(swan_dive_under_fire_, (
            // sniper is either ready to shoot or shooting
            mem_path(sniper_, ["flags2", "ACTIVE"]) == 1
            && mem_path(sniper_, ["current_anim_state"]) >= enum_value(SNIPER_ANIM_STATE, "READY")
            && mem_path(sniper_, ["current_anim_state"]) <= enum_value(SNIPER_ANIM_STATE, "SHOOTING")

            // lara started a swan dive from the hanging crate
            && mem_path(lara_, ["pos", "y_pos"]) <= 0xfffff100
            && mem_path(lara_, ["pos", "y_pos"]) >= 0xfffff000
            && mem_changed_to(mem_path(lara_, ["current_anim_state"]), enum_value(LARA_ANIM_STATE, "SWANDIVE_BEGIN"))
        ))

    achievement(
        id=147353,
        badge="163938",
        title="Evasive Swan Maneuvers",
        description=format("[{0}] Swan dive into the water from the hanging crate while the snipers are shooting at you", level_name("BASE")),
        points=3,
        trigger=level_cheat_protection("BASE")
                && never_not_playing_level("BASE")
                && tally(1, swan_dive_under_fire_)
                && mem_changed_from_to(mem_path(lara_, ["current_anim_state"]),
                                       enum_value(LARA_ANIM_STATE, "SWANDIVE_END"),
                                       enum_value(LARA_ANIM_STATE, "UNDERWATER_DIVING"))
    )
}
_sniper_swan_achievement()

function _sniper_achievement() {
    lara_ = item_var("BASE", "Lara")
    snipers_ = item_group_vars("BASE", "Snipers")

    full_hp_snipers_ = always_true()
    dead_snipers_ = always_true()
    for sniper_ in snipers_ {
        full_hp_snipers_ = full_hp_snipers_
            && mem_path(sniper_, ["flags2", "ACTIVE"]) == 1
            && mem_path(sniper_, ["hit_points"]) == 0x23
        dead_snipers_ = dead_snipers_
            && mem_path(sniper_, ["hit_points"]) == 0xc000
    }

    achievement(
        id=147354,
        badge="163939",
        title="Real Snipers Use a Desert Eagle",
        description=format("[{0}] Kill both full-hp snipers using only 2 bullets and without taking damage", level_name("BASE")),
        points=5,
        trigger=level_cheat_protection("BASE")
                && never_not_playing_level("BASE")

                // store a hit when entering the sniper area whilst they're active and at full hp
                && once(full_hp_snipers_
                        && mem_changed_to(mem_path(lara_, ["room_number"]), 141))

                // reset if lara takes damage or shoots more than twice
                && never(took_damage(lara_))
                && never(repeated(3, mem_changed_from_to(mem_path(lara, ["flags", "HAS_FIRED"]), 0, 1)))

                // trigger when both snipers are dead
                && dead_snipers_
    )
}
_sniper_achievement()

function _continuity_error_achievement() {
    lara_ = item_var("BASE", "Lara")
    achievement(
        id=147355,
        badge="163940",
        title="Continuity Error",
        description=format("[{0}] Board the submarine even though you're pretty sure you heard Lara dying just now", level_name("BASE")),
        points=5,
        trigger=level_cheat_protection("BASE")
                && never_not_in_level("BASE")

                // store a hit if lara dies during the fadeout. must use the sound effect instead of lara's
                // anim state because the latter can change to DEATH without the sound having time to play
                // before the cutscene starts, in which case the player doesn't know about the death and the
                // achievement shouldn't trigger
                && once(mem(screen_fading) == 1
                        && sound_playing("LARA_KNEES_DEATH"))

                // trigger when the cutscene starts (after the screen fades back in)
                && cutscene_started("BASE", "Board Submarine")

                // just to be safe, reset the hit if lara does normal movement outside of a cutscene
                && never(!in_a_cutscene()
                         && doing_normal_movement(lara_))
    )
}
_continuity_error_achievement()


//
//   T H E   S U B M A R I N E
//

beat_level_achievement("SUBMARINE", 147356, "163994", 5)

secrets_achievement("SUBMARINE", 147357, "163995", 3)

function _chef_achievement() {
    chef_ = item_var("SUBMARINE", "Chef")
    achievement(
        id=147358,
        badge="163996",
        title="You Saw Nothing",
        description=format("[{0}] Incapacitate the chef after having been spotted by him at least once", level_name("SUBMARINE")),
        points=3,
        trigger=level_cheat_protection("SUBMARINE")
                && never_not_playing_level("SUBMARINE")
                && once(mem_path(chef_, ["current_anim_state"]) == enum_value(CHEF_ANIM_STATE, "STALKING"))
                && mem_path(chef_, ["current_anim_state"]) == enum_value(CHEF_ANIM_STATE, "INCAPACITATED")
    )
}
_chef_achievement()

function _rations_achievement() {
    medis_ = item_group_vars("SUBMARINE", "Medipacks")

    prev_medis_collected_ = 0
    medis_collected_ = 0
    for medi_ in medis_ {
        prev_medis_collected_ = prev_medis_collected_ + prev(mem_path(medi_, ["flags", "KILLED"]))
        medis_collected_ = medis_collected_ + mem_path(medi_, ["flags", "KILLED"])
    }

    total_medis_ = length(medis_)

    achievement(
        id=147359,
        badge="163997",
        title="No Chef and Out of Rations",
        description=format("[{0}] Collect every medipack in the level", level_name("SUBMARINE")),
        points=5,
        trigger=level_cheat_protection("SUBMARINE")
                && playing_level("SUBMARINE")
                && prev_medis_collected_ == total_medis_ - 1
                && medis_collected_ == total_medis_
                && measured(medis_collected_ == 3)
    )
}
_rations_achievement()


//
//   D E E P S E A   D I V E
//

beat_level_achievement("DEEPSEA_DIVE", 147360, "163998", 5)

secrets_achievement("DEEPSEA_DIVE", 147361, "163999", 1)

function _chaff_achievement() {
    sub_nums_ = item_group_nums("DEEPSEA_DIVE", "Attack Submarines")
    subs_ = item_group_vars("DEEPSEA_DIVE", "Attack Submarines")
    
    start_sub_positions_ = {
        0:  [0x7a00, 0x3900, 0x12a00],
        13: [0x7a00, 0x3b00, 0x10e00],
        15: [0x4a00, 0x3880, 0x12200]
    }

    subs_at_starting_positions_ = always_true()
    for it_ in array_zip(sub_nums_, subs_) {
        num_ = it_[0]
        sub_ = it_[1]
        subs_at_starting_positions_ = subs_at_starting_positions_
            && mem_path(sub_, ["pos", "x_pos"]) == start_sub_positions_[num_][0]
            && mem_path(sub_, ["pos", "y_pos"]) == start_sub_positions_[num_][1]
            && mem_path(sub_, ["pos", "z_pos"]) == start_sub_positions_[num_][2]
    }

    dyn_items_ = level_dyn_items("DEEPSEA_DIVE")
    never_torpedo_targetting_lara_ = always_true()
    for i_ in range(0, array_var_size(dyn_items_))
        never_torpedo_targetting_lara_ = never_torpedo_targetting_lara_
            && never(mem_path(dyn_items_, [i_, "object_number"]) == enum_value(OBJECT_TYPE, "TORPEDO")
                     // -1 targets lara. if a chaff is targetted, contains the slot index of the chaff
                     && mem_path(dyn_items_, [i_, "item_flags", 0]) == 0xffff
                     && mem_path(dyn_items_, [i_, "item_flags", 1]) > 0)

    achievement(
        id=147362,
        badge="164000",
        title="Better Safe Than Sorry",
        description=format("[{0}] Complete the level without being targeted by a torpedo", level_name("DEEPSEA_DIVE")),
        points=5,
        trigger=level_cheat_protection("DEEPSEA_DIVE")
                && never_not_playing_level("DEEPSEA_DIVE")

                // the enemy subs don't move until lara moves close to them, so we use their
                // original positions as the starting point of the challenge
                && once(subs_at_starting_positions_)

                // reset if a torpedo is fired towards lara
                && never_torpedo_targetting_lara_

                && completed_level("DEEPSEA_DIVE")
    )
}
_chaff_achievement()

function _air_achievement() {
    achievement(
        id=147363,
        badge="164001",
        title="Free Diving Prodigy",
        description=format("[{0}] Escape with at least 25% oxygen remaining", level_name("DEEPSEA_DIVE")),
        points=5,
        trigger=level_cheat_protection("DEEPSEA_DIVE")
                && completed_level("DEEPSEA_DIVE")
                && is_positive(typeof_path(lara, ["air"]), mem_path(lara, ["air"]))
                && mem_path(lara, ["air"]) >= 450
    )
}
_air_achievement()


//
//   S I N K I N G   S U B M A R I N E
//

beat_level_achievement("SINKING_SUBMARINE", 147364, "164002", 5)

secrets_achievement("SINKING_SUBMARINE", 147365, "164003", 2)

act_nlnmas_achievement("RUSSIA", 147366, "164004", 25)

function _canister_achievement() {
    canister_ = item_var("SINKING_SUBMARINE", "Nitrogen Canister")
    switch_ = item_var("SINKING_SUBMARINE", "Electricity Switch")
    achievement(
        id=147367,
        badge="164005",
        title="Shocking Platforming",
        description=format("[{0}] Collect the Nitrogen Canister before shutting down the electricity", level_name("SINKING_SUBMARINE")),
        points=5,
        trigger=level_cheat_protection("SINKING_SUBMARINE")
                && playing_level("SINKING_SUBMARINE")
                && mem_changed_from_to(mem_path(canister_, ["flags", "KILLED"]), 0, 1)
                && item_activation_mask_bitcount(switch_) < 5
    )
}
_canister_achievement()

function _desert_eagle_achievement() {
    gun_ = item_var("SINKING_SUBMARINE", "Desert Eagle")
    enemies_ = item_group_vars("SINKING_SUBMARINE", "Enemies")
    
    all_enemies_dead_ = always_true()
    for enemy_ in enemies_
        all_enemies_dead_ = all_enemies_dead_
            && mem_path(enemy_, ["flags", "KILLED"]) == 1

    achievement(
        id=147368,
        badge="164006",
        title="Preparing for Next Level",
        description=format("[{0}] Collect the Desert Eagle after killing every enemy in the level", level_name("SINKING_SUBMARINE")),
        points=2,
        trigger=level_cheat_protection("SINKING_SUBMARINE")
                && playing_level("SINKING_SUBMARINE")
                && all_enemies_dead_
                && mem_changed_from_to(mem_path(gun_, ["flags", "KILLED"]), 0, 1)
    )
}
_desert_eagle_achievement()


//
//   G A L L O W S   T R E E
//

beat_level_achievement("GALLOWS_TREE", 147369, "164007", 5)

secrets_achievement("GALLOWS_TREE", 147370, "164008", 3)

function _changeling_achievement() {
    _changeling = item_var("GALLOWS_TREE", "Changeling 1")
    achievement(
        id=147371,
        badge="164013",
        title="Suspicious Barrel",
        description=format("[{0}] Complete the level without alerting the Changeling near the well", level_name("GALLOWS_TREE")),
        points=3,
        trigger=level_cheat_protection("GALLOWS_TREE")
                && mem_path(_changeling, ["flags2", "ACTIVE"]) == 0
                && completed_level("GALLOWS_TREE")
    )
}
_changeling_achievement()

function _well_achievement() {
    lara_ = item_var("GALLOWS_TREE", "Lara")

    achievement(
        id=147372,
        badge="164009",
        title="Swan Down the Well",
        description=format("[{0}] Swan dive into the well", level_name("GALLOWS_TREE")),
        points=3,
        trigger=level_cheat_protection("GALLOWS_TREE")
                && never_not_playing_level("GALLOWS_TREE")
                && item_in_positive_2d_box(lara_, 65250, 66800, 67450, 68900)
                && mem_changed_from_to(mem_path(lara_, ["current_anim_state"]),
                                       enum_value(LARA_ANIM_STATE, "SWANDIVE_END"),
                                       enum_value(LARA_ANIM_STATE, "UNDERWATER_DIVING"))
    )
}
_well_achievement()

function _gallows_skip_achievement() {
    lara_ = item_var("GALLOWS_TREE", "Lara")
    tube_ = item_var("GALLOWS_TREE", "Rubber Tube")

    achievement(
        id=147373,
        badge="164010",
        title="I'm Not Jumping Down a Well",
        description=format("[{0}] Collect the rubber tube without going through the well or otherwise entering water", level_name("GALLOWS_TREE")),
        points=5,
        trigger=level_cheat_protection("GALLOWS_TREE")
                && never_not_playing_level("GALLOWS_TREE")
                && once(mem_path(lara_, ["room_number"]) == 132)
                && never(mem_path(lara, ["water_status"]) != enum_value(LARA_WATER_STATUS, "ABOVE_WATER"))
                && mem_changed_from_to(mem_path(tube_, ["flags", "KILLED"]), 0, 1)
    )
}
_gallows_skip_achievement()

function _torch_achievement() {
    dyn_items_ = level_dyn_items("GALLOWS_TREE")
    torch_in_hole_ = always_false()
    for i_ in range(0, array_var_size(dyn_items_) - 1) {
        item_ = addressof_path(dyn_items_, [i_])
        torch_in_hole_ = torch_in_hole_
            || (mem_path(item_, ["object_number"]) == enum_value(OBJECT_TYPE, "BURNING_TORCH_ITEM")
                && item_in_positive_2d_box(item_, 31250, 33275, 48650, 50800)
                && is_positive(typeof_path(item_, ["pos", "y_pos"]), mem_path(item_, ["pos", "y_pos"]))
                && mem_path(item_, ["pos", "y_pos"]) >= 11225)
    }

    achievement(
        id=147374,
        badge="164011",
        title="Feed the Demon",
        description=format("[{0}] Throw a lit torch down the demon's pit", level_name("GALLOWS_TREE")),
        points=2,
        trigger=level_cheat_protection("GALLOWS_TREE")
                && playing_level("GALLOWS_TREE")
                && torch_in_hole_
    )
}
_torch_achievement()

function _bad_end_achievement() {
    achievement(
        id=147375,
        badge="164012",
        title="Bad End",
        description=format("[{0}] Try to complete the level only to have the Changelings stop you", level_name("GALLOWS_TREE")),
        points=2,
        trigger=level_cheat_protection("GALLOWS_TREE")
                && playing_level("GALLOWS_TREE")
                && cutscene_ended("GALLOWS_TREE", "Bad Ending")
    )
}
_bad_end_achievement()


//
//   L A B Y R I N T H
//

beat_level_achievement("LABYRINTH", 147376, "164014", 5)

secrets_achievement("LABYRINTH", 147377, "164015", 3)

function _phantom_skeletons_achievement() {
    lara_ = item_var("LABYRINTH", "Lara")
    achievement(
        id=147378,
        badge="164016",
        title="I See Dead People",
        description=format("[{0}] Take no damage between revealing the Phantom Skeletons in the chapel and banishing them", level_name("LABYRINTH")),
        points=5,
        trigger=level_cheat_protection("LABYRINTH")
                && never_not_playing_level("LABYRINTH")
                && once(cutscene_started("LABYRINTH", "Reveal Skeletons"))
                && never(took_damage(lara_))
                && cutscene_ended("LABYRINTH", "Kill Skeletons")
    )
}
_phantom_skeletons_achievement()

function _labyrinth_achievement() {
    lara_ = item_var("LABYRINTH", "Lara")
    wisp_ = item_var("LABYRINTH", "Will-O'-Wisp")

    wisp_cur_waypoint_ = addressof_path(wisp_, ["item_flags", 3])

    achievement(
        id=147379,
        badge="164017",
        title="The Darkest Path",
        description=format("[{0}] Get through the maze without jumping, and fast enough to leave the Will-O'-Wisp behind", level_name("LABYRINTH")),
        points=5,
        trigger=level_cheat_protection("LABYRINTH")
                && never_not_playing_level("LABYRINTH")

                // store a hit when lara is at the start of the labyrinth
                // the normal movement requirement is there because during jumps above the pit sometimes lara's x positions
                // snaps way back for one frame (probably related to collision with the will-o'-wisp?)
                && once(mem_path(lara_, ["pos", "x_pos"]) >= 28700
                        && mem_path(lara_, ["pos", "x_pos"]) <= 30200
                        && doing_normal_movement(lara_))

                // no jumping and the will-o'-wisp must be, at most, hovering above the last pit
                && never(or_alts(started_jump_alts(lara_)))
                && mem(wisp_cur_waypoint_) <= 0xd

                // trigger when lara slides out of the labyrinth
                && mem_path(lara_, ["pos", "z_pos"]) <= 38400
                && is_positive(typeof_path(lara_, ["pos", "x_pos"]), mem_path(lara_, ["pos", "x_pos"]))
                && mem_path(lara_, ["pos", "x_pos"]) >= 24165
    )
}
_labyrinth_achievement()


//
//   O L D   M I L L
//

beat_level_achievement("OLD_MILL", 147380, "164018", 5)

secrets_achievement("OLD_MILL", 147381, "164019", 3)

act_nlnmas_achievement("IRELAND", 147382, "164020", 25)

function _chalk_achievement() {
    chalk_ = item_var("OLD_MILL", "Chalk")
    
    changelings_not_distracted_ = always_true()
    for changeling_ in item_group_vars("OLD_MILL", "Changelings")
        changelings_not_distracted_ = changelings_not_distracted_
            && mem_path(changeling_, ["current_anim_state"]) != enum_value(CHANGELING_ANIM_STATE, "DISTRACTED")

    achievement(
        id=147383,
        badge="164021",
        title="To the Chalkboard, You Two!",
        description=format("[{0}] Collect the Chalk without distracting the Changelings", level_name("OLD_MILL")),
        points=5,
        trigger=level_cheat_protection("OLD_MILL")
                && playing_level("OLD_MILL")
                && changelings_not_distracted_
                && mem_changed_from_to(mem_path(chalk_, ["flags", "KILLED"]), 0, 1)
    )
}
_chalk_achievement()

function _optional_chasm_achievement() {
    lara_ = item_var("OLD_MILL", "Lara")
    medi_ = item_var("OLD_MILL", "Chasm Medipack")

    achievement(
        id=147384,
        badge="164022",
        title="Disappointment in Item Form",
        description=format("[{0}] Collect the medipack at the back end of the chasm with the swinging rope and leave", level_name("OLD_MILL")),
        points=3,
        trigger=level_cheat_protection("OLD_MILL")
                && never_not_playing_level("OLD_MILL")

                // medipak collected in the current session
                && once(mem_changed_from_to(mem_path(medi_, ["flags", "KILLED"]), 0, 1))

                // trigger when lara climbs back to the crawl space that leaves the area
                && mem_path(lara_, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, "CLIMB_TO_CRAWL")
                && item_in_positive_2d_box(lara_, 61225, 62595, 34090, 34990)
    )
}
_optional_chasm_achievement()

function _fire_secret_achievement() {
    secret_ = item_var("OLD_MILL", "Secret 2")

    flames_active_ = always_true()
    for flame_ in item_group_vars("OLD_MILL", "Secret 2 Flames")
        flames_active_ = flames_active_
            && mem_path(flame_, ["flags2", "ACTIVE"]) == 1

    achievement(
        id=147385,
        badge="164023",
        title="Firewalking",
        description=format("[{0}] Collect the second secret with the flame traps still active and without being on fire", level_name("OLD_MILL")),
        points=5,
        trigger=level_cheat_protection("OLD_MILL")
                && playing_level("OLD_MILL")
                && flames_active_
                && mem_path(lara, ["flags", "BURN"]) == 0
                && mem_changed_from_to(mem_path(secret_, ["flags", "KILLED"]), 0, 1)
    )
}
_fire_secret_achievement()

function _hag_achievement() {
    lara_ = item_var("OLD_MILL", "Lara")
    achievement(
        id=147386,
        badge="164024",
        title="I'm Keeping It!",
        description=format("[{0}] Leave the water while in possession of the Hag's Silver Coin", level_name("OLD_MILL")),
        points=3,
        trigger=level_cheat_protection("OLD_MILL")
                && playing_level("OLD_MILL")
                && mem_path(lara, ["puzzle_items", 1]) == 1
                && !in_a_cutscene()
                && doing_normal_movement(lara_)
    )
}
_hag_achievement()


//
//   T H E   1 3 T H   F L O O R
//

beat_level_achievement("THIRTEENTH_FLOOR", 147387, "164025", 10)

secrets_achievement("THIRTEENTH_FLOOR", 147388, "164026", 3)

level_nlnmas_achievement("THIRTEENTH_FLOOR", 147389, "164027", 10)

function _headshot_achievement() {
    guards_ = item_group_vars("THIRTEENTH_FLOOR", "Killable Guards")

    headshot_kill_ = []
    for guard_ in guards_ {
        creature_ = cast_var(pointer_t(CREATURE_INFO), addressof_path(guard_, ["data"]))
        array_push(headshot_kill_,
            // was just hit by lara for the first time
            mem_changed_from_to(mem_path(creature_, ["flags2", "HURT_BY_LARA"]), 0, 1)

            // ...and died straight away (one possible with an head shot)
            && is_positive(word_t, prev(mem_path(guard_, ["hit_points"])))
            && !is_positive(word_t, mem_path(guard_, ["hit_points"]))

            // ...and lara's HK was in sniper mode
            && mem_path(lara, ["hk_type_carried", "AMMO_1"]) == 1
        )
    }

    achievement(
        id=147390,
        badge="164028",
        title="Sniper Main",
        description=format("[{0}] Kill 10 guards with a single headshot in sniper mode [no loading]", level_name("THIRTEENTH_FLOOR")),
        points=10,
        trigger=level_cheat_protection("THIRTEENTH_FLOOR")
                && never_not_playing_level("THIRTEENTH_FLOOR")
                && tally(10, headshot_kill_)
                && measured(tally(10, headshot_kill_))
    )
}
_headshot_achievement()

function _covert_achievement() {
    lara_ = item_var("THIRTEENTH_FLOOR", "Lara")
    duct_explosion_ = item_var("THIRTEENTH_FLOOR", "Duct Explosion 1")
    sleeping_guard_ = item_var("THIRTEENTH_FLOOR", "Sleeping Guard")
    hidden_guard_ = item_var("THIRTEENTH_FLOOR", "Hidden Armored Guard")

    turrets_inactive_ = always_true()
    for turret_ in item_group_vars("THIRTEENTH_FLOOR", "Turrets")
        turrets_inactive_ = turrets_inactive_
            && mem_path(turret_, ["flags2", "ACTIVE"]) == 0

    achievement(
        id=147391,
        badge="164029",
        title="Covert Operations",
        description=format("[{0}] Reach the Iris Lab Access corridor without alerting any guards or turrets to your presence", level_name("THIRTEENTH_FLOOR")),
        points=5,
        trigger=level_cheat_protection("THIRTEENTH_FLOOR")
                && playing_level("THIRTEENTH_FLOOR")

                // duct didn't blow up => enemy not alerted
                && item_status_is(duct_explosion_, "INACTIVE")

                // none of the optional turrets were activated
                // also ensures the sleeing guard was not awakened
                // also ensures that no blue guards were alerted
                && turrets_inactive_

                // didn't alert the hidden guard in the bug room => used chloroform on the armored guard
                && mem_path(hidden_guard_, ["flags2", "ACTIVE"]) == 0
                && mem_path(hidden_guard_, ["flags", "KILLED"]) == 0

                // trigger when lara is in the corridor
                && mem_path(lara_, ["room_number"]) == 71
    )
}
_covert_achievement()

function _scientist_early_kill_achievement() {
    scientist_ = item_var("THIRTEENTH_FLOOR", "Iris Lab Scientist")

    achievement(
        id=147845,
        badge="165232",
        title="A Little Too Late for That",
        description=format("[{0}] Hear the plan to enter the Iris Lab after having already killed the scientist", level_name("THIRTEENTH_FLOOR")),
        points=2,
        trigger=level_cheat_protection("THIRTEENTH_FLOOR")
                && never_not_playing_level("THIRTEENTH_FLOOR")
                
                // scientist is dead
                && mem_path(scientist_, ["flags", "KILLED"]) == 1

                // trigger when the cutscene ends...
                && cutscene_ended("ESCAPE_WITH_THE_IRIS", "Iris Lab Plan")

                // ...and the track explaining the plan is playing.
                // why? the cutscene can go one of two ways. if the players goes into it right after killing the scientist, before the
                // extra guards are unleashed, the sound track of the cutscene will get replaced midway with the track for the cutscene
                // in which lara's berated for killing the scientist. in that scenario, the player won't hear the now impossible plan,
                // which is the whole point of this
                && mem(cd_track_id) == 0x36
    )
}
_scientist_early_kill_achievement()

function _scientist_achievement() {
    achievement(
        id=147444,
        badge="164691",
        title="Cuz We Need Him, Yea?",
        description=format("[{0}] Have the scientist help you gain access to the Iris Lab", level_name("THIRTEENTH_FLOOR")),
        points=2,
        trigger=level_cheat_protection("THIRTEENTH_FLOOR")
                && playing_level("THIRTEENTH_FLOOR")
                && cutscene_ended("THIRTEENTH_FLOOR", "Scientist Tag Team")
    )
}
_scientist_achievement()

function _overt_achievement() {
    everyone_is_dead_ = always_true()
    for person_ in item_group_vars("THIRTEENTH_FLOOR", "Killable People")
        everyone_is_dead_ = everyone_is_dead_
            && mem_path(person_, ["flags", "KILLED"]) == 1

    achievement(
        id=147392,
        badge="164030",
        title="Yes, Lara, I'm on a Rampage",
        description=format("[{0}] Complete the level having taken out every possible guard and scientist", level_name("THIRTEENTH_FLOOR")),
        points=10,
        trigger=level_cheat_protection("THIRTEENTH_FLOOR")
                && completed_level("THIRTEENTH_FLOOR")
                && everyone_is_dead_
    )
}
_overt_achievement()


//
//   E S C A P E   W I T H   T H E   I R I S
//

beat_level_achievement("ESCAPE_WITH_THE_IRIS", 147393, "164031", 10)

secrets_achievement("ESCAPE_WITH_THE_IRIS", 147394, "164032", 3)

level_nlnmas_achievement("ESCAPE_WITH_THE_IRIS", 147395, "164033", 25)

function _see_lasers_achievement() {
    lara_ = item_var("ESCAPE_WITH_THE_IRIS", "Lara")

    achievement(
        id=147396,
        badge="164034",
        title="Infrared Vision",
        description=format("[{0}] After the x-ray machine, find a way to see the invisible lasers blocking the path to the elevators",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=2,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")
                && mem_path(camera, ["type"]) == enum_value(CAMERA_TYPE, "LOOK")
                && mem(infrared_active) == 1
                && item_in_positive_2d_box(lara_, 29700, 37200, 67600, 69600)
                && mem_path(camera, ["target", "z"]) >= 58850
                && mem_path(camera, ["target", "z"]) <= 77725
                && mem_path(camera, ["target", "y"]) >= -27155
                && mem_path(camera, ["target", "y"]) <= -23185
    )
}
_see_lasers_achievement()

function _sprint_achievement() {
    lara_ = item_var("ESCAPE_WITH_THE_IRIS", "Lara")

    sprinting_ = always_false()
    for anim_ in ["RUN_TO_SPRINT_LEFT", "RUN_TO_SPRINT_RIGHT", "SPRINT"]
        sprinting_ = sprinting_
            || mem_path(lara_, ["anim_number"]) == enum_value(LARA_ANIM, anim_)

    hard_stop_ = always_false()
    for anim_ in ["SPRINT_SLIDE_STAND_LEFT", "SPRINT_SLIDE_STAND_RIGHT"]
        hard_stop_ = hard_stop_
            || mem_changed_from_to(mem_path(lara_, ["anim_number"]), enum_value(LARA_ANIM, anim_), enum_value(LARA_ANIM, "STAY_SOLID"))

    was_not_sprinting_or_stopping_ = always_true()
    for anim_ in ["RUN_TO_SPRINT_LEFT", "RUN_TO_SPRINT_RIGHT", "SPRINT",
                  "SPRINT_SLIDE_STAND_LEFT", "SPRINT_SLIDE_STAND_RIGHT"] {
        was_not_sprinting_or_stopping_ = was_not_sprinting_or_stopping_
            && prev(mem_path(lara_, ["anim_number"])) != enum_value(LARA_ANIM, anim_)
    }

    achievement(
        id=147397,
        badge="164035",
        title="Slam on the Breaks",
        description=format("[{0}] From the end of the hallway, sprint straight towards the invisible lasers and slide to a sudden stop just short of them",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=5,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && never_not_playing_level("ESCAPE_WITH_THE_IRIS")

                // must start sprinting at the back end of the hallway
                && once(item_in_positive_2d_box(lara_, 26100, 29700, 67250, 70050)
                        && sprinting_)

                // never stop sprinting (or coming to a stop)! uses a delta because we need one frame of not sprinting to trigger
                && never(was_not_sprinting_or_stopping_)

                // trigger when lara comes to a hard stop...
                && hard_stop_
                
                // ... and is one step away from touching the lasers...
                && is_positive(dword_t, mem_path(lara_, ["pos", "x_pos"]))
                && mem_path(lara_, ["pos", "x_pos"]) >= 0x90d0

                // ... and is still alive (excludes any attempts that touch the lasers)
                && is_positive(word_t, mem_path(lara_, ["hit_points"]))
    )
}
_sprint_achievement()

function _monitor_achievement() {
    achievement(
        id=147398,
        badge="164036",
        title="Future Sight",
        description=format("[{0}] Use the security monitor", level_name("ESCAPE_WITH_THE_IRIS")),
        points=2,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")
                && prev(mem_path(camera, ["pos", "x"])) == 0x00007200
                && prev(mem_path(camera, ["pos", "y"])) == 0xffff9e00
                && prev(mem_path(camera, ["pos", "z"])) == 0x00011a00
                && mem_changed_from_to(mem_path(camera, ["fixed_camera"]), 1, 0)
    )
}
_monitor_achievement()

function _restroom_achievement() {
    doors_werent_open_ = always_false()
    doors_are_open_ = always_true()
    for door_ in item_group_vars("ESCAPE_WITH_THE_IRIS", "Restroom Stall Doors") {
        doors_werent_open_ = doors_werent_open_
            || prev(mem_path(door_, ["current_anim_state"])) != enum_value(KICK_DOOR_ANIM_STATE, "OPEN")
        doors_are_open_ = doors_are_open_
            && mem_path(door_, ["current_anim_state"]) == enum_value(KICK_DOOR_ANIM_STATE, "OPEN")
    }

    achievement(
        id=147399,
        badge="164037",
        title="This! Is! Lara!",
        description=format("[{0}] Kick open every restroom stall", level_name("ESCAPE_WITH_THE_IRIS")),
        points=2,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")
                && doors_werent_open_
                && doors_are_open_
    )
}
_restroom_achievement()

function _ambush_meds_achievement() {
    lara_ = item_var("ESCAPE_WITH_THE_IRIS", "Lara")

    n_medis_collected_ = 0
    for medi_ in item_group_vars("ESCAPE_WITH_THE_IRIS", "Ambush Medipacks")
        n_medis_collected_ = n_medis_collected_ + mem_path(medi_, ["flags", "KILLED"])

    start_cond_ = once(mem_path(lara_, ["room_number"]) == 39
                       && n_medis_collected_ == 0)

    achievement(
        id=147400,
        badge="164038",
        title="Questionable Endeavour",
        description=format("[{0}] When ambushed in the elevator, collect the two medipacks and escape using at most one medipack in the process",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=5,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")

                // start when lara is inside the elevator with no medipacks collected
                && start_cond_

                // reset if we use more than one medipack (small medipacks count for half)
                // also require the start condition to have been true before counting medipacks, otherwise we'll
                // count medipack uses before the challenge itself
                && never(tally(3, [
                    start_cond_ && mem_decreased_by(mem_path(lara, ["num_small_medipack"]), 1),
                    start_cond_ && mem_decreased_by(mem_path(lara, ["num_large_medipack"]), 1),
                    start_cond_ && mem_decreased_by(mem_path(lara, ["num_large_medipack"]), 1)
                ]))

                // trigger when lara reactivates the elevator iff the medipacks have been collected
                && cutscene_started("ESCAPE_WITH_THE_IRIS", "Elevator Fall")
                && n_medis_collected_ == 2
    )
}
_ambush_meds_achievement()

function _backtrack_med_achievement() {
    lara_ = item_var("ESCAPE_WITH_THE_IRIS", "Lara")
    medi_ = item_var("ESCAPE_WITH_THE_IRIS", "Backtrack Medipack")

    start_cond_ = once(
        mem_path(camera, ["pos", "x"]) == 0x8e00
        && mem_path(camera, ["pos", "y"]) == 0xfffff300
        && mem_path(camera, ["pos", "z"]) == 0x11e00
        && mem_changed_from_to(mem_path(camera, ["fixed_camera"]), 0, 1))

    achievement(
        id=147846,
        badge="165233",
        title="Another Questionable Endeavour",
        description=format("[{0}] After the motion sensor room is broken into, backtrack for a medipack and get to the teleporter room using at most one small medipack",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=5,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")
                
                // start when the fixed camera happens
                && start_cond_
                
                // reset if we use more than one small medipack, or a single large medipack
                && never(repeated(2, start_cond_ && mem_decreased_by(mem_path(lara, ["num_small_medipack"]), 1)))
                && never(mem_decreased_by(mem_path(lara, ["num_large_medipack"]), 1))

                // trigger when lara reaches the teleporter room if the medipack was collected
                && mem_path(medi_, ["flags", "KILLED"]) == 1
                && mem_path(lara_, ["room_number"]) == 147
    )
}
_backtrack_med_achievement()

function _midcore_achievement() {
    lara_ = item_var("ESCAPE_WITH_THE_IRIS", "Lara")
    restroom_card_ = item_var("ESCAPE_WITH_THE_IRIS", "Restroom Card")
    xray_switch_ = item_var("ESCAPE_WITH_THE_IRIS", "X-Ray Button 1")
    guard_ = item_var("ESCAPE_WITH_THE_IRIS", "Last Guard")

    achievement(
        id=147401,
        badge="164039",
        title="Midcore Protection",
        description=format("[{0}] Discover & use both keypad combinations and find the location of the Teleporter Disc without using a walkthrough [single session, loading allowed]",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=5,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && never_not_playing_or_loading_level("ESCAPE_WITH_THE_IRIS")

                // collected the restroom card before unlocking the corresponding door
                && once(keypad_success([8, 5, 2, 6])
                        && mem_path(restroom_card_, ["flags", "KILLED"]) == 1)

                // activated the x-ray before collecting the teleporter disc
                && once(mem_path(lara_, ["room_number"]) == 17  // avoids trigger while loading
                        && mem_path(lara, ["puzzle_items", 2]) == 0
                        && mem_changed_from_to(mem_path(xray_switch_, ["current_anim_state"]),
                                               enum_value(SWITCH_ANIM_STATE, "OFF"), enum_value(SWITCH_ANIM_STATE, "ON")))

                // saw guard using the keypad
                // kinda... because it's very hard to tell whether lara is actually looking at the keypad
                && once(mem_path(guard_, ["current_anim_state"]) == enum_value(BLUE_GUARD_ANIM_STATE, "USING_KEYPAD")

                        // looking either directly, through the binoculars or through the HK
                        && mem_path(camera, ["old_type"]) == enum_value(CAMERA_TYPE, "LOOK")

                        // while in the duct
                        && (mem_path(lara_, ["room_number"]) == 161
                            || mem_path(lara_, ["room_number"]) == 86))

                // trigger the second code is successfully entered
                && keypad_success([1, 6, 7, 2])
    )
}
_midcore_achievement()

function _xray_achievement() {
    guard_ = item_var("ESCAPE_WITH_THE_IRIS", "Last Guard")
    switch_ = item_var("ESCAPE_WITH_THE_IRIS", "X-Ray Button 2")

    achievement(
        id=147402,
        badge="164040",
        title="You Had One Job",
        description=format("[{0}] At the end of the level, deactivate the x-ray machine without alerting or incapacitating the guard",
                           level_name("ESCAPE_WITH_THE_IRIS")),
        points=5,
        trigger=level_cheat_protection("ESCAPE_WITH_THE_IRIS")
                && playing_level("ESCAPE_WITH_THE_IRIS")

                // guard is still alive and not alerted
                && mem_path(guard_, ["flags", "KILLED"]) == 0
                && mem_path(cast_var(pointer_t(CREATURE_INFO), addressof_path(guard_, ["data"])), ["flags2", "ALERTED"]) == 0

                // trigger when x-ray machine is disabled
                && mem_changed_from_to(mem_path(switch_, ["current_anim_state"]),
                                       enum_value(SWITCH_ANIM_STATE, "OFF"), enum_value(SWITCH_ANIM_STATE, "ON"))
    )
}
_xray_achievement()


//
//   R E D   A L E R T
//

beat_level_achievement("RED_ALERT", 147403, "164041", 10)

secrets_achievement("RED_ALERT", 147404, "164042", 3)

level_nlnmas_achievement("RED_ALERT", 147405, "164043", 25)

function _no_steam_achievement() {
    lara_ = item_var("RED_ALERT", "Lara")
    valve_ = item_var("RED_ALERT", "Steam Valve")
    
    x_pos_ = mem_path(lara_, ["pos", "x_pos"])
    z_pos_ = mem_path(lara_, ["pos", "z_pos"])

    achievement(
        id=147406,
        badge="164044",
        title="No Foggy Glasses",
        description=format("[{0}] Get past the invisible lasers without blowing up the steam valve", level_name("RED_ALERT")),
        points=5,
        trigger=level_cheat_protection("RED_ALERT")
                && never_not_playing_level("RED_ALERT")

                // start before all the lasers
                && once(is_positive(dword_t, z_pos_) && z_pos_ >= 84725
                        && is_positive(dword_t, x_pos_) && x_pos_ <= 58675)

                // trigger if lara reaches the room past the lasers...
                && is_positive(dword_t, z_pos_) && z_pos_ >= 84725
                && is_positive(dword_t, x_pos_) && x_pos_ >= 63225

                // ... and the steam valve hasn't been destroyed...
                && mem_path(valve_, ["flags2", "ACTIVE"]) == 0

                // ... and lara is still alive (excludes attempts in which lara dies on the last laser)
                && is_positive(word_t, mem_path(lara_, ["hit_points"]))
    )
}
_no_steam_achievement()

function _shooting_range_achievement() {
    switch1_ = item_var("RED_ALERT", "Range 1 Switch")
    switch2_ = item_var("RED_ALERT", "Range 2 Switch")
    door2_ = item_var("RED_ALERT", "Range 2 Door")

    achievement(
        id=147407,
        badge="164045",
        title="Bullseye",
        description=format("[{0}] Beat both shooting ranges back to back [no loading]", level_name("RED_ALERT")),
        points=5,
        trigger=level_cheat_protection("RED_ALERT")
                && never_not_playing_level("RED_ALERT")

                // started the first shooting range in the current session
                && once(mem_changed_from_to(mem_path(switch1_, ["current_anim_state"]),
                        enum_value(SWITCH_ANIM_STATE, "OFF"), enum_value(SWITCH_ANIM_STATE, "ON")))

                // successfully completed the second shooting range
                && mem_path(switch2_, ["current_anim_state"]) == enum_value(SWITCH_ANIM_STATE, "ON")
                && mem_changed_from_to(mem_path(door2_, ["current_anim_state"]),
                                       enum_value(DOOR_ANIM_STATE, "CLOSED"),
                                       enum_value(DOOR_ANIM_STATE, "OPEN"))
    )
}
_shooting_range_achievement()

function _cyborg_achievement() {
    lara_ = item_var("RED_ALERT", "Lara")
    cyborg_ = item_var("RED_ALERT", "Cyborg 1")

    achievement(
        id=147408,
        badge="164046",
        title="Cyberbullying",
        description=format("[{0}] Defeat the first Cyborg without taking damage", level_name("RED_ALERT")),
        points=5,
        trigger=level_cheat_protection("RED_ALERT")
                && never_not_playing_level("RED_ALERT")
        
                // saw the cyborg at max hp (item_flags[0] counts up to 0xb, at which point the water will kill the cyborg)
                && once(mem_path(cyborg_, ["item_flags", 0]) == 0)

                && never(took_damage(lara_))

                // the cyborg doesn't get the 0xc000 marker. just stays at 0 hp
                && mem_changed_from_to(mem_path(cyborg_, ["hit_points"]), 0x32, 0)
    )
}
_cyborg_achievement()

function _bar_achievement() {
    lara_ = item_var("RED_ALERT", "Lara")
    button_ = item_var("RED_ALERT", "Bar Switch")

    never_crouching_ = always_true()
    for anim_state_ in ["CROUCH_IDLE", "CROUCH_ROLL", "CROUCH_TURN_LEFT", "CROUCH_TURN_RIGHT"]
        never_crouching_ = never_crouching_
            && never(mem_path(lara_, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, anim_state_))

    achievement(
        id=147409,
        badge="164047",
        title="One Manhattan, Please",
        description=format("[{0}] Enter the bar, press the button, and escape without crouching or being shot more than 3 times",
                           level_name("RED_ALERT")),
        points=5,
        trigger=level_cheat_protection("RED_ALERT")
                && never_not_playing_level("RED_ALERT")

                // entered the bar and pressed the button
                && once(mem_changed_from_to(mem_path(lara_, ["room_number"]), 152, 46))
                && once(mem_changed_from_to(mem_path(button_, ["current_anim_state"]),
                                            enum_value(SWITCH_ANIM_STATE, "OFF"), enum_value(SWITCH_ANIM_STATE, "ON")))

                // reset if lara takes damage / is shot 4 times
                && never(repeated(4, took_damage(lara_)))

                // reset if lara crouches
                && never_crouching_

                // trigger upon exiting the bar
                && mem_changed_from_to(mem_path(lara_, ["room_number"]), 46, 152)
    )
}
_bar_achievement()

function _cyborg_trap_achievement() {
    cyborg_ = item_var("RED_ALERT", "Cyborg 2")
    door_ = item_var("RED_ALERT", "Trap Room Door")

    achievement(
        id=147410,
        badge="164048",
        title="Too Fast for Your Own Good",
        description=format("[{0}] After getting back from the bar, close the trap room before the Cyborg gets to it", level_name("RED_ALERT")),
        points=5,
        trigger=level_cheat_protection("RED_ALERT")
                && playing_level("RED_ALERT")
                && mem_path(cyborg_, ["room_number"]) == 142
                && mem_path(door_, ["current_anim_state"]) == enum_value(DOOR_ANIM_STATE, "CLOSED")
    )
}
_cyborg_trap_achievement()


//
//   N O T   L E V E L    S P E C I F I C
//

function _tightrope_fall_achievement() {
    achievement(
        id=147411,
        badge="164049",
        title="Stumbling to Success",
        description="Lose your balance on a tightrope, but still make it across",
        points=5,
        trigger=any_level_cheat_protection()
                && playing_a_level()

                // changed directly from failing to balance to standing
                && (prev(mem_path(lara_item, ["current_anim_state"])) == enum_value(LARA_ANIM_STATE, "TIGHTROPE_BALANCING_LEFT")
                    || prev(mem_path(lara_item, ["current_anim_state"])) == enum_value(LARA_ANIM_STATE, "TIGHTROPE_BALANCING_RIGHT"))
                && mem_path(lara_item, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, "STOP")

                // height remaining the same
                && mem_didnt_change(mem_path(lara_item, ["pos", "y_pos"]))
    )
}
_tightrope_fall_achievement()

function _tightrope_achievement() {
    on_tightrope_alts_ = []
    for anim_state_ in ["TIGHTROPE_IDLE", "TIGHTROPE_TURNAROUND", "TIGHTROPE_FORWARD",
                        "TIGHTROPE_BALANCING_LEFT", "TIGHTROPE_BALANCING_RIGHT",
                        "TIGHTROPE_RESTORE_BALANCE", "TIGHTROPE_ENTER", "TIGHTROPE_EXIT"] {
        array_push(on_tightrope_alts_,
            mem_path(lara_item, ["current_anim_state"]) == enum_value(LARA_ANIM_STATE, anim_state_))
    }

    achievement(
        id=147412,
        badge="164050",
        title="Embrace the Boredom",
        description="Stand on a tightrope for at least 5 minutes [no pausing or inventory!]",
        points=5,
        trigger=any_level_cheat_protection()
                && playing_a_level()
                && never(in_inventory())
                && never(paused())
                && never(!or_alts(on_tightrope_alts_))
                && tally(time_to_frames(5, 0), on_tightrope_alts_)
    )
}
_tightrope_achievement()

function _fast_shoot_achievement() {
    round_shot_ = mem_path(lara, ["gun_type"]) == enum_value(WEAPON_TYPE, "REVOLVER")
                  && mem_path(lara, ["flags", "HAS_FIRED"]) == 1
                  && mem_decreased_by(mem_path(lara, ["num_revolver_ammo"]), 1)

    achievement(
        id=147847,
        badge="165234",
        title="Speed Shooting",
        description="Fire 10 revolver rounds in less than 3 seconds without using the laser sight",
        points=5,
        trigger=never_not_playing_a_level()
                && repeated(10, round_shot_)
                && never(once(round_shot_)
                         && repeated(time_to_frames(0, 3), always_true()))
    )
}
_fast_shoot_achievement()

function _special_features_achievement() {
    storyboard_sizes_ = [12, 15, 12]

    viewed_storyboards_ = always_true()
    for it_ in array_enumerate(storyboard_sizes_) {
        row_ = it_[0]
        size_ = it_[1]
        for i_ in range(0, size_) {
            viewed_storyboards_ = viewed_storyboards_
                && once(in_special_features()
                        && mem(title_submenu_row) == row_
                        && mem(storyboard_page) == i_)
        }
    }

    achievement(
        id=147413,
        badge="164051",
        title="Not So Special Features",
        description="Unlock and sit through all the Special Features",
        points=5,
        trigger=viewed_storyboards_
                // end of the next-generation fmv
                && once(in_special_features()
                        && mem_changed_from_to(mem_path(active_disp_env, ["isrgb24"]), 1, 0))
    )
}
_special_features_achievement()

}


// ================================== \\
// ================================== \\
//                                    \\
//      L E A D E R B O A R D S       \\
//                                    \\
// ================================== \\
// ================================== \\

function _training_area_lb() {
    lara_ = item_var("STREETS_OF_ROME", "Lara")
    door_ = item_var("STREETS_OF_ROME", "Training Area Door")

    leaderboard(
        title="Training Area RTA",
        description="Complete the training area in Streets of Rome as fast as possible [no loading]",
        start=(playing_level("STREETS_OF_ROME")
               && mem_path(door_, ["current_anim_state"]) == enum_value(DOOR_ANIM_STATE, "CLOSED")
               && prev(mem_path(lara_, ["pos", "x_pos"])) > 44030
               && mem_path(lara_, ["pos", "x_pos"]) <= 44030
               && mem_path(lara_, ["pos", "z_pos"]) <= 34825),
        cancel=(!playing_level("STREETS_OF_ROME")
                || (prev(mem_path(lara_, ["pos", "x_pos"])) <= 45055
                    && mem_path(lara_, ["pos", "x_pos"]) > 45055)),
        submit=mem_changed_to(mem_path(door_, ["current_anim_state"]), enum_value(DOOR_ANIM_STATE, "OPEN")),
        value=measured(not_paused_no_alts())
    )
}
_training_area_lb()

function level_rta_start(level) =>
    level_start(level)

function level_rta_cancel(level) =>
    all_guns_cheat()
    || or_alts(all_items_cheat_alts(level))
    // leave one frame to submit
    || (prev(mem(gameflow_status)) != enum_value(GAMEFLOW_STATUS, "IN_LEVEL")
        && prev(mem(gameflow_status)) != enum_value(GAMEFLOW_STATUS, "LOAD_LEVEL"))

function level_rta_submit(level) =>
    completed_level(level)

for level_ in playable_levels {
    leaderboard(
        title=format("{0} RTA", level_name(level_)),
        description=format("Complete {0} as fast as possible [no loading]", level_name(level_)),
        start=level_rta_start(level_),
        cancel=level_rta_cancel(level_),
        submit=level_rta_submit(level_),
        value=measured(not_paused_no_alts())
    )
}

// ==================================== \\
// ==================================== \\
//                                      \\
//      R I C H   P R E S E N C E       \\
//                                      \\
// ==================================== \\
// ==================================== \\

function rp_level() {
    _lookup = {}
    for _level in level_meta
        _lookup[enum_value(LEVEL_ID, _level)] = level_name(_level)
    return rich_presence_lookup("Level", mem(level_id), _lookup, "an unknown location")
}

rich_presence_conditional_display(in_special_features(), "Lara is looking through the Special Features, feeling disappointed")
rich_presence_conditional_display(in_credits(), "Lara is gloating while watching the credits")
rich_presence_conditional_display(in_title(), "Lara is wasting time on the title screen")
rich_presence_conditional_display(in_or_loading_a_level(), "Lara is making her way through {0}", rp_level())
rich_presence_display("Lara is in parts unknown")
