dofile("data/lib/extoutfit_lib.lua")
local json = dofile("data/lib/json.lua")

local SHADER_SELECTOR_OPCODE = 248

local SHADERS = {
  { id = 1,  shadername = "outfit_rainbow",          name = "Arco-iris" },
  { id = 2,  shadername = "ShaderChargeBlue",        name = "Carga Azul" },
  { id = 3,  shadername = "ShaderChargeGreen",       name = "Carga Verde" },
  { id = 4,  shadername = "ShaderChargeYellow",      name = "Carga Amarela" },
  { id = 5,  shadername = "ShaderChargeRed",         name = "Carga Vermelha" },
  { id = 6,  shadername = "ShaderOutBlack",          name = "Contorno Preto" },
  { id = 7,  shadername = "ShaderOutBlue",           name = "Contorno Azul" },
  { id = 8,  shadername = "ShaderOutRed",            name = "Contorno Vermelho" },
  { id = 9,  shadername = "ShaderOutPurple",         name = "Contorno Roxo" },
  { id = 10, shadername = "ShaderOutMultiColors",    name = "Contorno Multicor" },
  { id = 11, shadername = "ShaderEstaticYellow",     name = "Estatico Amarelo" },
  { id = 12, shadername = "upgrade",                 name = "Upgrade" },
  { id = 13, shadername = "lendario",                name = "Lendario" },
  { id = 14, shadername = "mitico",                  name = "Mitico" },
  { id = 15, shadername = "epico",                   name = "Epico" },
  { id = 16, shadername = "ShaderChargeLightPink",   name = "Carga Rosa Claro" },
  { id = 17, shadername = "ShaderChargeMultiColors", name = "Carga Multicor" },
  { id = 18, shadername = "ShaderChargeObito",       name = "Carga Obito" },
  { id = 19, shadername = "especial",                name = "Especial" },
  { id = 20, shadername = "fire_aura",               name = "Aura de Fogo" },
  { id = 21, shadername = "big_fire_aura",           name = "Big Fire Aura" },
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
  if getPlayerStorageValue(cid, 81001) == 1 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You already have a shader selection open.")
    return true
  end

  setPlayerStorageValue(cid, 81000, item.uid)
  setPlayerStorageValue(cid, 81001, 1)

  local shadersJson = json.encode(SHADERS)
  doPlayerSendExtendedOpcode(cid, SHADER_SELECTOR_OPCODE, "open|" .. shadersJson)
  return true
end
