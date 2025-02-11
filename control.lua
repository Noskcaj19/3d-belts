local empty_map_gen_settings = {
  default_enable_all_autoplace_controls = false,
  property_expression_names = { cliffiness = 0 },
  autoplace_settings = {
    tile = { settings = { ["dirt-1"] = { frequency = "normal", size = "normal", richness = "normal" } } },
  },
  starting_area = "none",
}

local scaffold_map_gen_settings = {
  default_enable_all_autoplace_controls = false,
  property_expression_names = { cliffiness = 0 },
  autoplace_settings = {
    tile = { settings = { ["black-refined-concrete"] = { frequency = "normal", size = "normal", richness = "normal" } } },
  },
  starting_area = "none",
}

local function create_level_display(player)
  local root = player.gui.top.level
  if root then
    player.gui.top.level.destroy()
  end

  player.gui.top.add { type = "label", name = "level", caption = "Level 0" }
end

script.on_init(function(data)
  if not storage.surfaces or storage.surfaces[0] then
    local nauvis_idx = game.get_surface('nauvis').index
    storage.surfaces = {}
    storage.surfaces[0] = nauvis_idx
  end

  for _, player in pairs(game.players) do
    create_level_display(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  create_level_display(game.players[event.player_index])
end)


local function update_gui(player, new_level)
  if not player.gui.top.level then
    create_level_display(player)
  end
  player.gui.top.level.caption = "Level " .. new_level
end

local function table_invert(t)
  local s = {}
  for k, v in pairs(t) do
    s[v] = k
  end
  return s
end

local function level_from_surface(idx)
  local inv_surfaces = table_invert(storage.surfaces)
  return inv_surfaces[idx]
end

local function flip_direction(dir)
  if dir == defines.direction.north then
    return defines.direction.south
  elseif dir == defines.direction.south then
    return defines.direction.north
  elseif dir == defines.direction.east then
    return defines.direction.west
  elseif dir == defines.direction.west then
    return defines.direction.east
  end
end

---@param event EventData.on_built_entity | EventData.on_robot_built_entity
---@param err string
local function prevent_construction(event, err)
  local entity = event.entity
  local player = nil
  if event.player_index then
    player = game.players[event.player_index]
  end
  local stack = { name = entity.prototype.mineable_properties.products[1].name, amount = 1 }
  if event.name == defines.events.on_built_entity
      and player
      and player.can_insert(stack) then
    player.create_local_flying_text { text = err, create_at_cursor = true }
    player.insert(stack)
  else
    -- TODO: doesn't work?
    local ground_item = entity.surface.create_entity {
      name = "item-on-ground",
      position = entity.position,
      stack = stack }
    if ground_item and ground_item.valid then
      ground_item.order_deconstruction(entity.force)
    end
  end
  entity.destroy()
end

---@param up string
---@return string
local function down_belt_name_from_up(up)
  local name = string.gsub(up, "(%w*%-?)up%-belt", "%1down-belt")
  return name
end

---@param down string
---@return string
local function up_belt_name_from_down(down)
  local name = string.gsub(down, "(%w*%-?)down%-belt", "%1up-belt")
  return name
end

local error_no_z_level = "Unable to create multiple z-levels here"
local error_collision = "Collision with entity in other z-level"

script.on_event({ defines.events.on_built_entity, defines.events.on_robot_built_entity }, function(event)
  local entity = event.entity
  if entity.name:match('%w*down%-belt$') then
    entity.linked_belt_type = "input"
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event, error_no_z_level)
      return
    end

    local surface = storage.surfaces[current_level - 1] and game.get_surface(storage.surfaces[current_level - 1])
    local new_surface = false
    if not surface then
      new_surface = true
      surface = game.create_surface("Level " .. current_level - 1, empty_map_gen_settings)
      storage.surfaces[current_level - 1] = surface.index
    end
    local up_belt_name = up_belt_name_from_down(entity.name)
    if not new_surface and not surface.can_place_entity { name = up_belt_name, position = entity.position } then
      prevent_construction(event, error_collision)
      return
    end

    local other_belt = surface.create_entity {
      name = up_belt_name,
      position = entity.position,
      direction = flip_direction(entity.direction),
      force = entity.force,
    }
    if other_belt then
      other_belt.linked_belt_type = "output"
      entity.connect_linked_belts(other_belt)
    end
  elseif entity.name:match('%w*up%-belt$') then
    entity.linked_belt_type = "input"
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event, error_no_z_level)
      return
    end

    local surface = storage.surfaces[current_level + 1] and game.get_surface(storage.surfaces[current_level + 1])
    local new_surface = false
    if not surface then
      new_surface = true
      surface = game.create_surface("Level " .. current_level + 1, scaffold_map_gen_settings)
      storage.surfaces[current_level + 1] = surface.index
    end

    local down_belt_name = down_belt_name_from_up(entity.name)
    if not new_surface and not surface.can_place_entity { name = down_belt_name, position = entity.position } then
      prevent_construction(event, error_collision)
      return
    end

    local other_belt = surface.create_entity {
      name = down_belt_name,
      position = entity.position,
      direction = flip_direction(entity.direction),
      force = entity.force,
    }
    if other_belt then
      other_belt.linked_belt_type = "output"
      entity.connect_linked_belts(other_belt)
    end
  elseif entity.name == "up-pole" then
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event, error_no_z_level)
      return
    end

    local surface = storage.surfaces[current_level + 1] and game.get_surface(storage.surfaces[current_level + 1])
    local new_surface = false
    if not surface then
      new_surface = true
      surface = game.create_surface("Level " .. current_level + 1, scaffold_map_gen_settings)
      storage.surfaces[current_level + 1] = surface.index
    end

    if not new_surface and not surface.can_place_entity { name = "down-pole", position = entity.position } then
      prevent_construction(event, error_collision)
      return
    end

    local other_pole = surface.create_entity {
      name = "down-pole",
      position = entity.position,
      force = entity.force,
    }
    if other_pole then
      local other_connector = other_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      local connector = entity.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      connector.connect_to(other_connector, false, defines.wire_origin.script)
      -- other_pole.connect_neighbour(entity)
    end
  elseif entity.name == "down-pole" then
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event, error_no_z_level)
      return
    end

    local surface = storage.surfaces[current_level - 1] and game.get_surface(storage.surfaces[current_level - 1])
    local new_surface = false
    if not surface then
      new_surface = true
      surface = game.create_surface("Level " .. current_level - 1, scaffold_map_gen_settings)
      storage.surfaces[current_level - 1] = surface.index
    end

    if not new_surface and not surface.can_place_entity { name = "up-pole", position = entity.position } then
      prevent_construction(event, error_collision)
      return
    end

    local other_pole = surface.create_entity {
      name = "up-pole",
      position = entity.position,
      force = entity.force,
    }
    if other_pole then
      local other_connector = other_pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      local connector = entity.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      connector.connect_to(other_connector, false, defines.wire_origin.script)
      --other_pole.connect_neighbour(entity)
    end
  end
end)

script.on_event({ defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity }, function(event)
  local entity = event.entity
  if entity.name:match('%w*down%-belt$') or entity.name:match('%w*up%-belt$') then
    local other_belt = entity.linked_belt_neighbour
    if other_belt then
      other_belt.destroy()
    end
  elseif entity.name == "up-pole" or entity.name == "down-pole" then
    local current_level = level_from_surface(entity.surface_index)
    if not current_level then
      return
    end

    local surface
    if entity.name == "up-pole" then
      surface = storage.surfaces[current_level + 1] and game.get_surface(storage.surfaces[current_level + 1])
    else
      surface = storage.surfaces[current_level - 1] and game.get_surface(storage.surfaces[current_level - 1])
    end
    if not surface then
      return
    end

    local target_entity
    if entity.name == "up-pole" then
      target_entity = "down-pole"
    else
      target_entity = "up-pole"
    end
    local other_pole = surface.find_entity(target_entity, entity.position)
    if other_pole then
      other_pole.destroy()
    end
  end
end)

script.on_event("3dbelt-down", function(event)
  local player = game.players[event.player_index]
  local current_level = level_from_surface(player.surface_index)

  if not current_level then
    player.create_local_flying_text { text = "Unable to teleport from here", create_at_cursor = true }
    return
  end

  local surface = storage.surfaces[current_level - 1] and game.get_surface(storage.surfaces[current_level - 1])
  if surface then
    player.teleport(player.position, surface)
    update_gui(player, current_level - 1)
  end
end)

script.on_event("3dbelt-up", function(event)
  local player = game.players[event.player_index]
  local current_level = level_from_surface(player.surface_index)

  if not current_level then
    player.create_local_flying_text { text = "Unable to teleport from here", create_at_cursor = true }
    return
  end

  local surface = storage.surfaces[current_level + 1] and game.get_surface(storage.surfaces[current_level + 1])
  if surface then
    player.teleport(player.position, surface)
    update_gui(player, current_level + 1)
  end
end)

script.on_event("3dbelt-flip", function(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if not entity then return end
  if not (entity.name:match("%w*%-?down%-belt$") or entity.name:match("%w*%-?up%-belt$")) then return end
  local other = entity.linked_belt_neighbour
  if other then
    entity.disconnect_linked_belts()
    local t = entity.linked_belt_type
    entity.linked_belt_type = other.linked_belt_type
    other.linked_belt_type = t 
    entity.connect_linked_belts(other)
  end
end)
