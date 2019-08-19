// Pokemon Stadium
// #ID = 10181
// md5 = ed1378bc12115f71209a77844965ba50

charmap = {
    "eol": 0x00,
    "\n":  0x0a,
    " ":   0x20,
    "!":   0x21,
    "'":   0x27,
    "(":   0x28,
    ")":   0x29,
    "*":   0x2a,
    "+":   0x2b,
    ",":   0x2c,
    "-":   0x2d,
    ".":   0x2e,
    "/":   0x2f,
    "0":   0x30,
    "1":   0x31,
    "2":   0x32,
    "3":   0x33,
    "4":   0x34,
    "5":   0x35,
    "6":   0x36,
    "7":   0x37,
    "8":   0x38,
    "9":   0x39,
    ":":   0x3a,
    ";":   0x3b,
    "=":   0x3d,
    "?":   0x3f,
    "A":   0x41,
    "B":   0x42,
    "C":   0x43,
    "D":   0x44,
    "E":   0x45,
    "F":   0x46,
    "G":   0x47,
    "H":   0x48,
    "I":   0x49,
    "J":   0x4a,
    "K":   0x4b,
    "L":   0x4c,
    "M":   0x4d,
    "N":   0x4e,
    "O":   0x4f,
    "P":   0x50,
    "Q":   0x51,
    "R":   0x52,
    "S":   0x53,
    "T":   0x54,
    "U":   0x55,
    "V":   0x56,
    "W":   0x57,
    "X":   0x58,
    "Y":   0x59,
    "Z":   0x5a,
    "[":   0x5b,
    "]":   0x5d,
    "a":   0x61,
    "b":   0x62,
    "c":   0x63,
    "d":   0x64,
    "e":   0x65,
    "f":   0x66,
    "g":   0x67,
    "h":   0x68,
    "i":   0x69,
    "j":   0x6a,
    "k":   0x6b,
    "l":   0x6c,
    "m":   0x6d,
    "n":   0x6e,
    "o":   0x6f,
    "p":   0x70,
    "q":   0x71,
    "r":   0x72,
    "s":   0x73,
    "t":   0x74,
    "u":   0x75,
    "v":   0x76,
    "w":   0x77,
    "x":   0x78,
    "y":   0x79,
    "z":   0x7a,
    "¡":   0xa1,
    "pk$": 0xa5,
    "♂":   0xa9,
    "ª":   0xaa,
    "·":   0xb7,
    "º":   0xba,
    "pk":  0xbc,
    "mn":  0xbd,
    "♀":   0xbe,
    "¿":   0xbf,
    "À":   0xc0,
    "Á":   0xc1,
    "Â":   0xc2,
    "Ä":   0xc4,
    "Ç":   0xc7,
    "È":   0xc8,
    "É":   0xc9,
    "Ê":   0xca,
    "Ë":   0xcb,
    "Ì":   0xcc,
    "Í":   0xcd,
    "Î":   0xce,
    "Ï":   0xcf,
    "Ñ":   0xd1,
    "Ò":   0xd2,
    "Ó":   0xd3,
    "Ô":   0xd4,
    "Ö":   0xd6,
    "×":   0xd7,
    "Ù":   0xd9,
    "Ú":   0xda,
    "Û":   0xdb,
    "Ü":   0xdc,
    "ß":   0xdf,
    "à":   0xe0,
    "á":   0xe1,
    "â":   0xe2,
    "ä":   0xe4,
    "ç":   0xe7,
    "è":   0xe8,
    "é":   0xe9,
    "ê":   0xea,
    "ë":   0xeb,
    "ì":   0xec,
    "í":   0xed,
    "î":   0xee,
    "ï":   0xef,
    "ñ":   0xf1,
    "ò":   0xf2,
    "ó":   0xf3,
    "ô":   0xf4,
    "ö":   0xf6,
    "ù":   0xf9,
    "ú":   0xfa,
    "û":   0xfb,
    "ü":   0xfc
}

function text_char(base_addr, index) {
    return byte(base_addr + ((index / 4) * 4) + (3 - (index % 4)))
}

function text_starts_with(addr, text) {
    // text is layed-out in memory in 4 character groups. the groups are
    // ordered in relation to each other, but the characters in each group
    // are in reverse order
    // ex: the memory layout for "Hello World!" is "lleHoW o!dlr"
    cond = always_true()
    index = 0
    for chr in text {
        cond = cond && text_char(addr, index) == charmap[chr]
        index = index + 1
    }
    return cond
}

function text_started_with(addr, text) {
    cond = always_true()
    index = 0
    for chr in text {
        cond = cond && prev(text_char(addr, index)) == charmap[chr]
        index = index + 1
    }
    return cond
}

function text_used_to_start_with(addr, text) {
    // in the previous frame, all characters match
    prev_cond = always_true()
    index = 0
    for chr in text {    
        prev_cond = prev_cond && prev(text_char(addr, index)) == charmap[chr]
        index = index + 1
    }
    // in the current frame, at least one character does not
    cond = always_false()
    index = 0
    for chr in text {
        cond = cond || text_char(addr, index) != charmap[chr]
        index = index + 1
    }
    return prev_cond && cond
}

trainer = {
    "Trainer":    0x01,
    "Brock":      0x02,
    "Misty":      0x03,
    "Surge":      0x04,
    "Erika":      0x05,
    "Koga":       0x06,
    "Sabrina":    0x07,
    "Blaine":     0x08,
    "Giovani":    0x09,
    "Lorelei":    0x0a,
    "Bruno":      0x0b,
    "Agatha":     0x0c,
    "Lance":      0x0d,
    "Rival":      0x0e,
    "Bug Boy":    0x0f,
    "Lass":       0x10,
    "Lad":        0x11,
    "JR♂":        0x12,
    "JR♀":        0x13,
    "Nerd":       0x14,
    "Pkmniac":    0x15,
    "Beauty":     0x16,
    "Cool♂":      0x17,
    "Cool♀":      0x18,
    "Hiker":      0x19,
    "Medium":     0x1a,
    "Sailor":     0x1b,
    "Old Man":    0x1c,
    "Fisher":     0x1d,
    "Lab Man":    0x1e,
    "Burglar":    0x1f,
    "Birdboy":    0x20,
    "Judoboy":    0x21,
    "Gambler":    0x22,
    "Juggler":    0x23,
    "Rocker":     0x24,
    "Mr.Fix":     0x25,
    "Biker":      0x26,
    "Cueball":    0x27,
    "Swimmer":    0x28,
    "Tamer":      0x29,
    "Psychic":    0x2a,
    "Rocket":     0x2b,
    "Mewtwo":     0x34,
    "Trainer ×2": 0x35
}

pokemon = {
    "Bulbasaur":         0x01,
    "Ivysaur":           0x02,
    "Venusaur":          0x03,
    "Charmander":        0x04,
    "Charmeleon":        0x05,
    "Charizard":         0x06,
    "Squirtle":          0x07,
    "Wartortle":         0x08,
    "Blastoise":         0x09,
    "Caterpie":          0x0a,
    "Metapod":           0x0b,
    "Butterfree":        0x0c,
    "Weedle":            0x0d,
    "Kakuna":            0x0e,
    "Beedrill":          0x0f,
    "Pidgey":            0x10,
    "Pidgeotto":         0x11,
    "Pidgeot":           0x12,
    "Rattata":           0x13,
    "Raticate":          0x14,
    "Spearow":           0x15,
    "Fearow":            0x16,
    "Ekans":             0x17,
    "Arbok":             0x18,
    "Pikachu":           0x19,
    "Raichu":            0x1a,
    "Sandshrew":         0x1b,
    "Sandslash":         0x1c,
    "Nidoran♀":          0x1d,
    "Nidorina":          0x1e,
    "Nidoqueen":         0x1f,
    "Nidoran♂":          0x20,
    "Nidorino":          0x21,
    "Nidoking":          0x22,
    "Clefairy":          0x23,
    "Clefable":          0x24,
    "Vulpix":            0x25,
    "Ninetales":         0x26,
    "Jigglypuff":        0x27,
    "Wigglytuff":        0x28,
    "Zubat":             0x29,
    "Golbat":            0x2a,
    "Oddish":            0x2b,
    "Gloom":             0x2c,
    "Vileplume":         0x2d,
    "Paras":             0x2e,
    "Parasect":          0x2f,
    "Venonat":           0x30,
    "Venomoth":          0x31,
    "Diglett":           0x32,
    "Dugtrio":           0x33,
    "Meowth":            0x34,
    "Persian":           0x35,
    "Psyduck":           0x36,
    "Golduck":           0x37,
    "Mankey":            0x38,
    "Primeape":          0x39,
    "Growlithe":         0x3a,
    "Arcanine":          0x3b,
    "Poliwag":           0x3c,
    "Poliwhirl":         0x3d,
    "Poliwrath":         0x3e,
    "Abra":              0x3f,
    "Kadabra":           0x40,
    "Alakazam":          0x41,
    "Machop":            0x42,
    "Machoke":           0x43,
    "Machamp":           0x44,
    "Bellsprout":        0x45,
    "Weepinbell":        0x46,
    "Victreebel":        0x47,
    "Tentacool":         0x48,
    "Tentacruel":        0x49,
    "Geodude":           0x4a,
    "Graveler":          0x4b,
    "Golem":             0x4c,
    "Ponyta":            0x4d,
    "Rapidash":          0x4e,
    "Slowpoke":          0x4f,
    "Slowbro":           0x50,
    "Magnemite":         0x51,
    "Magneton":          0x52,
    "Farfetch'd":        0x53,
    "Doduo":             0x54,
    "Dodrio":            0x55,
    "Seel":              0x56,
    "Dewgong":           0x57,
    "Grimer":            0x58,
    "Muk":               0x59,
    "Shellder":          0x5a,
    "Cloyster":          0x5b,
    "Gastly":            0x5c,
    "Haunter":           0x5d,
    "Gengar":            0x5e,
    "Onix":              0x5f,
    "Drowzee":           0x60,
    "Hypno":             0x61,
    "Krabby":            0x62,
    "Kingler":           0x63,
    "Voltorb":           0x64,
    "Electrode":         0x65,
    "Exeggcute":         0x66,
    "Exeggutor":         0x67,
    "Cubone":            0x68,
    "Marowak":           0x69,
    "Hitmonlee":         0x6a,
    "Hitmonchan":        0x6b,
    "Lickitung":         0x6c,
    "Koffing":           0x6d,
    "Weezing":           0x6e,
    "Rhyhorn":           0x6f,
    "Rhydon":            0x70,
    "Chansey":           0x71,
    "Tangela":           0x72,
    "Kangaskhan":        0x73,
    "Horsea":            0x74,
    "Seadra":            0x75,
    "Goldeen":           0x76,
    "Seaking":           0x77,
    "Staryu":            0x78,
    "Starmie":           0x79,
    "Mr. Mime":          0x7a,
    "Scyther":           0x7b,
    "Jynx":              0x7c,
    "Electabuzz":        0x7d,
    "Magmar":            0x7e,
    "Pinsir":            0x7f,
    "Tauros":            0x80,
    "Magikarp":          0x81,
    "Gyarados":          0x82,
    "Lapras":            0x83,
    "Ditto":             0x84,
    "Eevee":             0x85,
    "Vaporeon":          0x86,
    "Jolteon":           0x87,
    "Flareon":           0x88,
    "Porygon":           0x89,
    "Omanyte":           0x8a,
    "Omastar":           0x8b,
    "Kabuto":            0x8c,
    "Kabutops":          0x8d,
    "Aerodactyl":        0x8e,
    "Snorlax":           0x8f,
    "Articuno":          0x90,
    "Zapdos":            0x91,
    "Moltres":           0x92,
    "Dratini":           0x93,
    "Dragonair":         0x94,
    "Dragonite":         0x95,
    "Mewtwo":            0x96,
    "Mew":               0x97,
    "Substitute":        0x98,
    "Pikachu (Yellow)":  0x99
}

move = {
    "Pound":         0x01,
    "Karate Chop":   0x02,
    "Doubleslap":    0x03,
    "Comet Punch":   0x04,
    "Mega Punch":    0x05,
    "Pay Day":       0x06,
    "Fire Punch":    0x07,
    "Ice Punch":     0x08,
    "Thunderpunch":  0x09,
    "Scratch":       0x0a,
    "Vicegrip":      0x0b,
    "Guillotine":    0x0c,
    "Razor Wind":    0x0d,
    "Swords Dance":  0x0e,
    "Cut":           0x0f,
    "Gust":          0x10,
    "Wing Attack":   0x11,
    "Whirlwind":     0x12,
    "Fly":           0x13,
    "Bind":          0x14,
    "Slam":          0x15,
    "Vine Whip":     0x16,
    "Stomp":         0x17,
    "Double Kick":   0x18,
    "Mega Kick":     0x19,
    "Jump Kick":     0x1a,
    "Rolling Kick":  0x1b,
    "Sand-Attack":   0x1c,
    "Headbutt":      0x1d,
    "Horn Attack":   0x1e,
    "Fury Attack":   0x1f,
    "Horn Drill":    0x20,
    "Tackle":        0x21,
    "Body Slam":     0x22,
    "Wrap":          0x23,
    "Take Down":     0x24,
    "Thrash":        0x25,
    "Double-Edge":   0x26,
    "Tail Whip":     0x27,
    "Poison Sting":  0x28,
    "Twineedle":     0x29,
    "Pin Missile":   0x2a,
    "Leer":          0x2b,
    "Bite":          0x2c,
    "Growl":         0x2d,
    "Roar":          0x2e,
    "Sing":          0x2f,
    "Supersonic":    0x30,
    "Sonicboom":     0x31,
    "Disable":       0x32,
    "Acid":          0x33,
    "Ember":         0x34,
    "Flamethrower":  0x35,
    "Mist":          0x36,
    "Water Gun":     0x37,
    "Hydro Pump":    0x38,
    "Surf":          0x39,
    "Ice Beam":      0x3a,
    "Blizzard":      0x3b,
    "Psybeam":       0x3c,
    "Bubblebeam":    0x3d,
    "Aurora Beam":   0x3e,
    "Hyper Beam":    0x3f,
    "Peck":          0x40,
    "Drill Peck":    0x41,
    "Submission":    0x42,
    "Low Kick":      0x43,
    "Counter":       0x44,
    "Seismic Toss":  0x45,
    "Strength":      0x46,
    "Absorb":        0x47,
    "Mega Drain":    0x48,
    "Leech Seed":    0x49,
    "Growth":        0x4a,
    "Razor Leaf":    0x4b,
    "Solarbeam":     0x4c,
    "Poisonpowder":  0x4d,
    "Stun Spore":    0x4e,
    "Sleep Powder":  0x4f,
    "Petal Dance":   0x50,
    "String Shot":   0x51,
    "Dragon Rage":   0x52,
    "Fire Spin":     0x53,
    "Thundershock":  0x54,
    "Thunderbolt":   0x55,
    "Thunder Wave":  0x56,
    "Thunder":       0x57,
    "Rock Throw":    0x58,
    "Earthquake":    0x59,
    "Fissure":       0x5a,
    "Dig":           0x5b,
    "Toxic":         0x5c,
    "Confusion":     0x5d,
    "Psychic":       0x5e,
    "Hypnosis":      0x5f,
    "Meditate":      0x60,
    "Agility":       0x61,
    "Quick Attack":  0x62,
    "Rage":          0x63,
    "Teleport":      0x64,
    "Night Shade":   0x65,
    "Mimic":         0x66,
    "Screech":       0x67,
    "Double Team":   0x68,
    "Recover":       0x69,
    "Harden":        0x6a,
    "Minimize":      0x6b,
    "Smokescreen":   0x6c,
    "Confuse Ray":   0x6d,
    "Withdraw":      0x6e,
    "Defense Curl":  0x6f,
    "Barrier":       0x70,
    "Light Screen":  0x71,
    "Haze":          0x72,
    "Reflect":       0x73,
    "Focus Energy":  0x74,
    "Bide":          0x75,
    "Metronome":     0x76,
    "Mirror Move":   0x77,
    "Selfdestruct":  0x78,
    "Egg Bomb":      0x79,
    "Lick":          0x7a,
    "Smog":          0x7b,
    "Sludge":        0x7c,
    "Bone Club":     0x7d,
    "Fire Blast":    0x7e,
    "Waterfall":     0x7f,
    "Clamp":         0x80,
    "Swift":         0x81,
    "Skull Bash":    0x82,
    "Spike Cannon":  0x83,
    "Constrict":     0x84,
    "Amnesia":       0x85,
    "Kinesis":       0x86,
    "Softboiled":    0x87,
    "Hi Jump Kick":  0x88,
    "Glare":         0x89,
    "Dream Eater":   0x8a,
    "Poison Gas":    0x8b,
    "Barrage":       0x8c,
    "Leech Life":    0x8d,
    "Lovely Kiss":   0x8e,
    "Sky Attack":    0x8f,
    "Transform":     0x90,
    "Bubble":        0x91,
    "Dizzy Punch":   0x92,
    "Spore":         0x93,
    "Flash":         0x94,
    "Psywave":       0x95,
    "Splash":        0x96,
    "Acid Armor":    0x97,
    "Crabhammer":    0x98,
    "Explosion":     0x99,
    "Fury Swipes":   0x9a,
    "Bonemerang":    0x9b,
    "Rest":          0x9c,
    "Rock Slide":    0x9d,
    "Hyper Fang":    0x9e,
    "Sharpen":       0x9f,
    "Conversion":    0xa0,
    "Tri Attack":    0xa1,
    "Super Fang":    0xa2,
    "Slash":         0xa3,
    "Substitute":    0xa4,
    "Struggle":      0xa5
}

// pokemon struct:
pokemon_struct_offset = {
    "hp":         0x00,  // word
    "id":         0x03,  // byte
    "type_2":     0x05,  // byte
    "type_1":     0x04,  // byte
    "level":      0x07,  // byte
    "move_3_id":  0x08,  // byte
    "move_2_id":  0x09,  // byte
    "move_1_id":  0x0a,  // byte
    "trainer_id": 0x0c,  // word
    "move_4_id":  0x0f,  // byte
    "pp_left":    0x20,  // byte
    "pp_down":    0x21,  // byte
    "pp_right":   0x22,  // byte
    "pp_up":      0x23   // byte
}
pokemon_struct_sizeof = 0x54

function pk_array_field_addr(arr_base_addr, arr_index, field_name) {
    return arr_base_addr + pokemon_struct_offset[field_name] + (arr_index * pokemon_struct_sizeof)
}

// P1's 6-pokemon team
p1_6_team_arr_addr = 0x0aeddc

function p1_6_team_pk_trainer_id(pk_index) => word(pk_array_field_addr(p1_6_team_arr_addr, pk_index, "trainer_id"))
function p1_6_team_pk_id(pk_index) => byte(pk_array_field_addr(p1_6_team_arr_addr, pk_index, "id"))

function p1_6_team_all_rentals() {
    cond = always_true()
    for pk_index in range(0, 5) {
        cond = cond && p1_6_team_pk_trainer_id(pk_index) == 0
    }
    return cond
}

// P1's 3-pokemon team
p1_3_team_arr_addr = 0x0ae560

function p1_3_team_pk_hp(pk_index) => word(pk_array_field_addr(p1_3_team_arr_addr, pk_index, "hp"))
function p1_3_team_pk_trainer_id(pk_index) => word(pk_array_field_addr(p1_3_team_arr_addr, pk_index, "trainer_id"))

function p1_3_team_pk_fainted(pk_index) => p1_3_team_pk_hp(pk_index) == 0
function p1_3_team_none_fainted() {
    cond = always_true()
    for pk_index in range(0, 2) {
        cond = cond && !p1_3_team_pk_fainted(pk_index)
    }
    return cond
}
function p1_3_team_all_fainted() {
    cond = always_true()
    for pk_index in range(0, 2) {
        cond = cond && p1_3_team_pk_fainted(pk_index)
    }
    return cond
}
function p1_3_team_no_rentals() {
    cond = always_true()
    for pk_index in range(0, 2) {
        cond = cond && p1_3_team_pk_trainer_id(pk_index) != 0
    }
    return cond
}

// P2's 3-pokemon team
p2_3_team_arr_addr = 0x0ae77c

function p2_3_team_pk_hp(pk_index) => word(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "hp"))
function p2_3_team_pk_id(pk_index) => byte(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "id"))
function p2_3_team_pk_pp_left(pk_index) => byte(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "pp_left"))
function p2_3_team_pk_pp_down(pk_index) => byte(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "pp_down"))
function p2_3_team_pk_pp_right(pk_index) => byte(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "pp_right"))
function p2_3_team_pk_pp_up(pk_index) => byte(pk_array_field_addr(p2_3_team_arr_addr, pk_index, "pp_up"))

function p2_3_team_pk_fainted(pk_index) => p2_3_team_pk_hp(pk_index) == 0
function p2_3_team_all_fainted() {
    cond = always_true()
    for pk_index in range(0, 2) {
        cond = cond && p2_3_team_pk_fainted(pk_index)
    }
    return cond
}

// battle state
function turn_player_ptr() {
    // dunno what this points to, but it can be used distinguish whose turn it is
    return dword(0x104c00)
}
function is_p1_turn() => turn_player_ptr() == 0x8033b0e0
function is_p2_turn() => turn_player_ptr() == 0x802e7040
function was_p1_turn() => prev(turn_player_ptr()) == 0x8033b0e0
function was_p2_turn() => prev(turn_player_ptr()) == 0x802e7040

function win_flag() => byte(0x0af6f3)
function entered_battle_result_screen() => prev(byte(0x079017)) == 0 && byte(0x079017) == 1
function battle_is_won() {
    // win_flag changes right after the battle fades away
    return win_flag() == 1
}
function battle_is_lost() {
    // win_flag remains at 0 throughout the battle, so we need an extra
    // check to ensure this triggers only when the battle fades away
    return win_flag() == 0
           && entered_battle_result_screen()
}

function trainer_id() => byte(0x0ae779)
function fighting_by_id(trainer_name) => trainer_id() == trainer[trainer_name]
function fighting_someone() => trainer_id() != 0

function trainer_position() => byte(0x0ae540)
function fighting_by_position(position) => trainer_position() == position

function p1_current_pk() => byte(0x0af6d4)
function p1_current_pk_is(pk_name) => p1_current_pk() == pokemon[pk_name]

function p2_current_pk() => byte(0x0af6fc)
function p2_current_pk_is(pk_name) => p2_current_pk() == pokemon[pk_name]

function p2_pk1_current_move() => byte(0x1e8e7f)
function p2_pk2_current_move() => byte(0x1e8ef1)
function p2_pk3_current_move() => byte(0x1e8f6b)
function p2_pk1_current_move_is(move_name) => p2_pk1_current_move() == move[move_name]
function p2_pk2_current_move_is(move_name) => p2_pk2_current_move() == move[move_name]
function p2_pk3_current_move_is(move_name) => p2_pk3_current_move() == move[move_name]

function p2_early_current_move_is(move_name) {
    // changes when turn starts
    return byte(0x288645) == move[move_name]
}
function p2_late_current_move_is(move_name) {
    // changes when move starts
    return byte(0x288633) == move[move_name]
}

function p2_current_pk_hp() => byte(0x2885fa)  // changes when turn starts

p2_current_pk_hp_text_addr = 0x0816b0
function p2_current_hp_text_char(index) => text_char(p2_current_pk_hp_text_addr, index)
function p2_current_hp_text_is_zero() {
    return text_starts_with(p2_current_pk_hp_text_addr, [" "," ","0","/"])
}
function p2_current_hp_text_was_one() {
    return text_started_with(p2_current_pk_hp_text_addr, [" "," ","1","/"])
}
function p2_current_hp_just_turned_zero() {
    return p2_current_hp_text_is_zero()
        && (
            (prev(p2_current_hp_text_char(1)) == charmap[" "] && prev(p2_current_hp_text_char(2)) != charmap["0"])
            || (prev(p2_current_hp_text_char(1)) != charmap[" "] && prev(p2_current_hp_text_char(2)) == charmap["0"])
        )
}

function p2_current_pk_has_no_pp_left() {
    cond = always_false()
    for pk_index in range(0, 2) {
        cond = cond || (p2_current_pk() == p2_3_team_pk_id(pk_index)
                        && p2_3_team_pk_pp_left(pk_index) == 0
                        && p2_3_team_pk_pp_down(pk_index) == 0
                        && p2_3_team_pk_pp_right(pk_index) == 0
                        && p2_3_team_pk_pp_up(pk_index) == 0)
    }
    return cond
}

// game state

cup_difficulty = {
    "Poke Ball":   0x00,
    "Great Ball":  0x01,
    "Ultra Ball":  0x02,
    "Master Ball": 0x03
}
function cup_difficulty() => byte(0x0ae541)
function in_cup_difficulty(difficulty_name) => cup_difficulty() == cup_difficulty[difficulty_name]

gym = {
    "Pewter":     0x00,
    "Cerulean":   0x01,
    "Vermilion":  0x02,
    "Celadon":    0x03,
    "Fuchsia":    0x04,
    "Saffron":    0x05,
    "Cinnabar":   0x06,
    "Viridian":   0x07,
    "Elite Four": 0x08,
    "Rival":      0x09
}
function gym_id() => byte(0x0ae541)  // same as cup difficulty
function in_gym(gym_name) => gym_id() == gym[gym_name]

rules = {
    "Anything Goes":     0x00,
    "Poke Cup":          0x03,
    "Petit Cup":         0x04,
    "Pika Cup":          0x05,
    "Prime Cup":         0x06,
    "Gym Leader Castle": 0x07
}
function rules_id() => byte(0x0ae542)

mode = {
    "Free Battle":                      0x00,
    "Poke Cup":                         0x03,
    "Petit Cup":                        0x04,
    "Pika Cup":                         0x05,
    "Prime Cup":                        0x06,
    "Gym Leader Castle":                0x07,
    "Mewtwo":                           0x08,
    "Battle Now":                       0x09,
    "Battle Demo":                      0x10,  // ??
    "Victory Lap":                      0x11,
    "Uninitialized":                    0x12,
    "GLC Pokemon Prize":                0x15,
    "Mewtwo Animation":                 0x18,
    "Minigame Demo":                    0x19,  // ??
    "Victory Palace Pokemon Prize":     0x1a
}
function mode_id() => byte(0x0ae543)
function in_mode(mode_name) => mode_id() == mode[mode_name]

mode2 = {
    "Game Start":        0x01,
    "Title Screen":      0x02,
    "Select Screen":     0x04,
    "Plaza":             0x10,
    "Gallery":           0x11,
    "Options":           0x13,
    "Stadium":           0x20,
    "Free Battle":       0x21,
    "Mewtwo":            0x22,
    "Kids Club":         0x23,
    "Victory Palace":    0x24,
    "Pokemon Lab":       0x25,
    "GB Tower":          0x26,
    "Gym Leader Castle": 0x27,
    "Battle Now 1P":     0x28,
    "Battle Now 2P":     0x29
}
function mode2_id() => byte(0x75668)
function in_mode2(mode_name) => mode2_id() == mode2[mode_name]

round = {
    1: 0x00,
    2: 0x01
}
function round_val() => byte(0x0af731)
function in_round(round_n) => round_val() == round[round_n]

function continues() => byte(0x0af730)
function have_continues(n) => continues() == n

cup_select_opt = {
    "Prime Cup": 0x01,
    "Pika Cup":  0x02,
    "Petit Cup": 0x03,
    "Poke Cup":  0x05
}
function stadium_cup_select_option_val() => byte(0x8144c)
function stadium_cup_selected_option(opt_name) {
    return stadium_cup_select_option_val() == cup_select_opt[opt_name]
}

// pokemon prize

function prize_pk_id() => byte(0x1dc098)
function prize_pk_is(pk_name) => prize_pk_id() == pokemon[pk_name]

function prize_pk_trigger_moment() {
    // no clue what this is, but it changes from 1 to 0 when the congratulations
    // song starts playing, so it's good as a moment to trigger achievements
    flag = byte(0xb5224)
    return prev(flag) == 0x01 && flag == 0x00
}

// It's a pain to find addresses for surfing pikachu stuff, because:
//   - the known "mode" flags do not have specific values for the surfing pikachu sequence
//   - cannot use normal savestates, since they don't work with the transfer pak active
//   - cannot save-and-quit before the last battle, since the game will not give you
//     surfing pikachu if you start from a save
// The only way I managed was to create savestates at the various stages of the surfing
// pikachu sequence. If we load a savestate and pause right away, it's possible
// to briefly look at the memory before the game complains about the transfer pak.
// Used two such sequences of savestates to identify which addresses are fixed and which
// are dynamic.

function surfing_pikachu_trigger_moment() {
    // "Take good care of PIKACHU" text appears in the last screen when pikachu gets
    // its surf board, which is the perfect time to trigger. Luckily the text always
    // appears in the same address.
    // Found other possible triggers, but I trust the text more because it's visible
    // on screen.
    text_addr = 0x816b0
    return text_starts_with(text_addr, ["T","a","k","e"," ","g","o","o","d"," ","c","a","r","e"," ","o","f"])
}

// hall of fame

function hall_of_fame_n_pk() {
    // only active when in the hall of fame
    return byte(0x1930d8)
}

function victory_lap_pk_id() => byte(0x1d64e4)

hofame_pokemon_struct_offset = {
    "cup":          0x00,  // byte (same value as "mode" + 0x80 if round 2)
    "level":        0x01,  // byte
    "trainer_id":   0x02,  // word
    "nickname":     0x04,  // string[10] (subtract 0x3F to get ascii, terminated by 0x50)
    "trainer_name": 0x0F,  // string[7]  (subtract 0x3F to get ascii, terminated by 0x50)
}
hofame_pokemon_struct_sizeof = 26

function hofame_byte(hof_addr, pk_index, field_name) {
    return byte(hof_addr + (pk_index * hofame_pokemon_struct_sizeof) + hofame_pokemon_struct_offset[field_name])
}

hofame_addr = 0x13c064
post_win_hofame_addr = 0x13ffe4
hofame_next_section_addr = 0x13cfb8

function hofame_pk_level(pk_index) => hofame_byte(hofame_addr, pk_index, "level")

function hofame_in_memory() {
    // the hall-of-fame data lives in SRAM, but shows up in memory sometimes, such as
    // before and after battles.
    // we can check for a fixed pattern that preceeds the hall-of-fame section in SRAM.
    // if the pattern's there, then the hall-of-fame data is in memory! or is it?
    // turns out that SRAM does not get loaded into memory in a single frame, so just
    // checking for a preceeding pattern can lead us to think the hall-of-fame is in
    // memory when it's only partially there. to bypass this issue, we also check for
    // a subsequent pattern. even if the SRAM is not completely loaded into memory yet,
    // we can be sure that the hall-of-fame part of it is already there is full.
    return byte(hofame_addr - 12) == charmap["O"]
        && byte(hofame_addr - 11) == charmap["P"]
        && byte(hofame_addr -  6) == charmap["E"]
        && byte(hofame_addr -  5) == charmap["K"]
        && byte(hofame_addr -  2) == 0x00
        && byte(hofame_addr -  1) == 0x01
        && byte(hofame_next_section_addr) == charmap["O"]
        && byte(hofame_next_section_addr + 1) == charmap["P"]
        && byte(hofame_next_section_addr + 6) == charmap["E"]
        && byte(hofame_next_section_addr + 7) == charmap["K"]
        
}

function hofame_was_in_memory() {
    return prev(byte(hofame_addr - 12)) == charmap["O"]
        && prev(byte(hofame_addr - 11)) == charmap["P"]
        && prev(byte(hofame_addr -  6)) == charmap["E"]
        && prev(byte(hofame_addr -  5)) == charmap["K"]
        && prev(byte(hofame_addr -  2)) == 0x00
        && prev(byte(hofame_addr -  1)) == 0x01
        && prev(byte(hofame_next_section_addr)) == charmap["O"]
        && prev(byte(hofame_next_section_addr + 1)) == charmap["P"]
        && prev(byte(hofame_next_section_addr + 6)) == charmap["E"]
        && prev(byte(hofame_next_section_addr + 7)) == charmap["K"]
}

function hofame_total_was_lt(n) {
    // count one hit per registered pokemon, reset if we get n hits
    // hits cannot be accumulated for more than one frame
    cond = prev(hofame_pk_level(0)) != 0x00
    for pk_index in range(1, 150) {
        cond = cond || prev(hofame_pk_level(pk_index)) != 0x00
    }
    return never(repeated(n, cond))
}

function hofame_total_is_ge(n) {
    // count one hit per registered pokemon, trigger if we reach n hits
    // hits cannot be accumulated for more than one frame
    cond = hofame_pk_level(0) != 0x00
    for pk_index in range(1, 150) {
        cond = cond || hofame_pk_level(pk_index) != 0x00
    }
    return repeated(n, cond)
}

function reset_if_hofame_did_not_change() {
    cond = prev(hofame_pk_level(0)) == hofame_pk_level(0)
    for pk_index in range(1, 150) {
        cond = cond || prev(hofame_pk_level(pk_index)) == hofame_pk_level(pk_index)
    }
    return never(repeated(150, cond))
}

function hofame_pk_just_registered(pk_name) {
    return prev(hofame_pk_level(pokemon[pk_name] - 1)) == 0x00
        && hofame_pk_level(pokemon[pk_name] - 1) != 0x00
}

// pokemon lab

pk_lab_option = {
    "Prize":       0x03,
    "PC":          0x04,
    "Trade":       0x05,
    "Game Select": 0x06,
    "Pokedex":     0x07
}
function pk_lab_option_val() => byte(0x1d5754)
function active_pk_lab_option(option_name) {
    return pk_lab_option_val() == pk_lab_option[option_name]
}

pk_lab_screen = {
    "Lab":            0x000F6320,
    "PC":             0x001149c0,
    "PC > Pokemon":   0x00041470,
    "PC > Items":     0x000fb230,
    "PC > Boxes":     0x00048af0,
    "Game Select":    0x00073550,
    "Prize":          0x00039560,
    "Pokedex":        0x00075f70,
    "Pokedex > Data": 0x00045b20,
    "Pokedex > Area": 0x00068b60
}
function pk_lab_screen_val() => dword(0x0a608c)
function active_pk_lab_screen(screen_name) {
    return pk_lab_screen_val() == pk_lab_screen[screen_name]
}

box_type = {
    "Party": 0x00,
    "GB":    0x01,
    "N64":   0x02
}
function pk_lab_prize_box_type() => byte(0x1d2610)
function pk_lab_prize_box_index() => byte(0x1d2614)
function active_pk_lab_prize_box_type(box_type_name) {
    return pk_lab_prize_box_type() == box_type[box_type_name]
}

function pk_lab_prize_saving() {
    saving_text_addr = 0x801e7ddc
    saving_box_header_text_ptr = dword(0x815f0)
    return saving_box_header_text_ptr == saving_text_addr
}

// gallery

function bonus_flag() => byte(0x11c6f8)
function gallery_bonus_activated() => bonus_flag() == 0x01

button_desc_addr = 0x081670
function gallery_bonus_text_disappeared() {
    return text_used_to_start_with(button_desc_addr, ["C","o","n","g","r","a","t","u","l","a","t","i","o","n","s","!"])
}

// minigames

function minigame_whos_the_best() => byte(0x124638)
function minigame_playing_whos_the_best() => minigame_whos_the_best() == 0x01

minigame_difficulty = {
    "Easy":   0x00,
    "Normal": 0x01,
    "Hard":   0x02,
    "Hyper":  0x03
}
function minigame_difficulty_val() => byte(0x12464a)
function in_minigame_difficulty(difficulty_name) => minigame_difficulty_val() == minigame_difficulty[difficulty_name]

function minigame_hyper_unlocked_flag() => byte(0x12463a)
function minigame_hyper_just_unlocked() {
    return prev(minigame_hyper_unlocked_flag()) == 0x00
        && minigame_hyper_unlocked_flag() == 0x01
}

function minigame_wins_to_champ() => byte(0x124648)
function minigame_p1_wins() => word(0x124652)
function minigame_p2_wins() => word(0x124650)
function minigame_p3_wins() => word(0x124656)
function minigame_p4_wins() => word(0x124654)

function minigame_p1_is_com() => word(0x124642) == 0x0001
function minigame_p2_is_com() => word(0x124640) == 0x0001
function minigame_p3_is_com() => word(0x124646) == 0x0001
function minigame_p4_is_com() => word(0x124644) == 0x0001
function minigame_playing_solo() {
    return !minigame_p1_is_com() && minigame_p2_is_com()
         && minigame_p3_is_com() && minigame_p4_is_com()
}

function minigame_paused() => byte(0x1248a6)
function minigame_is_paused() => minigame_paused() == 0x01

function minigame_p1_won() => byte(0x124a0f) == 0x01
function minigame_p2_won() => byte(0x124a0e) == 0x01
function minigame_p3_won() => byte(0x124a0d) == 0x01
function minigame_p4_won() => byte(0x124a0c) == 0x01

minigame = {
    "Magikarp's Splash": 0x01,
    "Clefairy Says":     0x02,
    "Run, Rattata, Run": 0x03,
    "Snore War":         0x05,
    "Thundering Dynamo": 0x06,
    "Sushi-Go-Round":    0x09,
    "Ekans' Hoop Hurl":  0x0d,
    "Rock Harden":       0x0f,
    "Dig! Dig! Dig!":    0x10
    
}
function minigame_id() => byte(0x81890)
function in_minigame(minigame_name) => minigame_id() == minigame[minigame_name]

function minigame_magikarp_score() => byte(0x18d400)
function minigame_magikarp_score_ge(n) => minigame_magikarp_score() >= n

function minigame_clefairy_hp() => byte(0x18f36a)
function minigame_clefairy_at_max_hp() {
    // hp starts at 100, reduces by 20 per hit
    return minigame_clefairy_hp() == 100
}
function minigame_clefairy_no_hp() => minigame_clefairy_hp() < 20

function minigame_rattata_1p_place() {
    // 0x04 through the minigame
    // changes to 0-indexed placement when 1P crosses the finish line
    return byte(0x18dd00)
}
function minigame_rattata_1p_just_finished() {
    return prev(minigame_rattata_1p_place()) == 0x04
        && minigame_rattata_1p_place() != 0x04
}

function minigame_rattata_barriers_hit() => byte(0x18dcfe)
function minigame_rattata_no_barriers_hit() => minigame_rattata_barriers_hit() == 0

function minigame_drowzee_hp() {
    // starts at 330, goes down to 0. decreases even if no hypnosis miss
    return word(0x18d24a)
}
function minigame_drowzee_hypnosis_state() {
    // 0x0000 when hypnosis succeeds, 0xffff when it fails
    return word(0x1a3236)
}
function minigame_drowzee_missed_hypnosis() => minigame_drowzee_hypnosis_state() == 0xffff
function minigame_drowzee_just_missed_hypnosis() {
    return prev(minigame_drowzee_hypnosis_state()) == 0x0000
        && minigame_drowzee_hypnosis_state() == 0xffff
}

function minigame_sushi_score_immediate() => word(0x196060)
function minigame_sushi_score_end_counter() => word(0x196064)
function minigame_sushi_score_ge(n) => minigame_sushi_score_immediate() >= n

function minigame_ekans_score() => byte(0x1a02c0)
function minigame_ekans_score_ge(n) => minigame_ekans_score() >= n

function minigame_harden_hp() {
    // starts at 400, goes down to 0
    return word(0x193aaa)
}
function minigame_harden_hp_percentage_ge(perc) {
    return minigame_harden_hp() >= (perc * 400) / 100
}

function minigame_timer() {
    // increases by 2 per frame, does not stop when game is paused
    return word(0xb3a95)
}
function minigame_timer_as_frames() {
    return minigame_timer() / 2
}
function minigame_timer_le(tenths_secs) {
    return minigame_timer() <= (tenths_secs * 6 * 2)
}
function minigame_timer_as_millis() {
    return minigame_timer() * (100 / (2 * 60))
}

minigame_mode_val = {
    "in game":               0x00,
    "winner annoucement":    0x01,
    "who's the best state":  0x02,
    "post game choice":      0x03,
    "who chooses next":      0x04,
    "next chooser selected": 0x05,
    "game select":           0x06
}
function minigame_mode() => byte(0x124850)
function in_minigame_mode(mode_name) => minigame_mode() == minigame_mode_val[mode_name]

function minigame_finished_flag() {
    // switches when winner is announced
    return byte(0x124870)
}
function minigame_finished() => minigame_finished_flag() == 0x01

function minigame_countdown() {
    // at 4 in game start screen
    // counts down to 0
    // switches to 0xffff when game starts
    return word(0x1246d2)
}
function minigame_countdown_ended() {
    return prev(minigame_countdown()) == 0x0000
        && minigame_countdown() == 0xffff
}
function minigame_after_countdown() => minigame_countdown() == 0xffff

minigame_not_in_control = 0x8003adb0
function minigame_control_ptr() {
    // 0x8003adb0 after losing control
    // something else otherwise
    return dword(0xaa42c)
}
function minigame_just_lost_control() {
    return prev(minigame_control_ptr()) != minigame_not_in_control
        && minigame_control_ptr() == minigame_not_in_control
}


//=======================================//
//                                       //
//        A C H I E V E M E N T S        //
//                                       //
//=======================================//

// transfer pak

achievement(
    id=79852,
    badge="85913",
    title="Bring Your Pokemon to Work Day",
    description="Win a Stadium or Gym Leader Castle battle using only Pokemon from a Red, Blue or Yellow game",
    points=1,
    trigger=((in_mode2("Gym Leader Castle") && in_mode("Gym Leader Castle"))
             || (in_mode2("Stadium") && (in_mode("Petit Cup") || in_mode("Pika Cup") || in_mode("Poke Cup") || in_mode("Prime Cup"))))
            && fighting_someone()
            && p1_3_team_no_rentals()
            && p2_3_team_all_fainted()
            && battle_is_won()
)

achievement(
    id=79853,
    badge="85918",
    title="Take Me With You",
    description="Transfer a Pokemon from Oak's prize pokeball to a Red, Blue or Yellow game",
    points=1,
    trigger=in_mode2("Pokemon Lab")
            && active_pk_lab_option("Prize")
            && active_pk_lab_screen("Prize")
            && (active_pk_lab_prize_box_type("Party") || active_pk_lab_prize_box_type("GB"))
            && pk_lab_prize_saving()
)

//
// completion achievements

function beat_trainer_by_id_trigger(mode_name, trainer_name, round) {
    return in_mode(mode_name)
           && fighting_by_id(trainer_name)
           && in_round(round)
           && p2_3_team_all_fainted()
           && battle_is_won()
}

// gym leader castle R1 & R2

function castle_ach(trainer_id, round, title, description, points, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=beat_trainer_by_id_trigger("Gym Leader Castle", trainer_id, round)
    )
}

castle_ach("Brock",   1, "Brock",         "Defeat Pewter Gym Leader Brock",       3,  79855, "85847")
castle_ach("Misty",   1, "Misty",         "Defeat Cerulean Gym Leader Misty",     3,  79856, "85849")
castle_ach("Surge",   1, "Surge",         "Defeat Vermilion Gym Leader Surge",    3,  79857, "85851")
castle_ach("Erika",   1, "Erika",         "Defeat Celadon Gym Leader Erika",      3,  79858, "85853")
castle_ach("Koga",    1, "Koga",          "Defeat Fuchsia Gym Leader Koga",       3,  79859, "85855")
castle_ach("Sabrina", 1, "Sabrina",       "Defeat Saffron Gym Leader Sabrina",    3,  79860, "85857")
castle_ach("Blaine",  1, "Blaine",        "Defeat Cinnabar Gym Leader Blaine",    3,  79861, "85859")
castle_ach("Giovani", 1, "Giovani",       "Defeat Viridian Gym Leader Giovani",   3,  79862, "85861")
castle_ach("Rival",   1, "The Very Best", "Defeat the Elite Four and your Rival", 10, 79863, "85863")

castle_ach("Brock",   2, "Brock R-2",         "Defeat Pewter Gym Leader Brock in Round 2",       5,  79876, "85848")
castle_ach("Misty",   2, "Misty R-2",         "Defeat Cerulean Gym Leader Misty in Round 2",     5,  79877, "85850")
castle_ach("Surge",   2, "Surge R-2",         "Defeat Vermilion Gym Leader Surge in Round 2",    5,  79878, "85852")
castle_ach("Erika",   2, "Erika R-2",         "Defeat Celadon Gym Leader Erika in Round 2",      5,  79879, "85854")
castle_ach("Koga",    2, "Koga R-2",          "Defeat Fuchsia Gym Leader Koga in Round 2",       5,  79880, "85856")
castle_ach("Sabrina", 2, "Sabrina R-2",       "Defeat Saffron Gym Leader Sabrina in Round 2",    5,  79881, "85858")
castle_ach("Blaine",  2, "Blaine R-2",        "Defeat Cinnabar Gym Leader Blaine in Round 2",    5,  79882, "85860")
castle_ach("Giovani", 2, "Giovani R-2",       "Defeat Viridian Gym Leader Giovani in Round 2",   5,  79883, "85862")
castle_ach("Rival",   2, "The Very Best R-2", "Defeat the Elite Four and your Rival in Round 2", 25, 79884, "85864")

// cups R1 & R2

function beat_cup_trigger(mode_name, difficulty_name, round) {
    return in_mode(mode_name)
        && in_cup_difficulty(difficulty_name)
        && fighting_by_position(8)
        && in_round(round)
        && p2_3_team_all_fainted()
        && battle_is_won()
}

function cup_ach(mode, difficulty, round, title, description, points, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=beat_cup_trigger(mode, difficulty, round)
    )
}

cup_ach("Petit Cup",  "Poke Ball",   1, "Petit Cup",             "Win the Petit Cup",             10, 79864, "85865")
cup_ach("Pika Cup",   "Poke Ball",   1, "Pika Cup",              "Win the Pika Cup",              10, 79865, "85866")
cup_ach("Poke Cup",   "Poke Ball",   1, "Poke Ball Poke Cup",    "Win the Poke Ball Poke Cup",    5,  79866, "85867")
cup_ach("Poke Cup",   "Great Ball",  1, "Great Ball Poke Cup",   "Win the Great Ball Poke Cup",   5,  79867, "85868")
cup_ach("Poke Cup",   "Ultra Ball",  1, "Ultra Ball Poke Cup",   "Win the Ultra Ball Poke Cup",   5,  79868, "85869")
cup_ach("Poke Cup",   "Master Ball", 1, "Master Ball Poke Cup",  "Win the Master Ball Poke Cup",  10, 79869, "85870")
cup_ach("Prime Cup",  "Poke Ball",   1, "Poke Ball Prime Cup",   "Win the Poke Ball Prime Cup",   5,  79870, "85871")
cup_ach("Prime Cup",  "Great Ball",  1, "Great Ball Prime Cup",  "Win the Great Ball Prime Cup",  5,  79871, "85872")
cup_ach("Prime Cup",  "Ultra Ball",  1, "Ultra Ball Prime Cup",  "Win the Ultra Ball Prime Cup",  5,  79872, "85873")
cup_ach("Prime Cup",  "Master Ball", 1, "Master Ball Prime Cup", "Win the Master Ball Prime Cup", 10, 79873, "85874")

cup_ach("Petit Cup",  "Poke Ball",   2, "Petit Cup R-2",             "Win the Petit Cup in Round 2",             25, 79886, "85875")
cup_ach("Pika Cup",   "Poke Ball",   2, "Pika Cup R-2",              "Win the Pika Cup in Round 2",              25, 79885, "85876")
cup_ach("Poke Cup",   "Poke Ball",   2, "Poke Ball Poke Cup R-2",    "Win the Poke Ball Poke Cup in Round 2",    10, 79887, "85877")
cup_ach("Poke Cup",   "Great Ball",  2, "Great Ball Poke Cup R-2",   "Win the Great Ball Poke Cup in Round 2",   10, 79888, "85878")
cup_ach("Poke Cup",   "Ultra Ball",  2, "Ultra Ball Poke Cup R-2",   "Win the Ultra Ball Poke Cup in Round 2",   10, 79889, "85879")
cup_ach("Poke Cup",   "Master Ball", 2, "Master Ball Poke Cup R-2",  "Win the Master Ball Poke Cup in Round 2",  25, 79890, "85880")
cup_ach("Prime Cup",  "Poke Ball",   2, "Poke Ball Prime Cup R-2",   "Win the Poke Ball Prime Cup in Round 2",   10, 79891, "85881")
cup_ach("Prime Cup",  "Great Ball",  2, "Great Ball Prime Cup R-2",  "Win the Great Ball Prime Cup in Round 2",  10, 79892, "85882")
cup_ach("Prime Cup",  "Ultra Ball",  2, "Ultra Ball Prime Cup R-2",  "Win the Ultra Ball Prime Cup in Round 2",  10, 79893, "85883")
cup_ach("Prime Cup",  "Master Ball", 2, "Master Ball Prime Cup R-2", "Win the Master Ball Prime Cup in Round 2", 25, 79894, "85884")

// mewtwo

function mewtwo_trigger(round) {
    return in_mode("Mewtwo")
           && fighting_by_id("Mewtwo")
           && in_round(round)
           && p2_3_team_pk_fainted(0)
           && battle_is_won()
}

function mewtwo_ach(round, title, description, points, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=mewtwo_trigger(round)
    )
}

mewtwo_ach(1, "The Ultimate Pokemon",     "Defeat Mewtwo",            5,  79874, "85885")
mewtwo_ach(2, "The Ultimate Pokemon R-2", "Defeat Mewtwo in Round 2", 10, 79895, "85886")

// battle now

function battle_now_ach(round, title, description, points, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=beat_trainer_by_id_trigger("Battle Now", "Trainer", round)
                && in_mode2("Battle Now 1P")
    )
}

battle_now_ach(1, "Thirsty for Battle",    "Defeat Red in 1P \"Battle Now!\"",            3, 79854, "85910")
battle_now_ach(2, "Right Here, Right Now", "Defeat Yellow in 1P \"Battle Now!\" Round 2", 3, 79875, "85911")

// hall of fame

function hofame_progression_ach(title, description, points, n_pokemon, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=hofame_in_memory()
                && hofame_total_was_lt(n_pokemon)
                && hofame_total_is_ge(n_pokemon)
                // since the hofame totals are calculated with Hits in a single frame,
                // we need to reset the achievement at least every other frame to set the
                // accumulated Hits back to 0. so, we reset whenever the hall-of-frame
                // data is the same as in the previous frame. as a result, the cheevo can
                // only trigger in the exact frame when the hall-of-fame is updated
                && reset_if_hofame_did_not_change()
    )
}

hofame_progression_ach("A Respectable Start",   "Register 50 Pokemon in the Hall of Fame",  10, 50,  79908, "85915")
hofame_progression_ach("Most of the Way There", "Register 100 Pokemon in the Hall of Fame", 25, 100, 79909, "85916")

achievement(
    id=79910,
    badge="85912",
    title="It's All a Blur",
    description="Get an Amnesia Psyduck for registering 151 Pokemon in the Hall of Fame",
    points=50,
    trigger=in_mode2("Victory Palace")
            && in_mode("Victory Palace Pokemon Prize")
            && prize_pk_is("Psyduck")
            && prize_pk_trigger_moment()
)

achievement(
    id=79907,
    badge="85917",
    title="Raised Him Myself",
    description="Register Mewtwo into the Hall of Fame",
    points=2,
    trigger=hofame_in_memory()
            && hofame_was_in_memory()
            && hofame_pk_just_registered("Mewtwo")
)

// battle challenges

achievement(
    id=79896,
    badge="85887",
    title="Bored Medical Team",
    description="Win a cup using only rental Pokemon and not letting a single one faint",
    points=10,
    trigger=(in_mode("Petit Cup") || in_mode("Pika Cup") || in_mode("Poke Cup") || in_mode("Prime Cup"))
            && p1_6_team_all_rentals()
            && have_continues(7)
            && fighting_by_position(8)
            && p1_3_team_none_fainted()
            && p2_3_team_all_fainted()
            && battle_is_won()
)

achievement(
    id=79903,
    badge="85888",
    title="Rent-a-Mew",
    description="Defeat Mewtwo in Round 2 using only rental Pokemon and having Mew deliver the final blow",
    points=10,
    trigger=mewtwo_trigger(2)
            && p1_6_team_all_rentals()
            && p1_current_pk_is("Mew")
)

achievement(
    id=79901,
    badge="85909",
    title="Rental Champion",
    description="Defeat the Elite Four and your Rival in Round 2 using only rental Pokemon",
    points=50,
    trigger=beat_trainer_by_id_trigger("Gym Leader Castle", "Rival", 2)
            && p1_6_team_all_rentals()
)

function rental_cup_ach(mode, difficulty, title, description, points, id, badge) {
    achievement(
        id=id,
        badge=badge,
        title=title,
        description=description,
        points=points,
        trigger=beat_cup_trigger(mode, difficulty, 2)
                && p1_6_team_all_rentals()
    )
}

rental_cup_ach("Petit Cup",  "Poke Ball",   "Petit Cup for Rent", "Win the Petit Cup in Round 2 using only rental Pokemon",             50, 79897, "85905")
rental_cup_ach("Pika Cup",   "Poke Ball",   "Pika Cup for Rent",  "Win the Pika Cup in Round 2 using only rental Pokemon",              50, 79898, "85906")
rental_cup_ach("Poke Cup",   "Master Ball", "Poke Cup for Rent",  "Win the Master Ball Poke Cup in Round 2 using only rental Pokemon",  50, 79899, "85907")
rental_cup_ach("Prime Cup",  "Master Ball", "Prime Cup for Rent", "Win the Master Ball Prime Cup in Round 2 using only rental Pokemon", 50, 79900, "85908")

// misc

achievement(
    id=79905,
    badge="85889",
    title="House Advantage",
    description="Lose a Stadium or Gym Leader Castle battle even though all enemy pokemon have fainted",
    points=5,
    trigger=((in_mode2("Gym Leader Castle") && in_mode("Gym Leader Castle"))
             || (in_mode2("Stadium") && (in_mode("Petit Cup") || in_mode("Pika Cup") || in_mode("Poke Cup") || in_mode("Prime Cup"))))
            && p1_3_team_all_fainted()
            && p2_3_team_all_fainted()
            && battle_is_lost()
)

achievement(
    id=79906,
    badge="85891",
    title="The Struggle is Real",
    description="Get an opposing Pokemon to knock itself out with Struggle in a Stadium or Gym Leader Castle battle",
    points=2,
    // developing this was, ironically, a struggle... notes:
    //   - normal hp value goes to zero when turn starts, so we look at the hp text instead,
    //     to trigger at a more appropriate/satisfying moment
    //   - we check that the hp was not 0 in the last frame and is 0 in the current frame to
    //     ensure that the pokemon was knocked out in its own turn. is_p2_turn by itself
    //     is not enough, because the game still goes into P2-turn mode even when we knock the
    //     the pokemon out normally in P1's turn, which would cause the achievement to trigger
    //     if we only checked that the current hp is 0
    //   - current move value is not in a static location
    //   - per-pokemon current move does not update for Struggle....
    trigger=((in_mode2("Gym Leader Castle") && in_mode("Gym Leader Castle"))
             || (in_mode2("Stadium") && (in_mode("Petit Cup") || in_mode("Pika Cup") || in_mode("Poke Cup") || in_mode("Prime Cup"))))
            && fighting_someone()
            && is_p2_turn()
            && p2_current_hp_just_turned_zero()
            // fair warning: if the pokemon knocks itself out with his literal last PP,
            // the cheevo will trigger even though Struggle wasn't used.
            // famous last words: this is extremely unlikely to happen!
            && p2_current_pk_has_no_pp_left()
)

achievement(
    id=79904,
    badge="85890",
    title="The Ultimate Reward!",
    description="Go to the gallery and obtain your reward for beating the whole game",
    points=1,
    trigger=in_mode2("Gallery")
            && gallery_bonus_activated()            // the bonus will always be active, but the
            && gallery_bonus_text_disappeared()  // text disappears when A is pressed, which
                                                 // is exactly when we want to trigger
)

// surfing pikachu

achievement(
    id=79902,
    badge="85914",
    title="What's a Lapras to a Pikachu?",
    description="Teach Surf to a Pikachu as the reward for using it in every battle of a Master Ball Prime Cup R-2 win",
    points=50,
    trigger=in_mode2("Stadium")
            && in_mode("Victory Lap")
            && surfing_pikachu_trigger_moment()
)

// minigames
// notes: must be played on hard, as P1, with 3 COMs

function minigame_common_trigger(minigame_name) {
    return in_mode2("Kids Club")
           && never(in_minigame_mode("game select"))  // - reset if we get out of the minigame
           && never(!in_minigame(minigame_name))      // - reset if the selected minigame is not the target
           && never(!minigame_after_countdown())      // - wait until the countdown is finished to process the remaining logic
           && never(minigame_is_paused())             // - reset if paused
           && once(minigame_countdown_ended())        // - make sure the remaining logic operates on the whole game's timeframe
           && minigame_playing_solo()
           && in_minigame_difficulty("Hard")
           && minigame_p1_won()
           && minigame_finished()                     // - trigger when the winner is announced
}

achievement(
    id=79911,
    badge="86593",
    title="Fish out of Water",
    description="Win Magikarp's Splash with 30+ points (as 1P vs 3 Hard COMs, no pausing)",
    points=5,
    trigger=minigame_common_trigger("Magikarp's Splash")
            && minigame_magikarp_score_ge(30)
)

achievement(
    id=79912,
    badge="86594",
    title="Honor Student",
    description="Win Clefairy Says without making a single mistake (as 1P vs 3 Hard COMs, no pausing)",
    points=5,
    trigger=minigame_common_trigger("Clefairy Says")
            && minigame_clefairy_at_max_hp()
)

achievement(
    id=79913,
    badge="86595",
    title="Rat Race",
    description="Win \"Run, Rattata, Run\" without hitting a single hurdle (as 1P vs 3 Hard COMs, no pausing)",
    points=2,
    trigger=minigame_common_trigger("Run, Rattata, Run")
            && minigame_rattata_no_barriers_hit()
)

achievement(
    id=79914,
    badge="86596",
    title="Hypnotherapy",
    description="Win Snore War without missing more than 5 Hypnosis (as 1P vs 3 Hard COMs, no pausing)",
    points=10,
    trigger=minigame_common_trigger("Snore War")
            && never(repeated(6, minigame_drowzee_just_missed_hypnosis()))
)

achievement(
    id=79915,
    badge="86597",
    title="Lightning Fast",
    description="Win Thundering Dynamo in 8 seconds or less (as 1P vs 3 Hard COMs, no pausing)",
    points=5,
    trigger=minigame_common_trigger("Thundering Dynamo")
            && once(                             // store the fact that:
                minigame_timer_le(80)            //   timer was <= 8s ...
                && minigame_just_lost_control()  //   ... when the player lost control (the winner is only announced later)
            )
)

achievement(
    id=79916,
    badge="86598",
    title="No Chopsticks Required",
    description="Win Sushi-Go-Round having spent 12.000+ poke dollars (as 1P vs 3 Hard COMs, no pausing)",
    points=10,
    trigger=minigame_common_trigger("Sushi-Go-Round")
            && minigame_sushi_score_ge(12000)
)

achievement(
    id=79917,
    badge="86599",
    title="Shoot Some Hoops",
    description="Win Ekans' Hoop Hurl with a 15+ score (as 1P vs 3 Hard COMs, no pausing)",
    points=10,
    trigger=minigame_common_trigger("Ekans' Hoop Hurl")
            && minigame_ekans_score_ge(15)
)

achievement(
    id=79918,
    badge="86600",
    title="Tough It Out",
    description="Win Rock Harden with 50%+ HP left (as 1P vs 3 Hard COMs, no pausing)",
    points=10,
    trigger=minigame_common_trigger("Rock Harden")
            && minigame_harden_hp_percentage_ge(50)
)

achievement(
    id=79919,
    badge="86601",
    title="Water at the End of the Tunnel",
    description="Win \"Dig! Dig! Dig!\" in 6.5 seconds or less (as 1P vs 3 Hard COMs, no pausing)",
    points=3,
    trigger=minigame_common_trigger("Dig! Dig! Dig!")
           && once(                             // store the fact that:
               minigame_timer_le(65)            //   timer was <= 6.5s ...
               && minigame_just_lost_control()  //   ... when the player lost control (the winner is only announced later)
           )
)

function whos_the_best_common_trigger(difficulty) {
    return minigame_playing_solo()
           && in_minigame_difficulty(difficulty)
           && in_minigame_mode("who's the best state")
           && minigame_wins_to_champ() == 9
           && minigame_p1_wins() == 9
}

achievement(
    id=79920,
    badge="85901",
    title="COM Sweep",
    description="Win \"Who's the best?\" after 9 wins as 1P vs 3 Normal COMs without letting them have a single win",
    points=10,
    trigger=whos_the_best_common_trigger("Normal")
            && minigame_p2_wins() == 0
            && minigame_p3_wins() == 0
            && minigame_p4_wins() == 0
)

achievement(
    id=79921,
    badge="85902",
    title="Go Hard or Go Home",
    description="Win \"Who's the best?\" after 9 wins as 1P vs 3 Hard COMs without them collectively having more than 9 wins",
    points=10,
    trigger=whos_the_best_common_trigger("Hard")
            && (minigame_p2_wins() + minigame_p3_wins() + minigame_p4_wins()) <= 9
)

achievement(
    id=79922,
    badge="85903",
    title="Hyperactive COMs",
    description="Unlock Hyper COM level in the Kids Club",
    points=5,
    trigger=in_minigame_difficulty("Hard")
            && in_minigame_mode("who's the best state")
            && minigame_hyper_just_unlocked()
)

achievement(
    id=79923,
    badge="85904",
    title="I Swear They're Cheating",
    description="Win \"Who's the best?\" after 9 wins as 1P vs 3 Hyper COMs",
    points=25,
    trigger=whos_the_best_common_trigger("Hyper")
)



//=======================================//
//                                       //
//       R I C H   P R E S E N C E       //
//                                       //
//=======================================//

round_lookup = rich_presence_lookup("Round", round_val(), {
    0x00: "",
    0x01: " R-2"
}, "")

trainer_lookup = rich_presence_lookup("Trainer", trainer_id(), {
    0x01: "Trainer",
    0x02: "Brock",
    0x03: "Misty",
    0x04: "Surge",
    0x05: "Erika",
    0x06: "Koga",
    0x07: "Sabrina",
    0x08: "Blaine",
    0x09: "Giovani",
    0x0a: "Lorelei",
    0x0b: "Bruno",
    0x0c: "Agatha",
    0x0d: "Lance",
    0x0e: "Rival",
    0x0f: "Bug Boy",
    0x10: "Lass",
    0x11: "Lad",
    0x12: "JR♂",
    0x13: "JR♀",
    0x14: "Nerd",
    0x15: "Pkmniac",
    0x16: "Beauty",
    0x17: "Cool♂",
    0x18: "Cool♀",
    0x19: "Hiker",
    0x1a: "Medium",
    0x1b: "Sailor",
    0x1c: "Old Man",
    0x1d: "Fisher",
    0x1e: "Lab Man",
    0x1f: "Burglar",
    0x20: "Birdboy",
    0x21: "Judoboy",
    0x22: "Gambler",
    0x23: "Juggler",
    0x24: "Rocker",
    0x25: "Mr.Fix",
    0x26: "Biker",
    0x27: "Cueball",
    0x28: "Swimmer",
    0x29: "Tamer",
    0x2a: "Psychic",
    0x2b: "Rocket",
    0x34: "Mewtwo",
    0x35: "Trainer ×2"
}, "Trainer")

// start

rich_presence_conditional_display(
    in_mode2("Game Start"),
    "Watching a Pokemon parade"
)

// selection screens

rich_presence_conditional_display(
    in_mode2("Title Screen") || in_mode2("Select Screen") || in_mode2("Plaza") || in_mode2("Options"),
    "In the {0}, wondering what to do next",
    rich_presence_lookup("SelectScreen", mode2_id(), {
        0x02: "Title Screen",
        0x04: "Select Screen",
        0x10: "Trainer's Plaza",
        0x13: "Options"
    })
)

// gallery

rich_presence_conditional_display(
    in_mode2("Gallery"),
    "In the Gallery, looking at pretty Pokemon pictures"
)

// pokemon lab

rich_presence_conditional_display(
    in_mode2("Pokemon Lab"),
    "{0} in the Pokemon Lab",
    rich_presence_lookup("LabOption", pk_lab_screen_val(), {
        0x000F6320: "Chilling",
        0x001149c0: "Working the PC",
        0x00041470: "Working the PC",
        0x000fb230: "Working the PC",
        0x00048af0: "Working the PC",
        0x00073550: "Selecting a GB game",
        0x00039560: "Collecting a prize Pokemon",
        0x00075f70: "Checking out the Pokedex",
        0x00045b20: "Checking out the Pokedex",
        0x00068b60: "Checking out the Pokedex"
    }),
    "Chilling"
)

// hall of fame

rich_presence_conditional_display(
    in_mode2("Victory Palace"),
    "Admiring the {0} Pokemon in the Hall of Fame",
    rich_presence_value("HoFTotal", hall_of_fame_n_pk())
)

// GB tower

rich_presence_conditional_display(
    in_mode2("GB Tower"),
    "In the Game Boy Tower, wishing it worked"
)

// stadium

rich_presence_conditional_display(
    in_mode2("Stadium")
    && (
        // use the valid options to detect being in the cup-select screen of stadium
        stadium_cup_selected_option("Poke Cup") || stadium_cup_selected_option("Petit Cup")
        || stadium_cup_selected_option("Pika Cup") || stadium_cup_selected_option("Prime Cup")
        // after selecting a cup, the trainer id is set to 0 and can be used to know if
        // we're preparing for the cup or already in it
        || !fighting_someone()
    ),
    "Getting ready to compete in a{0} Stadium Cup", round_lookup
)

cup_lookup = rich_presence_lookup("Cup", mode_id(), {
    0x03: "Poke Cup",
    0x04: "Petit Cup",
    0x05: "Pika Cup",
    0x06: "Prime Cup"
})

cup_battle_no_val = rich_presence_value("CupBattleNo", trainer_position())

cup_continues_val = rich_presence_value("CupContinues", continues())

rich_presence_conditional_display(
    in_mode2("Stadium") && (in_mode("Poke Cup") || in_mode("Prime Cup")),
    "Fighting {0} in Battle {1} of {2}{3}{4} with {5} continue(s)",
    trainer_lookup,
    cup_battle_no_val,
    rich_presence_lookup("CupDifficulty", cup_difficulty(), {
        0x00: "Poke Ball ",
        0x01: "Great Ball ",
        0x02: "Ultra Ball ",
        0x03: "Master Ball "
    }, ""),
    cup_lookup,
    round_lookup,
    cup_continues_val
)

rich_presence_conditional_display(
    in_mode2("Stadium") && (in_mode("Pika Cup") || in_mode("Petit Cup")),
    "Fighting {0} in Battle {1} of {2}{3} with {4} continue(s)",
    trainer_lookup,
    cup_battle_no_val,
    cup_lookup,
    round_lookup,
    cup_continues_val
)

// free battle

rich_presence_conditional_display(
    in_mode2("Free Battle") && !fighting_someone(),
    "Getting ready for a Free Battle"
)

rich_presence_conditional_display(
    in_mode2("Free Battle"),
    "In a Free Battle"
)

// gym leader castle

rich_presence_conditional_display(
    in_mode2("Gym Leader Castle") && !fighting_someone(),
    "Getting ready to fight in the Gym Leader Castle{0}", round_lookup
)

rich_presence_conditional_display(
    in_mode2("Gym Leader Castle"),
    "Fighting {0} in {1}{2}",
    trainer_lookup,
    rich_presence_lookup("Gym", gym_id(), {
        0x00: "Pewter Gym",
        0x01: "Cerulean Gym",
        0x02: "Vermilion Gym",
        0x03: "Celadon Gym",
        0x04: "Fuchsia Gym",
        0x05: "Saffron Gym",
        0x06: "Cinnabar Gym",
        0x07: "Viridian Gym",
        0x08: "the Elite Four",
        0x09: "the Elite Four"
    }, "the Gym Leader Castle"),
    round_lookup
)

// mewtwo

rich_presence_conditional_display(
    in_mode2("Mewtwo") && !fighting_someone(),
    "Getting ready to take on Mewtwo{0}", round_lookup
)

rich_presence_conditional_display(
    in_mode2("Mewtwo"),
    "Taking on the ultimate Pokemon, Mewtwo{0}", round_lookup
)

// battle now

rich_presence_conditional_display(
    in_mode2("Battle Now 1P") || in_mode2("Battle Now 2P"),
    "Fighting {0} in{1} Battle Now!",
    rich_presence_lookup("BattleNowOpponent", mode2_id(), {
        0x28: "COM",
        0x29: "2P"
    }),
    round_lookup
)

// kids club

function minigame_playing() {
    // not a boolean, but is mostly 1 after having chosen all the minigame options
    // (mode, difficulty, wins to champion, ...)
    return byte(0x136257) == 0x01
}

minigame_difficulty_lookup = rich_presence_lookup("MinigameDifficulty", minigame_difficulty_val(), {
    0x00: "Easy",
    0x01: "Normal",
    0x02: "Hard",
    0x03: "Hyper"
})

rich_presence_conditional_display(
    in_mode2("Kids Club") && minigame_playing() && minigame_playing_whos_the_best(),
    "Playing \"Who's the Best?\" in {0} difficulty with {1}/{2} wins",
    minigame_difficulty_lookup,
    rich_presence_value("Minigame1PWins", minigame_p1_wins()),
    rich_presence_value("MinigameWinsToChamp", minigame_wins_to_champ())
)

rich_presence_conditional_display(
    in_mode2("Kids Club"),
    "In the Kids Club"
)

// fallback

rich_presence_display("In parts unknown")



//=======================================//
//                                       //
//        L E A D E R B O A R D S        //
//                                       //
//=======================================//

function leaderboard_start(minigame_name) {
    return in_mode2("Kids Club")
        && minigame_playing_solo()
        && in_minigame_difficulty("Hard")
        && in_minigame(minigame_name)
        && minigame_countdown_ended()
}

function leaderboard_cancel(minigame_name) {
    return always_false()
        || !in_mode2("Kids Club")
        || in_minigame_mode("game select")
        || !in_minigame(minigame_name)
        || minigame_is_paused()
}

function highscore_leaderboard_submit() {
    return minigame_finished()
}

function minigame_highscore_leaderboard(minigame_name, description, value, extra_cancel_trigger) {
    leaderboard(
        title=minigame_name,
        description=description,
        start=leaderboard_start(minigame_name),
        cancel=leaderboard_cancel(minigame_name) || extra_cancel_trigger,
        submit=highscore_leaderboard_submit(),
        value=value
    )
}

function minigame_lowest_time_leaderboard(minigame_name, description, extra_cancel_trigger, submit_trigger) {
    leaderboard(
        title=minigame_name,
        description=description,
        start=leaderboard_start(minigame_name),
        cancel=leaderboard_cancel(minigame_name) || extra_cancel_trigger,
        submit=submit_trigger,
        value=minigame_timer_as_frames(),
        format="FRAMES"
    )
}

minigame_highscore_leaderboard(
    "Magikarp's Splash",
    "Highest score as 1P vs 3 Hard COMs",
    minigame_magikarp_score(),
    always_false()
)

minigame_highscore_leaderboard(
    "Clefairy Says",
    "Most HP left as 1P vs 3 Hard COMs",
    minigame_clefairy_hp(),
    minigame_clefairy_no_hp()
)

minigame_highscore_leaderboard(
    "Snore War",
    "Most HP left as 1P vs 3 Hard COMs",
    minigame_drowzee_hp(),
    always_false()
)

minigame_highscore_leaderboard(
    "Sushi-Go-Round",
    "Most poke dollars spent as 1P vs 3 Hard COMs",
    minigame_sushi_score_immediate(),
    always_false()
)

minigame_highscore_leaderboard(
    "Ekans' Hoop Hurl",
    "Highest score as 1P vs 3 Hard COMs",
    minigame_ekans_score(),
    always_false()
)

minigame_highscore_leaderboard(
    "Rock Harden",
    "Most HP left as 1P vs 3 Hard COMs",
    minigame_harden_hp(),
    always_false()
)

minigame_lowest_time_leaderboard(
    "Thundering Dynamo",
    "Lowest win time as 1P vs 3 Hard COMs",
    (minigame_just_lost_control() && !minigame_p1_won()),
    (minigame_just_lost_control() && minigame_p1_won())
)

minigame_lowest_time_leaderboard(
    "Run, Rattata, Run",
    "Lowest time as 1P vs 3 Hard COMs",
    always_true(),
    minigame_rattata_1p_just_finished()
)

minigame_lowest_time_leaderboard(
    "Dig! Dig! Dig!",
    "Lowest win time as 1P vs 3 Hard COMs",
    (minigame_just_lost_control() && !minigame_p1_won()),
    (minigame_just_lost_control() && minigame_p1_won())
)

function fake_highscore_leaderboard(minigame_name, extra_cancel_trigger) {
    achievement(title="Highscore Leaderboard Start", description="Start", points=1, trigger=leaderboard_start(minigame_name))
    achievement(title="Highscore Leaderboard Cancel", description="Cancel", points=1, trigger=leaderboard_cancel(minigame_name) || extra_cancel_trigger)
    achievement(title="Highscore Leaderboard Submit", description="Submit", points=1, trigger=highscore_leaderboard_submit())
}

function fake_lowest_time_leaderboard(minigame_name, extra_cancel_trigger, submit_trigger) {
    achievement(title="Time Leaderboard Start", description="Start", points=1, trigger=leaderboard_start(minigame_name))
    achievement(title="Time Leaderboard Cancel", description="Cancel", points=1, trigger=leaderboard_cancel(minigame_name) || extra_cancel_trigger)
    achievement(title="Time Leaderboard Submit", description="Submit", points=1, trigger=submit_trigger)
}

//fake_highscore_leaderboard("Clefairy Says", minigame_clefairy_no_hp())
//fake_lowest_time_leaderboard(
//    "Dig! Dig! Dig!",
//    (minigame_just_lost_control() && !minigame_p1_won()),
//    (minigame_just_lost_control() && minigame_p1_won())
//)


