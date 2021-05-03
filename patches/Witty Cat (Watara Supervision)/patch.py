import argparse
import shutil

parser = argparse.ArgumentParser("Patch Witty Cat (Watara Supervision)")
parser.add_argument("in_original")
parser.add_argument("out_patched")

args = parser.parse_args()

print(f"Patching '{args.in_original}' into '{args.out_patched}'...")

shutil.copyfile(args.in_original, args.out_patched)

with open(args.out_patched, 'r+b') as patched:

  # The game only tries to render 16 items, but the 9th level contains 20,
  # making the last 4 invisible. Invisible items are still collectible. However,
  # the very last item, in addition to being invisible, is also placed above a
  # drop and has no floor under it, making it uncollectible and the level
  # unbeatable.
  # 
  # It's unclear whether the extra 4 items were intended to exist or are there
  # by mistake/bug. The uncollectible item could be fixed by moving it a little
  # bit to the left, and the items could be made visible by forcing the game
  # to render 20 items instead of 16. However, we deemed the level difficult
  # enough, and decided to just cut the extra 4 items out. Note that all other
  # levels only have 10 items, so the last level still has significantly more
  # at 16.

  # patch the number of items in the last level from 0x14 to 0x10
  patched.seek(0xf773)
  patched.write(b'\x10')

  # patch the level data to remove the 4 items. otherwise the game will
  # interpret the x-positions of the last 4 items as the y-positions of the
  # first 4 and so on...
  patched.seek(0x096b)
  patched.write(
    # x positions
    b'\x08\x08\x08\x08\x18\x42\x42\x42\x42\x42\x48\x54\x54\x54\x54\x84'

    # y positions
    b'\x48\x60\x78\x90\xa8\x00\x30\xa8\xc0\xd8\x78\x18\x48\xa8\xd8\x18'

    # sprites
    b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x00\x01\x02\x03\x04\x05'
  )
