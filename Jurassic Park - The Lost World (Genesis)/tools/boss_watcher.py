from pymem import Pymem
import os
import time
import msvcrt
import sys
import colorama
from colorama import Style


base_addr = 0xe52c7e0  # change me

def to_emu_ptr(game_ptr):
  return base_addr + (game_ptr & 0xffff)

def psx_ptr_str(psx_ptr):
  return f'0x{psx_ptr:08x}'

def read32(mem, ptr):
  return mem.read_ushort(to_emu_ptr(ptr)) << 16 | mem.read_ushort(to_emu_ptr(ptr + 2))

def write32(mem, ptr, val):
  mem.write_ushort(to_emu_ptr(ptr), val >> 16)
  mem.write_ushort(to_emu_ptr(ptr + 2), val & 0xffff)

def read_struct(mem, ptr, struct_def):
  s = { name: rw[0](mem, ptr + offset) for name, (offset, rw) in struct_def.items() }
  s.update({'addr': ptr})
  return s

def set_struct_field(mem, ptr, struct_def, field, value):
  offset, rw = struct_def[field]
  rw[1](mem, ptr + offset, value)

uchar_rw  = (lambda mem, ptr: mem.read_uchar(to_emu_ptr(ptr)),
             lambda mem, ptr, val: mem.write_uchar(to_emu_ptr(ptr), val))
ushort_rw = (lambda mem, ptr: mem.read_ushort(to_emu_ptr(ptr)),
             lambda mem, ptr, val: mem.write_ushort(to_emu_ptr(ptr), val))
uint_rw   = (read32, write32)

##
##   o b j e c t s

object_lists_ptr = 0xffffcf28
n_object_lists = 0xd

LLIST = {
  "head": (0x0, uint_rw),
  "tail": (0x4, uint_rw)
}
LLIST_sizeof = 0x8

LLIST_NODE = {
  "previous": (0x0, uint_rw),
  "next":     (0x4, uint_rw),
  "object":   (0x8, uint_rw)
}

OBJECT = {
  "node":        (0x00, uint_rw),
  "size":        (0x10, ushort_rw),
  "behaviour_f": (0x12, uint_rw),
  "render_f":    (0x16, uint_rw),
  "command_f":   (0x1a, uint_rw)
}

object_ids_by_behaviour_f = {
  0x046a9a: "b bar widget",
  0x055528: "timeout",
  0x0532cc: "b4 player missile",
  0x05346c: "b4 enemy missile"
}

object_ids_by_command_f = {
  0x05878e: "b1 raptor",
  0x057528: "b1 player",
  0x05a1f0: "b1 hunter bike",
  0x058b74: "b1 player shot",
  0x05957e: "b1 player sight",
  0x0569e0: "b1 level scroll",
  0x046788: "b paused",
  0x055742: "b1 manager",
  0x057994: "b1 camera",  # for lack of better understanding
  0x047bfa: "sound fx player",
  0x0471d8: "b1 end sequence",
  0x05cbde: "b2 t-rex",
  0x04a12a: "b3 player",
  0x04ecbe: "b4 player"
}

def read_object_list(mem, addr):
  l = []
  while addr != 0:
    node = read_struct(mem, addr, LLIST_NODE)
    obj = read_struct(mem, node["object"], OBJECT)
    obj.update({
      "name": object_ids_by_command_f.get(obj["command_f"],
                object_ids_by_behaviour_f.get(obj["behaviour_f"], "?"))
    })
    l.append((node, obj))
    addr = node["next"]
  return l

def read_object_lists(mem):
  addr = read32(mem, object_lists_ptr)
  lists = [read_struct(mem, addr + i * LLIST_sizeof, LLIST)
           for i in range(n_object_lists)]
  return [(l, read_object_list(mem, l["head"])) for l in lists]

def pivot_object_lists(obj_lists):
  objs = {}
  for list_idx, (_, nodes) in enumerate(obj_lists):
    for _, obj in nodes:
      if obj['addr'] not in objs:
        objs[obj['addr']] = (obj, [list_idx])
      else:
        objs[obj['addr']][1].append(list_idx)
  return sorted(objs.values(), key=lambda o: o[0]['addr'])


##
##   d i s p l a y

def bright(s):
  return f"{Style.BRIGHT}{s}{Style.NORMAL}"

def dim(s):
  return f"{Style.BRIGHT}{s}{Style.NORMAL}"

def fp(ptr):
  return f"0x{ptr & 0xffff:04x}" if (ptr >> 0x10) == 0xffff else f"0x{ptr:06x}"

##
##   m a i n

colorama.init(convert=True)
mem = Pymem("RALibretro")
paused = False
list_view = False
cheat_menu_open = False

def process_keyboard():
  while msvcrt.kbhit():
    c = msvcrt.getch()
    if c == b'p':
      global paused
      paused = not paused
    elif c == b' ':
      global list_view
      list_view = not list_view
    elif c == b'c':
      global cheat_menu_open
      cheat_menu_open = True

while True:
  process_keyboard()

  out = ""

  object_lists = read_object_lists(mem)
  objs = pivot_object_lists(object_lists)

  if list_view:
    for i, (obj_list, nodes) in enumerate(object_lists):
      if not nodes:
        continue
      out += f"list 0x{i:x}: head={fp(obj_list['head'])} tail={fp(obj_list['tail'])}\n"
      for nd, o in nodes:
        out += f"  {fp(o['addr'])} (0x{o['size']:03x}): {o['name']:15}"
        out += f"  {fp(o['behaviour_f'])} {fp(o['render_f'])} {fp(o['command_f'])}\n"
      out += "\n"
  else:
    out = "objects:\n"
    for o, lists in objs:
      out += f"  {fp(o['addr'])} (0x{o['size']:03x}): {o['name']:18}"
      out += f"  {fp(o['behaviour_f'])} {fp(o['render_f'])} {fp(o['command_f'])}"
      out += f"  {lists}\n"
    out += "\n"

  if paused:
    out += "(paused)\n"

  os.system('cls')
  print(out)

  if cheat_menu_open:
    print("[cheat menu]")
    print()
    print("1. nop object behaviour_f")
    print("2. nop object render_f")
    print("3. nop object command_f")
    print("4. nop render_f of all")
    print()
    option = input("which? ")

    if option == "1":
      obj_addr = int(input("which object? 0x"), 16)
      set_struct_field(mem, (0xffff << 0x10) | obj_addr, OBJECT, 'behaviour_f', 0x3a098)
    elif option == "2":
      obj_addr = int(input("which object? 0x"), 16)
      set_struct_field(mem, (0xffff << 0x10) | obj_addr, OBJECT, 'render_f', 0x3a098)
    elif option == "3":
      obj_addr = int(input("which object? 0x"), 16)
      set_struct_field(mem, (0xffff << 0x10) | obj_addr, OBJECT, 'command_f', 0x3a098)
    elif option == "4":
      for o, _ in objs:
        set_struct_field(mem, o['addr'], OBJECT, 'render_f', 0x3a098)
    
    cheat_menu_open = False

  while True:
    if not paused:
      time.sleep(0.5)
      break
    else:
      time.sleep(0.5)
      process_keyboard()
