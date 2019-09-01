local AUXLOADER = require "auxLoader"
local path = arg[2]
path = string.format("%s.lua", path)
path = AUXLOADER.format(path)

local MATRIX = require "matrix"

local chunck = love.filesystem.load(path)
local MAP = chunck()

local blockImg = {}

function love.load()
  img = love.graphics.newImage("maps/tilesheet_complete.png")

  print("MAP = ", MAP)
  blockImg = AUXLOADER.blocks(MAP)

  love.filesystem.setRequirePath(path)

  --local layer = MAP.layers[1]
  --local block = layer.data[1]
  --local aux = AUXLOADER.format()
  --image = love.graphics.newImage(aux)
end

function love.draw()

  love.graphics.setNewFont(20)

  love.graphics.print("Hello world!", 400, 300)

  love.graphics.setBackgroundColor(MAP.backgroundcolor)

  --love.graphics.print(MAP.version, 100, 100)

  --love.graphics.draw(image, 0, 0)
  love.graphics.draw(img, blockImg, 50, 50)

end
