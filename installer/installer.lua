local comp = require("component")
local fs = require("filesystem")
local key = require("keyboard")
local event = require("event")
local term = require("term")

local internet = comp.internet
local gpu = comp.gpu;

local line = 1

oW, oH = gpu.getResolution()
print(oW..", "..oH)

gpu.setForeground(0x004488)
gpu.setBackground(0xffffff)
gpu.fill(1, 1, oW, oH, " ")

gpu.setResolution(40, 20)
w, h = gpu.getResolution()

local printCentered = function(txt, height)
  gpu.set(w / 2 - math.floor(string.len(txt) / 2), height, txt)
  line = height + 1
  if line > h then
    line = 1
  end
end

printCentered("Welcome to Fractal OS!", 2)
printCentered("An open source OS for Open Computers!", 3)

os.sleep(2)

printCentered("Install? y/n", 5)

local ch = ''

repeat -- Wait until they type a valid key...
  _, _, _, ch = event.pull('key_down')
until ch == 21 or ch == 49 -- y = 21; n = 49

if ch == 49 then
  printCentered("Cancelling installation", line)
  os.sleep(2)
  gpu.setForeground(0xffffff)
  gpu.setBackground(0x000000)
  gpu.setResolution(oW, oH)

  gpu.fill(1, 1, oW, oH, " ")

  term.clear()
  os.exit()
end

local function internetRequest(url)
  local success, response = pcall(internet.request, url)
  if success then
    local responseData = ""
    while true do
      local data, responseChunk = response.read()
      if data then
        responseData = responseData..data
      else
        if responseChunk then
          return false, responseChunk
        else
          return true, responseData
        end
      end
    end
  else
    return false, reason
  end
end

local function err(ex) -- TODO: Make better
  os.execute("cls")
  print(ex)
  os.exit()
end

local function getFileFromURL(url, path)
  local success, response = internetRequest(url)
  if success then
    fs.makeDirectory(fs.path(path) or "/")
    local file = io.open(path, "w")
    file:write(response)
    file:close()
  else
    err("Could not connect to the url \""..url.."\"")
  end
end

printCentered("Installing...", line)
local githubRoot = "https://raw.githubusercontent.com/Cornchipss/FractalOS/master/"
local fractalCore = require("fractalcore")

fs.makeDirectory(fractalCore.rootDir)
fs.makeDirectory(fractalCore.coreDir)
fs.makeDirectory(fractalCore.rootDir)
fs.makeDirectory(fractalCore.rootDir)
fs.makeDirectory(fractalCore.userDir)
fs.makeDirectory(fractalCore.userDir)

getFileFromURL(githubRoot.."core/fractalcore.lua", fractalCore.libDir.."fractalcore.lua")
getFileFromURL(githubRoot.."core/desktop.lua", fractalCore.coreDir.."desktop.lua")
getFileFromURL(githubRoot.."core/boot.lua", fractalCore.rootDir.."boot.lua")
gpu.setResolution(oW, oH)
os.execute("cls")
