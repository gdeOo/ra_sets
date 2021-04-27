// Chimera
// #ID = 17606

//   _  _  _                              
//  | |(_)| |                             
//  | | _ | |__   _ __  __ _  _ __  _   _ 
//  | || || '_ \ | '__|/ _` || '__|| | | |
//  | || || |_) || |  | (_| || |   | |_| |
//  |_||_||_.__/ |_|   \__,_||_|    \__, |
//                                   __/ |
//                                  |___/ 

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


//   _                            
//  | |                           
//  | |_  _   _  _ __    ___  ___ 
//  | __|| | | || '_ \  / _ \/ __|
//  | |_ | |_| || |_) ||  __/\__ \
//   \__| \__, || .__/  \___||___/
//         __/ || |               
//        |___/ |_|               

SPRITE_ID = enum_t("SPRITE_ID", {
    "NONE":             0x00,
    "TOASTER_1":        0x08, "TOASTER_2":        0x09, "TOASTER_3":        0x0a, "TOASTER_4":        0x0b,
    "ELECTRIC_FENCE_1": 0x0c, "ELECTRIC_FENCE_2": 0x0d, "ELECTRIC_FENCE_3": 0x0e, "ELECTRIC_FENCE_4": 0x0f,
    "HOURGLASS_1":      0x10, "HOURGLASS_2":      0x11, "HOURGLASS_3":      0x12, "HOURGLASS_4":      0x13,
    "PANDORAS_BOX_1":   0x14, "PANDORAS_BOX_2":   0x15, "PANDORAS_BOX_3":   0x16, "PANDORAS_BOX_4":   0x17,
    "PLAYER_NE_1":      0x18, "PLAYER_NE_2":      0x19, "PLAYER_NE_3":      0x1a, "PLAYER_NE_4":      0x1b,
    "PLAYER_SE_1":      0x1c, "PLAYER_SE_2":      0x1d, "PLAYER_SE_3":      0x1e, "PLAYER_SE_4":      0x1f,
    "PLAYER_SW_1":      0x20, "PLAYER_SW_2":      0x21, "PLAYER_SW_3":      0x22, "PLAYER_SW_4":      0x23,
    "PLAYER_NW_1":      0x24, "PLAYER_NW_2":      0x25, "PLAYER_NW_3":      0x26, "PLAYER_NW_4":      0x27,
    "DISAPPEAR_1":      0x28, "DISAPPEAR_2":      0x29, "DISAPPEAR_3":      0x2a, "DISAPPEAR_4":      0x2b,
    "TERMINAL":         0x2c,
    "TORCH":            0x2d,
    "BOLT":             0x2e,
    "SPANNER":          0x2f,
    "PYRAMUD_DOWN":     0x30,
    "PYRAMUD_UP":       0x31,
    "PADLOCK":          0x32,
    "KEY":              0x33,
    "MUG":              0x34,
    "BREAD":            0x35,
    "DOOR_SN":          0x36,
    "DOOR_EW":          0x37,
    "WARHEAD":          0x38,
    "RADIATION_SOURCE": 0x39,
    "PICKED_UP":        0x80
}, byte_t)


//                                                  
//                                                  
//   _ __ ___    ___  _ __ ___    ___   _ __  _   _ 
//  | '_ ` _ \  / _ \| '_ ` _ \  / _ \ | '__|| | | |
//  | | | | | ||  __/| | | | | || (_) || |   | |_| |
//  |_| |_| |_| \___||_| |_| |_| \___/ |_|    \__, |
//                                             __/ |
//                                            |___/ 

pos_we            = make_var(               byte_t, 0x0023)
pos_ns            = make_var(               byte_t, 0x0024)
paused            = make_var(               byte_t, 0x0209)
score             = make_var(               word_t, 0x0222)
room_id           = make_var(               byte_t, 0x0224)
room_background   = make_var(               byte_t, 0x0256)
room_item         = make_var(            SPRITE_ID, 0x025c)
n_active_warheads = make_var(               byte_t, 0x02a9)
control_mode      = make_var(               byte_t, 0x06cb)
room_items        = make_var(array_t(byte_t, 0x40), 0x06cf)

function in_game() => mem(control_mode) != 0
function game_started() => mem_changed_from(mem(control_mode), 0)
function game_ended() => mem_changed_to(mem(control_mode), 0)


//                _      _                                            _        
//               | |    (_)                                          | |       
//    __ _   ___ | |__   _   ___ __   __ ___  _ __ ___    ___  _ __  | |_  ___ 
//   / _` | / __|| '_ \ | | / _ \\ \ / // _ \| '_ ` _ \  / _ \| '_ \ | __|/ __|
//  | (_| || (__ | | | || ||  __/ \ V /|  __/| | | | | ||  __/| | | || |_ \__ \
//   \__,_| \___||_| |_||_| \___|  \_/  \___||_| |_| |_| \___||_| |_| \__||___/
//                                                                             
//                                                                             

function eliminate_achievement(id, badge, title, description, points, first_sprite, last_sprite) {
    achievement(title, description, points, id=id, badge=badge,
        trigger=in_game()
                && prev(mem(room_item)) >= enum_value(SPRITE_ID, first_sprite)
                && prev(mem(room_item)) <= enum_value(SPRITE_ID, last_sprite)
                && mem(room_item) == enum_value(SPRITE_ID, "DISAPPEAR_1")
    )
}

eliminate_achievement(151097, "169117", "Trust Me, I'm an Electrician", "Eliminate an electric fence", 3, "ELECTRIC_FENCE_1", "ELECTRIC_FENCE_4")
eliminate_achievement(151098, "169118", "Pass the Butter", "Eliminate a toaster", 5, "TOASTER_1", "TOASTER_4")
eliminate_achievement(151099, "169119", "Master Key", "Unlock a door", 5, "DOOR_SN", "DOOR_EW")
eliminate_achievement(151100, "169120", "Whac-a-Mole", "Eliminate a box that used to belong to Pandora", 5, "PANDORAS_BOX_1", "PANDORAS_BOX_4")
eliminate_achievement(151101, "169121", "Time Is but an Illusion", "Eliminate a reverse flowing hourglass", 5, "HOURGLASS_1", "HOURGLASS_4")

achievement(
    id=151092,
    badge="169112",
    title="DIY Warhead",
    description="Activate a warhead assembled from a spanner and a bolt",
    points=5,
    trigger=in_game()
            && mem_changed_from_to(mem(n_active_warheads), 0, 1)
)

achievement(
    id=151093,
    badge="169113",
    title="Locked Away",
    description="Activate a warhead assembled from a key and a padlock",
    points=5,
    trigger=in_game()
            && mem_changed_from_to(mem(n_active_warheads), 1, 2)
)

achievement(
    id=151094,
    badge="169114",
    title="In the Dark",
    description="Activate a warhead obtained from searching a dark room with a torch",
    points=10,
    trigger=in_game()
            && mem_changed_from_to(mem(n_active_warheads), 2, 3)
            // the torch becomes unobtainable if the pyramid warhead is activated first, so this
            // warhead must always be the third one to activate. because the pyramid warhead can
            // also be the third, we additionally check that the torch was collected
            // note: prev because upon activation of the 3rd warhead, the torchlight is always
            // replaced with a mug, regardless of having been collected or not
            && prev(mem_path(room_items, [(0x1e-1)])) == enum_value(SPRITE_ID, "PICKED_UP")
)

achievement(
    id=151095,
    badge="169115",
    title="Alien Technology",
    description="Activate a warhead assembled from two mirrored pyramids",
    points=10,
    trigger=in_game()
            // if we're activating the 4th warhead, it's guaranteed to be the pyramid one.
            // if it's only the 3rd warhead, we need to ensure the torch wasn't collected.
            && (mem_changed_from_to(mem(n_active_warheads), 3, 4)
                || (mem_changed_from_to(mem(n_active_warheads), 2, 3)
                    && prev(mem_path(room_items, [(0x1e-1)])) == enum_value(SPRITE_ID, "TORCH")))
)

achievement(
    id=151096,
    badge="169116",
    title="The Ending That Never Was",
    description="Complete mission Chimera",
    points=10,
    trigger=// wait for the final message to scroll before triggering
            game_ended()
            && prev(mem(room_background)) == 0xaa
            && prev(mem(n_active_warheads)) == 4
)

achievement(
    id=151102,
    badge="169122",
    title="This Is My Life Now",
    description="Get stuck on the wrong side of a warhead",
    points=2,
    trigger=in_game()
            && mem_changed_to(mem(room_item), enum_value(SPRITE_ID, "WARHEAD"))
            && mem(pos_we) >= 6
            && mem_in(mem(room_id), [0x26, 0x11, 0x06, 0x1d])
)


//   _                   _              _                             _      
//  | |                 | |            | |                           | |     
//  | |  ___   __ _   __| |  ___  _ __ | |__    ___    __ _  _ __  __| | ___ 
//  | | / _ \ / _` | / _` | / _ \| '__|| '_ \  / _ \  / _` || '__|/ _` |/ __|
//  | ||  __/| (_| || (_| ||  __/| |   | |_) || (_) || (_| || |  | (_| |\__ \
//  |_| \___| \__,_| \__,_| \___||_|   |_.__/  \___/  \__,_||_|   \__,_||___/
//                                                                           
//                                                                           

leaderboard(
    title="High Score",
    description="High Score",
    start  = game_ended(),
    cancel = always_false(),
    submit = game_ended(),
    value  = prev(mem(score)),
    format = "VALUE"
)

leaderboard(
    title="Speedrun",
    description="Complete the mission as fast as possible",
    start  = game_started(),
    cancel = game_ended() && (prev(mem(room_background)) != 0xaa || prev(mem(n_active_warheads)) != 4),
    submit = game_ended() && prev(mem(room_background)) == 0xaa && prev(mem(n_active_warheads)) == 4,
    value  = measured(mem(paused) != 1),
    format = "FRAMES"
)

//         _        _                                                      
//        (_)      | |                                                     
//   _ __  _   ___ | |__     _ __   _ __  ___  ___   ___  _ __    ___  ___ 
//  | '__|| | / __|| '_ \   | '_ \ | '__|/ _ \/ __| / _ \| '_ \  / __|/ _ \
//  | |   | || (__ | | | |  | |_) || |  |  __/\__ \|  __/| | | || (__|  __/
//  |_|   |_| \___||_| |_|  | .__/ |_|   \___||___/ \___||_| |_| \___|\___|
//                          | |                                            
//                          |_|                                            

rich_presence_conditional_display(!in_game(), "Wasting time on the title screen")

rich_presence_display("Wandering about an alien ship - {0} of 4 warheads activated",
                      rich_presence_value("Warheads", mem(n_active_warheads), "VALUE"))

