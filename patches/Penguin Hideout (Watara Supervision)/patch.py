import argparse
import shutil

parser = argparse.ArgumentParser("Patch Penguin Hideout (Watara Supervision)")
parser.add_argument("in_original")
parser.add_argument("out_patched")

args = parser.parse_args()

print(f"Patching '{args.in_original}' into '{args.out_patched}'...")

shutil.copyfile(args.in_original, args.out_patched)

with open(args.out_patched, 'r+b') as patched:

  # Level 45 is impossible to beat because it doesn't contain any diamonds.
  #
  # The obvious fix would be to put some diamonds in it, essentially making up
  # a new level...
  #
  # There's, however, a demo level that isn't usually available to play. We can
  # repurpose that level as level 45, thus fixing the issue using a level that
  # was already in the game.

  patched.seek(0x30fa)
  demo_level = patched.read(0x1e)
  patched.seek(0x3046)
  patched.write(demo_level)
