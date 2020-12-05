import argparse
import struct
import os

from collections import namedtuple
from glob import glob
from PIL import Image
from shutil import copyfile

ap = argparse.ArgumentParser()
ap.add_argument('data_orig_dir', help='Directory containing unmodified *.TR2 level files from the PC version (must not be the game\'s data directory)')
ap.add_argument('textures_dir', help='Directory containing modified textures (same structure as the output of dump_textures_pc.py)')
ap.add_argument('game_data_dir', help='Data directory of the PC version (ex: C:\SteamLibrary\steamqpps\common\Tomb Raider (II)\data)')
ap.add_argument('--reset', action='store_true', help='Reset to the unmodified version of levels')
args = ap.parse_args()

def readu32(f):
  return struct.unpack('<I', f.read(4))[0]

for orig_fname in glob(os.path.join(args.data_orig_dir, '*.tr2')):
  dst_fname = os.path.join(args.game_data_dir, os.path.basename(orig_fname))
  copyfile(orig_fname, dst_fname)
  if args.reset:
    continue

  level_name = os.path.splitext(os.path.basename(orig_fname))[0]

  with open(dst_fname, 'rb+') as lf:
    lf.seek(
      4          # version
      + 256 * 3  # palette
      + 256 * 4  # palette 16
    )
    n_tex_tiles = readu32(lf)
    lf.seek(256 * 256 * n_tex_tiles, 1)       # tex tiles 8

    base = lf.tell()

    for new_texture in glob(os.path.join(args.textures_dir, f'{level_name}/16_*.png')):
      n = int(os.path.basename(new_texture).replace('16_', '').replace('.png', ''))

      img = Image.open(new_texture)
      argb = [(
        (int(p[3] / 255) << 15)
        | (int(p[0] * 31 / 255) << 10)
        | (int(p[1] * 31 / 255) << 5)
        | (int(p[2] * 31 / 255))
      ) for p in img.getdata()]

      argb_packed = bytes([xx for x in argb for xx in [(x & 0xff), (x & 0xff00) >> 8]])

      lf.seek(base + 256 * 256 * 2 * n)
      lf.write(argb_packed)
