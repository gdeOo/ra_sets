import argparse
import os
import re

from collections import namedtuple

ap = argparse.ArgumentParser()
ap.add_argument('emulator_dir')
args = ap.parse_args()

data_dir = os.path.join(args.emulator_dir, "RACache/Data")
user_fname = os.path.join(data_dir, "11377-User.txt")
tmp_user_fname = os.path.join(data_dir, "11377-User.tmp.txt")
bak_user_fname = os.path.join(data_dir, "11377-User.bak.txt")

cheevo_re = re.compile(r'^(?P<prefix>[0-9]+:")(?P<trigger>[^"]+)":"(?P<name>[^"]+)(?P<suffix>".*)$')

PauseLock = namedtuple('PauseLock', ['pause', 'reset'])
pause_locks = {
  # Streets of Rome
  '0xH000555=1' : PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cf3e9=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cec99=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1ccbf9=0_N:0xT1ceb79=0_P:0xH0a7314>0.1.',
    'R:0xX1fffc0=70828'),

  # Trajan's Markets
  '0xH000555=2': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d560d=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d521d=0_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d30ed=0_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d290d=0_P:0xH0a7318=1.1.',
    'R:0xX1fffc0=70828'),

  # Colosseum
  '0xH000555=3': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bc839=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bf149=0_C:0xN0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_A:0xT1bdb59=0_N:0xT1bd409<2_P:0xH0a7317=1.1.',
    'R:0xX1fffc0=70828'),

  # The Base
  '0xH000555=4': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d1985=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d36c5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d2d35=0_N:0xT1d6695=0_P:0xS0a7322>0.1.',
    'R:0xX1fffc0=70828'),

  # The Submarine
  '0xH000555=5': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7dd9=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7b09=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d2469=0_N:0xT1d3c99<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d94e9=0_N:0xT1d8919<2_P:0xH0a7317=1.1.',
    'R:0xX1fffc0=70828'),

  # Deepsea Dive
  '0xH000555=6': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=6_N:0xH09cd21!=1_N:0xM0a3ced=0_P:0xM0a7326=1.1.',
    'R:0xX1fffc0=70828'),

  # Sinking Submarine
  '0xH000555=7': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1dd915=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db1b5=0_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db905=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1da3a5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xR0a3ce9=0_P:0xS0a7322=1.1.',
    'R:0xX1fffc0=70828'),

  # Gallows Tree
  '0xH000555=8': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_N:0xT1c36fd=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xO1c3638=0_N:0xN1c3638<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xT1c3c9d=0_N:0xT1c486d<2_P:0xH0a7315=1.1.',
    'R:0xX1fffc0=70828'),

  # Old Mill
  '0xH000555=9': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xT1d38dd=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xO0a3cec=0_N:0xH0a7314=1_P:0xX0a2c08!=34.1.',
    'R:0xX1fffc0=70828'),

  # Labyrinth
  '0xH000555=10': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8611=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8221=0_P:0xH0a7315=1.1.',
    'R:0xX1fffc0=70828'),

  # The 13th Floor
  '0xH000555=11': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1cecc9=0_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1d5059=0_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1ce579=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1cf149=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1d1ae9=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_P:0xM0a7326=1.1.',
    'R:0xX1fffc0=70828'),

  # Escape With the Iris
  '0xH000555=12': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_N:0xT1cb2fd=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_N:0x 1cdbfe=233_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_P:0xM0a7326=1.1.',
    'R:0xX1fffc0=70828'),

  # Red Alert
  '0xH000555=14': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=14_N:0xH09cd21!=1_A:0xT1cb505=0_N:0xT1cab75<2_P:0xH0a7314=1.1.',
    'R:0xX1fffc0=70828'),

  # Rome arc
  '0xH000555=101': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cf3e9=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cec99=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1ccbf9=0_N:0xT1ceb79=0_C:0xH0a7314>0_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d560d=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d521d=0_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d30ed=0_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d290d=0_C:0xH0a7318=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bc839=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bf149=0_C:0xN0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_A:0xT1bdb59=0_N:0xT1bd409<2_P:0xH0a7317=1.1.',
    'R:0xX1fffc0=70828'),

  # Russian Submarine arc
  '0xH000555=104': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d1985=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d36c5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d2d35=0_N:0xT1d6695=0_C:0xS0a7322>0_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7dd9=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7b09=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d2469=0_N:0xT1d3c99<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d94e9=0_N:0xT1d8919<2_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=6_N:0xH09cd21!=1_N:0xM0a3ced=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1dd915=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db1b5=0_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db905=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1da3a5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xR0a3ce9=0_P:0xS0a7322=1.1.',
    'R:0xX1fffc0=70828'),

  # Black Isle arc
  '0xH000555=108': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_N:0xT1c36fd=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xO1c3638=0_N:0xN1c3638<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xT1c3c9d=0_N:0xT1c486d<2_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xT1d38dd=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xO0a3cec=0_N:0xH0a7314=1_C:0xX0a2c08!=34_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8611=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8221=0_P:0xH0a7315=1.1.',
    'R:0xX1fffc0=70828'),

  # Any Level
  '0xH000555=255': PauseLock(
    'N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cf3e9=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1cec99=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=1_N:0xH09cd21!=1_N:0xT1ccbf9=0_N:0xT1ceb79=0_C:0xH0a7314>0_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d560d=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d521d=0_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d30ed=0_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=2_N:0xH09cd21!=1_N:0xT1d290d=0_C:0xH0a7318=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bc839=0_C:0xM0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bf149=0_C:0xN0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_N:0xT1bdeb9=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=3_N:0xH09cd21!=1_A:0xT1bdb59=0_N:0xT1bd409<2_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d1985=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d36c5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=4_N:0xH09cd21!=1_N:0xT1d2d35=0_N:0xT1d6695=0_C:0xS0a7322>0_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7dd9=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_N:0xT1d7b09=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d2469=0_N:0xT1d3c99<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=5_N:0xH09cd21!=1_A:0xT1d94e9=0_N:0xT1d8919<2_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=6_N:0xH09cd21!=1_N:0xM0a3ced=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1dd915=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db1b5=0_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1db905=0_C:0xR0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xT1da3a5=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=7_N:0xH09cd21!=1_N:0xR0a3ce9=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_N:0xT1c36fd=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xO1c3638=0_N:0xN1c3638<2_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=8_N:0xH09cd21!=1_A:0xT1c3c9d=0_N:0xT1c486d<2_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xT1d38dd=0_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=9_N:0xH09cd21!=1_N:0xO0a3cec=0_N:0xH0a7314=1_C:0xX0a2c08!=34_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8611=0_C:0xH0a7314=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=10_N:0xH09cd21!=1_N:0xT1c8221=0_C:0xH0a7315=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1cecc9=0_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1d5059=0_C:0xH0a7317=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1ce579=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1cf149=0_C:0xS0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_N:0xT1d1ae9=0_C:0xT0a7322=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=11_N:0xH09cd21!=1_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_N:0xT1cb2fd=0_C:0xN0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_N:0x 1cdbfe=233_C:0xH0a7316=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=12_N:0xH09cd21!=1_C:0xM0a7326=1_N:0xX1fffc0=70564_N:0xX0a39cc=0_N:0xH0a3a88=14_N:0xH09cd21!=1_A:0xT1cb505=0_N:0xT1cab75<2_P:0xH0a7314=1.1.',
    'R:0xX1fffc0=70828')
}

AltGroup = namedtuple('AltGroup', ['conditions'])
alt_groups = {}

def split_trigger(trigger):
  groups = []
  group_start = 0
  search_start = 0
  try:
    while True:
      i = trigger.index('S', search_start)
      if trigger[i-2:i] != '0x':
        groups.append(trigger[group_start:i])
        group_start = i + 1
      search_start = i + 1
  except ValueError:
    groups.append(trigger[group_start:])
    return groups

with open(user_fname, 'r') as user_f, open(tmp_user_fname, 'w') as tmp_user_f:
  for line in user_f:
    ma = cheevo_re.match(line)
    if not ma:
      tmp_user_f.write(line)
      continue

    name  = ma.group('name')
    trigger = ma.group('trigger')

    groups = split_trigger(trigger)
    core, alts = groups[0], groups[1:]

    pause_lock_reset = ''
    for placeholder, pause_lock in pause_locks.items():
      if placeholder + '_' not in core:
        continue

      print(f"{name}: pause lock: {placeholder}")

      # remove the placeholder
      core = core.replace('_' + placeholder, '')
      core = core.replace(placeholder + '_', '')

      # the pause goes in the core group
      core = core + "_" + pause_lock.pause

      # add to the global pause lock reset
      if pause_lock.reset not in pause_lock_reset:
        pause_lock_reset += '_' + pause_lock.reset

    for placeholder, alt_group in alt_groups.items():
      if placeholder not in core:
        continue

      print(f"{name}: alt_group: {placeholder}")

      # remove the placeholder
      core = core.replace('_' + placeholder, '')
      core = core.replace(placeholder + '_', '')

      # add the alt group after core
      if len(alts) == 0:
        alts = ["1=1", "1=0_" + alt_group.conditions]
      else:
        alts = ["1=0_" + alt_group.conditions] + alts

    # the pause lock reset goes into its own alt
    if pause_lock_reset != '':
      if len(alts) == 0:
        alts = ["1=1_" + pause_lock.reset]  # single alt must be true
      else:
        alts = ["1=0_" + pause_lock.reset] + alts

    trigger = 'S'.join([core] + alts)

    tmp_user_f.write(ma.group('prefix') + trigger + '":"'
                     + ma.group('name') + ma.group('suffix') + '\n')

if os.path.isfile(bak_user_fname):
  os.remove(bak_user_fname)
os.rename(user_fname, bak_user_fname)
os.rename(tmp_user_fname, user_fname)
