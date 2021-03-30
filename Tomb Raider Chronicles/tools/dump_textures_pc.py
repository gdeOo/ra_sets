import argparse
import io
import struct
import os
import zlib

from collections import namedtuple
from glob import glob
from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument('input_dir', help='Directory containing *.trc level files from the PC version')
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

tr_textile16 = namedtuple('tr_textile16', ['tile'])
def read_tr_textile16(f):
  return tr_textile16([readu16(f) for _ in range(256 * 256)])

tr_textile32 = namedtuple('tr_textile32', ['tile'])
def read_tr_textile32(f):
  return tr_textile32([readu32(f) for _ in range(256 * 256)])

def textile16_to_rgba(tex):
  return [(
    (((x & 0x7c00) >> 10) << 3) + 3,
    (((x & 0x03e0) >> 5) << 3) + 3,
    ((x & 0x001f) << 3) + 3,
    0xff if (x & 0x8000) != 0 else 0
  ) for x in tex.tile]

def textile32_to_rgba(tex):
  return [(
    (x & 0x00ff0000) >> 16,
    (x & 0x0000ff00) >> 8,
    (x & 0x000000ff),
    ((x & 0xff000000) >> 24)
  ) for x in tex.tile]

def read_compressed(f):
  uncompressed_size = readu32(f)
  compressed_size = readu32(f)
  compressed_block = f.read(compressed_size)
  uncompressed_block = zlib.decompress(compressed_block)
  return io.BytesIO(uncompressed_block)

level_files = glob(os.path.join(args.input_dir, '*.trc'))

for level_fname in level_files:
  level_name = os.path.splitext(os.path.basename(level_fname))[0]
  dump_dir = os.path.join(args.output_dir, level_name)
  if not os.path.exists(dump_dir):
    os.makedirs(dump_dir)

  with open(level_fname, 'rb') as f:
    version = readu32(f)

    num_room_textiles = readu16(f)
    num_obj_textiles = readu16(f)
    num_bump_textiles = readu16(f)
    num_textiles = num_room_textiles + num_obj_textiles + num_bump_textiles

    b = read_compressed(f)
    textiles32 = [read_tr_textile32(b) for _ in range(num_textiles)]
    b = read_compressed(f)
    textiles16 = [read_tr_textile16(b) for _ in range(num_textiles)]

    for i, tex in enumerate(textiles16):
      rgba = textile16_to_rgba(tex)
      img = Image.new("RGBA", (256, 256))
      img.putdata(rgba)
      img.save(os.path.join(dump_dir, f"16_{i}.png"))

    for i, tex in enumerate(textiles32):
      rgb = textile32_to_rgba(tex)
      img = Image.new("RGBA", (256, 256))
      img.putdata(rgb)
      img.save(os.path.join(dump_dir, f"32_{i}.png"))
