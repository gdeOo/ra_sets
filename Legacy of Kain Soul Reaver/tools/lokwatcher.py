from pymem import Pymem
import os
import time
import msvcrt
import sys
from colorama import Style


base_addr = 0x13b07c00  # change me

eu = False
if len(sys.argv) > 1:
  eu = sys.argv[1].lower() == "eu"

def region_addr(addr):
  if not eu:
    return addr
  if addr >= 0x80cf440 and addr < 0x80d1038:
    return addr + 0x71c
  if addr >= 0x80d1038 and addr < 0x80d1960:
    return addr + 0x72c
  return addr + 0x734


def to_real_ptr(psx_ptr):
  return base_addr + (psx_ptr & 0xffffff)

def psx_ptr_str(psx_ptr):
  return f'0x{psx_ptr:08x}'

##
##   s t r u c t s

level__struct_fields = {
  "PuzzleInstances":  220,  # EventPointers*
  "dynamicMusicName": 244,  # char*
  "streamUnitID":     248,  # dword
}

EventPointers__struct_fields = {
  "numPuzzles": 0,     # dword
  "eventInstances": 4  # Event*[numPuzzles]
}

Event__struct_fields = {
  "processingPuppetShow": 5,  # byte
  "eventVariables":       6,  # word[5]
}

InstanceList__struct_fields = {
  "numInstances": 0,  # dword
  "first": 4,         # _Instance*
}

_Instance__struct_fields = {
  "next":             8,    # _Instance*
  "instanceID":       16,   # dword
  "flags":            20,   # dword
  "flags2":           24,   # dword
  "object":           28,   # Object*
  "data":             36,   # void*
  "introNum":         48,   # dword
  "introUniqueId":    60,   # dword
  "position.x":       92,   # word
  "position.y":       94,   # word
  "position.z":       96,   # word
  "queryFunc":        252,  # dword(*)()
  "LinkChild":        304,  # _Instance*
  "introName":        320,  # char[12]
  "extraData":        332,  # void*
  "currentMainState": 376,  # dword
  "curAnim":          460,  # dword
}
_Instance__sizeof = 616

Object__struct_fields = {
  "id": 4,  # word
}

melchiah_extraData = {
  "current_anim": 128,  # dword
}

_InstancePool__struct_fields = {
  "instance": 8,  #_Instance[60]
}

def instance_field_ptr(instance_ptr, field):
  return instance_ptr + _Instance__struct_fields[field]

##
##   g a m e T r a c k e r X

gameTrackerX_level_addr = region_addr(0x80d1038)
gameTrackerX_playerInstance_addr = region_addr(0x80d103c)
gameTrackerX_baseAreaName_addr = region_addr(0x80d116c)
gameTrackerX_StreamUnitID_addr = region_addr(0x80d1188)
gameTrackerX_instanceList_addr = region_addr(0x80d1044)
gameTrackerX_instancePool_addr = region_addr(0x80d1048)

def area_name(mem):
  return mem.read_string(to_real_ptr(gameTrackerX_baseAreaName_addr), 16)

def stream_unit_id(mem):
  return mem.read_uint(to_real_ptr(gameTrackerX_StreamUnitID_addr))

def player_instance(mem):
  inst_ptr = mem.read_uint(to_real_ptr(gameTrackerX_playerInstance_addr))
  if inst_ptr != 0:
    return read_instance(mem, inst_ptr)
  return None

##
##   i n s t a n c e s

def object_field_ptr(object_ptr, field):
  return object_ptr + Object__struct_fields[field]

def instances(mem):
  list_ptr = mem.read_uint(to_real_ptr(gameTrackerX_instanceList_addr))
  n_instances = mem.read_uint(to_real_ptr(list_ptr + InstanceList__struct_fields["numInstances"]))

  instance_list = []
  instance_ptr = mem.read_uint(to_real_ptr(list_ptr + InstanceList__struct_fields["first"]))
  while instance_ptr != 0:
    instance_list.append({
      'ptr': to_real_ptr(instance_ptr),
      'name': mem.read_string(to_real_ptr(instance_ptr + _Instance__struct_fields["introName"]), 12),
      'id': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["instanceID"])),
      'flags': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["flags"])),
      'flags2': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["flags2"]))
    })
    instance_ptr = mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["next"]))

  return instance_list

def read_instance(mem, instance_ptr):
  data_ptr = mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["data"]))
  extra_data_ptr = mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["extraData"]))
  return {
    'ptr': to_real_ptr(instance_ptr),
    'id': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["instanceID"])),
    'name': mem.read_string(to_real_ptr(instance_ptr + _Instance__struct_fields["introName"]), 12),
    'anim': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["curAnim"])),
    'flags': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["flags"])),
    'flags2': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["flags2"])),
    'data': to_real_ptr(data_ptr),
    'data[0x10]': mem.read_uint(to_real_ptr(data_ptr) + 0x10),
    'extraData': to_real_ptr(extra_data_ptr),
    'extraData[0]': mem.read_uint(to_real_ptr(extra_data_ptr)),
    'extraData[0x31*4]': mem.read_uint(to_real_ptr(extra_data_ptr) + 0x31 * 4),
    'extraData[0x51*4]': mem.read_ushort(to_real_ptr(extra_data_ptr) + 0x51 * 4),
    'extraData[0x144]': mem.read_ushort(to_real_ptr(extra_data_ptr) + 0x144),
    'extraData[340]': mem.read_uchar(to_real_ptr(extra_data_ptr) + 340),
    'extraData[hitPoints]': mem.read_ushort(to_real_ptr(extra_data_ptr) + 320),
    'position': (mem.read_short(to_real_ptr(instance_ptr + _Instance__struct_fields["position.x"])),
                 mem.read_short(to_real_ptr(instance_ptr + _Instance__struct_fields["position.y"])),
                 mem.read_short(to_real_ptr(instance_ptr + _Instance__struct_fields["position.z"]))),
    'queryFunc': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["queryFunc"])),
    'LinkChild': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["LinkChild"])),
    'currentMainState': mem.read_uint(to_real_ptr(instance_ptr + _Instance__struct_fields["currentMainState"]))
  }

def instance_pool(mem):
  pool_ptr = mem.read_uint(to_real_ptr(gameTrackerX_instancePool_addr))

  pool = {
    'ptr': pool_ptr,
    'instances': []
  }

  instance_ptr = pool_ptr + _InstancePool__struct_fields["instance"]
  for i in range(0, 60):
    pool['instances'].append(read_instance(mem, instance_ptr))
    instance_ptr += _Instance__sizeof

  return pool



##
##   e v e n t s

def level_field_ptr(mem, field):
  return mem.read_uint(to_real_ptr(gameTrackerX_level_addr)) + level__struct_fields[field]

def n_events(mem):
  events_ptr = mem.read_uint(to_real_ptr(level_field_ptr(mem,"PuzzleInstances")))
  n = mem.read_uint(to_real_ptr(events_ptr + 0))
  return n

def event_ptr(mem, evt_idx):
  events_ptr = mem.read_uint(to_real_ptr(level_field_ptr(mem, "PuzzleInstances")))
  return mem.read_uint(to_real_ptr(events_ptr + EventPointers__struct_fields["eventInstances"] + 4 * evt_idx))

def event_number(mem, evt_idx):
  evt_ptr = event_ptr(mem, evt_idx)
  return mem.read_short(to_real_ptr(evt_ptr))

def event_puppet(mem, evt_idx):
  return mem.read_uchar(to_real_ptr(event_ptr(mem, evt_idx) + Event__struct_fields["processingPuppetShow"]))

def event_var(mem, evt_idx, var_idx):
  evt_ptr = event_ptr(mem, evt_idx)
  return mem.read_short(to_real_ptr(evt_ptr + Event__struct_fields["eventVariables"] + 2 * var_idx))

def all_events(mem):
  n = n_events(mem)
  return [{
    'puppet': event_puppet(mem, evt_idx),
    'vars': [event_var(mem, evt_idx, var_idx) for var_idx in range(5)]
  } for evt_idx in range(n)]

def dyn_music_name(mem):
  return mem.read_string(to_real_ptr(mem.read_uint(to_real_ptr(level_field_ptr(mem, "dynamicMusicName")))))

class EventsDiff:
  def __init__(self, mem):
    self.mem = mem
    self.stream_unit_id = None
    self.events = None

  def toggle(self):
    if self.stream_unit_id is None:
      self.stream_unit_id = stream_unit_id(self.mem)
      self.events = [evt['vars'] for evt in all_events(self.mem)]
    else:
      self.stream_unit_id = None
      self.events = None

  def to_str(self):
    unit_id = stream_unit_id(self.mem)
    events = all_events(self.mem)

    if self.stream_unit_id is not None and self.stream_unit_id != unit_id:
      self.toggle()
      self.toggle()

    out = ''

    for evt_idx in range(len(events)):
      number = event_number(self.mem, evt_idx)
      ptr = to_real_ptr(event_ptr(self.mem, evt_idx))
      out += f'  {evt_idx:2} = {number:2} 0x{ptr:08x} '
      if self.events is None:
        out += f"puppet={events[evt_idx]['puppet']} vars={events[evt_idx]['vars']}"
      else:
        out += f"puppet={events[evt_idx]['puppet']} vars={self.events[evt_idx]} => "
        out += f"[{', '.join(f'{Style.BRIGHT}{aval}{Style.NORMAL}' if bval != aval else f'{aval}' for bval, aval in zip(self.events[evt_idx], events[evt_idx]['vars']))}]"
      out += '\n'

    return out

class InstancesDiff:
  def __init__(self, mem):
    self.mem = mem
    self.instances = None
    self.stream_unit_id = None

  def toggle(self):
    if self.instances is None:
      self.instances = instances(self.mem)
      self.stream_unit_id = stream_unit_id(self.mem)
    else:
      self.instances = None
      self.stream_unit_id = None

  def to_str(self):
    new_instances = instances(self.mem)
    new_unit_id = stream_unit_id(self.mem)

    if self.stream_unit_id is not None and self.stream_unit_id != new_unit_id:
      self.toggle()

    out = ''
    if self.instances is None:
      for inst in new_instances:
        out += f"  0x{inst['ptr']:8x} {inst['name']:10} id={inst['id']:2} flags=[{inst['flags']:08x} {inst['flags2']:08x}]\n"
    else:
      old_by_id = {inst['id']: inst for inst in self.instances}
      new_by_id = {inst['id']: inst for inst in new_instances}
      diff = [(old_by_id.get(inst['id'], None), inst) for inst in new_instances]
      diff += [(inst, None) for inst in self.instances if inst['id'] not in new_by_id]
      for old_inst, new_inst in diff:
        inst = new_inst if new_inst is not None else old_inst
        out += f"  0x{inst['ptr']:8x} {inst['name']:10} id={inst['id']:2} "
        if old_inst is not None and new_inst is not None:
          styles1 = (f"{Style.BRIGHT}", f"{Style.NORMAL}") if old_inst['flags'] != new_inst['flags'] else ("", "")
          styles2 = (f"{Style.BRIGHT}", f"{Style.NORMAL}") if old_inst['flags2'] != new_inst['flags2'] else ("", "")
          out += f"flags=[{old_inst['flags']:08x} {old_inst['flags2']:08x}]"
          out += f" => [{styles1[0]}{new_inst['flags']:08x}{styles1[1]} {styles2[0]}{new_inst['flags2']:08x}{styles2[1]}]"
        elif old_inst is None:
          out += f"flags=                    => {Style.BRIGHT}[{new_inst['flags']:08x} {new_inst['flags2']:08x}]{Style.NORMAL}"
        else:
          out += f"flags={Style.BRIGHT}[{old_inst['flags']:08x} {old_inst['flags2']:08x}]{Style.NORMAL}"
        out += '\n'

    return out


##
##   r a z i e l

raziel_addr = region_addr(0xd5278)

__Player__struct = {
  "State.SectionList[0].Process": 12,    # void (*)()
  "Mode":                         868,   # dword
  "Senses.HitMonster":            968,   # _Instance*
  "Senses.EngagedList":           984,   # __EngagedInstance[15]
  "Senses.EngagedMask":           988,   # dword
  "Senses.heldClass":             1004,  # dword
  "HealthScale":                  1016,  # word
  "HealthBalls":                  1018,  # word
  "HitPoints":                    1020,  # dword
  "Abilities":                    1032,  # dword
  "GlyphManaMax":                 1040,  # word
  "CurrentPlane":                 1080,  # dword
  "attackCurrentHit":             1108,  # _Instance*
  "attackLastHit":                1112,  # _Instance*
}

def raziel_field_ptr(field):
  return raziel_addr + __Player__struct[field]

def raziel_process(mem):
  return mem.read_uint(to_real_ptr(raziel_field_ptr("State.SectionList[0].Process")))

def raziel_in_cutscene(mem):
  return raziel_process(mem) in (0x8009aa98, 0x8009ae34)

def raziel_max_mana(mem):
  return mem.read_short(to_real_ptr(raziel_field_ptr("GlyphManaMax")))

def raziel_health_scale(mem):
  return mem.read_short(to_real_ptr(raziel_field_ptr("HealthScale")))

def raziel_health_balls(mem):
  return mem.read_short(to_real_ptr(raziel_field_ptr("HealthBalls")))

def current_hit_real_addr(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  return to_real_ptr(inst) if inst != 0 else 0

def current_hit_id(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    return mem.read_uint(to_real_ptr(instance_field_ptr(inst, "instanceID")))
  return -1

def current_hit_data(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    addr = mem.read_uint(to_real_ptr(instance_field_ptr(inst, "data")))
    return to_real_ptr(addr) if addr != 0 else 0
  return 0

def current_hit_extra_data(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    addr = mem.read_uint(to_real_ptr(instance_field_ptr(inst, "extraData")))
    return to_real_ptr(addr) if addr != 0 else 0
  return 0

def current_hit_object_addr(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    addr = mem.read_uint(to_real_ptr(instance_field_ptr(inst, "object")))
    return to_real_ptr(addr) if addr != 0 else 0
  return 0

def current_hit_current_anim(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    return mem.read_uint(to_real_ptr(instance_field_ptr(inst, "curAnim")))
  return None

def current_hit_intro_num(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    return mem.read_uint(to_real_ptr(instance_field_ptr(inst, "introNum")))
  return None

def current_hit_intro_unique_id(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    return mem.read_uint(to_real_ptr(instance_field_ptr(inst, "introUniqueId")))
  return None

def current_hit_object_id(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    obj = mem.read_uint(to_real_ptr(instance_field_ptr(inst, "object")))
    if obj != 0:
      return mem.read_short(to_real_ptr(object_field_ptr(obj, "id")))
  return None

def current_hit(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackCurrentHit")))
  if inst != 0:
    return mem.read_string(to_real_ptr(instance_field_ptr(inst, "introName")), 12)
  return "none"

def raziel_last_hit(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("attackLastHit")))
  if inst != 0:
    return read_instance(mem, inst)
  return None

def raziel_hit_monster(mem):
  inst = mem.read_uint(to_real_ptr(raziel_field_ptr("Senses.HitMonster")))
  if inst != 0:
    return read_instance(mem, inst)
  return None

def raziel_engaged_mask(mem):
  return mem.read_uint(to_real_ptr(raziel_field_ptr("Senses.EngagedMask")))

def abilities(mem):
  return mem.read_uint(to_real_ptr(raziel_field_ptr("Abilities")))

def human_opinion(mem):
  save_ptr = mem.read_uint(to_real_ptr(0xcfaec))
  return mem.read_short(to_real_ptr(save_ptr + 12))

class RazielDiff:
  def __init__(self, mem):
    self.mem = mem
    self.diffing = False

  def toggle(self):
    if self.diffing:
      self.diffing = False
    else:
      self.diffing = True
      self._abilities = abilities(self.mem)

  def abilities(self):
    if not self.diffing:
      return f"{abilities(self.mem):08x}"

    new_abilities = abilities(self.mem)
    if new_abilities != self._abilities:
      return f"{self._abilities:08x} => {Style.BRIGHT}{new_abilities:08x}{Style.NORMAL}"
    else:
      return f"{self._abilities:08x} => {new_abilities:08x}"

###############

__EngagedInstance__struct = {
  "instance": 0,  # _Instance*
}
__EngagedInstance__sizeof = 8

engaged_list_addr = region_addr(0x800d5988)  # _EngagedInstance[15]

def engaged_list(mem):
  l = []
  p = engaged_list_addr
  for i in range(0, 15):
    inst_ptr = mem.read_uint(to_real_ptr(p + __EngagedInstance__struct["instance"]))
    if inst_ptr == 0:
      l.append(None)
    else:
      l.append(read_instance(mem, inst_ptr))
    p = p + __EngagedInstance__sizeof
  return l

###############

WarpRoom = {
  "name":       0,   # char[16]
  "streamUnit": 16,  # _StreamUnit*
}
WarpRoom_sizeof = 20

_StreamUnit = {
  "level": 8,  # Level*
}

warp_room_array_addr = region_addr(0x800cf444)  # WarpRoom[14]

def warp_rooms(mem):
  rooms = []
  for i in range(14):
    name = mem.read_string(to_real_ptr(warp_room_array_addr + (i * WarpRoom_sizeof) + WarpRoom["name"]))
    unit_ptr = mem.read_uint(to_real_ptr(warp_room_array_addr + (i * WarpRoom_sizeof) + WarpRoom["streamUnit"]))
    rooms.append({
      'name': name,
      'unit_ptr': unit_ptr
    })
  return rooms


mem = Pymem("RALibretro")
events_diff = EventsDiff(mem)
instances_diff = InstancesDiff(mem)
raziel_diff = RazielDiff(mem)
paused = False
show_inst_idx = 12

def process_keyboard():
  while msvcrt.kbhit():
    c = msvcrt.getch()
    if c == b' ':
      events_diff.toggle()
      instances_diff.toggle()
      raziel_diff.toggle()
    elif c == b'p':
      global paused
      paused = not paused
    elif c == b'\xe0':
      global show_inst_idx
      c = msvcrt.getch()
      if ord(c) == 80:
        show_inst_idx = min(59, show_inst_idx + 1)
      elif ord(c) == 72:
        show_inst_idx = max(0, show_inst_idx - 1)


while True:
  process_keyboard()

  out = ""

  out += f"area name:      {area_name(mem)}\n"
  out += f"stream unit id: {stream_unit_id(mem):x}\n\n"
  out += f"events:\n"
  out += events_diff.to_str()
  out += '\n'

  out += f"instances: {[inst['name'] for inst in instances(mem)]}"
  #out += instances_diff.to_str()
  out += '\n\n'

  pool = instance_pool(mem)
  out += f"inst pool: 0x{to_real_ptr(pool['ptr']):08x}\n"
  col_lens = [max(len(pool['instances'][i]['name']) for i in range(c, 60, 6))
              for c in range(6)]

  p = pool['instances']
  for s in range(0, 60, 6):
    row = ' '.join(
      f"{i:2}: "
      + f"{Style.BRIGHT if p[i]['id'] != 0 else ''}"
        + f"{p[i]['name']}{' ' * (col_lens[i%6] - len(p[i]['name']))}"
      + f"{Style.NORMAL}"
      #+ f" {p[i]['queryFunc']:08x}"
      #+ f" {p[i]['anim']:3}"
      + f" {p[i]['id']:4}"
      + f"{' *' if p[i]['queryFunc'] == 0x8007e414 else '  '}"
      for i in range(s, s+6)
    )
    out += f"  {row}\n"
  out += "\n"

  if show_inst_idx is not None:
    inst = pool['instances'][show_inst_idx]
    out += f"inst {show_inst_idx}: ptr=0x{inst['ptr']:08x} name={inst['name']}"
    out += f" anim={inst['anim']} state={inst['currentMainState']}"
    #out += f" dead? {inst['flags2'] & 0x40 == 0}"
    out += f" flags=0x{inst['flags']:08x} 0x{inst['flags2']:08x}\n"
    out += f"  data 0x{inst['data']:08x} [0x10]=0x{inst['data[0x10]']:08x}\n"
    out += f"  extraData 0x{inst['extraData']:08x} [0]=0x{inst['extraData[0]']:08x} dead? {inst['extraData[0]'] & 0x200 != 0}"
    out += f" [0x144]=0x{inst['extraData[0x144]']:08x} [340]={inst['extraData[340]']}\n"
    out += f"  position={inst['position']} queryFunc=0x{inst['queryFunc']:08x}"
    out += "\n\n"

  raz_inst = player_instance(mem)
  raz_last_hit = raziel_last_hit(mem)
  raz_hit_mon = raziel_hit_monster(mem)
  raz_child_inst = read_instance(mem, raz_inst['LinkChild']) if raz_inst['LinkChild'] != 0 else None
  out += f"raziel:\n"
  out += f"  process: 0x{raziel_process(mem):08x}\n"
  out += f"  in cutscene? {raziel_in_cutscene(mem)}\n"
  out += f"  instance:  0x{raz_inst['ptr']:08x} name={raz_inst['name']} anim={raz_inst['anim']}\n"
  if raz_child_inst is None:
    out += f"  child: --\n"
  else:
    out += f"  child: {raz_child_inst['name']}\n"
  out += f"  abilities: {raziel_diff.abilities()}\n"
  out += f"  health: scale={raziel_health_scale(mem)} balls={raziel_health_balls(mem)}\n"
  out += f"  max mana: {raziel_max_mana(mem)}\n"
  out += f"  human opinion: {human_opinion(mem)}\n"
  if True:
    out += f"  attack current hit: 0x{current_hit_real_addr(mem):08x}\n"
    #out += f"    id:            {current_hit_id(mem)}\n"
    out += f"    name:          {current_hit(mem)}\n"
    #out += f"    intro num:     {current_hit_intro_num(mem)}\n"
    #out += f"    intro uniq id: {current_hit_intro_unique_id(mem)}\n"
    #out += f"    data:          0x{current_hit_data(mem):08x}\n"
    #out += f"    extra data:    0x{current_hit_extra_data(mem):08x}\n"
    #out += f"    object:        0x{current_hit_object_addr(mem):08x}\n"
    #out += f"      id:            {current_hit_object_id(mem)}\n"
    #out += f"    current anim:  {current_hit_current_anim(mem)}\n"  #0x1cc / 460
    if not raz_last_hit:
      out += f"  attack last hit: none\n"
    else:
      out += f"  attack last hit: 0x{raz_last_hit['ptr']:08x} name={raz_last_hit['name']}\n"
    if not raz_hit_mon:
      out += f"  hit monster: none\n"
    else:
      out += f"  hit monster: 0x{raz_hit_mon['ptr']:08x} name={raz_hit_mon['name']}\n"

  if False:
    out += "\nwarps:\n"
    for warp in warp_rooms(mem):
      out += f"  {warp['name']} unit=0x{warp['unit_ptr']:08x}\n"

  out += f"\nengaged mask: 0x{raziel_engaged_mask(mem):08x}\n"
  out += "engaged:\n"
  l = engaged_list(mem)
  col_lens = [max(len(l[i]['name']) if l[i] else 4 for i in range(c, 15, 5))
              for c in range(5)]
  for s in range(0, 15, 5):
    row = ' '.join(
      f"{i:2}: "
      + f"{Style.BRIGHT if l[i] and l[i]['id'] != 0 else ''}"
        + f"{l[i]['name'] if l[i] else '----'}{' ' * (col_lens[i%5] - (len(l[i]['name']) if l[i] else 4))}"
      + f"{Style.NORMAL}"
      + f" {l[i]['id'] if l[i] else 0:4}"
      for i in range(s, s+5)
    )
    out += f"  {row}\n"

  if paused:
    out += "(paused)\n"

  os.system('cls')
  print(out)

  while True:
    if not paused:
      time.sleep(0.5)
      break
    else:
      time.sleep(0.5)
      process_keyboard()

