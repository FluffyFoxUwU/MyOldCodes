#!/bin/lua5.3
--Only work on Linux
local objDir = "./objects" --Where to put .o files
local I = "./" --For the includes
local CFLAGS = "" --Linker options
local out = "main" --The output executable
local linker = "g++" --The linker command
local C_Compiler = "gcc" --the C compiler
local Cpp_Compiler = "g++ -fext-numeric-literals" --The C++ compiler
local assembler = "nasm" --Assembler only used when assembling .asm files
local ins = {}
local filePaths = {}
local blacklistedDirectory = { --put blacklisted directories here
  "./objects"
}

--[[
  ./this_file_name.lua clean
      will delete objDir content (Any data in it will be erase)
  ./this_file_name.lua (source file name needs to be no spaces in the name e.g. "main.cpp", "main.c" or "main.asm")
      compile the file then put it into objDir
  ./this_file_name.lua all
      compile if the source has no source.o file 
  ./this_file_name.lua force-all
      recompile every source file
  ./this_file_name.lua sources
      will print every source file detected
  ./this_file_name.lua link
      will link every file in objDir regardless if some sources.o not exist
  When being run without any argument it will doing nothing
  this program only accept first argument while ignoring others
]]

function ins.all()
  for k, v in pairs(ins) do
    if k ~= "all" and k ~= "clean" and k ~= "sources" and k ~= "link" and k ~= "force-all" then
      local tmp = io.open(objDir.."/"..k:gsub(".cpp$", ".o"):gsub(".c$", ".o"):gsub(".asm$", ".o"))
      if tmp == nil then
        ins[k](k)
      end
    end
  end
  
  print("Linking...")
  print("Command: \""..linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS.."\"")
  os.execute(linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS)
  return
end

function ins.forceall()
  for k, v in pairs(ins) do
    if k ~= "all" and k ~= "clean" and k ~= "sources" and k ~= "link" and k ~= "force-all" then
      ins[k](k)
    end
  end
  
  print("Linking...")
  print("Command: \""..linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS.."\"")
  os.execute(linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS)
  return
end

ins["force-all"] = ins.forceall
ins.forceall = nil;

function ins.clean()
  print("Cleaning...")
  os.execute("rm -rf "..objDir)
  os.execute("rm -rf "..out)
  os.execute("mkdir "..objDir)
end

function ins.link()
  print("Linking...")
  print("Command: \""..linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS.."\"")
  os.execute(linker.." "..objDir.."/*.o -o "..out.." "..CFLAGS)
end

function ins.sources()
  print("Getting all .cpp sources")

  local tmp = {}
  local h =io.popen("find . -type f -iregex \".*\\.cpp\"")
  for line in h:lines() do
    local no = 0
    for _, dir in ipairs(blacklistedDirectory) do
      if line:gmatch(dir)() ~= nil then
        no = no + 1
      end
    end
    if no == 0 then
      print(line)
    end 
  end
  
  print("Getting all .c sources")
  
  local h =io.popen("find . -type f -iregex \".*\\.c\"")
  for line in h:lines() do
    local no = 0
    for _, dir in ipairs(blacklistedDirectory) do
      if line:gmatch(dir)() ~= nil then
        no = no + 1
      end
    end
    if no == 0 then
      print(line)
    end 
  end
  
  print("Getting all .asm sources")
  
  local h =io.popen("find . -type f -iregex \".*\\.asm\"")
  for line in h:lines() do
    local no = 0
    for _, dir in ipairs(blacklistedDirectory) do
      if line:gmatch(dir)() ~= nil then
        print(line)
        break
      end
    end
    if no == 0 then
      print(line)
    end 
  end
end

local cpp_src = {}
local c_src = {}
local asm_src = {}

local h =io.popen("find . -type f -iregex \".*\\.cpp\"")
for line in h:lines() do
  local no = 0
  for _, dir in ipairs(blacklistedDirectory) do
    if line:gmatch(dir)() ~= nil then
      no = no + 1
    end
  end
  if no == 0 then
    filePaths[line:gmatch("[^/]*[.]cpp$")()] = line
    local a, b = line:gmatch("[^/]*[.]cpp$")()
    table.insert(cpp_src, a)
  end
end

local h =io.popen("find . -type f -iregex \".*\\.c\"")
for line in h:lines() do
  local no = 0
  for _, dir in ipairs(blacklistedDirectory) do
    if line:gmatch(dir)() ~= nil then
      no = no + 1
    end
  end
  if no == 0 then
    filePaths[line:gmatch("[^/]*[.]c$")()] = line
    local a, b = line:gmatch("[^/]*[.]c$")()
    table.insert(c_src, a)
  end
end

local h =io.popen("find . -type f -iregex \".*\\.asm\"")
for line in h:lines() do
  local no = 0
  for _, dir in ipairs(blacklistedDirectory) do
    if line:gmatch(dir)() ~= nil then
      no = no + 1
    end
  end
  if no == 0 then
    filePaths[line:gmatch("[^/]*[.]asm$")()] = line
    local a, b = line:gmatch("[^/]*[.]asm$")()
    table.insert(asm_src, a)
  end
end

for _, file in ipairs(cpp_src) do
  ins[file] = function(self)
    print("Compiling "..self)
    print("Command: \""..Cpp_Compiler.." -c -I"..I.." "..filePaths[self].." -o "..objDir.."/"..self:gsub(".cpp$", ".o").."\"")
    local a, b, c = os.execute(Cpp_Compiler.." -c -I"..I.." "..filePaths[self].." -o "..objDir.."/"..self:gsub(".cpp$", ".o"))
    if c ~= 0 then
      print("Terminating...")
      os.exit()
    end
  end
end

for _, file in ipairs(c_src) do
  ins[file] = function(self)
    print("Compiling "..self)
    print("Command: \""..C_Compiler.." -c -I"..I.." "..filePaths[self].." -o "..objDir.."/"..self:gsub(".c$", ".o").."\"")
    local a, b, c = os.execute(C_Compiler.." -c -I"..I.." "..filePaths[self].." -o "..objDir.."/"..self:gsub(".c$", ".o"))
    if c ~= 0 then
      print("Terminating...")
      os.exit()
    end
  end
end

for _, file in ipairs(asm_src) do
  ins[file] = function(self)
    print("Compiling "..self)
    print("Command: \""..assembler.." -O2 -f elf64 "..filePaths[self].." -o "..objDir.."/"..self:gsub(".asm$", ".o").."\"")
    local a, b, c = os.execute(assembler.." -O2 -f elf64 "..filePaths[self].." -o "..objDir.."/"..self:gsub(".asm$", ".o"))
    if c ~= 0 then
      print("Terminating...")
      os.exit()
    end
  end
end

if table.pack(arg)[1][1] == nil then
  print("Nothing to do")
  return
end

if ins[table.pack(arg)[1][1]] == nil then
  print("No such function \""..tostring(table.pack(arg)[1][1]).."\"")
  return
else
  print("Running...")
  ins[table.pack(arg)[1][1]](table.pack(arg)[1][1])
end
