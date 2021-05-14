import argparse
import os
import re

from collections import namedtuple

ap = argparse.ArgumentParser()
ap.add_argument('emulator_dir')
args = ap.parse_args()

data_dir = os.path.join(args.emulator_dir, "RACache/Data")
user_fname = os.path.join(data_dir, "6578-User.txt")
tmp_user_fname = os.path.join(data_dir, "6578-User.tmp.txt")
bak_user_fname = os.path.join(data_dir, "6578-User.bak.txt")

cheevo_re = re.compile(r'^(?P<prefix>[0-9]+:")(?P<trigger>[^"]+)":"(?P<name>[^"]+)(?P<suffix>".*)$')

PauseLock = namedtuple('PauseLock', ['pause', 'reset'])
pause_locks = {
  # score exploit
  '0xH001234=17' : PauseLock(
    'R:d0xH00009e!=0xH00009e_A:2=0_N:d0xH00014a=0xH00014a_N:d0xH00014b=48_C:0xH00014b=53_A:3=0_N:d0xH00014a=0xH00014a_N:d0xH00014b=53_C:0xH00014b=48_B:7=0_N:d0xH00014a=0xH00014a_N:d0xH00014b=53_C:0xH00014b=48_B:8=0_N:d0xH00014a=0xH00014a_N:d0xH00014b=48_P:0xH00014b=53.20.',
    'R:0xH0000ff=0')
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
