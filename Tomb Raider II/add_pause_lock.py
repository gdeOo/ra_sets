import argparse
import os
import re

from collections import namedtuple

ap = argparse.ArgumentParser()
ap.add_argument('emulator_dir')
args = ap.parse_args()

data_dir = os.path.join(args.emulator_dir, "RACache/Data")
user_fname = os.path.join(data_dir, "11341-User.txt")
tmp_user_fname = os.path.join(data_dir, "11341-User.tmp.txt")
bak_user_fname = os.path.join(data_dir, "11341-User.bak.txt")

cheevo_re = re.compile(r'^(?P<prefix>[0-9]+:")(?P<trigger>[^"]+)":"(?P<name>[^"]+)(?P<suffix>".*)$')

PauseLock = namedtuple('PauseLock', ['pause', 'reset'])
pause_locks = {
  # level skip + all guns
  '0x 000001=1': PauseLock(
    'P:0x 087a20=18.1._P:0x 087a20=16.1.',
    'N:0xH085a49!=1_R:0x 089ce8=1'
  ),

  # corner bug
  '0x 000003=3': PauseLock(
    'd0xX087a7c!=0_I:0xX08c6b8_N:0x 00000e=28_N:d0xT08c51f=1_N:0xT08c51f=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=28_N:d0xT08c51f!=1_N:0xT08c51f!=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=28_N:d0xT08c51f!=1_N:0xT08c51f=1_A:d0xX08c51c_B:0xX08c51c_P:0>=501.1._I:0xX08c6b8_N:0x 00000e=1_N:d0xT08c51f=1_N:0xT08c51f=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=1_N:d0xT08c51f!=1_N:0xT08c51f!=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=1_N:d0xT08c51f!=1_N:0xT08c51f=1_A:d0xX08c51c_B:0xX08c51c_P:0>=501.1._I:0xX08c6b8_N:0x 00000e=17_N:d0xT08c51f=1_N:0xT08c51f=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=17_N:d0xT08c51f!=1_N:0xT08c51f!=1_N:d0xX08c51c>0xX08c51c_B:0xX08c51c_P:d0xX08c51c>=500.1._I:0xX08c6b8_N:0x 00000e=17_N:d0xT08c51f!=1_N:0xT08c51f=1_A:d0xX08c51c_B:0xX08c51c_P:0>=501.1.',
    'N:0xH085a49!=1_R:0x 089ce8=1'
  )
}

AltGroup = namedtuple('AltGroup', ['conditions'])
alt_groups = {
  '0x 001111=0': AltGroup('R:0x 08a1e8=1_P:0x 08a228=12.1.')
}

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

    trigger = ma.group('trigger')

    groups = split_trigger(trigger)
    core, alts = groups[0], groups[1:]

    pause_lock_reset = ''
    for placeholder, pause_lock in pause_locks.items():
      if placeholder not in core:
        continue

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
