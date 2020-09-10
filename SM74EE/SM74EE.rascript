// ~Hack~ Super Mario 74 Extreme Edition
// #ID = 10547


// ------------- //
//   u t i l s   //
// ------------- //

function just_changed(mem, from, to) => prev(mem) == from && mem == to
function just_changed_to(mem, to) => prev(mem) != to && mem == to

// comparing floats as integers:
//   - if both are positive, compare as normal
//   - if both are negative, compare in reverse
//   - all positive values < all negative values

function float_ge_pos(mem, val) => mem >= val
function float_le_pos(mem, val) => mem <= val

function float_ge_neg(mem, val) => mem < val
function float_le_neg(mem, val) => mem > val

// ----------------- //
//   s t r u c t s   //
// ----------------- //

object__struct = {
    "active":                0x76,  // word
    "behaviour script":     0x20c,  // dword
    "power star index":     0x18b,  // byte
    "cork box tangible":    0x14c,  // byte (boolean)
    "block state":          0x14c,  // byte
    "big boo hp":           0x184,  // dword
    "king whomp attacking": 0x178,  // byte (boolean)
    "spawner num secrets":   0xf4,  // dword
}
object__sizeof = 0x260

function struct_field(struct_def, base, field) => base + struct_def[field]

function object_field(base, field) => struct_field(object__struct, base, field)

// ---------------
//   m e m o r y
// ---------------

demo_timer__addr = 0x1a7c32
demo_timer__mem = word(demo_timer__addr)
function in_demo() => demo_timer__mem == 800

mario_anim__addr = 0x33b17c
mario_anim__mem = dword(mario_anim__addr)
mario_anim__values = {
    "star dance ground (exit)":    0x00001302,
    "star dance ground (no exit)": 0x00001307,
    "star dance water":            0x00001303,
    "long jump":                   0x03000888,
    "twirl":                       0x108008a4,
    "twirl landing":               0x18800238,
    "ground pound":                0x008008a9,
    "ground pound landing":        0x0080023c,
    "in cannon":                   0x00001371,
    "shot from cannon":            0x00880898,
}

function mario_anim_is(name) => mario_anim__mem == mario_anim__values[name]

function mario_anim_changed_to(name) {
    return prev(mario_anim__mem) != mario_anim__values[name]
        && mario_anim__mem == mario_anim__values[name]
}

coins__addr = 0x33b21a
coins__mem = word(coins__addr)

// normal starts = 1-6; 100 coin star = 7
last_star__addr = 0x32dd87
last_star__mem = byte(last_star__addr)

level_id__addr = 0x32ddfa
level_id__mem = byte(level_id__addr)
level_id__values = {
    "Overworld 1":    0x1a,
    "Overworld 2":    0x1f,
    "Overworld 3":    0x06,
    "Castle Grounds": 0x10,
    "Course 1":       0x09,
    "Course 2":       0x18,
    "Course 3":       0x0c,
    "Course 4":       0x05,
    "Course 5":       0x04,
    "Course 6":       0x07,
    "Course 7":       0x16,
    "Course 8":       0x08,
    "Course 9":       0x17,
    "Course 10":      0x0a,
    "Course 11":      0x0b,
    "Course 12":      0x24,
    "Course 13":      0x0d,
    "Course 14":      0x0e,
    "Course 15":      0x0f,
    "Triarc-Bridge":  0x14,
    "Slide":          0x1b,
    "Bowser 1":       0x11,
    "Bowser 2":       0x13,
    "Bowser 3":       0x15,
    "Battle 1":       0x1e,
    "Battle 2":       0x21,
    "Battle 3":       0x22,
    "Wing Cap":       0x1d,
    "Metal Cap":      0x1c,
    "Vanish Cap":     0x12,
}

function in_level(name) => level_id__mem == level_id__values[name]
function just_entered_level(name) => just_changed_to(level_id__mem, level_id__values[name])

function level_names(short, full) => { "short": short, "full": full }
level_names = {
    "Course 1":       "Devil's Dice",
    "Course 2":       "Virusvine Veranda",
    "Course 3":       "Deepred Depths",
    "Course 4":       "System of a Downtown",
    "Course 5":       "Drowned Factory",
    "Course 6":       "Infernopit Cave",
    "Course 7":       "Melting Icecrystal-Tower",
    "Course 8":       "Overgrown Oasis",
    "Course 9":       "Fireflower Fields",
    "Course 10":      "Breezing Beach",
    "Course 11":      "Dried-Out Dead Desert",
    "Course 12":      "Cliff of Pain",
    "Course 13":      "Acid Peaks",
    "Course 14":      "Veneno Sphere",
    "Course 15":      "Crudelo Sphere",

    "Slide":          "Old Supply Slide",

    "Bowser 1":       "Bowser's Beautiful Backyard",
    "Bowser 2":       "Bowser's Quicksand Pit",
    "Bowser 3":       "Ztar Zanctuary",

    "Metal Cap":      "Toxic Terrace",
    "Vanish Cap":     "Dust Destination",
    "Wing Cap":       "Devil's Pit",

    "Overworld 1":    "First Overworld",
    "Overworld 2":    "Lake of the Lords",
    "Overworld 3":    "Third Overworld",

    "Castle Grounds": "Castle Grounds",
    "Triarc-Bridge":  "Triarc-Bridge"
}

star_names = {
    // "Overworld 1":   3 stars (toad & 2x MIPS)
    // "Overworld 2":   6 stars
    // "Overworld 3":   2 stars (both toads)
    // "Metal Cap":     6 stars
    // "Vanish Cap":    6 stars
    // "Wing Cap":      3 stars
    // "Bowser 1":      4 stars
    // "Bowser 2":      5 stars (+2 in Ztar section)
    // "Bowser 3":      6 stars (-2 in Bowser 2 section)

    // "Slide":         4 stars

    // "Triarc-Bridge": 7 stars

    "Course 1":  ["Little Warm-Up"                    , "Let's-a-Go!"                   , "Scale the Tower"             ,
                  "Fundamental Tunnel Problems"       , "First Red Katastrophe"         , "You Won't Find Me!"          ],
    "Course 2":  ["The Vine's Treasure"               , "Time Pressure Travel"          , "On Top of That Wall!"        ,
                  "Jumping-Parcour 1"                 , "Jumping-Parcour 2"             , "Light Red Coins"             ],
    "Course 3":  ["The Upper End of the Crater"       , "Small Pillar Training"         , "Hot Step Stones"             ,
                  "Deep Within the Volcano"           , "Artistic Coin Search"          , "Painful Experience"          ],
    "Course 4":  ["Ghost Odyssee"                     , "Guardian of the Village"       , "Expanded Secret Room"        ,
                  "Death Pit"                         , "So Close and Yet So Far Away"  , "Hidden Coward"               ],
    "Course 5":  ["Pearl Diver"                       , "The Tunnel Labyrinth Part 1"   , "The Tunnel Labyrinth Part 2" ,
                  "The Tunnel Labyrinth Part 3"       , "The Tunnel Labyrinth Part 4"   , "The Tunnel Labyrinth Part 5" ],
    "Course 6":  ["Deep Within the Caldron"           , "Balls of Steel and Fire"       , "Blue Contrast Blocks"        ,
                  "Side Caldron Shenanigans"          , "Dance with the Heave-Hos"      , "Red Sin"                     ],
    "Course 7":  ["Brick Battle"                      , "Floatation in Block Form"      , "Soul of a Climber"           ,
                  "Bloor-Red Finances"                , "Annoying Search"               , "Unjustifiable Search"        ],
    "Course 8":  ["Still Under Construction"          , "Flood Landing Stage"           , "Not So Secret Secret Anymore",
                  "Doubtful Pyramid"                  , "Hidden Hermit"                 , "You Shall Drown!"            ],
    "Course 9":  ["Another Rematch with King Bomb-omb", "Windy Mill"                    , "Way Too Easy Coins"          ,
                  "The Unstable Wooden Construction"  , "Not So Secret Cavern"          , "Bark Beetle Jumps"           ],
    "Course 10": ["Secret of the Smaragos"            , "Hot Pole-Dance"                , "Somewhere in the Nowhere"    ,
                  "Nowhere in the Somewhere"          , "Cold Tomb"                     , "Hemoglobin-Coins"            ],
    "Course 11": ["Burning Feet"                      , "Airy Stored Coins"             , "The Old Hideout"             ,
                  "Grave Digger"                      , "Cemetary Artistics"            , "The Sand Plateau's Torture"  ],
    "Course 12": ["Move Your Butt Up There!"          , "Way Too High"                  , "Another Problematic Box"     ,
                  "Heave-Ho Cave"                     , "You-Can-Guess-Which Coins"     , "Brazenly Placed"             ],
    "Course 13": ["Welcome to the Acid Swamp"         , "Eye to Eye"                    , "Acidproof Boxes"             ,
                  "In the Big Cave"                   , "Another Climbing Challenge"    , "Lava-Colored Glitter"        ],
    "Course 14": ["The Same Place in a Worse World"   , "Through the Heart of the World", "The Edge of the World"       ,
                  "The Roof of the World"             , "Worldwide Pain"                , "Bloodred Coins of Ruination" ],
    "Course 15": ["The Nightmare Begins"              , "Just Go Crazy"                 , "Straight From Hell"          ,
                  "Traumatising Experience"           , "Morbid Deadly Puzzle"          , "Bloody Scream of Rage"       ]
}

function star_def(name, id) => {"name": name, "id": id}

star_indexes = {
    // the names used here are from https://www.youtube.com/playlist?list=PLzlzF6Vh69NBpoYvqvuKaBdHsmg3m_pfs
    "Slide":         {"Bottom of the Slide": 1          , "Hidden Star": 2                    , "Skippable Blocks": 3          ,
                      "Reds": 4                                                                                                },
    
    "Metal Cap":     {"Thin Poles": 1                   , "Toxic Stairs": 2                   , "Hidden Star": 3               ,
                      "Skinny Bridge": 4                , "Sloped Skyway": 5                  , "Reds": 6                      },
    "Vanish Cap":    {"Skippable Wall Kick Arches": 1   , "Inside the House": 2               , "Underneath the Level": 3      ,
                      "Atop the Mesh-Work": 4           , "Straight Long-Jump from Above": 5  , "Reds": 6                      },
    "Wing Cap":      {"Hidden Star": 1                  , "High in the Sky": 2                , "Reds": 3                      },

    "Bowser 1":      {"Annoying Wallkicks": 1           , "Very Well Hidden Star": 2          , "Corner of the Big Building": 3,
                      "Reds": 4                                                                                                },
    "Bowser 2":      {"Hidden in the Window": 1         , "Shell-Climb to the Mountain Top": 2, "Wallkicks Will Work 2.0": 3   ,
                      "Stupid Boxes": 4                 , "Reds": 5                           , "Left Path": 6                 ,
                      "Right Path": 7                                                                                          },
    "Bowser 3":      {"Tiny Burning Platforms": 1       , "Underneath the Level": 2           , "Reds": 3                      ,
                      "Back Through the Cannon Holes": 4                                                                       },
    
    "Overworld 1":   {"Toad": 1                         , "Mips #1": 4                        , "Mips #2": 5                   },
    "Overworld 2":   {"Reds": 1                         , "On Top of the Building": 2         , "Precise Slopes in the Sky": 3 ,
                      "Wallkicks in the Sky": 4         , "More Precise Slopes": 5            , "Inside the Mountain": 6       },
    "Overworld 3":   {"Horn Toad": 2                    , "Basement Toad": 3                                                   },

    "Triarc-Bridge": {"Reds": 1                         , "Underneath the Pillar": 2          , "Underneath the Path": 3       ,
                      "Hidden in the Chimney": 4        , "Behind the Towers": 5              , "Underneath the Building": 6   ,
                      "Underneath the Grass": 7                                                                                }
}

function just_collected_star(level, star_index) {
    return in_level(level)
           && last_star__mem == star_index
           && (mario_anim_changed_to("star dance ground (exit)")
               || mario_anim_changed_to("star dance ground (no exit)")
               || mario_anim_changed_to("star dance water"))
}

dialog_id__addr = 0x331486
dialog_id__mem = word(dialog_id__addr)
dialog_id__values = {
    "Overworld 1 Ground Level Toad 1": 0x001e,
    "Overworld 1 Ground Level Toad 2": 0x002a,
    "Overworld 1 Ground Level Toad 3": 0x0020,
    "Overworld 1 Ground Level Toad 4": 0x0022,
    "Overworld 1 Ground Level Toad 5": 0x0021,
    "Overworld 1 Upper Level Toad 6":  0x0023,

    "Engage King Bob-omb":    0x0011,
    "Re-engage King Bob-omb": 0x0080,
    "Defeat King Bob-omb":    0x0074,

    "Back Story 1 of 5": 0x0049,
    "Back Story 2 of 5": 0x004a,
    "Back Story 3 of 5": 0x004b,
    "Back Story 4 of 5": 0x004e,
    "Back Story 5 of 5": 0x004d,
    
    "Overworld 3 Basement Toad With Star":    0x0053,
    "Overworld 3 Basement Toad Without Star": 0x009c,
    
    "Veneno-Info 1 of 3": 0x0034,
    "Veneno-Info 2 of 3": 0x0035,
    "Veneno-Info 3 of 3": 0x0036,
    
    "Crudelo-Info 1 of 5": 0x0038,
    "Crudelo-Info 2 of 5": 0x0039,
    "Crudelo-Info 3 of 5": 0x003a,
    "Crudelo-Info 4 of 5": 0x003b,
    "Crudelo-Info 5 of 5": 0x003c,
    "Crudelo-Info 6 of 5": 0x003d,
}

function reading_dialog(name) => dialog_id__mem == dialog_id__values[name]

// ------------- //
//   m a r i o   //
// ------------- //

mario__struct = {
    "hat bitflags":       0x04,  // byte
    "x":                  0x3c,  // dword (float)
    "y":                  0x40,  // dword (float)
    "z":                  0x44,  // dword (float)
    "interaction object": 0x78,  // dword (pointer to object)
    "ridden object":      0x84,  // dword (pointer to object)
    "coins":              0xaa,  // word
    "hp":                 0xac,  // byte / word
    "nof stars (hud)":    0xf6,  // word
}

mario__addr = 0x33b170
stood_on_object__addr = 0x330e34

function mario_field(field) => struct_field(mario__struct, mario__addr, field)

function hat_in_hand()        => bit5(mario_field("hat bitflags"))
function hat_on_head()        => bit4(mario_field("hat bitflags"))
function wearing_wing_cap()   => bit3(mario_field("hat bitflags"))
function wearing_metal_cap()  => bit2(mario_field("hat bitflags"))
function wearing_vanish_cap() => bit1(mario_field("hat bitflags"))

function pos_x() => dword(mario_field("x"))
function pos_y() => dword(mario_field("y"))
function pos_z() => dword(mario_field("z"))

function interaction_object() => tbyte(mario_field("interaction object"))
function ridden_object() => tbyte(mario_field("ridden object"))
function stood_on_object() => tbyte(stood_on_object__addr)

function nof_coins() => word(mario_field("coins"))

function hp_int() => byte(mario_field("hp"))
function just_took_damage() => prev(hp_int()) > hp_int()

function hp() => word(mario_field("hp"))
function respawned() => hp() == 0x0100

function nof_stars() => word(mario_field("nof stars (hud)"))

function in_3d_box(x_min, x_max, y_min, y_max, z_min, z_max) {
    cond = always_true()

    for coord in [[pos_x(), x_min, x_max],
                  [pos_y(), y_min, y_max],
                  [pos_z(), z_min, z_max]] {
        mem = coord[0]
        min = coord[1]
        max = coord[2]

        if (min < 0)
            cond = cond && float_ge_neg(mem, min)
        else if (min > 0)
            cond = cond && float_ge_pos(mem, min)
        else
            cond = cond && not_implemented()
            
        if (max < 0)
            cond = cond && float_le_neg(mem, max)
        else if (max > 0)
            cond = cond && float_le_pos(mem, max)
        else
            cond = cond && not_implemented()
    }
    
    return cond
}

// ----------------- //
//   o b j e c t s   //
// ----------------- //

behaviour_script__values = {
    "blue coin block":        0x800ed6e8,
    "blue coin for block":    0x800ed708,
    "koopa shell":            0x800ed0bc,
    "power star 1":           0x800eefbc,
    "box (shell)":            0x800ed3d0,
    "hidden cork box":        0x800ec63c,
    "big boo":                0x800ed8e8,
    "king whomp":             0x800edd38,
    "secret star spawner":    0x800ef07c,
    "thwomp":                 0x800ebd48,
    "file select background": 0x8008fd10
}

function object_is_active(addr) => word(object_field(addr, "active")) == 0x0101
function object_was_active(addr) => prev(word(object_field(addr, "active"))) == 0x0101
function object_just_deactivated(addr) => object_was_active(addr) && !object_active(addr)

function object_is(addr, name) => dword(object_field(addr, "behaviour script")) == behaviour_script__values[name]

// object specific
function object_power_star_index(addr)     => byte(object_field(addr, "power star index"))
function object_cork_box_is_tangible(addr) => byte(object_field(addr, "cork box tangible"))
function object_block_is_open(addr)        => byte(object_field(addr, "block state")) > 2
function object_big_boo_hp(addr)           => dword(object_field(addr, "big boo hp"))
function object_king_whomp_attacking(addr) => byte(object_field(addr, "king whomp attacking"))
function object_spawner_num_secrets(addr)  => dword(object_field(addr, "spawner num secrets"))

// --------------------------- //
//   o b j e c t   a r r a y   //
// --------------------------- //

object_array__addr = 0x33d488

function nth_array_object(index) => object_array__addr + (index * object__sizeof)

function array_object_index_is(obj_addr, index) => ((obj_addr - object_array__addr) / object__sizeof) == index

function array_object_is_active(index) => object_is_active(nth_array_object(index))
function array_object_was_active(index) => object_was_active(nth_array_object(index))
function array_object_just_deactivated(index) => array_object_was_active(index) && !array_object_is_active(index)

function array_object_is(index, name) => object_is(nth_array_object(index), name)

function array_object_cork_box_is_tangible(index) => object_cork_box_is_tangible(nth_array_object(index))
function array_object_block_is_open(index)        => object_block_is_open(nth_array_object(index))
function array_object_big_boo_hp(index)           => object_big_boo_hp(nth_array_object(index))
function array_object_king_whomp_attacking(index) => object_king_whomp_attacking(nth_array_object(index))
function array_object_spawner_num_secrets(index)  => object_spawner_num_secrets(nth_array_object(index))

object_indexes = {
    "Course 1":  { "Shell Box": 29 },
    "Course 2":  { "Hidden Slanted Cork Boxes": [42, 43] },
    "Course 3":  { "Metal Cap Block": 57 },
    "Course 4":  { "Big Boo": 55 },
    "Course 6":  { "Thwomps": [46, 47, 48] },
    "Course 7":  { "King Whomp": 62 },
    "Course 10": { "Hidden Cork Boxes": [51, 52],
                   "Secret Star Spawner": 59 },
    "Slide":     { "Hidden Cork Boxes": [14, 15, 16, 17] }
}

// ----------------------- //
//   b l u e   c o i n s   //
// ----------------------- //

// values are [<index of block, [<index of coin>, ...]]
blue_coin_indexes = {
    "Course 1":  [ 8, range( 5,  7)],
    "Course 2":  [21, range(15, 20)],
    "Course 3":  [27, range(22, 26)],
    "Course 4":  [39, range(33, 38)],
    "Course 5":  [ 5, range( 3,  4)],
    "Course 6":  [12, range( 2, 11)],
    "Course 7":  [13, range( 8, 12)],
    "Course 8":  [22, range(19, 21)],
    "Course 9":  [30, range(26, 29)],
    "Course 10": [16, range(12, 15)],
    "Course 11": [35, range(30, 34)],
    "Course 12": [14, range(11, 13)],
    "Course 13": [29, range(21, 28)],
    "Course 14": [34, range(28, 33)]
}

// --------------------------- //
//   i n t e r a c t i o n s   //
// --------------------------- //

function collecting_star_object(index) {
    obj = interaction_object()
    return obj != 0
           && object_is(obj, "power star 1")
           && object_power_star_index(obj) == index
}

function was_riding_shell() => prev(ridden_object()) != 0 && object_is(prev(ridden_object()), "koopa shell")
function riding_shell() => ridden_object() != 0 && object_is(ridden_object(), "koopa shell")


// =========================== //
//                             //
//   A C H I E V E M E N T S   //
//                             //
// =========================== //

// --------------------------- //
//   c o u r s e   s t a r s   //
// --------------------------- //

function stars_meta(points, ids, badge_ids) => { "points": points, "ids": ids, "badge_ids": badge_ids }

course_stars_meta = {
    "Course 1":  stars_meta([ 2,  2,  2,  2,   3,   2,  5], range(117547, 117553), range(127351, 127357)),
    "Course 2":  stars_meta([ 2,  5,  2,  2,   2,  10, 10], range(117554, 117560), range(127358, 127364)),
    "Course 3":  stars_meta([ 4,  5,  2,  2,  10,   2, 50], range(117561, 117567), range(127365, 127371)),
    "Course 4":  stars_meta([ 2,  2,  3,  5,   4,   2, 25], range(117568, 117574), range(127372, 127378)),
    "Course 5":  stars_meta([ 5,  3,  3,  4,   5,  10, 10], range(117575, 117581), range(127379, 127385)),
    "Course 6":  stars_meta([ 2,  4,  2,  5,   3,  10, 10], range(117582, 117588), range(127386, 127392)),
    "Course 7":  stars_meta([ 5, 10, 10, 10,   4,   2, 25], range(117589, 117595), range(127393, 127399)),
    "Course 8":  stars_meta([ 5, 10,  5, 10,   3,   5, 25], range(117596, 117602), range(127400, 127406)),
    "Course 9":  stars_meta([ 4, 10, 10, 10,   5,   5, 10], range(117603, 117609), range(127407, 127413)),
    "Course 10": stars_meta([10, 10,  2,  1,   3,  10, 10], range(117610, 117616), range(127414, 127420)),
    "Course 11": stars_meta([ 2, 10,  5,  5,  10,  10, 50], range(117617, 117623), range(127421, 127427)),
    "Course 12": stars_meta([ 4, 10,  4, 10,  25,  10, 50], range(117624, 117630), range(127428, 127434)),
    "Course 13": stars_meta([ 5,  5,  5,  2,  10,   5, 10], range(117631, 117637), range(127435, 127441)),
    "Course 14": stars_meta([10, 10, 10, 50,  50, 100, 25], range(117638, 117644), range(127442, 127448)),
    "Course 15": stars_meta([25, 25, 25, 50,  50, 100, 50], range(117645, 117651), range(127449, 127455))
}

function course_star_achievement(course_index, star_index) {
    level_id = format("Course {0}", course_index)
    level_name = level_names[level_id]

    if (star_index == 7) {
        id = course_stars_meta[level_id]["ids"][6]
        badge_id = format("{0}", course_stars_meta[level_id]["badge_ids"][6])
        title = format("{0} 100 Coins", level_name)
        description = format("Collect the 100 coin star in {0}", level_name)
    } else {
        id = course_stars_meta[level_id]["ids"][star_index - 1]
        badge_id = format("{0}", course_stars_meta[level_id]["badge_ids"][star_index - 1])
        star_name = star_names[level_id][star_index - 1]
        title = star_name
        description = format("Collect star '{0}' in {1}", star_name, level_name)
    }

    achievement(
        id = id,
        badge=badge_id,
        title=title,
        description=description,
        points=course_stars_meta[level_id]["points"][star_index - 1],
        trigger=just_collected_star(level_id, star_index)
    )
}

for course_index in range(1, 15)
    for star_index in range(1, 7)
        course_star_achievement(course_index, star_index)

// ----------------------------------- //
//   n o n - c o u r s e   s t a r s   //
// ----------------------------------- //

non_course_stars_meta = {
    "Slide":         stars_meta([ 2,  2, 10, 10            ], range(117652, 117655), range(127456, 127459)),
    "Metal Cap":     stars_meta([ 3,  2,  2,  2,  4, 25    ], range(117656, 117661), range(127460, 127465)),
    "Vanish Cap":    stars_meta([10,  5,  2, 10,  4, 25    ], range(117662, 117667), range(127466, 127471)),
    "Wing Cap":      stars_meta([ 1,  3,  5                ], range(117668, 117670), range(127472, 127474)),
    "Bowser 1":      stars_meta([ 3,  1,  5, 10,           ], range(117671, 117674), range(127475, 127478)),
    "Bowser 2":      stars_meta([ 2, 10, 10,  5, 50, 10,  5], range(117675, 117681), range(127479, 127485)),
    "Bowser 3":      stars_meta([ 5, 10,  5, 50,           ], range(117682, 117685), range(127486, 127489)),
    "Overworld 1":   stars_meta([ 1,  1,  1                ], range(117686, 117688), range(127490, 127492)),
    "Overworld 2":   stars_meta([ 4,  3,  4,  5,  1,  5    ], range(117689, 117694), range(127493, 127498)),
    "Overworld 3":   stars_meta([ 1,  1                    ], range(117695, 117696), range(127499, 127500)),
    "Triarc-Bridge": stars_meta([ 5,  5,  5,  5,  5,  5,  2], range(117697, 117703), range(127501, 127507))
}

function non_course_star_achievements(level_id, star_cheevos) {
    level_name = level_names[level_id]
    i = 0
    for star_cheevo in star_cheevos {
        star_name = star_cheevo[0]
        star_index = star_indexes[level_id][star_name]
        title = format(star_cheevo[1], level_name)
        description = format(star_cheevo[2], level_name)
        if (level_id == "Bowser 2") {
            id = non_course_stars_meta[level_id]["ids"][star_index - 1]
            badge_id = format("{0}", non_course_stars_meta[level_id]["badge_ids"][star_index - 1])
            points = non_course_stars_meta[level_id]["points"][star_index - 1]
        } else {
            id = non_course_stars_meta[level_id]["ids"][i]
            badge_id = format("{0}", non_course_stars_meta[level_id]["badge_ids"][i])
            points = non_course_stars_meta[level_id]["points"][i]
        }
        i = i + 1

        achievement(
            id=id,
            badge=badge_id,
            title=title,
            description=description,
            points=points,
            trigger=just_collected_star(level_id, star_index)
        )
    }
}

non_course_star_achievements("Slide", [
    ["Bottom of the Slide", "Slide Along"            , "Collect the star at the bottom of {0}"],
    ["Hidden Star"        , "Not Part of the Scenery", "Collect the hidden star in {0}"       ],
    ["Skippable Blocks"   , "Walled Off"             , "Collect the star behind a wall in {0}"],
    ["Reds"               , "{0} Reds"               , "Collect the red coin star in {0}"     ]
])

non_course_star_achievements("Metal Cap", [
    ["Thin Poles"   , "Double the Punishment", "Collect the star past the thin poles in {0}"    ],
    ["Toxic Stairs" , "Toxic Stairs"         , "Collect the star at the top of the stair in {0}"],
    ["Hidden Star"  , "Amongst the Sludge"   , "Collect the hidden star in {0}"                 ],
    ["Skinny Bridge", "Noodle Bridge"        , "Collect the star past a bridge in {0}"          ],
    ["Sloped Skyway", "Sloped Skyway"        , "Collect the star at the top of {0}"             ],
    ["Reds"         , "{0} Reds"             , "Collect the red coin star in {0}"               ]
])

non_course_star_achievements("Vanish Cap", [
    ["Skippable Wall Kick Arches"   , "Wallkick Arches"  , "Collect the star at the top of a bottomless arch in {0}"],
    ["Inside the House"             , "In da House"      , "Collect the star inside the building in {0}"            ],
    ["Underneath the Level"         , "Into the Void"    , "Collect the hidden star in {0}"                         ],
    ["Atop the Mesh-Work"           , "Atop the Meshwork", "Collect the star behind the cobwebs in {0}"             ],
    ["Straight Long-Jump from Above", "Leap of Faith"    , "Collect the star hidden behind a facade in {0}"         ],
    ["Reds"                         , "{0} Reds"         , "Collect the red coin star in {0}"                       ]
])

non_course_star_achievements("Wing Cap", [
    ["Hidden Star"    , "Submerged"      , "Collect the hidden star in {0}"  ],
    ["High in the Sky", "High in the Sky", "Collect the highest star in {0}" ],
    ["Reds"           , "{0} Reds"       , "Collect the red coin star in {0}"]
])

non_course_star_achievements("Bowser 1", [
    ["Annoying Wallkicks"        , "Tight Climb"   , "Collect the star on top of the spawn building in {0}"],
    ["Very Well Hidden Star"     , "Out of Bounds" , "Collect the hidden star in {0}"                      ],
    ["Corner of the Big Building", "Cornered !-Box", "Collect the star stuck in a corner in {0}"           ],
    ["Reds"                      , "{0} Reds"      , "Collect the red coin star in {0}"                    ]
])

non_course_star_achievements("Bowser 2", [
    ["Hidden in the Window"           , "Star Robbery"           , "Collect the hidden star in {0}"                    ],
    ["Shell-Climb to the Mountain Top", "Shell Climber"          , "Collect the star on the mountain in {0}"           ],
    ["Wallkicks Will Work 2.0"        , "Wall Kicks Will Work EE", "Collect the star in a pit in {0}"                  ],
    ["Stupid Boxes"                   , "Box Madness"            , "Collect the star past a box obstacle course in {0}"],
    ["Reds"                           , "{0} Reds"               , "Collect the red coin star in {0}"                  ]
])

// Bowser 3 stars that are placed in Bower 2's level
non_course_star_achievements("Bowser 2", [
    ["Left Path" , "Ztar's Left Path" , format("Collect the star on the left path of {0}", level_names["Bowser 3"])],
    ["Right Path", "Ztar's Right Path", format("Collect the star on the right path of {0}", level_names["Bowser 3"])]
])

non_course_star_achievements("Bowser 3", [
    ["Tiny Burning Platforms"       , "Tiny Burning Platforms", "Collect the star past some tiny platforms in {0}"],
    ["Underneath the Level"         , "Right Above Hell"      , "Collect the star underneath the level in {0}"    ],
    ["Back Through the Cannon Holes", "Cannonless"            , "Collect the star in the cannon tunnel of {0}"    ],
    ["Reds"                         , "{0} Reds"              , "Collect the red coin star in {0}"                ]
])

non_course_star_achievements("Overworld 1", [
    ["Toad"   , "Lava Toad"       , "Collect the star in possession of a Toad in the first overworld"           ],
    ["Mips #1", "Long Time No See", "Collect the star in possession of a familiar rabbit in the first overworld"],
    ["Mips #2", "Deja Vu"         , "Collect the star... haven't I done this before?"                           ]
])

non_course_star_achievements("Overworld 2", [
    ["On Top of the Building"   , "Between Two Horns"    , "Collect the star on top of a horned building in {0}"],
    ["Precise Slopes in the Sky", "Slopes in the Sky"    , "Collect the walled off star in {0}"                 ],
    ["Wallkicks in the Sky"     , "Wall Kicks in the Sky", "Collect the star in the sky of {0}"                 ],
    ["More Precise Slopes"      , "Sloped Triple Jumps"  , "Collect the star past a triple jump obstacle in {0}"],
    ["Inside the Mountain"      , "Lake Secret"          , "Collect the hidden star in {0}"                     ],
    ["Reds"                     , "{0} Reds"             , "Collect the red coin star in {0}"                   ]
])

non_course_star_achievements("Overworld 3", [
    ["Horn Toad"    , "Roof Toad"    , "Collect the star held by a high-born Toad in the third overworld"],
    ["Basement Toad", "Basement Toad", "Collect the star held by a low-born Toad in the third overwold"  ]
])

non_course_star_achievements("Triarc-Bridge", [
    ["Underneath the Pillar"  , "Triarc Secret #1", "Collect the first hidden star in {0}" ],
    ["Underneath the Path"    , "Triarc Secret #2", "Collect the second hidden star in {0}"],
    ["Hidden in the Chimney"  , "Triarc Secret #3", "Collect the third hidden star in {0}" ],
    ["Behind the Towers"      , "Triarc Secret #4", "Collect the fourth hidden star in {0}"],
    ["Underneath the Building", "Triarc Secret #5", "Collect the fifth hidden star in {0}" ],
    ["Underneath the Grass"   , "Triarc Secret #6", "Collect the sixth hidden star in {0}" ],
    ["Reds"                   , "{0} Reds"        , "Collect the red coin star in {0}"     ]
])


// ------------------------------- //
//   b o w s e r   b a t t l e s   //
// ------------------------------- //

achievement(
    id=117704,
    badge="127508",
    title="Bowser Meh Edition",
    description=format("Defeat Bowser in {0} and obtain the key to the second overworld", level_names["Bowser 1"]),
    points=5,
    trigger=(
        in_level("Battle 1")
        && mario_anim_is("star dance ground (exit)")
    )
)

achievement(
    id=117705,
    badge="127509",
    title="Bowser Lukewarm Edition",
    description=format("Defeat Bowser in {0} and obtain the key to the third overworld", level_names["Bowser 2"]),
    points=5,
    trigger=(
        in_level("Battle 2")
        && mario_anim_is("star dance ground (exit)")
    )
)

achievement(
    id=117706,
    badge="127510",
    title="Bowser Extreme Edition",
    description=format("Defeat Bowser in {0} and collect the final star", level_names["Bowser 3"]),
    points=25,
    trigger=(
        in_level("Battle 3")
        && wearing_wing_cap() == 1
    )
)


// ----------------------- //
//   b l u e   c o i n s   //
// ----------------------- //

blue_coins_ids = range(117707, 117720)
blue_coins_points = [3, 4, 10, 5, 10, 4, 10, 5, 5, 3, 10, 10, 5, 25]

function blue_coin_achievement(course_index) {
    course_id = format("Course {0}", course_index)
    course_name = level_names[course_id]
    coin_indexes = blue_coin_indexes[course_id][1]

    // a coin is considered collected when it deactivates on the same frame that mario's
    // number of collected coins increases by 5 or more. this is not a perfect solution,
    // but given the context it's extremely unlikely to be exploitable
    coins_cond = always_true()
    for coin_index in coin_indexes {
        coins_cond = coins_cond && once(
            array_object_is(coin_index, "blue coin for block")
            && array_object_just_deactivated(coin_index)
            && (nof_coins() - prev(nof_coins())) >= 5
        )
    }
    
    if (course_index < 8) {
        badge_id = 127511 + course_index - 1
    } else {
        badge_id = 127511 + course_index
    }
    
    achievement(
        id=blue_coins_ids[course_index - 1],
        badge=format("{0}", badge_id),
        title=format("{0} Blues", course_name),
        description=format("Collect every switch blue coin in {0}", course_name),
        points=blue_coins_points[course_index - 1],
        trigger=(
            never(!in_level(course_id))
            && coins_cond
        )
    )
}

for course_index in range(1, 14)
    blue_coin_achievement(course_index)


// --------------------------------- //
//   s t a r   c h a l l e n g e s   //
// --------------------------------- //

achievement(
    id=117721,
    badge="127526",
    title="What the Shell?!",
    description=format("Collect star '{0}' in {1} while riding the shell",
                       star_names["Course 1"][0], level_names["Course 1"]),
    points=3,
    trigger=in_level("Course 1")
            && collecting_star_object(0)
            && was_riding_shell()
)

achievement(
    id=117722,
    badge="127527",
    title="Not So Fundamental Tunnel Problems",
    description=format("Collect star '{0}' in {1} without using the shell",
                       star_names["Course 1"][3], level_names["Course 1"]),
    points=3,
    trigger=just_collected_star("Course 1", 4)
            && array_object_is(object_indexes["Course 1"]["Shell Box"], "box (shell)")
            && array_object_is_active(object_indexes["Course 1"]["Shell Box"])
)

function intended_parcour_trigger() {
    boxes = object_indexes["Course 2"]["Hidden Slanted Cork Boxes"]

    touched_boxes_cond = always_true()
    for box in boxes
        touched_boxes_cond = touched_boxes_cond
            && once(stood_on_object() != 0 && array_object_index_is(stood_on_object(), box))

    return (
        // must touch both hidden boxes before collecting the star
        touched_boxes_cond
        && just_collected_star("Course 2", 5)
        
        // reset if not in course 2
        && never(!in_level("Course 2"))

        // reset if the boxes are reactivated
        && never(array_object_is(boxes[0], "hidden cork box")
                 && array_object_is_active(boxes[0])
                 && just_changed(array_object_cork_box_is_tangible(boxes[0]), 0, 1))

        // reset if on the upper level from which the star can be obtained without using the boxes
        && never(float_ge_neg(pos_y(), 0xc3ed8000)) // -475
    )
}

achievement(
    id=117723,
    badge="127528",
    title="Intended Parcour",
    description=format("Collect star '{0}' in {1} using the hidden cork boxes",
                       star_names["Course 2"][4], level_names["Course 2"]),
    points=10,
    trigger=intended_parcour_trigger()
)

achievement(
    id=117724,
    badge="127529",
    title="Small Pillar Mastery",
    description=format("Collect star '{0}' in {1} without taking damage",
                       star_names["Course 3"][1], level_names["Course 3"]),
    points=10,
    trigger=once(just_entered_level("Course 3"))
            && never(!in_level("Course 3"))
            && never(just_took_damage())
            && just_collected_star("Course 3", 2)
)

achievement(
    id=117725,
    badge="127530",
    title="Ok Experience",
    description=format("Collect star '{0}' in {1} without using the Metal Cap",
                       star_names["Course 3"][5], level_names["Course 3"]),
    points=5,
    trigger=once(just_entered_level("Course 3"))
            && never(!in_level("Course 3"))
            && never(wearing_metal_cap() == 1)
            && just_collected_star("Course 3", 6)
)

function boo_trigger() {
    boo = object_indexes["Course 4"]["Big Boo"]
    return (
        never(!in_level("Course 4"))

        // saw big boo at max hp
        && once(array_object_is(boo, "big boo")
                && array_object_is_active(boo)
                && array_object_big_boo_hp(boo) == 3)

        // big boo always damaged whilst mario was long jumping
        && never(array_object_is(boo, "big boo")
                 && array_object_is_active(boo)
                 && prev(array_object_big_boo_hp(boo)) > array_object_big_boo_hp(boo)
                 && !mario_anim_is("long jump"))

        // big boo is kill
        && array_object_is(boo, "big boo")
        && array_object_is_active(boo)
        && just_changed(array_object_big_boo_hp(boo), 1, 0)
    )
}

achievement(
    id=117726,
    badge="127531",
    title="The Long Jump Is My Favorite Attack",
    description=format("Defeat Big Boo in {0} using long jumps only", level_names["Course 4"]),
    points=2,
    trigger=boo_trigger()
)

achievement(
    id=117727,
    badge="127532",
    title="You're a Plumber, Mario!",
    description=format("Collect star '{0}' in {1} by going through the sewer",
                       star_names["Course 4"][1], level_names["Course 4"]),
    points=4,
    trigger=(
        never(!in_level("Course 4"))
        // was at the sewer entrance
        && once(in_3d_box(0xc57a0000, 0xc53b8000,   // -4000, -3000
                          0xc42f0000, 0xc2c80000,   //  -700,  -100
                          0x45034000, 0x45480000))  //  2100,  3200
        // was at the bottom of the sewer exit
        && once(in_3d_box(0xc5802000, 0xc5228000,   // -4100, -2600
                          0xc4af0000, 0xc4960000,   // -1400, -1200
                          0x459f6000, 0x45c4e000))  //  5100,  6300
        // was at the sewer exit
        && once(in_3d_box(0xc5802000, 0xc5228000,   // -4100, -2600
                          0x44a8c000, 0x45002000,   //  1350,  2050
                          0x459f6000, 0x45c4e000))  //  5100,  6300
        // and collected the star
        && just_collected_star("Course 4", 2)
    )
)

achievement(
    id=117728,
    badge="127533",
    title="Transoceanic Flight",
    description=format("Collect star '{0}' in {1} without using the Metal Cap",
                       star_names["Course 5"][4], level_names["Course 5"]),
    points=5,
    trigger=once(just_entered_level("Course 5"))
            && never(!in_level("Course 5"))
            && never(wearing_metal_cap() == 1)
            && just_collected_star("Course 5", 5)
)

function thwomp_allergies_trigger() {
    thwomps_cond = always_true()
    for thwomp_idx in object_indexes["Course 6"]["Thwomps"] {
        thwomps_cond = thwomps_cond && never(
            stood_on_object() != 0
            && array_object_index_is(stood_on_object(), thwomp_idx)
            && object_is(stood_on_object(), "thwomp")
            && object_is_active(stood_on_object())
        )
    }

    return (
        never(!in_level("Course 6"))
        && once(just_entered_level("Course 6"))
        && thwomps_cond
        && just_collected_star("Course 6", 3)
    )
}

achievement(
    id=117729,
    badge="127534",
    title="Thwomp Allergies",
    description=format("Collect star '{0}' in {1} without standing on any of the Thwomps",
                       star_names["Course 6"][2], level_names["Course 6"]),
    points=5,
    trigger=thwomp_allergies_trigger()
)

achievement(
    id=117730,
    badge="127535",
    title="Really, Dance With the Heave-Hos",
    description=format("Collect star '{0}' in {1} the intended way, making your way across the pillars",
                       star_names["Course 6"][4], level_names["Course 6"]),
    points=10,
    trigger=(
        never(!in_level("Course 6"))

        // was on the balcony before the first pillar
        && once(in_3d_box(0x43af0000, 0x44834000,   //  350, 1050
                          0x4533b000, 0x4536d000,   // 2875, 2925
                          0x44160000, 0x45098000))  //  600, 2200

        // reset if mario is close to the ground below the pillars
        && never(float_le_pos(pos_y(), 0x44160000))  // 600

        && just_collected_star("Course 6", 5)
    )
)

achievement(
    id=117731,
    badge="127536",
    title="Precision Landing",
    description=format("Collect star '{0}' in {1} by using a Spindrift",
                       star_names["Course 7"][4], level_names["Course 7"]),
    points=5,
    trigger=(
        never(!in_level("Course 7"))

        // was twirling in the vicinity of the enclave with the star
        && once(
            in_3d_box(0x43af0000, 0x44034000,  //   350,   525
                      0xc49c4000, 0xc3af0000,  // -1250,  -350
                      0xc592e000, 0xc58a4800)  // -4700, -4425
            && mario_anim_is("twirl")
        )

        // reset if mario goes too far below the enclave (only was to exit)
        && never(float_le_neg(pos_y(), 0xc49c4000))

        && just_collected_star("Course 7", 5)
    )
)

function king_whomp_trigger() {
    king_whomp = object_indexes["Course 7"]["King Whomp"]
    return (
        in_level("Course 7")

        // king whomp isn't attacking (meaning it can only be ground pounded on the head)
        && array_object_is(king_whomp, "king whomp")
        && array_object_is_active(king_whomp)
        && array_object_king_whomp_attacking(king_whomp) == 0

        // mario is standing on king whomp and finished a ground pound
        && stood_on_object() != 0
        && array_object_index_is(stood_on_object(), object_indexes["Course 7"]["King Whomp"])
        && mario_anim_is("ground pound landing")
    )
}

achievement(
    id=117732,
    badge="127537",
    title="That's Not How You Do It!",
    description=format("Ground Pound King Whomp's head in {0}", level_names["Course 7"]),
    points=2,
    trigger=king_whomp_trigger()
)

achievement(
    id=117733,
    badge="127538",
    title="Always Wear Your Hard Hat",
    description=format("Collect star '{0}' in {1} whilst wearing the Metal Cap",
                       star_names["Course 8"][0], level_names["Course 8"]),
    points=10,
    trigger=(
        in_level("Course 8")
        && collecting_star_object(0)
        && prev(wearing_metal_cap()) == 1
    )
)

achievement(
    id=117734,
    badge="127539",
    title="Stand Your Ground",
    description=format("Defeat King Bob-omb in {0} without leaving his anti-plumber platform", level_names["Course 9"]),
    points=5,
    trigger=(
        never(!in_level("Course 9"))
        && once(reading_dialog("Engage King Bob-omb"))
        && never(float_le_pos(pos_y(), 0x437a0000))  // 250
        && reading_dialog("Defeat King Bob-omb")
    )
)

achievement(
    id=117735,
    badge="127540",
    title="Perfect Tightrope Jumping",
    description=format("Collect star '{0}' in {1} without taking damage",
                       star_names["Course 9"][4], level_names["Course 9"]),
    points=10,
    trigger=(
        never(!in_level("Course 9"))
        && once(just_entered_level("Course 9"))
        && never(just_took_damage())
        && just_collected_star("Course 9", 5)
    )
)

function pole_dancing_trigger() {
    spawner = object_indexes["Course 10"]["Secret Star Spawner"]
    return (
        never(!in_level("Course 10"))

        // remember the first collected secret
        && once(
            array_object_is(spawner, "secret star spawner")
            && array_object_is_active(spawner)
            && just_changed(array_object_spawner_num_secrets(spawner), 0, 1)
        )

        // reset if mario gets too close to the ground
        && never(float_le_neg(pos_y(), 0xc3af0000))  // -350

        // trigger when the last secret is collected
        && array_object_is(spawner, "secret star spawner")
        && array_object_is_active(spawner)
        && just_changed(array_object_spawner_num_secrets(spawner), 4, 5)
    )
}

achievement(
    id=117737,
    badge="127541",
    title="Pole Dancing Champion",
    description=format("Collect every secret in {0} without falling off the poles", level_names["Course 10"]),
    points=10,
    trigger=pole_dancing_trigger()
)

function butt_sliding_trigger() {
    box = object_indexes["Course 10"]["Hidden Cork Boxes"][0]
    return (
        never(!in_level("Course 10"))
        && once(just_entered_level("Course 10"))

        // reset if the boxes ever become tangible
        && never(array_object_is(box, "hidden cork box")
                 && array_object_is_active(box)
                 && just_changed(array_object_cork_box_is_tangible(box), 0, 1))

        && just_collected_star("Course 10", 3)
    )
}

achievement(
    id=117739,
    badge="127542",
    title="Butt Sliding",
    description=format("Collect star '{0}' in {1} without using the !-switch box",
                       star_names["Course 10"][2], level_names["Course 10"]),
    points=5,
    trigger=butt_sliding_trigger()
)

achievement(
    id=117740,
    badge="127543",
    title="Mandatory Torture",
    description=format("Collect star '{0}' in {1} the intended way, by wall kicking through all 3 arches",
                       star_names["Course 11"][5], level_names["Course 11"]),
    points=10,
    trigger=(
        never(!in_level("Course 11"))

        // was at the first arch
        && once(in_3d_box(0xc46d8000, 0xc3660000,   //  -950,  -230
                          0x44af0000, 0x454e4000,   //  1400,  3300
                          0xc4bb8000, 0xc4548000))  // -1500,  -850

        // was at the second arch
        && once(in_3d_box(0xc4d70000, 0xc46d8000,   // -1720,  -950
                          0x44af0000, 0x454e4000,   //  1400,  3300
                          0xc4bb8000, 0xc4548000))  // -1500,  -850

        // was at the third arch
        && once(in_3d_box(0xc517e000, 0xc4d70000,   // -2430, -1720
                          0x44af0000, 0x454e4000,   //  1400,  3300
                          0xc4bb8000, 0xc4548000))  // -1500,  -850

        // reset if below the quicksand platform
        && never(float_le_pos(pos_y(), 0x44a8c000))  // 1400

        && just_collected_star("Course 11", 6)
    )
)

function scaling_the_wall_trigger() {
    box = object_indexes["Slide"]["Hidden Cork Boxes"][0]
    return (
        never(!in_level("Slide"))
        && once(just_entered_level("Slide"))

        // reset if the boxes ever become tangible
        && never(array_object_is(box, "hidden cork box")
                 && array_object_is_active(box)
                 && just_changed(array_object_cork_box_is_tangible(box), 0, 1))

        && just_collected_star("Slide", star_indexes["Slide"]["Skippable Blocks"])
    )
}

achievement(
    id=117742,
    badge="127545",
    title="Scaling the Wall",
    description=format("Collect the star behind a wall in {0} without using the !-switch boxes", level_names["Slide"]),
    points=10,
    trigger=scaling_the_wall_trigger()
)

achievement(
    id=117743,
    badge="127544",
    title="A Different Kind of Cannonless",
    description=format("Collect the red coin star in {0} without using the cannon", level_names["Wing Cap"]),
    points=5,
    trigger=(
        never(!in_level("Wing Cap"))
        && once(just_entered_level("Wing Cap"))
        && never(mario_anim_is("in cannon"))
        && just_collected_star("Wing Cap", star_indexes["Wing Cap"]["Reds"])
    )
)

achievement(
    id=117745,
    badge="127546",
    title="A Trip Through Chuckya Tunnel",
    description=format("Collect the hidden star in {0} by going through the Chuckya Tunnel", level_names["Bowser 2"]),
    points=10,
    trigger=(
        never(!in_level("Bowser 2"))

        // was at the chokehold where mario climbs into the platforms
        && once(in_3d_box(0x45066000, 0x453b8000,    //  2150,  3000
                          0x454b2000, 0x45b09000,    //  3250,  5650
                          0xc5cb2000, 0xc5b3b000))   // -6500, -5750

        // was at the platform with the last chukya
        && once(in_3d_box(0x4581b000, 0x45915000,    //  4150,  4650
                          0x45aa5000, 0x45ad7000,    //  5450,  5550
                          0xc584d000, 0xc56a6000))   // -4250, -3750

        // reset if mario leaves the tunnel from the entrance
        && never(in_3d_box(0x42480000, 0x44480000,   //    50,   800
                           0x45642000, 0x458b1000,   //  3640,  4450
                           0xc5cb2000, 0xc5b54000))  // -6500, -5800

        && just_collected_star("Bowser 2", star_indexes["Bowser 2"]["Hidden in the Window"])
    )
)

achievement(
    id=117747,
    badge="127547",
    title="WC Stands for Wall Cick",
    description=format("Speak to basement Toad in the third overworld without using the Wing Cap"),
    points=5,
    trigger=(
        never(!in_level("Overworld 3"))

        // entered the level _or_ respawned after dying in it
        && tally(1, [
            just_entered_level("Overworld 3"),
            respawned()
        ])

        // reset if mario's in the tunnel with the wing cap
        && never(
            in_3d_box(0x44548000, 0x44ce4000,  // same box
                      0xc49c4000, 0xc4228000,
                      0x453b8000, 0x45947000)
            && wearing_wing_cap() == 1
        )

        // trigger when talking to the toad
        && (
            reading_dialog("Overworld 3 Basement Toad With Star")
            || reading_dialog("Overworld 3 Basement Toad Without Star")
        )
    )
)


// ----------------------------- //
//   m i s c e l l a n e o u s   //
// ----------------------------- //

achievement(
    id=117748,
    badge="127548",
    title="I'll Take Every Tip You Have",
    description="Speak to the five angry Toads reachable at the start of the game without leaving the first overworld",
    points=1,
    trigger=(
        never(!in_level("Overworld 1"))
        && once(reading_dialog("Overworld 1 Ground Level Toad 1"))
        && once(reading_dialog("Overworld 1 Ground Level Toad 2"))
        && once(reading_dialog("Overworld 1 Ground Level Toad 3"))
        && once(reading_dialog("Overworld 1 Ground Level Toad 4"))
        && once(reading_dialog("Overworld 1 Ground Level Toad 5"))
    )
)

achievement(
    id=117750,
    badge="127549",
    title="Extreme Lore",
    description="Read all backstory signs without leaving the third overworld",
    points=1,
    trigger=(
        never(!in_level("Overworld 3"))
        && once(reading_dialog("Back Story 1 of 5"))
        && once(reading_dialog("Back Story 2 of 5"))
        && once(reading_dialog("Back Story 3 of 5"))
        && once(reading_dialog("Back Story 4 of 5"))
        && once(reading_dialog("Back Story 5 of 5"))
    )
)

achievement(
    id=117751,
    badge="127550",
    title="Veneno Taunts",
    description=format("Read the 3 Veneno-Info signs in {0} without exiting the course", level_names["Course 14"]),
    points=10,
    trigger=(
        never(!in_level("Course 14"))
        && once(reading_dialog("Veneno-Info 1 of 3"))
        && once(reading_dialog("Veneno-Info 2 of 3"))
        && once(reading_dialog("Veneno-Info 3 of 3"))
    )
)

achievement(
    id=117752,
    badge="127551",
    title="Crudelo Taunts",
    description=format("Read the 5 Crudelo-Info signs in {0} without exiting the course", level_names["Course 15"]),
    points=10,
    trigger=(
        never(!in_level("Course 15"))
        && once(reading_dialog("Crudelo-Info 1 of 5"))
        && once(reading_dialog("Crudelo-Info 2 of 5"))
        && once(reading_dialog("Crudelo-Info 3 of 5"))
        && once(reading_dialog("Crudelo-Info 4 of 5"))
        && once(reading_dialog("Crudelo-Info 5 of 5"))
    )
)

achievement(
    id=117753,
    badge="127552",
    title="You Shouldn't Be Here",
    description=format("Read the impossible sign in {0}", level_names["Course 15"]),
    points=50,
    trigger=(
        in_level("Course 15")
        && reading_dialog("Crudelo-Info 6 of 5")
    )
)


// ============================= //
//                               //
//   R I C H   P R E S E N C E   //
//                               //
// ============================= //


function in_game() {
    // We're in-game when:
    //   - the first object in the object array is active (excludes title and mario screens)
    //   - that object is not the file select background (excludes the file select screen)
    //   - and we're not in a demo
    // Since it's impossible to get out of the game without resetting, once the conditions
    // are met we're always in-game (a hit is stored without a corresponding reset)
    return once(
        array_object_is_active(0)
        && !array_object_is(0, "file select background")
        && !in_demo())
}

bowser__lookup = rich_presence_lookup("Bowser", level_id__mem, {
    0x1e: "Bowser's Beautiful Backyard",
    0x21: "Bowser's Quicksand Pit",
    0x22: "Ztar Zanctuary"
}, "an unknown location")

rich_presence_conditional_display(
    in_game() && (in_level("Battle 1") || in_level("Battle 2") || in_level("Battle 3")),
    "Mario is spinning Bowser in {0}", bowser__lookup
)

level__lookup = rich_presence_lookup("Level", level_id__mem, {
    0x1a: "the first overworld",
    0x1f: "the Lake of the Lords",
    0x06: "the third overworld",
    0x10: "Castle Grounds",
    0x09: "Devil's Dice",
    0x18: "Virusvine Veranda",
    0x0c: "Deepred Depths",
    0x05: "System of a Downtown",
    0x04: "Drowned Factory",
    0x07: "Infernopit Cave",
    0x16: "Melting Icecrystal-Tower",
    0x08: "Overgrown Oasis",
    0x17: "Fireflower Fields",
    0x0a: "Breezing Beach",
    0x0b: "Dried-Out Dead Desert",
    0x24: "Cliff of Pain",
    0x0d: "Acid Peaks",
    0x0e: "Veneno Sphere",
    0x0f: "Crudelo Sphere",
    0x14: "Triarc-Bridge",
    0x1b: "Old Supply Slide",
    0x11: "Bowser's Beautiful Backyard",
    0x13: "Bowser's Quicksand Pit",
    0x15: "Ztar Zanctuary",
    0x1d: "Devil's Pit",
    0x1c: "Toxic Terrace",
    0x12: "Dust Destination"
}, "an unknown location")

stars__value = rich_presence_value("Stars", nof_stars())

plural__lookup = rich_presence_lookup("Plural", nof_stars(), {1: ""}, "s")

rich_presence_conditional_display(
    in_game(),
    "Mario is dragging himself through {0} with {1} star{2}", level__lookup, stars__value, plural__lookup
)

rich_presence_display("Mario is getting ready for a hellish adventure")

