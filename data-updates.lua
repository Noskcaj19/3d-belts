local downBeltItem = table.deepcopy(data.raw.item["underground-belt"])

downBeltItem.name = "down-belt"
downBeltItem.place_result = "down-belt"
downBeltItem.icon = "__3d-belts__/graphics/icons/down-belt.png"

local downBeltRecipe = table.deepcopy(data.raw["recipe"]["underground-belt"])
downBeltRecipe.enabled = true
downBeltRecipe.name = "down-belt"
downBeltRecipe.result = "down-belt"
data:extend{downBeltItem, downBeltRecipe}


local downBeltEntity = table.deepcopy(data.raw["underground-belt"]["underground-belt"])
downBeltEntity.name = "down-belt"
downBeltEntity.type = "linked-belt"

downBeltEntity.minable.result = "down-belt"
downBeltEntity.max_distance = nil
downBeltEntity.underground_sprite = nil
downBeltEntity.underground_remove_belts_sprite = nil
downBeltEntity.next_upgrade = nil
-- hsv 0.003, .57, -.1
local downBeltSheet = "__3d-belts__/graphics/entity/down-belt/down-belt-structure.png"
local downBeltSheetHr = "__3d-belts__/graphics/entity/down-belt/hr-down-belt-structure.png"
downBeltEntity.structure.direction_in.sheet.filename = downBeltSheet
downBeltEntity.structure.direction_in.sheet.hr_version.filename = downBeltSheetHr
downBeltEntity.structure.direction_in_side_loading.sheet.filename = downBeltSheet
downBeltEntity.structure.direction_in_side_loading.sheet.hr_version.filename = downBeltSheetHr
downBeltEntity.structure.direction_out.sheet.filename = downBeltSheet
downBeltEntity.structure.direction_out.sheet.hr_version.filename = downBeltSheetHr
downBeltEntity.structure.direction_out_side_loading.sheet.filename = downBeltSheet
downBeltEntity.structure.direction_out_side_loading.sheet.hr_version.filename = downBeltSheetHr

data:extend{downBeltEntity}




local upBeltItem = table.deepcopy(data.raw.item["underground-belt"])

upBeltItem.name = "up-belt"
upBeltItem.place_result = "up-belt"
upBeltItem.icon = "__3d-belts__/graphics/icons/up-belt.png"

local recipeUp = table.deepcopy(data.raw["recipe"]["underground-belt"])
recipeUp.enabled = true
recipeUp.name = "up-belt"
recipeUp.result = "up-belt"
data:extend{upBeltItem, recipeUp}


local upBeltEntity = table.deepcopy(data.raw["underground-belt"]["underground-belt"])
upBeltEntity.name = "up-belt"
upBeltEntity.type = "linked-belt"

upBeltEntity.minable.result = "up-belt"
upBeltEntity.max_distance = nil
upBeltEntity.underground_sprite = nil
upBeltEntity.underground_remove_belts_sprite = nil
upBeltEntity.next_upgrade = nil
-- hsv 0.32, 1, -.471
local upBeltSheet = "__3d-belts__/graphics/entity/up-belt/up-belt-structure.png"
local upBeltSheetHr = "__3d-belts__/graphics/entity/up-belt/hr-up-belt-structure.png"
upBeltEntity.structure.direction_in.sheet.filename = upBeltSheet
upBeltEntity.structure.direction_in.sheet.hr_version.filename = upBeltSheetHr
upBeltEntity.structure.direction_in_side_loading.sheet.filename = upBeltSheet
upBeltEntity.structure.direction_in_side_loading.sheet.hr_version.filename = upBeltSheetHr
upBeltEntity.structure.direction_out.sheet.filename = upBeltSheet
upBeltEntity.structure.direction_out.sheet.hr_version.filename = upBeltSheetHr
upBeltEntity.structure.direction_out_side_loading.sheet.filename = upBeltSheet
upBeltEntity.structure.direction_out_side_loading.sheet.hr_version.filename = upBeltSheetHr

data:extend{upBeltEntity}


local downPoleItem = table.deepcopy(data.raw.item["medium-electric-pole"])

downPoleItem.name = "down-pole"
downPoleItem.place_result = "down-pole"
downPoleItem.icon = "__3d-belts__/graphics/icons/down-pole.png"


local downPoleRecipe = table.deepcopy(data.raw["recipe"]["medium-electric-pole"])
downPoleRecipe.enabled = true
downPoleRecipe.name = "down-pole"
downPoleRecipe.result = "down-pole"
data:extend{downPoleItem, downPoleRecipe}


local downPoleEntity = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
downPoleEntity.name = "down-pole"
downPoleEntity.minable.result = "down-pole"
downPoleEntity.next_upgrade = nil
local downPoleSheet = "__3d-belts__/graphics/entity/down-pole/down-pole.png"
local downPoleSheetHr = "__3d-belts__/graphics/entity/down-pole/hr-down-pole.png"
downPoleEntity.pictures.layers[1].filename = downPoleSheet
downPoleEntity.pictures.layers[1].hr_version.filename = downPoleSheetHr
data:extend{downPoleEntity}


local upPole = table.deepcopy(data.raw.item["medium-electric-pole"])

upPole.name = "up-pole"
upPole.place_result = "up-pole"
upPole.icon = "__3d-belts__/graphics/icons/up-pole.png"

local upPoleRecipe = table.deepcopy(data.raw["recipe"]["medium-electric-pole"])
upPoleRecipe.enabled = true
upPoleRecipe.name = "up-pole"
upPoleRecipe.result = "up-pole"
data:extend{upPole, upPoleRecipe}


local upPoleEntity = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
upPoleEntity.name = "up-pole"
upPoleEntity.minable.result = "up-pole"
upPoleEntity.next_upgrade = nil
local upPoleSheet = "__3d-belts__/graphics/entity/up-pole/up-pole.png"
local upPoleSheetHr = "__3d-belts__/graphics/entity/up-pole/hr-up-pole.png"
upPoleEntity.pictures.layers[1].filename = upPoleSheet
upPoleEntity.pictures.layers[1].hr_version.filename = upPoleSheetHr
data:extend{upPoleEntity}

data:extend({
  {
    type = "custom-input",
    name = "3dbelt-up",
    key_sequence = "CONTROL + UP",
  },{
    type = "custom-input",
    name = "3dbelt-down",
    key_sequence = "CONTROL + DOWN",
  }
})