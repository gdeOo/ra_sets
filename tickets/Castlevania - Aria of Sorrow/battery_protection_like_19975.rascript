// Castlevania - Aria of Sorrow
// #ID = 510

// $01B1F8: LCK (status)
function lck_stat() => byte(0x01b1f8)

function never_not_in_game() => never(prev(lck_stat()) == 0)

achievement(
    title = "Backdash", description = "Obtained Grave Keeper Ability", points = 5,
    id = 3069, badge = "03563", published = "10/1/2013 5:36:42 AM", modified = "10/17/2018 3:30:59 AM",
    trigger =
        bit0(0x01B392) > prev(bit0(0x01B392))
        && never_not_in_game()
)

achievement(
    title = "Sliding", description = "Obtained Skeleton Blaze Ability", points = 5,
    id = 3068, badge = "03568", published = "10/1/2013 5:36:36 AM", modified = "10/17/2018 3:31:21 AM",
    trigger =
        bit4(0x01B392) > prev(bit4(0x01B392))
        && never_not_in_game()
)

achievement(
    title = "Double Jump", description = "Obtained Malphas Ability", points = 5,
    id = 3071, badge = "03565", published = "10/1/2013 5:36:52 AM", modified = "10/17/2018 3:31:32 AM",
    trigger =
        bit0(0x01B393) > prev(bit0(0x01B393))
        && never_not_in_game()
)

achievement(
    title = "Jumping Off Their Heads", description = "Obtained Kicker Skeleton Ability", points = 5,
    id = 3070, badge = "03564", published = "10/1/2013 5:36:47 AM", modified = "10/17/2018 3:31:43 AM",
    trigger =
        bit4(0x01B393) > prev(bit4(0x01B393))
        && never_not_in_game()
)

achievement(
    title = "Time Has Stopped", description = "Obtained Galamoth Ability", points = 5,
    id = 3072, badge = "03566", published = "10/1/2013 5:36:57 AM", modified = "10/17/2018 3:31:54 AM",
    trigger =
        bit4(0x01B394) > prev(bit4(0x01B394))
        && never_not_in_game()
)

achievement(
    title = "Super Jump", description = "Obtained Hippogryph Ability", points = 5,
    id = 3073, badge = "03567", published = "10/1/2013 5:37:02 AM", modified = "10/17/2018 3:32:04 AM",
    trigger =
        bit0(0x01B394) > prev(bit0(0x01B394))
        && never_not_in_game()
)

achievement(
    title = "Creaking Skull", description = "Defeated the 1st Boss as Soma", points = 5,
    id = 3074, badge = "03547", published = "10/1/2013 5:37:09 AM", modified = "10/17/2018 3:32:30 AM",
    trigger =
        bit1(0x01B3A4) > prev(bit1(0x01B3A4))
        && never_not_in_game()
)

achievement(
    title = "Manticore", description = "Defeated the 2nd Boss as Soma", points = 10,
    id = 3075, badge = "03548", published = "10/1/2013 5:37:15 AM", modified = "10/17/2018 3:32:14 AM",
    trigger =
        bit6(0x01B3A6) > prev(bit6(0x01B3A6))
        && never_not_in_game()
)

achievement(
    title = "Great Armor", description = "Defeated the 3rd Boss as Soma", points = 10,
    id = 3076, badge = "03549", published = "10/1/2013 5:37:20 AM", modified = "10/17/2018 3:35:19 AM",
    trigger =
        bit4(0x01B3A7) > prev(bit4(0x01B3A7))
        && never_not_in_game()
)

achievement(
    title = "Big Golem", description = "Defeated the 4th Boss as Soma", points = 10,
    id = 3077, badge = "03550", published = "10/1/2013 5:37:25 AM", modified = "10/12/2019 2:21:01 AM",
    trigger =
        bit5(0x01B3A8) > prev(bit5(0x01B3A8))
        && low4(0x0080A1) == 0
        && never_not_in_game()
)

achievement(
    title = "Headhunter", description = "Defeated the 5th Boss as Soma", points = 10,
    id = 3078, badge = "03551", published = "10/1/2013 5:37:29 AM", modified = "10/17/2018 3:36:41 AM",
    trigger =
        bit2(0x01B3AD) > prev(bit2(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "Death", description = "Defeated the 6th Boss as Soma", points = 10,
    id = 3079, badge = "03552", published = "10/1/2013 5:37:34 AM", modified = "10/17/2018 3:59:11 AM",
    trigger =
        bit3(0x01B3AD) > prev(bit3(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "Legion", description = "Defeated the 7th Boss as Soma", points = 10,
    id = 3080, badge = "03553", published = "10/1/2013 5:37:38 AM", modified = "10/17/2018 3:37:17 AM",
    trigger =
        bit4(0x01B3AD) > prev(bit4(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "Balore", description = "Defeated the 8th Boss as Soma", points = 10,
    id = 3081, badge = "03554", published = "10/1/2013 5:37:43 AM", modified = "10/17/2018 3:37:34 AM",
    trigger =
        bit5(0x01B3AD) > prev(bit5(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "Graham", description = "Defeated the 9th Boss as Soma", points = 10,
    id = 3082, badge = "03555", published = "10/1/2013 5:37:48 AM", modified = "10/17/2018 3:37:56 AM",
    trigger =
        bit7(0x01B3AD) > prev(bit7(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "J Who?", description = "Defeated the 10th Boss as Soma", points = 10,
    id = 3083, badge = "03556", published = "10/1/2013 5:37:54 AM", modified = "10/17/2018 3:38:27 AM",
    trigger =
        bit6(0x01B3AD) > prev(bit6(0x01B3AD))
        && never_not_in_game()
)

achievement(
    title = "Normal Chaos", description = "Beat the Game on Normal as Soma", points = 25,
    id = 3085, badge = "03569", published = "10/1/2013 5:38:03 AM", modified = "10/17/2018 3:39:04 AM",
    trigger =
        bit0(0x01B3AE) > prev(bit0(0x01B3AE))
        && never_not_in_game()
)

achievement(
    title = "Yellow Soul Collector", description = "Obtained All (YELLOW) Souls", points = 25,
    id = 3156, badge = "03635", published = "10/4/2013 5:11:19 AM", modified = "11/15/2019 11:56:41 PM",
    trigger =
        never_not_in_game()
        && (high4(0x01B36E) + high4(0x01B380)) >= 1 && 
              (low4(0x01B36E) + low4(0x01B380)) >= 1 && (high4(0x01B36F) + high4(0x01B381)) >= 1 && 
              (low4(0x01B36F) + low4(0x01B381)) >= 1 && (high4(0x01B370) + high4(0x01B382)) >= 1 && 
              (low4(0x01B370) + low4(0x01B382)) >= 1 && (high4(0x01B371) + high4(0x01B383)) >= 1 && 
              (low4(0x01B371) + low4(0x01B383)) >= 1 && (high4(0x01B372) + high4(0x01B384)) >= 1 && 
              (low4(0x01B372) + low4(0x01B384)) >= 1 && (high4(0x01B373) + high4(0x01B385)) >= 1 && 
              (low4(0x01B373) + low4(0x01B385)) >= 1 && (high4(0x01B374) + high4(0x01B386)) >= 1 && 
              (low4(0x01B374) + low4(0x01B386)) >= 1 && (high4(0x01B375) + high4(0x01B387)) >= 1 && 
              (low4(0x01B375) + low4(0x01B387)) >= 1 && (high4(0x01B376) + high4(0x01B388)) >= 1 && 
              (low4(0x01B376) + low4(0x01B388)) >= 1 && (high4(0x01B377) + high4(0x01B389)) >= 1 && 
              (low4(0x01B377) + low4(0x01B389)) >= 1 && (high4(0x01B378) + high4(0x01B38A)) >= 1 && 
              (low4(0x01B378) + low4(0x01B38A)) >= 1 && (high4(0x01B379) + high4(0x01B38B)) >= 1 && 
              (low4(0x01B379) + low4(0x01B38B)) >= 1 && (high4(0x01B37A) + high4(0x01B38C)) >= 1 && 
              (low4(0x01B37A) + low4(0x01B38C)) >= 1 && (high4(0x01B37B) + high4(0x01B38D)) >= 1 && 
              (low4(0x01B37B) + low4(0x01B38D)) >= 1 && (high4(0x01B37C) + high4(0x01B38E)) >= 1 && 
              (low4(0x01B37C) + low4(0x01B38E)) >= 1 && (high4(0x01B37D) + high4(0x01B38F)) >= 1 && 
              (low4(0x01B37D) + low4(0x01B38F)) >= 1 && (high4(0x01B37E) + high4(0x01B390)) >= 1 && 
              (low4(0x01B37E) + low4(0x01B390)) >= 1 && (low4(0x01B37F) + low4(0x01B391)) >= 1 &&
              (((prev(high4(0x01B36E)) + prev(high4(0x01B380))) == 0) ||
               ((prev(low4(0x01B36E)) + prev(low4(0x01B380))) == 0) ||
               ((prev(high4(0x01B36F)) + prev(high4(0x01B381))) == 0) ||
               ((prev(low4(0x01B36F)) + prev(low4(0x01B381))) == 0) ||
               ((prev(high4(0x01B370)) + prev(high4(0x01B382))) == 0) ||
               ((prev(low4(0x01B370)) + prev(low4(0x01B382))) == 0) ||
               ((prev(high4(0x01B371)) + prev(high4(0x01B383))) == 0) ||
               ((prev(low4(0x01B371)) + prev(low4(0x01B383))) == 0) ||
               ((prev(high4(0x01B372)) + prev(high4(0x01B384))) == 0) ||
               ((prev(low4(0x01B372)) + prev(low4(0x01B384))) == 0) ||
               ((prev(high4(0x01B373)) + prev(high4(0x01B385))) == 0) ||
               ((prev(low4(0x01B373)) + prev(low4(0x01B385))) == 0) ||
               ((prev(high4(0x01B374)) + prev(high4(0x01B386))) == 0) ||
               ((prev(low4(0x01B374)) + prev(low4(0x01B386))) == 0) ||
               ((prev(high4(0x01B375)) + prev(high4(0x01B387))) == 0) ||
               ((prev(low4(0x01B375)) + prev(low4(0x01B387))) == 0) ||
               ((prev(high4(0x01B376)) + prev(high4(0x01B388))) == 0) ||
               ((prev(low4(0x01B376)) + prev(low4(0x01B388))) == 0) ||
               ((prev(high4(0x01B377)) + prev(high4(0x01B389))) == 0) ||
               ((prev(low4(0x01B377)) + prev(low4(0x01B389))) == 0) ||
               ((prev(high4(0x01B378)) + prev(high4(0x01B38A))) == 0) ||
               ((prev(low4(0x01B378)) + prev(low4(0x01B38A))) == 0) ||
               ((prev(high4(0x01B379)) + prev(high4(0x01B38B))) == 0) ||
               ((prev(low4(0x01B379)) + prev(low4(0x01B38B))) == 0) ||
               ((prev(high4(0x01B37A)) + prev(high4(0x01B38C))) == 0) ||
               ((prev(low4(0x01B37A)) + prev(low4(0x01B38C))) == 0) ||
               ((prev(high4(0x01B37B)) + prev(high4(0x01B38D))) == 0) ||
               ((prev(low4(0x01B37B)) + prev(low4(0x01B38D))) == 0) ||
               ((prev(high4(0x01B37C)) + prev(high4(0x01B38E))) == 0) ||
               ((prev(low4(0x01B37C)) + prev(low4(0x01B38E))) == 0) ||
               ((prev(high4(0x01B37D)) + prev(high4(0x01B38F))) == 0) ||
               ((prev(low4(0x01B37D)) + prev(low4(0x01B38F))) == 0) ||
               ((prev(high4(0x01B37E)) + prev(high4(0x01B390))) == 0) ||
               ((prev(low4(0x01B37E)) + prev(low4(0x01B390))) == 0) ||
               ((prev(low4(0x01B37F)) + prev(low4(0x01B391))) == 0))
)

achievement(
    title = "Blue Soul Collector", description = "Obtained All (BLUE) Souls", points = 25,
    id = 3157, badge = "03636", published = "10/4/2013 5:30:33 AM", modified = "11/15/2019 11:56:45 PM",
    trigger =
        never_not_in_game()
        && (high4(0x01B354) + high4(0x01B361)) >= 1 && 
              (low4(0x01B354) + low4(0x01B361)) >= 1 && (high4(0x01B355) + high4(0x01B362)) >= 1 && 
              (low4(0x01B355) + low4(0x01B362)) >= 1 && (high4(0x01B356) + high4(0x01B363)) >= 1 && 
              (low4(0x01B356) + low4(0x01B363)) >= 1 && (high4(0x01B357) + high4(0x01B364)) >= 1 && 
              (low4(0x01B357) + low4(0x01B364)) >= 1 && (high4(0x01B358) + high4(0x01B365)) >= 1 && 
              (low4(0x01B358) + low4(0x01B365)) >= 1 && (high4(0x01B359) + high4(0x01B366)) >= 1 && 
              (low4(0x01B359) + low4(0x01B366)) >= 1 && (high4(0x01B35A) + high4(0x01B367)) >= 1 && 
              (low4(0x01B35A) + low4(0x01B367)) >= 1 && (high4(0x01B35B) + high4(0x01B368)) >= 1 && 
              (low4(0x01B35B) + low4(0x01B368)) >= 1 && (high4(0x01B35C) + high4(0x01B369)) >= 1 && 
              (low4(0x01B35C) + low4(0x01B369)) >= 1 && (high4(0x01B35D) + high4(0x01B36A)) >= 1 && 
              (low4(0x01B35D) + low4(0x01B36A)) >= 1 && (high4(0x01B35E) + high4(0x01B36B)) >= 1 && 
              (low4(0x01B35E) + low4(0x01B36B)) >= 1 && (high4(0x01B35F) + high4(0x01B36C)) >= 1 && 
              (low4(0x01B35F) + low4(0x01B36C)) >= 1 &&
              (((prev(high4(0x01B354)) + prev(high4(0x01B361))) == 0) ||
               ((prev(low4(0x01B354)) + prev(low4(0x01B361))) == 0) ||
               ((prev(high4(0x01B355)) + prev(high4(0x01B362))) == 0) ||
               ((prev(low4(0x01B355)) + prev(low4(0x01B362))) == 0) ||
               ((prev(high4(0x01B356)) + prev(high4(0x01B363))) == 0) ||
               ((prev(low4(0x01B356)) + prev(low4(0x01B363))) == 0) ||
               ((prev(high4(0x01B357)) + prev(high4(0x01B364))) == 0) ||
               ((prev(low4(0x01B357)) + prev(low4(0x01B364))) == 0) ||
               ((prev(high4(0x01B358)) + prev(high4(0x01B365))) == 0) ||
               ((prev(low4(0x01B358)) + prev(low4(0x01B365))) == 0) ||
               ((prev(high4(0x01B359)) + prev(high4(0x01B366))) == 0) ||
               ((prev(low4(0x01B359)) + prev(low4(0x01B366))) == 0) ||
               ((prev(high4(0x01B35A)) + prev(high4(0x01B367))) == 0) ||
               ((prev(low4(0x01B35A)) + prev(low4(0x01B367))) == 0) ||
               ((prev(high4(0x01B35B)) + prev(high4(0x01B368))) == 0) ||
               ((prev(low4(0x01B35B)) + prev(low4(0x01B368))) == 0) ||
               ((prev(high4(0x01B35C)) + prev(high4(0x01B369))) == 0) ||
               ((prev(low4(0x01B35C)) + prev(low4(0x01B369))) == 0) ||
               ((prev(high4(0x01B35D)) + prev(high4(0x01B36A))) == 0) ||
               ((prev(low4(0x01B35D)) + prev(low4(0x01B36A))) == 0) ||
               ((prev(high4(0x01B35E)) + prev(high4(0x01B36B))) == 0) ||
               ((prev(low4(0x01B35E)) + prev(low4(0x01B36B))) == 0) ||
               ((prev(high4(0x01B35F)) + prev(high4(0x01B36C))) == 0) ||
               ((prev(low4(0x01B35F)) + prev(low4(0x01B36C))) == 0))
)

achievement(
    title = "Red Soul Collector", description = "Obtained all (RED) Souls", points = 25,
    id = 3144, badge = "03616", published = "10/3/2013 6:36:31 AM", modified = "11/15/2019 11:56:49 PM",
    trigger =
        never_not_in_game()
        && (high4(0x01B31C) + high4(0x01B338)) >= 1 && 
              (low4(0x01B31C) + low4(0x01B338)) >= 1 && (high4(0x01B31D) + high4(0x01B339)) >= 1 && 
              (low4(0x01B31D) + low4(0x01B339)) >= 1 && (high4(0x01B31E) + high4(0x01B33A)) >= 1 && 
              (low4(0x01B31E) + low4(0x01B33A)) >= 1 && (high4(0x01B31F) + high4(0x01B33B)) >= 1 && 
              (low4(0x01B31F) + low4(0x01B33B)) >= 1 && (high4(0x01B320) + high4(0x01B33C)) >= 1 && 
              (low4(0x01B320) + low4(0x01B33C)) >= 1 && (high4(0x01B321) + high4(0x01B33D)) >= 1 && 
              (low4(0x01B321) + low4(0x01B33D)) >= 1 && (high4(0x01B322) + high4(0x01B33E)) >= 1 && 
              (low4(0x01B322) + low4(0x01B33E)) >= 1 && (high4(0x01B323) + high4(0x01B33F)) >= 1 && 
              (low4(0x01B323) + low4(0x01B33F)) >= 1 && (high4(0x01B324) + high4(0x01B340)) >= 1 && 
              (low4(0x01B324) + low4(0x01B340)) >= 1 && (high4(0x01B325) + high4(0x01B341)) >= 1 && 
              (low4(0x01B325) + low4(0x01B341)) >= 1 && (high4(0x01B326) + high4(0x01B342)) >= 1 && 
              (low4(0x01B326) + low4(0x01B342)) >= 1 && (high4(0x01B327) + high4(0x01B343)) >= 1 && 
              (low4(0x01B327) + low4(0x01B343)) >= 1 && (high4(0x01B328) + high4(0x01B344)) >= 1 && 
              (low4(0x01B328) + low4(0x01B344)) >= 1 && (high4(0x01B329) + high4(0x01B345)) >= 1 && 
              (low4(0x01B329) + low4(0x01B345)) >= 1 && (high4(0x01B32A) + high4(0x01B346)) >= 1 && 
              (low4(0x01B32A) + low4(0x01B346)) >= 1 && (high4(0x01B32B) + high4(0x01B347)) >= 1 && 
              (low4(0x01B32B) + low4(0x01B347)) >= 1 && (high4(0x01B32C) + high4(0x01B348)) >= 1 && 
              (low4(0x01B32C) + low4(0x01B348)) >= 1 && (high4(0x01B32D) + high4(0x01B349)) >= 1 && 
              (low4(0x01B32D) + low4(0x01B349)) >= 1 && (high4(0x01B32E) + high4(0x01B34A)) >= 1 && 
              (low4(0x01B32E) + low4(0x01B34A)) >= 1 && (high4(0x01B32F) + high4(0x01B34B)) >= 1 && 
              (low4(0x01B32F) + low4(0x01B34B)) >= 1 && (high4(0x01B330) + high4(0x01B34C)) >= 1 && 
              (low4(0x01B330) + low4(0x01B34C)) >= 1 && (high4(0x01B331) + high4(0x01B34D)) >= 1 && 
              (low4(0x01B331) + low4(0x01B34D)) >= 1 && (high4(0x01B332) + high4(0x01B34E)) >= 1 && 
              (low4(0x01B332) + low4(0x01B34E)) >= 1 && (high4(0x01B333) + high4(0x01B34F)) >= 1 && 
              (low4(0x01B333) + low4(0x01B34F)) >= 1 && (high4(0x01B334) + high4(0x01B350)) >= 1 && 
              (low4(0x01B334) + low4(0x01B350)) >= 1 && (high4(0x01B335) + high4(0x01B351)) >= 1 && 
              (low4(0x01B335) + low4(0x01B351)) >= 1 && (high4(0x01B336) + high4(0x01B352)) >= 1 && 
              (low4(0x01B336) + low4(0x01B352)) >= 1 && (low4(0x01B337) + low4(0x01B353)) >= 1 &&
              (((prev(high4(0x01B31C)) + prev(high4(0x01B338))) == 0) ||
               ((prev(low4(0x01B31C)) + prev(low4(0x01B338))) == 0) ||
               ((prev(high4(0x01B31D)) + prev(high4(0x01B339))) == 0) ||
               ((prev(low4(0x01B31D)) + prev(low4(0x01B339))) == 0) ||
               ((prev(high4(0x01B31E)) + prev(high4(0x01B33A))) == 0) ||
               ((prev(low4(0x01B31E)) + prev(low4(0x01B33A))) == 0) ||
               ((prev(high4(0x01B31F)) + prev(high4(0x01B33B))) == 0) ||
               ((prev(low4(0x01B31F)) + prev(low4(0x01B33B))) == 0) ||
               ((prev(high4(0x01B320)) + prev(high4(0x01B33C))) == 0) ||
               ((prev(low4(0x01B320)) + prev(low4(0x01B33C))) == 0) ||
               ((prev(high4(0x01B321)) + prev(high4(0x01B33D))) == 0) ||
               ((prev(low4(0x01B321)) + prev(low4(0x01B33D))) == 0) ||
               ((prev(high4(0x01B322)) + prev(high4(0x01B33E))) == 0) ||
               ((prev(low4(0x01B322)) + prev(low4(0x01B33E))) == 0) ||
               ((prev(high4(0x01B323)) + prev(high4(0x01B33F))) == 0) ||
               ((prev(low4(0x01B323)) + prev(low4(0x01B33F))) == 0) ||
               ((prev(high4(0x01B324)) + prev(high4(0x01B340))) == 0) ||
               ((prev(low4(0x01B324)) + prev(low4(0x01B340))) == 0) ||
               ((prev(high4(0x01B325)) + prev(high4(0x01B341))) == 0) ||
               ((prev(low4(0x01B325)) + prev(low4(0x01B341))) == 0) ||
               ((prev(high4(0x01B326)) + prev(high4(0x01B342))) == 0) ||
               ((prev(low4(0x01B326)) + prev(low4(0x01B342))) == 0) ||
               ((prev(high4(0x01B327)) + prev(high4(0x01B343))) == 0) ||
               ((prev(low4(0x01B327)) + prev(low4(0x01B343))) == 0) ||
               ((prev(high4(0x01B328)) + prev(high4(0x01B344))) == 0) ||
               ((prev(low4(0x01B328)) + prev(low4(0x01B344))) == 0) ||
               ((prev(high4(0x01B329)) + prev(high4(0x01B345))) == 0) ||
               ((prev(low4(0x01B329)) + prev(low4(0x01B345))) == 0) ||
               ((prev(high4(0x01B32A)) + prev(high4(0x01B346))) == 0) ||
               ((prev(low4(0x01B32A)) + prev(low4(0x01B346))) == 0) ||
               ((prev(high4(0x01B32B)) + prev(high4(0x01B347))) == 0) ||
               ((prev(low4(0x01B32B)) + prev(low4(0x01B347))) == 0) ||
               ((prev(high4(0x01B32C)) + prev(high4(0x01B348))) == 0) ||
               ((prev(low4(0x01B32C)) + prev(low4(0x01B348))) == 0) ||
               ((prev(high4(0x01B32D)) + prev(high4(0x01B349))) == 0) ||
               ((prev(low4(0x01B32D)) + prev(low4(0x01B349))) == 0) ||
               ((prev(high4(0x01B32E)) + prev(high4(0x01B34A))) == 0) ||
               ((prev(low4(0x01B32E)) + prev(low4(0x01B34A))) == 0) ||
               ((prev(high4(0x01B32F)) + prev(high4(0x01B34B))) == 0) ||
               ((prev(low4(0x01B32F)) + prev(low4(0x01B34B))) == 0) ||
               ((prev(high4(0x01B330)) + prev(high4(0x01B34C))) == 0) ||
               ((prev(low4(0x01B330)) + prev(low4(0x01B34C))) == 0) ||
               ((prev(high4(0x01B331)) + prev(high4(0x01B34D))) == 0) ||
               ((prev(low4(0x01B331)) + prev(low4(0x01B34D))) == 0) ||
               ((prev(high4(0x01B332)) + prev(high4(0x01B34E))) == 0) ||
               ((prev(low4(0x01B332)) + prev(low4(0x01B34E))) == 0) ||
               ((prev(high4(0x01B333)) + prev(high4(0x01B34F))) == 0) ||
               ((prev(low4(0x01B333)) + prev(low4(0x01B34F))) == 0) ||
               ((prev(high4(0x01B334)) + prev(high4(0x01B350))) == 0) ||
               ((prev(low4(0x01B334)) + prev(low4(0x01B350))) == 0) ||
               ((prev(high4(0x01B335)) + prev(high4(0x01B351))) == 0) ||
               ((prev(low4(0x01B335)) + prev(low4(0x01B351))) == 0) ||
               ((prev(high4(0x01B336)) + prev(high4(0x01B352))) == 0) ||
               ((prev(low4(0x01B336)) + prev(low4(0x01B352))) == 0) ||
               ((prev(low4(0x01B337)) + prev(low4(0x01B353))) == 0))
)

achievement(
    title = "Your Clock is Useless", description = "You've Defeated the Chronomage as Soma", points = 5,
    id = 3155, badge = "03634", published = "10/4/2013 3:18:30 AM", modified = "10/17/2018 3:44:16 AM",
    trigger =
        bit0(0x01B3A5) > prev(bit0(0x01B3A5))
        && never_not_in_game()
)

achievement(
    title = "Hey! Get Back Here!", description = "You've Defeated a Sky Fish as Soma", points = 5,
    id = 3154, badge = "03633", published = "10/4/2013 3:07:24 AM", modified = "10/12/2019 2:57:17 AM",
    trigger =
        bit1(0x01B3AA) > prev(bit1(0x01B3AA))
        && never_not_in_game()
)

achievement(
    title = "Sword of Light", description = "Obtained the Claimh Solais", points = 5,
    id = 3084, badge = "03557", published = "10/1/2013 5:37:58 AM", modified = "10/17/2018 3:45:13 AM",
    trigger =
        byte(0x01B2CD) > prev(byte(0x01B2CD))
        && never_not_in_game()
)

achievement(
    title = "The Sword in the Stone", description = "Obtained Excalibur", points = 5,
    id = 3091, badge = "03576", published = "10/2/2013 12:11:12 AM", modified = "10/17/2018 3:45:35 AM",
    trigger =
        byte(0x01B2D8) > prev(byte(0x01B2D8))
        && never_not_in_game()
)

achievement(
    title = "Lazer Gun", description = "Obtained Positron Rifle", points = 5,
    id = 3088, badge = "03575", published = "10/2/2013 12:06:45 AM", modified = "10/17/2018 3:45:58 AM",
    trigger =
        byte(0x01B2ED) > prev(byte(0x01B2ED))
        && never_not_in_game()
)

achievement(
    title = "Sword of Many Slashes", description = "Obtained the Valmanway", points = 10,
    id = 3087, badge = "03572", published = "10/2/2013 12:02:14 AM", modified = "7/29/2019 10:05:13 PM",
    trigger =
        byte(0x01B2EE) > prev(byte(0x01B2EE))
        && never_not_in_game()
)

achievement(
    title = "Deep Pockets", description = "Obtained 200,000 Gold", points = 10,
    id = 3132, badge = "03600", published = "10/3/2013 2:10:58 AM", modified = "11/16/2019 1:11:03 AM",
    trigger =
        prev(dword(0x01B290)) < 200000 && dword(0x01B290) >= 200000
        && never_not_in_game()
)

achievement(
    title = "Eater of Souls", description = "Obtained the Soul Eater Ring", points = 10,
    id = 3089, badge = "03573", published = "10/2/2013 12:06:56 AM", modified = "7/29/2019 10:05:18 PM",
    trigger =
        byte(0x01B317) > prev(byte(0x01B317))
        && never_not_in_game()
)

achievement(
    title = "Infinite MP!", description = "Obtained the Chaos Ring", points = 25,
    id = 3090, badge = "03574", published = "10/2/2013 12:07:06 AM", modified = "7/29/2019 10:05:21 PM",
    trigger =
        byte(0x01B31B) > prev(byte(0x01B31B))
        && never_not_in_game()
)

achievement(
    title = "HARD Exclusives", description = "Obtained all HARD Mode Exclusive Items", points = 10,
    id = 3134, badge = "03601", published = "10/3/2013 4:13:12 AM", modified = "3/15/2019 6:30:54 AM",
    trigger =
        never_not_in_game()
        && byte(0x01B2EC) >= 1 && byte(0x01B2E7) >= 1 && byte(0x01B302) >= 1
        && byte(0x01B314) >= 1 && byte(0x01B2DB) >= 1
        && ((repeated(120, byte(0x01B2EC) == 0))
            || (repeated(120, byte(0x01B2E7) == 0))
            || (repeated(120, byte(0x01B302) == 0))
            || (repeated(120, byte(0x01B314) == 0))
            || (repeated(120, byte(0x01B2DB) == 0)))
)
