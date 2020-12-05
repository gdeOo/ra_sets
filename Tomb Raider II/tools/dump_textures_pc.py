import argparse
import struct
import os

from collections import namedtuple
from glob import glob
from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument('input_dir', help='Directory containing *.TR2 level files from the PC version')
ap.add_argument('output_dir', help='Output directory')
args = ap.parse_args()

def advance(f, n):
  f.read(n)

def readu8(f):
  return struct.unpack('<B', f.read(1))[0]

def read16(f):
  return struct.unpack('<h', f.read(2))[0]

def readu16(f):
  return struct.unpack('<H', f.read(2))[0]

def read32(f):
  return struct.unpack('<i', f.read(4))[0]

def readu32(f):
  return struct.unpack('<I', f.read(4))[0]

tr_colour = namedtuple('tr_colour', ['red', 'green', 'blue'])
def read_tr_colour(f):
  return tr_colour(readu8(f), readu8(f), readu8(f))

tr_colour4 = namedtuple('tr_colour4', ['red', 'green', 'blue', 'unused'])
def read_tr_colour4(f):
  return tr_colour4(readu8(f), readu8(f), readu8(f), readu8(f))

tr_textile8 = namedtuple('tr_textile8', ['tile'])
def read_tr_textile8(f):
  return tr_textile8([readu8(f) for _ in range(256 * 256)])

tr_textile16 = namedtuple('tr_textile16', ['tile'])
def read_tr_textile16(f):
  return tr_textile16([readu16(f) for _ in range(256 * 256)])

def tex_tile8_to_rgb(tex, palette):
  return [(
    int(palette[x].red * 255 / 63),
    int(palette[x].green * 255 / 63),
    int(palette[x].blue * 255 / 63)
  ) for x in tex.tile]

def tex_tile16_to_rgba(tex):
  return [(
    int(((x & 0x7c00) >> 10) * 255 / 31),
    int(((x & 0x03e0) >> 5) * 255 / 31),
    int((x & 0x001f) * 255 / 31),
    ((x & 0x8000) >> 15) * 255
  ) for x in tex.tile]

level_files = glob(os.path.join(args.input_dir, '*.tr2'))

for level_fname in level_files:
  level_name = os.path.splitext(os.path.basename(level_fname))[0]
  dump_dir = os.path.join(args.output_dir, level_name)
  if not os.path.exists(dump_dir):
    os.makedirs(dump_dir)

  with open(level_fname, 'rb') as f:
    version = readu32(f)

    palette = [read_tr_colour(f) for _ in range(256)]
    palette16 = [read_tr_colour4(f) for _ in range(256)]

    n_tex_tiles = readu32(f)
    tex_tiles8 = [read_tr_textile8(f) for _ in range(n_tex_tiles)]
    tex_tiles16 = [read_tr_textile16(f) for _ in range(n_tex_tiles)]

    for i, tex in enumerate(tex_tiles8):
      rgb = tex_tile8_to_rgb(tex, palette)
      img = Image.new("RGB", (256, 256))
      img.putdata(rgb)
      img.save(os.path.join(dump_dir, f"8_{i}.png"))

    for i, tex in enumerate(tex_tiles16):
      rgba = tex_tile16_to_rgba(tex)
      img = Image.new("RGBA", (256, 256))
      img.putdata(rgba)
      img.save(os.path.join(dump_dir, f"16_{i}.png"))
