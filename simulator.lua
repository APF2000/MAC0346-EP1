--[[
entrada:

1 -  O estado das unidades
2 -  A sequencia de ataques realizados entre unidades

E deverão devolver como resultado:

O estado final das unidades após os ataques

]]

function run (scenario_input)
  print("run")
  return 0
end


--result = SIMULATOR.run(scenario_input)

--print(result)

local req = require "atributos"

<<<<<<< HEAD
return {
  ["a"] = "b"
}
=======
local SIMULATOR = {}

function SIMULATOR.run(scenario_input)

  --Colocar lógica aqui
  print("passei por aqui!")
  return scenario_input
  --return scenario_input.units
end

return SIMULATOR
>>>>>>> 793e41af04baff0a0da3619978d6fb7e1786b578
