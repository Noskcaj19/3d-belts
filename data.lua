local function make_belt(source, name, color, order)
    local beltItem = table.deepcopy(data.raw.item[source])

    beltItem.name = name
    beltItem.place_result = name
    beltItem.order = order

    beltItem.icons = {
        {
            icon = data.raw.item[source].icon,
            icon_size = data.raw.item[source].icon_size,
            icon_mipmaps = data.raw.item[source].icon_mipmaps,
        },
        {
            icon = "__3d-belts__/graphics/icons/underground-belt-mask.png",
            icon_size = 64,
            tint = color,
        }
    }

    local beltRecipe = table.deepcopy(data.raw["recipe"][source])
    beltRecipe.enabled = false
    beltRecipe.name = name
    beltRecipe.results = {
        {type="item", name=name, amount=1}
    }


    local beltEntity = table.deepcopy(data.raw["underground-belt"][source])
    beltEntity.name = name
    beltEntity.type = "linked-belt"

    beltEntity.allow_side_loading = true

    beltEntity.minable.result = name
    beltEntity.max_distance = nil
    beltEntity.underground_sprite = nil
    beltEntity.underground_remove_belts_sprite = nil
    beltEntity.next_upgrade = nil

    local colorMaskSprite = {
        filename = "__3d-belts__/graphics/entity/hr-underground-belt-structure-mask.png",
        tint = color,
        width = 192,
        height = 192,
        scale = 0.5,
        priority = "extra-high",
        y = 192,
    }
    local colorMaskSpriteSide = {
        filename = "__3d-belts__/graphics/entity/hr-underground-belt-structure-mask.png",
        tint = color,
        width = 192,
        height = 192,
        scale = 0.5,
        priority = "extra-high",
        y = 384,
    }

    local directions = {
        {
            name = "direction_in",
            sprite = colorMaskSprite,
        },
        {
            name = "direction_out",
            sprite = colorMaskSprite,
        },
        {
            name = "direction_in_side_loading",
            sprite = colorMaskSpriteSide,
        },
        {
            name = "direction_out_side_loading",
            sprite = colorMaskSpriteSide,
        }
    }
    for _, direction in pairs(directions) do
        beltEntity.structure[direction.name].sheets = {
            data.raw['underground-belt'][source].structure[direction.name].sheet,
            direction.sprite,
        }
    end

    return {
        item = beltItem,
        recipe = beltRecipe,
        entity = beltEntity,
    }
end


for _, variant in pairs({ "", "fast-", "express-" }) do
    local source = variant .. "underground-belt"
    local belt = make_belt(source, variant .. "down-belt", { r = 1, g = 0, b = 0, a = .8 },
        "za-" .. data.raw.item[source].order .. "-z")

    data:extend { belt.item, belt.recipe }
    data:extend { belt.entity }
end

for _, variant in pairs({ "", "fast-", "express-" }) do
    local source = variant .. "underground-belt"
    local belt = make_belt(source, variant .. "up-belt", { r = 0, g = 1, b = 0, a = .8 },
        "zb-" .. data.raw.item[source].order .. "-z")

    data:extend { belt.item, belt.recipe }
    data:extend { belt.entity }
end

for _, variant in pairs({
    {
        name = "",
        tech = "logistics",
    },
    {
        name = "fast-",
        tech = "logistics-2",
    },
    {
        name = "express-",
        tech = "logistics-3",
    }


}) do
    table.insert(data.raw.technology[variant.tech].effects, { type = "unlock-recipe", recipe = variant.name .. "up-belt"})
    table.insert(data.raw.technology[variant.tech].effects, { type = "unlock-recipe", recipe = variant.name .. "down-belt"})
end

local function make_pole(source, name)
    local pole = table.deepcopy(data.raw.item[source])

    pole.name = name
    pole.place_result = name
    pole.icon = "__3d-belts__/graphics/icons/" .. name .. ".png"
    pole.order = "a[energy]-e[" .. name .. "]"

    local poleRecipe = table.deepcopy(data.raw["recipe"][source])
    poleRecipe.enabled = false
    poleRecipe.name = name
    poleRecipe.results = {
        {type="item", name=name, amount=1}
    }
    data:extend { pole, poleRecipe }


    local poleEntity = table.deepcopy(data.raw["electric-pole"][source])
    poleEntity.name = name
    poleEntity.minable.result = name
    poleEntity.next_upgrade = nil
    local poleSheet = "__3d-belts__/graphics/entity/" .. name .. "/" .. name .. ".png"
    poleEntity.pictures.layers[1].filename = poleSheet
    data:extend { poleEntity }
end


make_pole("medium-electric-pole", "up-pole")
make_pole("medium-electric-pole", "down-pole")
table.insert(data.raw.technology["electric-energy-distribution-1"].effects, { type = "unlock-recipe", recipe = "up-pole"})
table.insert(data.raw.technology["electric-energy-distribution-1"].effects, { type = "unlock-recipe", recipe = "down-pole"})

data:extend({
    {
        type = "custom-input",
        name = "3dbelt-up",
        key_sequence = "CONTROL + SHIFT + mouse-wheel-up",
    },
    {
        type = "custom-input",
        name = "3dbelt-down",
        key_sequence = "CONTROL + SHIFT + mouse-wheel-down",
    },
    {
        type = "custom-input",
        name = "3dbelt-flip",
        key_sequence = "F",
    }
})
