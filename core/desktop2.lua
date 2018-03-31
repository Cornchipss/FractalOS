local fractalCore = require("fractalcore")
local winApi = require("window-api");

local computer = require("computer")
local comp = require("component")
local fs = require("filesystem")
local thread = require("thread")
local key = require("keyboard")
local event = require("event")

local gpu = comp.gpu
local running = true

-- Desktop width & height to work with --
w, h = gpu.getResolution()

-- Files to put on desktop
local files = {}
local directories = {}

local refreshFileList = function()
  local temp, reason = fs.list(fractalCore.getDir("desktop"))
  if not temp then
    err(reason)
  end
  for f in temp do
    local indexOf = string.find(f, "/")
    if indexOf ~= nil then
      table.insert(directories, f)
    else
      table.insert(files, f)
    end
  end
end

-- Event Handlers
local mouseDown = function(x, y, mouseBtn, player)
  touchX, touchY = x, y
end
local mouseUp = function(x, y, mouseBtn, player)
  touchX, touchY = -1, -1
end
local handleInterrupt = function()
  running = false
end

-- Event listener thread
local eventListenerT = thread.create(function()
  repeat
    -- Touch : Screen Address  , x   , y     , MouseBtn  , player
    -- Key D : Keyboard Address, idk , idk   , key id, player
    -- Key U : Same as Key D
    -- Scroll: Screen Address  , x   , y     , 1/-1 (dir), player
    -- Drag  : Screen Address  , x   , y     , MouseBtn  , player
    -- Paste : Address?        , text, player ---- Happens for each line

    -- TODO: Have this custom handeled by class requiring them
    local id, address, x, y, z, player = event.pullMultiple("interrupt", "key_down", "key_up", "touch", "drop", "clipboard", "scroll")
    if     id == "interrupted" then
      handleInterrupt()
    elseif id == "key_down" then
      fractalCore.setKeyDown(y, true)
    elseif id == "key_up" then
      fractalCore.setKeyDown(y, false)
    elseif id == "touch" then
      mouseDown(x, y, z, player)
    elseif id == "drop" then
      mouseUp(x, y, z, player)
    end
  until false
end)

local drawBackground = function()
  gpu.setForeground(0x000000)
  gpu.setBackground(0xFFFFFF)

  gpu.fill(1, 1, w, h, " ")
end

local setupButtons = function()
  local lastFileIndex = 0

  local btnWidth = 20
  local btnHeight = 9

  local iconsPerRow = math.floor(w / btnWidth)
  local paddingBetweenX = (w % btnWidth) / iconsPerRow

  local iconsPerCol = math.floor(h / btnHeight)
  local paddingBetweenY = (h % btnHeight) / iconsPerCol

  --[[
  for k, v in ipairs(files) do
    local id = k - 1

    local x = (id * btnWidth + (id + 1) * paddingBetweenX)
    local column = math.floor((x + btnWidth) / w)
    x = x % w
    local y = column * btnHeight + (column + 1) * paddingBetweenY

    --setButton(id, x, y, width, height, bgcolor, fgcolor, text)
    winApi.setButton(id, x, y, btnWidth, btnHeight, 0x333333, 0x888888, v)
    winApi.setButtonAlignmentVertical(id, "bottom")

    lastFileIndex = id
  end
]]
  for k, v in ipairs(directories) do
    

    winApi.setButton(id, x, y, btnWidth, btnHeight, 0x555555, 0x999999, v)
    winApi.setButtonAlignmentVertical(id, "bottom")
  end
end

local init = function()
  w, h = gpu.getResolution()
  if not fs.isDirectory(fractalCore.getDir("desktop")) then
    if fs.makeDirectory(fractalCore.getDir("desktop")) == nil then
      err("Error creating desktop directory!")
      os.exit()
    end
    -- Give them a nice welcoming gift
    local welcomeFile = fs.open(fractalCore.getDir("desktop").."/welcome.txt", "w")
    welcomeFile:write("Hello, and welcome to Fractal OS")
    welcomeFile:close()
  end

  refreshFileList()

  setupButtons()

  while running do
    drawBackground()

    winApi.drawAll()

    os.sleep(0.1)
  end

  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  os.execute("cls")
  os.exit()
end

-- Util functions
local err = function(msg)
  error(msg)
end

init()