// Pokemon Stadium 2
// #ID = 10258

// $091B03: 00 = your move, 01 = their move
function whose_turn() => byte(0x091B03)

// $11F302: 2a = battle victory
function battle_is_won() => byte(0x11F302)

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

// $1E1C3B: Move being used
function move_being_used() => byte(0x1E1C3B)

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
    title = "The Very Best", description = "Win a cup using a copy of Red's GSC team", points = 3,
    id = 58543, badge = "59283", published = "3/14/2018 7:49:46 PM", modified = "10/22/2019 5:03:01 PM",
    trigger =
        // we've been through every battle in this session
        repeated(420, trainer_id() == 1)
        && repeated(420, trainer_id() == 2)
        && repeated(420, trainer_id() == 3)
        && repeated(420, trainer_id() == 4)
        && repeated(420, trainer_id() == 5)
        && repeated(420, trainer_id() == 6)
        && repeated(420, trainer_id() == 7)
        && repeated(420, trainer_id() == 0)

        // is 0x22 = battle loss?
        && unless(battle_is_won() == 34)

        // reset if we're using a move that is not in the moveset of the allowed pokemon
        && never(move_being_used() != 0)
        && unless(move_being_used() == 56)
        && unless(move_being_used() == 229)
        && unless(move_being_used() == 110)
        && unless(move_being_used() == 189)
        && unless(move_being_used() == 33)
        && unless(move_being_used() == 202)
        && unless(move_being_used() == 45)
        && unless(move_being_used() == 77)
        && unless(move_being_used() == 184)
        && unless(move_being_used() == 17)
        && unless(move_being_used() == 7)
        && unless(move_being_used() == 129)
        && unless(move_being_used() == 39)
        && unless(move_being_used() == 244)
        && unless(move_being_used() == 60)
        && unless(move_being_used() == 174)
        && unless(move_being_used() == 111)
        && unless(move_being_used() == 29)
        && unless(move_being_used() == 86)
        && unless(move_being_used() == 231)
        && unless(move_being_used() == 85)
        && unless(move_being_used() == 57)
        && unless(move_being_used() == 133)

        // more exceptions... probably trying to exclude the moves used by the opponent
        // also, I feel like the code note's lying about the 0 or 1 part
        && unless(whose_turn() == 1)
        && unless(whose_turn() == 76)
        && unless(whose_turn() == 19)
        && unless(whose_turn() == 143)
        && unless(whose_turn() == 91)
        && unless(whose_turn() == 63)
        && unless(whose_turn() == 117)

        // trigger on the last battle when the opposing team is kill and ours isnt
        && p2_3team_0_hp() == 0 && p2_3team_1_hp() == 0 && p2_3team_2_hp() == 0
        && (
            (p1_3team_0_hp() != 0)
            || (p1_3team_1_hp() != 0)
            || (p1_3team_2_hp() != 0)
        )
)
