import argparse
import shutil

parser = argparse.ArgumentParser("Patch Chimera (Watara Supervision)")
parser.add_argument("in_original")
parser.add_argument("out_patched")

args = parser.parse_args()

print(f"Patching '{args.in_original}' into '{args.out_patched}'...")

shutil.copyfile(args.in_original, args.out_patched)

with open(args.out_patched, 'r+b') as patched:

  # PART 1: Make the 4th warhead collectible.
  #
  # Make the torch work in the dark room.
  # Original code related to using the torch is:
  #   if (cur_item == TORCH && room_background == 0x01) { ... }
  # ...but there's no room with a 0x01 background value.
  # The dark room, where the torch is meant to be used, has a background value
  # of 0xff, so patch that in.

  patched.seek(0xfefe)
  patched.write(b'\xff')

  # PART 1.1: Fix torch's pick-up message
  #
  # When the torch is picked up, the message reads: "YOU HAVE FOUND A YOU HAVE"
  # Should read "YOU HAVE FOUND A TORCH" instead...

  patched.seek(0xfd48)
  patched.write(b'\x13')

  # PART 2: Ending sequence.
  #
  # When all 4 warheads are active, the player is told to escape through the
  # dimly lit room near the beginning, but doing so doesnt trigger anything,
  # even though the game actually has a beat-the-game string:
  # "CONGRATULATIONS YOU HAVE SUCCESSFULLY COMPLETED MISSION CHIMERA"
  #
  # To make an ending sequence, we patch the location where the game prints
  # the "THIS IS A DARK ROOM" message, to also check whether the player has
  # entered the dimly lit room with 4 active warheads. If that's the case,
  # print the existing beat-the-game string and trigger a fade out like the
  # one that happens upon death (except without the scream). Also give the
  # player an extra 500 points (:

  patched.seek(0xf4b8)
  patched.write(
    b'\x4c\xa0\xff'  # JMP  0xffa0  (jumps into our code)
    b'\xea\xea\xea'  # 13 NOPs     (unnecessary, but might as well...)
    b'\xea\xea\xea'
    b'\xea\xea\xea'
    b'\xea\xea\xea'
    b'\xea'
  )

  patched.seek(0xffa0)
  patched.write(
    # code we erased from the patch site:
    #
    # if (cur_room_background == 0xff)
    #   display_msg(THIS_IS_A, DARK_ROOM, 0);

    b'\xad\x56\x02'  # LDA  cur_room_background
    b'\xc9\xff'      # CMP  #0xff
    b'\xd0\x09'      # BNE  0xffb0
    b'\xa9\x12'      # LDA  #0x12
    b'\xa2\x1a'      # LDA  #0x1a
    b'\xa0\x00'      # LDY  #0x00
    b'\x20\xd0\xe4'  # JSR  display_msg

    # new code to trigger the ending sequence
    #
    # if (cur_room_background == 0xaa && n_activated_warheads == 4) {
    #   display_msg(CONGRATULATIONS_YOU_HAVE_SUCCESSFULLY_COMPLETED_MISSION_CHIMERA,0,0);
    #   score += 500;
    #   screen_fade_out(0);
    #   goto post_death;
    # }
    b'\xad\x56\x02'  # LDA  cur_room_background
    b'\xc9\xaa'      # CMP  #0xaa
    b'\xd0\x34'      # BNE  0xffeb
    b'\xad\xa9\x02'  # LDA  n_activated_warheads
    b'\xc9\x04'      # CMP  #0x04
    b'\xd0\x2d'      # BNE  0xffeb
    b'\xa9\x20'      # LDA  #0x20
    b'\xa2\x00'      # LDX  #0x00
    b'\xa0\x00'      # LDY  #0x00
    b'\x20\xd0\xe4'  # JSR  display_msg

    # give 500 points
    b'\xa9\xfa'      # LDA  #0xfa
    b'\x18'          # CLC
    b'\x6d\x22\x02'  # ADC  score.lo
    b'\x8d\x22\x02'  # STA  score.lo
    b'\x90\x03'      # BCC  0xffd5
    b'\xee\x23\x02'  # INC  score.hi
    b'\xa9\xfa'      # LDA  #0xfa
    b'\x18'          # CLC
    b'\x6d\x22\x02'  # ADC  score.lo
    b'\x8d\x22\x02'  # STA  score.lo
    b'\x90\x03'      # BCC  0xffe3
    b'\xee\x23\x02'  # INC  score.hi

    # copy the death sequence, but without the scream
    b'\xa9\x00'      # LDA  #0x00
    b'\x20\x00\xe0'  # JSR  screen_fade_out
    b'\x4c\x3f\xe3'  # JMP  0xe33f

    # go back to the location we originally patched,
    # if the ending sequence was not triggered
    b'\x4c\xc8\xf4'  # JMP  0xf4c8
  )
