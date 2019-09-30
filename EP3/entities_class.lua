-- luacheck: globals love

-- Document creating class for entities

local Entity = require 'class' ()

local Vec = require "common/vec"
local large = require "entity/large"
local player = require "entity/player"
local simpleneg = require "entity/simpleneg"
local simplepos = require "entity/simplepos"
local slowpos = require "entity/slowpos"
local strongneg = require "entity/strongneg"
local strongpos = require "entity/strongpos"

local OBJECT_SPEED = 4
local MAP_RADIUS = 1000


----[[Auxiliary functions]]------

local function generateRandomPosition(rad)
  repeat
    x = math.random(-rad, rad)
    y = math.random(-rad, rad)
  until math.sqrt(x^2 + y^2) < rad
  return x, y
end

----[[Class functions]]------

function Entity:_init()
  --Initializing with default values
  self.position = {point = Vec(0, 0)}
  self.movement = {motion = Vec(0, 0)}
  self.body = {size = 8}
  self.control = {acceleration = 0.0, max_speed = 50.0}
  self.field = {strength = 1}
  self.charge = {strength = 1}
end

local function requireEntObj(name)
  local auxName = string.format("entity/%s", name)
  local loaded = love.filesystem.load(auxName)
  return loaded()
end

--- According to the name, delete the needless fields and set used fields:
function Entity:set(name)
  local path = "entity/" .. name
  local entity = require(path)

  if entity.position then --field exists
    local x, y = generateRandomPosition(MAP_RADIUS)
    self.position.point = Vec(x, y)
  else --field does not exist
    self.position = nil
  end
  if entity.movement == nil then --field does not exist
    self.movement = nil
  else --entity has movement
    self.movement.motion:set(-OBJECT_SPEED, 0)
  end
  self.body = entity.body
  self.control = entity.control
  self.field = entity.field
  self.charge = entity.charge
end

--- Draws entity according to their properties:
function Entity:draw()
  local hasfield = 0 --flag to tell if entity has field property
  local hasbody = 0 --flag to tell if entity has body property

  if self.position then --Entity has position
    local x,y = self.position.point:get() --store entitys position

    if self.field then --Entity has field property
      hasfield = 1
      -- Defining color of field:
      if self.field.strength < 0 then
        love.graphics.setColor(1, 0, 0) --red
      elseif self.field.strength > 0 then
        love.graphics.setColor(0, 0, 1) --blue
      else
        love.graphics.setColor(0, 1, 0) --green
      end
      -- Drawing field:
      love.graphics.circle('line', x, y, math.abs(self.field.strength))
    end

    if self.body then --Entity has body property
      hasbody = 1
      -- Defining color of field:
      if hasfield == 0 then --entity does't have field property
        love.graphics.setColor(0, 1, 0) --green
      end
      -- Drawing field:
      love.graphics.circle('fill', x, y, math.abs(self.body.size))
    end

    if self.charge then --Entity has charge property
      -- Defining color of charge:
      if self.charge.strength < 0 then
        love.graphics.setColor(1, 0, 0) --red
      elseif self.charge.strength > 0 then
        love.graphics.setColor(0, 0, 1) --blue
      else
        love.graphics.setColor(0, 1, 0) --green
      end
      -- Drawing charge:
      love.graphics.circle('fill', x+8, y, 4)
      love.graphics.circle('fill', x-8, y, 4)
    end

    if self.control then --Entity has control property (its the player!)
      local theta --store rotation of player
      -- Defining color of player:
      love.graphics.setColor(1, 1, 1) --white
      -- Drawing player:
      local mov_x, mov_y = self.movement.motion:get() --stores player move direction
      if mov_x > 0 and mov_y > 0 then --rotating player 45 degrees counter clockwise
        theta = math.pi/4
      elseif mov_x == 0 and mov_y > 0 then --rotating player 90 degrees counter clockwise
        theta = math.pi/2
      elseif mov_x < 0 and mov_y > 0 then --rotating player 135 degrees counter clockwise
        theta = math.pi*3/4
      elseif mov_x < 0 and mov_y == 0 then --rotating player 180 degrees
        theta = math.pi
      elseif mov_x < 0 and mov_y < 0 then --rotating player 135 degrees clockwise
        theta = -math.pi*3/4
      elseif mov_x == 0 and mov_y < 0 then --rotating player 90 degrees clockwise
        theta = -math.pi/2
      elseif mov_x > 0 and mov_y < 0 then --rotating player 45 degrees clockwise
        theta = -math.pi/4
      else --paralel to x axis, on positive orientation
        theta = 0
      end
      love.graphics.polygon('fill', x-3*math.cos(math.pi/4 + theta),y-3*math.sin(math.pi/4 + theta), x-3*math.cos(math.pi/4 - theta),y+3*math.sin(math.pi/4 - theta), x+5*math.cos(theta),y+5*math.sin(theta))
    end

    if hasfield == 0 and hasbody == 0 then --draw default circle
      -- Defining color of default circle:
      love.graphics.setColor(0, 1, 0) --green
      -- Drawing default circle:
      love.graphics.circle('line', x, y, 8)
    end
  end
  -- Puts collor back to default:
  love.graphics.setColor(1, 1, 1) --white
end

--- Mooves entity according to the movement property:
function Entity:move(dt)
  if self.movement then --entity has movement property
    local x,y = self.position.point:get() --store entitys position
    local mov_x, mov_y = self.movement.motion:get() --stores player move direction

    self.position.point:set(x + mov_x*dt, y + mov_y*dt)
    x,y = self.position.point:get() --store entitys position
    if math.sqrt(x^2 + y^2) > MAP_RADIUS then --is outside map limit
      self.position.point:set(-x, -y)
    end
  end
end


--- Changes the velocity vector of a moving entity with charge (self) based on
--  the force interection with an entity with field (other).
function Entity:force(other, dt)
  local Fx --x component of force vector
  local Fy --y component of force vector
  local C = 1000 --attraction canstant
  local f = other.field.strength
  local xf, yf = other.position.point:get()
  local q = self.charge.strength
  local xq, yq = self.position.point:get()
  local ax --x component of acceleration vector
  local ay --y component of acceleration vector
  local m --mass of charged unit
  if self.body == nil then
    m = 1
  else
    m = self.body.size
  end
  --Calculating forces and accelerations:
  Fx = C*f*q*((xq - xf)/((xq - xf)*(xq - xf) + (yq - yf)*(yq - yf)) )
  ax = Fx/m
  Fy = C*f*q*((yq - yf)/((xq - xf)*(xq - xf) + (yq - yf)*(yq - yf)) )
  ay = Fy/m
  --Calculate velocity of moving entity with charge:
  local vqx, vqy = self.movement.motion:get()
  self.movement.motion:set(vqx + ax*dt, vqy + ax*dt)
end


--- If entity has mass property (self), prevents that other entities (other)
--  occupy the same space.
function Entity:collision(other)
  --
end

return Entity
