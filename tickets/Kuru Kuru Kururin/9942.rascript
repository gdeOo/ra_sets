// Kuru Kuru Kururin
// #ID = 5377

// $004436: ModeAndDifficulty - 1=NormalAdv, 2EasyAdv, 3=Challenge, 5=Practice, 7=MakeUp, else 0 (setting this to 4 and doing adventure will make you automatically get 0.00 on each stage and win)
function mode_and_difficulty() => byte(0x004436)

function in_normal_adventure() => mode_and_difficulty() == 1
function in_easy_or_normal_adventure() => mode_and_difficulty() <= 2

// $044138: Training 5 Completion
function training_5_completed() => byte(0x044138) > 0

achievement(
    title = "Complete Training (Normal)", description = "Complete the training stages on normal difficulty.", points = 2,
    id = 21252, badge = "21154", published = "2/22/2015 10:35:48 PM", modified = "11/1/2019 5:59:46 AM",
    trigger =
        in_normal_adventure()
        && training_5_completed()
)

// Ticket 9942: Achieved just by skipping training. I may have also gone back into the training menu from the
//               grasslands 1.
//               MD5: 48f3bc6bf59c34f057bd98b29fd7b848
achievement(
    title = "Complete Training (Easy)", description = "Complete the training stages on easy or higher difficulty.", points = 1,
    id = 21253, badge = "21155", published = "2/22/2015 10:35:51 PM", modified = "11/1/2019 5:59:51 AM",
    trigger =
        in_easy_or_normal_adventure()
        && training_5_completed()
)
