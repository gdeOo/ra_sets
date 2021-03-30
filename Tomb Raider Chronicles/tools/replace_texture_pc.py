import argparse
import io
import struct
import os
import zlib

from collections import namedtuple
from glob import glob
from PIL import Image
from shutil import copyfile

ap = argparse.ArgumentParser()
ap.add_argument('data_orig_dir', help='Directory containing unmodified *.trc level files from the PC version (must not be the game\'s data directory)')
ap.add_argument('textures_dir', help='Directory containing modified textures (same structure as the output of dump_textures_pc.py)')
ap.add_argument('game_data_dir', help='Data directory of the PC version (ex: F:\GOG Games\Tomb Raider 5\data)')
ap.add_argument('--level', type=str, help='Name of level to modify (all if not provided)')
ap.add_argument('--reset', action='store_true', help='Reset to the unmodified version of levels')
args = ap.parse_args()

def readu32(f):
  return struct.unpack('<I', f.read(4))[0]

def writeu32(f, v):
  f.write(struct.pack('<I', v))

def read_compressed(f):
  uncompressed_size = readu32(f)
  compressed_size = readu32(f)
  compressed_block = f.read(compressed_size)
  uncompressed_block = zlib.decompress(compressed_block)
  return io.BytesIO(uncompressed_block)

for orig_fname in glob(os.path.join(args.data_orig_dir, '*.trc')):
  level_name = os.path.splitext(os.path.basename(orig_fname))[0]
  if args.level is not None and args.level != level_name:
    continue

  dst_fname = os.path.join(args.game_data_dir, os.path.basename(orig_fname))
  if args.reset:
    copyfile(orig_fname, dst_fname)
    continue

  with open(orig_fname, 'rb') as inf:
    with open(dst_fname, 'wb') as outf:
      outf.write(inf.read(
        4            # version
        + 2 + 2 + 2  # num textiles
      ))

      # discard the old textile32
      b = read_compressed(inf)

      # compress and write the new textile32
      new_textures = sorted(
        glob(os.path.join(args.textures_dir, f'{level_name}/32_*.png')),
        key=lambda f: int(os.path.basename(f).replace('32_', '').replace('.png', ''))
      )

      uncompressed_block = io.BytesIO()
      for new_texture in new_textures:
        img = Image.open(new_texture).convert("RGBA")
        argb = [(p[3] << 24
                 | p[0] << 16
                 | p[1] << 8
                 | p[2]) for p in img.getdata()]

        for pixel in argb:
          writeu32(uncompressed_block, pixel)

      uncompressed_block = uncompressed_block.getvalue()
      compressed_block = zlib.compress(uncompressed_block)

      writeu32(outf, len(uncompressed_block))
      writeu32(outf, len(compressed_block))
      outf.write(compressed_block)

      # copy everything else
      outf.write(inf.read())
