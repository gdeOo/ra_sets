// Pokemon Stadium 2
// #ID = 10258

// $1451D0: 16bit trainer id
function trainer_id() => byte(0x1451D0)

// $14528C: Your leftmost Pokemon's HP
function p1_3team_0_hp() => word(0x14528C)

// $1452E4: Your middlemost Pokemon's HP
function p1_3team_1_hp() => word(0x1452E4)

// $14533C: Your rightmost Pokemon's HP
function p1_3team_2_hp() => word(0x14533C)

// $14576C: Leftmost opposing Pokemon HP
function p2_3team_0_hp() => word(0x14576C)

// $1457C4: Middlemost opposing Pokemon HP
function p2_3team_1_hp() => word(0x1457C4)

// $14581C: Rightmost opposing Pokemon HP
function p2_3team_2_hp() => word(0x14581C)

mode__addr = 0x9de94
mode__mem = byte(mode__addr)
mode__values = {
    "Stadium": 0x08
    // no need for the others right now
}

function in_stadium() => mode__mem == mode__values["Stadium"]

pokemon_ids = {
    "Pikachu":   0x19,
    "Espeon":    0xc4,
    "Snorlax":   0x8f,
    "Venusaur":  0x03,
    "Charizard": 0x06,
    "Blastoise": 0x09
}

p1_6team_0_id__addr = 0x1460e3
p1_6team__sizeof = 96

function p1_6team_pokemon_is(idx, pokemon) {
    return byte(p1_6team_0_id__addr + (idx * p1_6team__sizeof)) == pokemon_ids[pokemon]
}

function p1_6team_is(team) {
    cond = always_true()
    i = 0
    for pokemon in team {
        cond = cond && p1_6team_pokemon_is(i, pokemon)
        i = i + 1
    }
    return cond
}

function fighting_nth_trainer(n) => trainer_id() == (n - 1)


// Ticket 22733: .
//               MD5: 1561C75D11CEDF356A8DDB1A4A5F9D5D
//               Emulator: RAProject64
// Ticket 17507: Because the achievement had two issues already reported, I activated the 'pause on reset' just to
//               avoid completing a cup after the achievement had already bugged out.
//               //               Until now it has wrongly reset twice in the prime and poke cups. The last time it happened I noticed
//               that the reset occurred as a slowpoke was starting a Dig.
//               //               Considering that the reset is supposed to occur based on the 'Move being used', I'm guessing that Dig
//               should be in the exception list (the Pause Ifs)?
//               MD5: FE05FB7A1E76ADCF8942B24A97748939
//               Emulator: RAProject64
// Ticket 13362: Didn't triggered after the first Pok� Cup
//               MD5: 1561c75d11cedf356a8ddb1a4a5f9d5d
// Ticket 13059: i used rentals in 50-55 cup didnt triggered i even used the same order written in the Pokemon Stadium
//               2 thread here on retroachievments
//               MD5: fe05fb7a1e76adcf8942b24a97748939
//               Emulator: RAProject64
achievement(
    title = "The Very Best", description = "Win a cup using a copy of Red's GSC team (in the correct order)", points = 3,
    id = 58543, badge = "59283", published = "3/14/2018 7:49:46 PM", modified = "10/22/2019 5:03:01 PM",
    trigger =
        // restrict the logic to cups
        in_stadium()
        
        // team must be correct and in order (foregoing the order requirement would
        // either require too many alts or an approximate solution)
        && p1_6team_is(["Pikachu", "Espeon", "Snorlax", "Venusaur", "Charizard", "Blastoise"])

        // trigger on the last battle...
        // (the hits avoid mistriggering during the transition into the last battle)
        && repeated(420, fighting_nth_trainer(8))
        && never(!fighting_nth_trainer(8))
        
        // ...when the opposing team is kill and ours isnt
        // note: this triggers before the last turn is carried out. I could make it trigger at a
        // more appropriate time, but since all other cheevos are like this, I'll keep this logic
        // for consistency's sake
        && p2_3team_0_hp() == 0 && p2_3team_1_hp() == 0 && p2_3team_2_hp() == 0
        && ((p1_3team_0_hp() != 0) || (p1_3team_1_hp() != 0) || (p1_3team_2_hp() != 0))
)

