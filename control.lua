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

script.on_init(function(data)
  if not global.surfaces or global.surfaces[0] then
    local nauvis_idx = game.get_surface('nauvis').index
    global.surfaces = {}
    global.surfaces[0] = nauvis_idx
  end

  for _, player in pairs(game.players) do
      create_level_display(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  create_level_display(game.players[event.player_index])
end)

function create_level_display(player)
  local root = player.gui.top.level
  if root then
    player.gui.top.level.destroy()
  end

  local root = player.gui.top.add{type="label",name="level",caption="Level 0"}
end

function update_gui(player, new_level)
  if not player.gui.top.level then
    create_level_display(player)
  end
  player.gui.top.level.caption = "Level " .. new_level
end

function table_invert(t)
   local s = {}
   for k, v in pairs(t) do
     s[v] = k
   end
   return s
end

function level_from_surface(idx)
  local inv_surfaces = table_invert(global.surfaces)
  return inv_surfaces[idx]
end

function flip_direction(dir)
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

function prevent_construction(event)
  local entity = event.created_entity
  local player = nil
  if event.player_index then
    player = game.players[event.player_index]
  end
  local stack = {name=entity.prototype.mineable_properties.products[1].name, amount=1}
  if event.name == defines.events.on_built_entity
    and player
    and player.can_insert(stack) then
    player.create_local_flying_text{text="Unable to create multiple z-levels here",create_at_cursor=true}
    player.insert(stack)
  else
    -- TODO: doesn't work?
    local ground_item = entity.surface.create_entity{
      name = "item-on-ground",
      position = entity.position,
      stack = stack}
    if ground_item and ground_item.valid then
      ground_item.order_deconstruction(entity.force)
    end
  end
  entity.destroy()
end


script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
  local entity = event.created_entity
  local player = nil
  if event.player_index then
    player = game.players[event.player_index]
  end
  if entity.name == "down-belt" then
    entity.linked_belt_type = "input"
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event)
      return
    end
    
    local surface = global.surfaces[current_level - 1] and game.get_surface(global.surfaces[current_level - 1])
    if not surface then
      surface = game.create_surface("Level " .. current_level - 1, empty_map_gen_settings)
      global.surfaces[current_level - 1] = surface.index
    end
    local other_belt = surface.create_entity{
      name="up-belt",
      position=entity.position,
      direction=flip_direction(entity.direction),
      force=entity.force,
    }
    other_belt.linked_belt_type = "output"
    entity.connect_linked_belts(other_belt)
  elseif entity.name == "up-belt" then
    entity.linked_belt_type = "input"
    local current_level = level_from_surface(entity.surface_index)
   
    if not current_level then
      prevent_construction(event)
      return
    end

    local surface = global.surfaces[current_level + 1] and game.get_surface(global.surfaces[current_level + 1])
    if not surface then
      surface = game.create_surface("Level " .. current_level + 1, scaffold_map_gen_settings)
      global.surfaces[current_level + 1] = surface.index
    end
    local other_belt = surface.create_entity{
      name="down-belt",
      position=entity.position,
      direction=flip_direction(entity.direction),
      force=entity.force,
    }
    other_belt.linked_belt_type = "output"
    entity.connect_linked_belts(other_belt)
  elseif entity.name == "up-pole" then
    local current_level = level_from_surface(entity.surface_index)
    
    if not current_level then
      prevent_construction(event)
      return
    end

    local surface = global.surfaces[current_level + 1] and game.get_surface(global.surfaces[current_level + 1])
    if not surface then
      surface = game.create_surface("Level " .. current_level + 1, scaffold_map_gen_settings)
      global.surfaces[current_level + 1] = surface.index
    end
    local other_pole = surface.create_entity{
      name="down-pole",
      position=entity.position,
      force=entity.force,
    }
    other_pole.connect_neighbour(entity)
  elseif entity.name == "down-pole" then
    local current_level = level_from_surface(entity.surface_index)

    if not current_level then
      prevent_construction(event)
      return
    end

    local surface = global.surfaces[current_level - 1] and game.get_surface(global.surfaces[current_level - 1])
    if not surface then
      surface = game.create_surface("Level " .. current_level - 1, scaffold_map_gen_settings)
      global.surfaces[current_level - 1] = surface.index
    end
    local other_pole = surface.create_entity{
      name="up-pole",
      position=entity.position,
      force=entity.force,
    }
    other_pole.connect_neighbour(entity)
  end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  if entity.name == "up-belt" or entity.name == "down-belt" then
    local other_belt = entity.linked_belt_neighbour
    if other_belt then
      other_belt.destroy()
    end
  end
end)

script.on_event("3dbelt-down", function(event)
  local player = game.players[event.player_index]
  local current_level = level_from_surface(player.surface_index)

  if not current_level then
    player.create_local_flying_text{text="Unable to teleport from here",create_at_cursor=true}
    return
  end

  local surface = global.surfaces[current_level - 1] and game.get_surface(global.surfaces[current_level - 1])
  if surface then
    player.teleport(player.position, surface)
    update_gui(player, current_level - 1)
  end
end)

script.on_event("3dbelt-up", function(event)
  local player = game.players[event.player_index]
  local current_level = level_from_surface(player.surface_index)
  
  if not current_level then
    player.create_local_flying_text{text="Unable to teleport from here",create_at_cursor=true}
    return
  end

  local surface = global.surfaces[current_level + 1] and game.get_surface(global.surfaces[current_level + 1])
  if surface then
    player.teleport(player.position, surface)
    update_gui(player, current_level + 1)
  end
end)