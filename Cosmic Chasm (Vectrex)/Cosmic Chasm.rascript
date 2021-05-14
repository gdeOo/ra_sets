// Cosmic Chasm
// #ID = 6578

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
FPS = 50

// what size should pointers be referenced through in AddAddress conditions?
POINTER_SIZE = 8

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

function pow(x, y) {
    if (y == 0)
        return 1
    else if (y % 2 == 0)
        return pow(x, y / 2) * pow(x, y / 2)
    else
        return x * pow(x, y / 2) * pow(x, y / 2)
}

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
low4_t  = builtin_t("low4")
high4_t = builtin_t("high4")
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
    if (t == "low4")  return low4(addr)
    if (t == "high4") return high4(addr)
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
        if (t["builtin"] == "low4")    return 1
        if (t["builtin"] == "high4")   return 1
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

BARRIERS =  bitflags_t("BARRIERS", {
    "UP_LEFT":    make_bitflag(0, bit7_t),
    "UP":         make_bitflag(0, bit6_t),
    "UP_RIGHT":   make_bitflag(0, bit5_t),
    "RIGHT":      make_bitflag(0, bit4_t),
    "DOWN_RIGHT": make_bitflag(0, bit3_t),
    "DOWN":       make_bitflag(0, bit2_t),
    "DOWN_LEFT":  make_bitflag(0, bit1_t),
    "LEFT":       make_bitflag(0, bit0_t)
}, byte_t)

ROOM_INFO = struct_t("ROOM_INFO", {
    "active_barriers": make_field(0x0, BARRIERS),
    "center_size":     make_field(0x1, byte_t),
    "n_enemies":       make_field(0x2, byte_t)
}, 0x3)

PLAYER_STATE = bitflags_t("PLAYER_STATE", {
    "COLLIDING": make_bitflag(0, bit7_t),
    "SHOOTING":  make_bitflag(0, bit6_t),
    "DRILLING":  make_bitflag(0, bit5_t),
    "BOUNCING":  make_bitflag(0, bit4_t),
    "SHIELDING": make_bitflag(0, bit3_t),
    "THRUSTING": make_bitflag(0, bit2_t)
}, byte_t)


//                                                  
//                                                  
//   _ __ ___    ___  _ __ ___    ___   _ __  _   _ 
//  | '_ ` _ \  / _ \| '_ ` _ \  / _ \ | '__|| | | |
//  | | | | | ||  __/| | | | | || (_) || |   | |_| |
//  |_| |_| |_| \___||_| |_| |_| \___/ |_|    \__, |
//                                             __/ |
//                                            |___/ 

text_settings  = make_var(                word_t, 0x002a)
n_players      = make_var(                byte_t, 0x0079)
bouncing_timer = make_var(                byte_t, 0x0095)
room_id        = make_var(                byte_t, 0x009e)
secret_timer   = make_var(                byte_t, 0x00aa)
player_state   = make_var(          PLAYER_STATE, 0x00b1)
n_lives        = make_var(                byte_t, 0x00ff)
saved_rooms    = make_var(array_t(ROOM_INFO, 16), 0x0101)
mission_n_text = make_var(    array_t(byte_t, 7), 0x0131)
countdown      = make_var(    array_t(byte_t, 4), 0x013a)
p1_score_text  = make_var(    array_t(byte_t, 7), 0x0146)

function run_started() =>
    mem_changed_to(mem(n_lives), 5)

function run_ended() =>
    mem_changed_from_to(mem(n_lives), 1, 0)

function ingame() =>
    mem(n_lives) != 0xff
    && (mem_path(mission_n_text, [4]) >= ascii["0"]
        || mem_path(mission_n_text, [5]) >= ascii["1"])

function ascii_string_to_value(str) {
    // the ascii values for numbers 0 through 9 are 0x30 through 0x39, so we can just use a low4
    // accessor to convert ascii to number. luckily, the character used for left padding is space,
    // whose value is 0x20, thus being equivalent to 0 using low4. it's almost like they designed
    // ascii thinking of this very moment!
    value_ = 0
    n_ = array_var_size(str) - 2
    for i in range(0, n_) {
        v_ = mem(cast_var(low4_t, addressof_path(str, [n_ - i])))
        value_ = value_ + (v_ * pow(10, i))
    }
    return value_
}

function mission_value() => ascii_string_to_value(mission_n_text)
function score_value() => ascii_string_to_value(p1_score_text)

function countdown_secs() =>
    100 * mem(cast_var(low4_t, addressof_path(countdown, [3])))
    + 1000 * mem(cast_var(low4_t, addressof_path(countdown, [2])))
    + 6000 * mem(cast_var(low4_t, addressof_path(countdown, [1])))
    + 60000 * mem(cast_var(low4_t, addressof_path(countdown, [0])))

function beat_any_mission() {
    c4 = mem_path(mission_n_text, [4])
    c5 = mem_path(mission_n_text, [5])
    return (prev(c5) >= ascii["0"] && prev(c5) <= ascii["8"]
            && prev(c5) + 1 == c5)
           || (c4 != ascii[" "] && prev(c5) == ascii["9"] && c5 == ascii["0"])
}

function beat_mission(n) =>
    mem_path(mission_n_text, [4]) == ascii[" "]
    && prev(mem_path(mission_n_text, [5])) == ascii["0"] + n
    && mem_path(mission_n_text, [5]) == ascii["0"] + n + 1

function score_exploit_alts() {
    c0 = mem_path(p1_score_text, [4])
    c1 = mem_path(p1_score_text, [5])

    // important: scores are always multiples of 5
    return [
        // 00->25 10->35 20->45 30->55 40->65 50->75 60->85 70->95
        prev(c0) + 2 == c0 && prev(c1) == ascii["0"] && c1 == ascii["5"],

        // 05->30 15->40 25->50 35->60 45->70 55->80 65->90
        prev(c0) + 3 == c0 && prev(c1) == ascii["5"] && c1 == ascii["0"],

        // 75->00 85->10 95->20
        prev(c0) == c0 + 7 && prev(c1) == ascii["5"] && c1 == ascii["0"],

        // 80->05 90->15
        prev(c0) == c0 + 8 && prev(c1) == ascii["0"] && c1 == ascii["5"]
    ]
}

//                _      _                                            _        
//               | |    (_)                                          | |       
//    __ _   ___ | |__   _   ___ __   __ ___  _ __ ___    ___  _ __  | |_  ___ 
//   / _` | / __|| '_ \ | | / _ \\ \ / // _ \| '_ ` _ \  / _ \| '_ \ | __|/ __|
//  | (_| || (__ | | | || ||  __/ \ V /|  __/| | | | | ||  __/| | | || |_ \__ \
//   \__,_| \___||_| |_||_| \___|  \_/  \___||_| |_| |_| \___||_| |_| \__||___/
//                                                                             
//                                                                             

function base_rules() =>
    mem(n_players) == 0

//
//   p a u s e   l o c k s
//

function score_exploit_pause_lock_placeholder() =>
    byte(0x1234) == 0x11

gen_pauselocks = false
if (gen_pauselocks == true) {

function _score_exploit_pause_lock() {
    // protection triggers if the player earns 25 points 20 times in a single room.
    // only legit way to get 25 points is by destroying a barrier, so this should only happen
    // at most 4 times in the same room. 20 times is just for safety. if the exploit is
    // used, the 20 hits are reached in seconds anyway
    achievement("score exploit lock", "score exploit lock", 5,
        once(byte(0x1) == 0x1)
        && never(mem_changed(mem(room_id)))
        && unless(tally(20, score_exploit_alts()))
    )
}
_score_exploit_pause_lock()

function _score_exploit_pause_lock_reset() {
    achievement("score exploit lock reset", "score exploit lock reset", 5,
        once(byte(0x1) == 0x1) && never(mem(n_lives) == 0)
    )
}
_score_exploit_pause_lock_reset()

}  // gen_pauselocks


//
//   p r o g r e s s i o n
//

function beat_mission_achievement(n, id, badge, title, points) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=format("Complete mission {0} [1P]", n),
        points=points,
        trigger=base_rules()
                && beat_mission(n)
    )
}

beat_mission_achievement(1, 152584, "172390", "Base Destruction", 3)
beat_mission_achievement(2, 152585, "172391", "Planetary Devastation", 5)
beat_mission_achievement(3, 152586, "172392", "Cosmic Extermination", 5)
beat_mission_achievement(4, 152587, "172393", "Civilizational Annihilation", 10)

//
//   h i g h s c o r e s
//

function is_ascii_number_ge(char_mem, n) =>
    char_mem >= ascii[format("{0}", n)] && char_mem <= ascii["9"]

function is_nonzero_ascii_number(char_mem) =>
    char_mem >= ascii["1"] && char_mem <= ascii["9"]

function _10k_achievement() {
    c1 = mem_path(p1_score_text, [1])

    achievement(
        id=152588,
        badge="172394",
        title="Subsistence Farming",
        description="Reach a score of 10.000 points [1P]",
        points=5,
        trigger=base_rules()
                && score_exploit_pause_lock_placeholder()
                && !is_nonzero_ascii_number(prev(c1))
                && is_ascii_number_ge(c1, 1)
    )
}
_10k_achievement()

function _25k_achievement() {
    c1 = mem_path(p1_score_text, [1])
    c2 = mem_path(p1_score_text, [2])

    achievement(
        id=152589,
        badge="172395",
        title="Commercial Farming",
        description="Reach a score of 25.000 points [1P]",
        points=10,
        trigger=base_rules()
                && score_exploit_pause_lock_placeholder()
                && c1 == ascii["2"]
                && !is_ascii_number_ge(prev(c2), 5)
                && is_ascii_number_ge(c2, 5)
    )
}
_25k_achievement()

function _50k_achievement() {
    c1 = mem_path(p1_score_text, [1])

    achievement(
        id=152590,
        badge="172396",
        title="Intensive Farming",
        description="Reach a score of 50.000 points [1P]",
        points=25,
        trigger=base_rules()
                && score_exploit_pause_lock_placeholder()
                && !is_ascii_number_ge(prev(c1), 5)
                && is_ascii_number_ge(c1, 5)
    )
}
_50k_achievement()


// 
//   c h a l l e n g e s
//

function mission_completed() =>
    // missions 1-9
    (mem_path(mission_n_text, [4]) == ascii[" "]
     && prev(mem_path(mission_n_text, [5])) >= ascii["1"]
     && prev(mem_path(mission_n_text, [5])) + 1 == mem_path(mission_n_text, [5]))
    // missions >= 10 (nobody should be able to get here, but might as well I guess...)
    || (mem_path(mission_n_text, [4]) >= ascii["0"] && mem_path(mission_n_text, [4]) <= ascii["9"]
        && prev(mem_path(mission_n_text, [5])) != mem_path(mission_n_text, [5]))
    

function _escape_achievement() {
    achievement(
        id=152591,
        badge="172398",
        title="Warp Speed Escape",
        description="Complete a mission with 8 or more seconds remaining on the countdown [1P]",
        points=5,
        trigger=base_rules()
                && mission_completed()
                && (mem_path(countdown, [0]) >= ascii["1"]
                    || (mem_path(countdown, [0]) == ascii["0"] && mem_path(countdown, [1]) >= ascii["8"]))
    )
}
_escape_achievement()

function _pacifist_achievement() {
    all_enemies_alive_ = always_true()
    for i in range(0, array_var_size(saved_rooms) - 1) {
        room = addressof_path(saved_rooms, [i])
        all_enemies_alive_ = all_enemies_alive_
            && mem_path(room, ["n_enemies"]) >= 8
    }

    achievement(
        id=152592,
        badge="172399",
        title="Planet Protectors Are People Too",
        description="Complete a mission having killed no enemies [1P]",
        points=5,
        trigger=base_rules()
                && mission_completed()
                && all_enemies_alive_
    )
}
_pacifist_achievement()

function _warpath_achievement() {
    all_enemies_dead_ = always_true()
    for i in range(0, array_var_size(saved_rooms) - 1) {
        room = addressof_path(saved_rooms, [i])
        all_enemies_dead_ = all_enemies_dead_
            && mem_path(room, ["n_enemies"]) == 0
    }

    achievement(
        id=152593,
        badge="172400",
        title="Or Are They?...",
        description="Complete a mission having killed every enemy [1P]",
        points=5,
        trigger=base_rules()
                && mission_completed()
                && all_enemies_dead_
    )
}
_warpath_achievement()

function _bounce_achievement() {
    achievement(
        id=152594,
        badge="172401",
        title="Bouncy Bouncy",
        description="Get forcibly thrown out of a cavern [1P]",
        points=1,
        trigger=base_rules()
                && prev(mem(bouncing_timer)) > 0
                && mem_changed(mem(room_id))
    )
}
_bounce_achievement()

function _deathless_achievement() {
    achievement(
        id=152595,
        badge="172402",
        title="Best Ship",
        description="Complete mission 3 without losing a single ship [1P]",
        points=10,
        trigger=base_rules()
                && beat_mission(3)
                && mem(n_lives) == 5
    )
}
_deathless_achievement()

function _programmer_achievement() {
    achievement(
        id=152596,
        badge="172403",
        title="A Simpler Time",
        description="Learn the name of the game's lone programmer",
        points=1,
        trigger=mem(text_settings) == 0x40fb
                && mem(secret_timer) > 0
    )
}
_programmer_achievement()


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
    description="Reach as high a score as possible [1P]",
    start =base_rules()
           && run_started(),
    cancel=never(mem_changed(mem(room_id)))
           && tally(20, score_exploit_alts()),
    submit=run_ended(),
    value =score_value(),
    format="VALUE"
)

leaderboard(
    title="High Mission",
    description="Reach as high a mission as possible [1P]",
    start =base_rules()
           && run_ended(),
    cancel=always_false(),
    submit=run_ended(),
    value =mission_value(),
    format="VALUE"
)

leaderboard(
    title="Fastest Escape",
    description="Escape a planet with as much time remaining as possible [1P]",
    start =base_rules()
           && beat_any_mission(),
    cancel=always_false(),
    submit=beat_any_mission(),
    value =countdown_secs(),
    format="SECS"
)


//         _        _                                                      
//        (_)      | |                                                     
//   _ __  _   ___ | |__     _ __   _ __  ___  ___   ___  _ __    ___  ___ 
//  | '__|| | / __|| '_ \   | '_ \ | '__|/ _ \/ __| / _ \| '_ \  / __|/ _ \
//  | |   | || (__ | | | |  | |_) || |  |  __/\__ \|  __/| | | || (__|  __/
//  |_|   |_| \___||_| |_|  | .__/ |_|   \___||___/ \___||_| |_| \___|\___|
//                          | |                                            
//                          |_|                                            

rich_presence_conditional_display(
    ingame(),
    "Burrowing inside the {0}{1} alien planet with a score of {2}",
    rich_presence_value("Mission", mission_value(), "VALUE"),
    rich_presence_lookup("MissionOrdinal", mission_value(), {1: "st", 2: "nd", 3: "rd"}, "th"),
    rich_presence_value("Score", score_value())
)

rich_presence_display("Getting ready to save the galaxy")
