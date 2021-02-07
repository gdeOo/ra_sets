from pymem import Pymem
import os
import time
import msvcrt
import sys
import colorama
from colorama import Style


base_addr = 0xd80c7e0  # change me

def to_emu_ptr(game_ptr):
  return base_addr + (game_ptr & 0xffff)

def psx_ptr_str(psx_ptr):
  return f'0x{psx_ptr:08x}'

def read32(mem, ptr):
  return mem.read_ushort(to_emu_ptr(ptr)) << 16 | mem.read_ushort(to_emu_ptr(ptr + 2))

def write32(mem, ptr, val):
  mem.write_ushort(to_emu_ptr(ptr), val >> 16)
  mem.write_ushort(to_emu_ptr(ptr + 2), val & 0xffff)

uchar_rw  = (lambda mem, ptr: mem.read_uchar(to_emu_ptr(ptr)),
             lambda mem, ptr, val: mem.write_uchar(to_emu_ptr(ptr), val))
ushort_rw = (lambda mem, ptr: mem.read_ushort(to_emu_ptr(ptr)),
             lambda mem, ptr, val: mem.write_ushort(to_emu_ptr(ptr), val))
uint_rw   = (read32, write32)

##
##   e n t i t i e s

entity_fields = {
  "next":        (0x00, uint_rw),
  "render_next": (0x04, uint_rw),
  "collider":    (0x08, uint_rw),
  "owner":       (0x0c, uint_rw),
  "behaviour":   (0x18, uint_rw),
  "render_f":    (0x1c, uint_rw),
  "flags":       (0x24, ushort_rw),  # bit7 = active?
  "type":        (0x26, uchar_rw),
  "id":          (0x27, uchar_rw),
  "linked_list": (0x28, uchar_rw),
  "x":           (0x36, ushort_rw),
  "y":           (0x3a, ushort_rw),
  "0x74":        (0x75, uchar_rw),
  "state":       (0x76, ushort_rw),
  "state timer": (0x78, ushort_rw),
  "aoe_type":    (0x80, ushort_rw),
  "param_N":     (0x8c, ushort_rw),
  "max_health":  (0xd8, ushort_rw),
  "health":      (0xda, ushort_rw),
}
entity_sizeof = 0xe4

def entity_field_ptr(entity_ptr, field):
  return entity_ptr + entity_fields[field][0]

def entity_value(mem, entity_ptr, field):
  return entity_fields[field][1][0](mem, entity_field_ptr(entity_ptr, field))

def set_entity_value(mem, entity_ptr, field, value):
  entity_fields[field][1][1](mem, entity_field_ptr(entity_ptr, field), value)

def behaviour_name(behaviour):
  return {
    0x003cc054: 'player',
    0x003cbfbc: 'dying player',
    0x003d423a: 'friendly hunter',

    # vehicles
    0x003caff0: 'car',
    0x003c98a6: 'boat',
    0x003c8350: 'cargo truck',
    0x003c73be: 'vehicle sight (cross)',
    0x003c7312: 'vehicle sight (triangle)',
    0x003e6450: 'enemy car',
    0x003c67fe: 'dying cargo truck',
    0x003d7bd6: 'trex chase car',

    # enemies
    0x003e6e7c: 'dilophosaurus',
    0x003e6d48: 'dying dilophosaurus',
    0x003e2254: 'troodon',
    0x003e2118: 'dying troodon',
    0x003e5774: 'mercenary',
    0x003e55fa: 'dying mercenary',
    0x003e401e: 'stegosaurus',
    0x003d0ae2: 'velociraptor',
    0x003d131c: 'dying velociraptor',
    0x003d29de: 'sandbag mercenary',
    0x003d2932: 'dying sandbag mercenary',
    0x003eb0c2: 't-rex',
    0x003eafae: 'dying t-rex',
    0x003e4e4c: 'triceratops',
    0x003e4c7c: 'incapacitated triceratops',
    0x003e1f68: 'triceratops beacon',  # disappears after the timeout
    0x003d6520: 't-rex (chase)',
    0x003ec8ca: 'baby stegosaurus',

    # containers
    0x003e86ba: 'crate',
    0x003e837a: 'barrel',
    0x003e8ff8: 'supply drop',
    0x003ea868: 'car/player drop',

    # pickups
    0x003e3694: 'machine gun ammo',
    0x003e30fe: 'armor',
    0x003e2f36: 'small health pack',
    0x003e2dac: 'large health pack',
    0x003ec1ba: 'JP coin',
    0x003e3c4c: 'gas rounds',
    0x003ec398: 'map',
    0x003e3236: 'fuel',
    0x003e3dfc: '1-up',
    0x003e3a4a: 'grenade ammo',
    0x003e3896: 'mine ammo',
    0x003e3290: 'missile ammo',
    0x003e3492: 'guided missile ammo',
    0x003d5490: 'amber',
    0x003ec062: 't-rex egg',
    0x003ec45e: 'clock',

    # environmental hazards
    0x003dad8c: 'mine',
    0x003c0ae4: 'gas plant',
    0x003ec168: 'small gas plant',
    0x003e9d3a: 'electric post',
    0x003e9d04: 'electric barrier',
    0x003d364c: 'cave gas emitter',
    0x003d3e8e: 'lava',
    0x003d32a4: 'cave ground gas',
    0x003d331e: 'cave lava fissure',
    0x003d3c50: 'falling rock',
    0x003d4054: 'fire',
    0x003d39fe: 'falling rock spawner',

    # objects
    0x003ea202: 'generator',
    0x003e7dfa: 'tent',
    0x003e8cea: 'signpost',
    0x003e968c: 'breakable rock',
    0x003d2d66: 'bunker',
    0x003d3038: 'dying bunker',
    0x003e7ea0: 'huge crate',
    0x003e8eb4: 'level flagpost',
    0x003ea3ee: 'checkpoint',
    0x003e29ca: 'sensor',
    0x003d25f4: 'mercenary sandbags',
    0x003e8e7c: 'dock signpost',
    0x003d4eb6: 'egg nest',
    0x003eacc4: 'water mine',
    0x003d1c0c: 'truck (escort mission)',
    0x003e76ae: 'alarm post',
    0x003e7d76: 'red truck',
    0x003e3e62: 'mercenary satcom',
    0x003e7716: 'alarm generator',
    0x003e82ac: 'campfire',
    0x003e6e62: 'stegosaurus carcass',
    0x003e6ce6: 'stego cage',
    0x003e6ab6: 'stego cage door',

    # projectiles
    0x003db834: 'dilophosaurus projectile',
    0x003dbfce: 'shotgun shot',
    0x003db09a: 'taser shot',
    0x003db478: 'tranquilizer shot',
    0x003dc7c8: 'machine gun shot',
    0x003dd5e8: 'mercenary shot',
    0x003dbb4e: 'grenade',
    0x003dd2fe: 'vehicle shot',
    0x003dd8f8: 'bunker spreadshot',
    0x003dc3f8: 'missile',

    # fx
    0x003dab58: 'ejected projectile',  # machine gun rounds, crate parts upon explosion
    0x003ed534: 'sparkling',
    0x003e2c42: 'pickup explosion',
    0x003e9ce4: 'electric shock',
    0x003e95be: 'cave entrance',  # in site 1
    0x003dc144: 'rocket firing',
    0x003d1f94: 'scrolling camera 1/3',
    0x003d7354: 'scrolling camera 2/3',
    0x003d744a: 'scrolling camera 3/3',
    0x003e2bde: 'explosion',
    0x003e76ac: 'alarm laser',
    0x003d64e8: 't-rex shadow (chase)',
    0x003d79a0: 'firestorm meter',
    0x003dcd2e: 'gas grenade cloud',
    0x003e78d6: 'alarm',
    0x003d200e: 'escorted truck explosion',
    0x003ec54a: 'countdown explosion',
    0x003ec4f0: 'countdown sub-explosion',

    # terrain / environment
    0x003ba40e: 'invisible barrier',
    0x003e1c64: 'cloud',
    0x003eab98: 'bird',
    0x003d5cf4: 'bat',

    # known unknowns
    0x003ed4c4: 'known unknown 1',
    0x003ca4ce: 'known unknown 3',
    0x003d364a: 'unknown cave leak',  # most likely spawners for smoke and lava fissures
  }.get(behaviour, 'unknown')

persistent_flag_offset = {
  0x13: 1,  # small health pack
  0x30: 2,  # mine
  0x57: 0,  # map
  0x69: 1,  # crate
}

entity_array_addr = 0xffff0000
entity_array_size = 130

def get_entity_at(mem, idx):
  entity_ptr = entity_array_addr + idx * entity_sizeof
  #if not (entity_value(mem, entity_ptr, 'flags') & 0x8000):
  #  return None

  entity = {
    field: entity_value(mem, entity_ptr, field)
    for field in entity_fields.keys()
  }

  entity.update({
    'index': idx,
    'addr':  entity_ptr,
    'behaviour_name': behaviour_name(entity['behaviour'])
  })

  if entity['id'] >= 0 and entity['type'] in persistent_flag_offset:
    offset = persistent_flag_offset[entity['type']]
    addr = 0xbf42 + offset * 0x20 + (entity['id'] >> 3)
    addr += (1 if addr % 2 == 0 else -1)
    entity['persistent_flag'] = (addr, 1 << (entity['id'] & 7))

  return entity

def get_entities(mem):
  return [e for e in [get_entity_at(mem, i) for i in range(entity_array_size)] if e['flags'] & 0x8000]

def get_all_entities(mem):
  return [get_entity_at(mem, i) for i in range(entity_array_size)]

def entity_ptr_to_index(ptr):
  #assert(ptr >= entity_array_addr and ptr <= entity_array_addr + entity_array_size * entity_sizeof)
  return (ptr - entity_array_addr) // entity_sizeof

def get_entity_linked_list(mem, head, link_field):
  l = []
  while head != 0:
    l.append(entity_ptr_to_index(head))
    head = read32(mem, head + entity_fields[link_field][0])
  return l

linked_lists = [
  ('ll1',          0xffffb014, 'next'),
  ('projectiles',  0xffffb018, 'next'),
  ('ll3',          0xffffb01c, 'next'),
  ('barriers',     0xffffb020, 'next'),
  ('debris',       0xffffb024, 'next'),
  ('zombie',       0xffffb028, 'next'),
  ('back_render',  0xffffb036, 'render_next'),
  ('front_render', 0xffffb032, 'render_next'),
  ('free',         0xffffc66c, 'next'),
  ('mid_render',   0xffffb02e, 'render_next'),
]

def get_linked_lists(mem):
  return [(name, addr, get_entity_linked_list(mem, read32(mem, addr), link_field))
          for name, addr, link_field in linked_lists]

revealed_map = 0xffff7400
player_entity = 0xffffa85c

def select_player_entity(mem, entities):
  ent_addr = read32(mem, player_entity)
  return next((e for e in entities if e['addr'] == ent_addr), None)

##
##   d i s p l a y

def bright(s):
  return f"{Style.BRIGHT}{s}{Style.NORMAL}"

def dim(s):
  return f"{Style.BRIGHT}{s}{Style.NORMAL}"

##
##   m a i n

colorama.init(convert=True)
mem = Pymem("RALibretro")
paused = False
cheat_menu_open = False
no_barriers_cheat = False
max_hp_cheat = False
no_water_mines_cheat = False
detail_inv_barriers = False
invincible_transport = False

def process_keyboard():
  while msvcrt.kbhit():
    c = msvcrt.getch()
    if c == b'p':
      global paused
      paused = not paused
    elif c == b'c':
      global cheat_menu_open
      cheat_menu_open = True

while True:
  process_keyboard()

  out = ""

  entities = get_entities(mem)
  player = select_player_entity(mem, entities)

  out += f"cheats: no-barriers = {no_barriers_cheat} | max-hp = {max_hp_cheat} | no-water-mines = {no_water_mines_cheat}\n\n"
  for e in (e for e in entities if e['behaviour_name'] == 'invisible barrier'):
    if no_barriers_cheat:
      if not (e['flags'] & 0x0080):
        set_entity_value(mem, e['addr'], 'flags', e['flags'] | 0x0080)
    else:
      if e['flags'] & 0x0080:
        set_entity_value(mem, e['addr'], 'flags', e['flags'] & 0xff7f)

  if max_hp_cheat and player and player['health'] < 0x2fd:
    set_entity_value(mem, player['addr'], 'health', 0x2fd)

  if invincible_transport:
    transport = next((e for e in entities if e['behaviour_name'] == 'truck (escort mission)'), None)
    if transport and transport['health'] < transport['max_health']:
      set_entity_value(mem, transport['addr'], 'health', transport['max_health'])

  if no_water_mines_cheat:
    for e in (e for e in entities if e['behaviour_name'] == 'water mine'):
      set_entity_value(mem, e['addr'], 'flags', e['flags'] & 0x7fff)

  out += f"player:\n"
  if not player:
    out += f" (none)\n"
  else:
    coll_ent = next((e for e in entities if e['addr'] == player['collider']), None)
    coll_str = (f"{entity_ptr_to_index(player['collider'])} (none)" if not coll_ent
                else (f"{coll_ent['index']} ({coll_ent['behaviour_name']})" if coll_ent['behaviour_name'] != 'unknown'
                      else bright(coll_ent['index'])))
    out += f" position: ({player['x']:04x}, {player['y']:04x}) collider: {coll_str}\n"
  out += "\n"


  out += f"entities ({len(entities)}){' (+ barriers)' if detail_inv_barriers else ''}:\n"
  out += "                name                      position      hp    state  id  type  flags  0x74  pflag\n"
  for e in entities:
    if (not detail_inv_barriers
        and e['behaviour_name'] == 'invisible barrier'
        and (player is None or e['addr'] != player['collider'])):
      continue
    type_str = (bright(f"unknown (0x{e['behaviour']:08x})") if e['behaviour_name'] == 'unknown'
                else e['behaviour_name'])
    out += f" [{e['index']: 3} | 0x{e['addr']&0xffff:04x}] {type_str:25} ({e['x']:04x}, {e['y']:04x})  "
    out += f"{e['health']:04x}  {e['state']:04x}   {e['id']:02x}  "
    out += f"{e['type']:02x}    {e['flags']:04x}   0x{e['render_f']:08x}    "
    if 'persistent_flag' in e:
      out += f"0x{e['persistent_flag'][0]:04x} {e['persistent_flag'][1]:02x}\n"
    else:
      out += "----\n"
  out += "\n"

  out += f"invisible barriers: {[e['index'] for e in entities if e['behaviour_name'] == 'invisible barrier']}\n"
  out += "\n"

  out += "linked lists:\n"
  llists = get_linked_lists(mem)
  for name, addr, llist in llists:
    out += f" {name:12} 0x{addr&0xffff:04x}: {llist}\n"
  out += "\n"

  if True and player is not None:
    all_entities = get_all_entities(mem)

    def ent_at(addr):
      return next((e for e in all_entities if e['addr'] == addr), None)

    def is_enemy_entity(ent):
      return (ent['type'] == 0x4e  # trex
              or (ent['type'] >= 0x14 and ent['type'] <= 0x32 and ent['type'] != 0x28
                  and ent['linked_list'] != 3 and ent['linked_list'] != 4
                  and ent['flags'] & 0x8))  # TARGETABLE

    def is_lethal_projectile(ent):
      return (ent['flags'] & 0x400     # IS_PROJECTILE
              and ent['param_N'] != 4  # dart
              and ent['owner'] == player['addr'])

    """
            && never(entity_is_active(ent)
                     && _is_enemy_entity(alt, ent)
                     && mem_path(ent, ["flags", "COLLIDING"]) == 1
                     && _is_lethal_projectile(addressof_path(ent, ["collider"])))
"""

    out += f"pacifism failures:\n"
    for e in all_entities:
      ent_check_1 = (e['flags'] != 0xffff and e['flags'] & 0x8000
                     and is_enemy_entity(e)
                     and e['flags'] & 0x100  # COLLIDING
                     #and ent_at(e['collider']) is not None
                     and is_lethal_projectile(ent_at(e['collider'])))
      ent_check_2 = (e['flags'] != 0xffff and e['flags'] & 0x8000
                     and is_enemy_entity(e)
                     and e['flags'] & 0x1000  # HIT_BY_AOE
                     and e['aoe_type'] == 7)  # GAS_GRENADE
      if ent_check_1 or ent_check_2:
        collider = ent_at(e['collider'])
        out += f"  [{e['index']: 2}]: collider = ({collider['type']:02x}, {collider['flags']:04x}, {collider['param_N']}, 0x{collider['owner']:08x})"

    collider = ent_at(player['collider'])
    check_1 = (player['flags'] != 0xffff and player['flags'] & 0x8000
               and player['type'] == 0  # VEHICLE
               and collider is not None
               and is_enemy_entity(collider)
               and collider['linked_list'] == 0
               and collider['flags'] & 0x4000) # KNOCKBACK
    if check_1:
      out += f"  * vehicle\n"

  if paused:
    out += "(paused)\n"

  os.system('cls')
  print(out)

  if cheat_menu_open:
    print("[cheat menu]")
    print()
    print("1. toggle no-barriers")
    print(f"2. toggle max-hp{' (unavailable)' if player is None else ''}")
    print(f"3. move entity to player{' (unavailable)' if player is None else ''}")
    print("4. disable entity")
    print("5. toggle no-water-mines")
    print("6. detail invisible barriers")
    print("7. invincible transport")
    print("8. reveal map")
    print()
    option = input("which? ")

    if option == "1":
      no_barriers_cheat = not no_barriers_cheat
    elif option == "2":
      max_hp_cheat = not max_hp_cheat
    elif option == "3":
      entity_index = input("which entity (index)? ")
      if entity_index.isnumeric():
        entity_index = int(entity_index)
        entity = next((e for e in entities if e['index'] == entity_index), None)
        if entity is not None:
          set_entity_value(mem, entity['addr'], 'x', player['x'] + 0x20)
          set_entity_value(mem, entity['addr'], 'y', player['y'] + 0x20)
    elif option == "4":
      entity_index = input("which entity (index)? ")
      if entity_index.isnumeric():
        entity_index = int(entity_index)
        entity = next((e for e in entities if e['index'] == entity_index), None)
        if entity is not None:
          set_entity_value(mem, entity['addr'], 'flags', entity['flags'] & 0x7fff)
    elif option == "5":
      no_water_mines_cheat = not no_water_mines_cheat
    elif option == "6":
      detail_inv_barriers = not detail_inv_barriers
    elif option == "7":
      invincible_transport = not invincible_transport
    elif option == "8":
      for i in range(512):
        mem.write_uchar(to_emu_ptr(revealed_map + i), 0xff)

    
    cheat_menu_open = False

  while True:
    if not paused:
      time.sleep(0.5)
      break
    else:
      time.sleep(0.5)
      process_keyboard()
