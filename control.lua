script.on_init(function()
	storage.pelagos_oilrig_foundation = storage.pelagos_oilrig_foundation or {}
	storage.pelagos_oilrig_tiles = storage.pelagos_oilrig_tiles or {}
end)

script.on_configuration_changed(function()
	storage.pelagos_oilrig_foundation = storage.pelagos_oilrig_foundation or {}
	storage.pelagos_oilrig_tiles = storage.pelagos_oilrig_tiles or {}
end)

-------------------------------------------------------------------------------
-- rigs config
-------------------------------------------------------------------------------
local RIGS = {
	["advanced-oil-rig"] = {
		foundation_tile = "advanced-oil-rig-concrete",
		edge_inner_tile = "advanced-oil-rig-concrete",
		edge_outer_tile = "advanced-oil-rig-hazard-concrete-left",
		edge_thickness = 2,
		outer_margin = 5,
	},
}

-------------------------------------------------------------------------------
-- helpers
-------------------------------------------------------------------------------
local function tile_key(surface_index, x, y)
	return surface_index .. ":" .. x .. ":" .. y
end

local function get_rig_bounds(rig, cfg)
	local box = rig.selection_box
	if not box then
		return nil
	end

	local left = math.floor(box.left_top.x) - cfg.outer_margin
	local top = math.floor(box.left_top.y) - cfg.outer_margin
	local right = math.ceil(box.right_bottom.x) + cfg.outer_margin
	local bottom = math.ceil(box.right_bottom.y) + cfg.outer_margin

	return {
		left = left,
		top = top,
		right = right,
		bottom = bottom,
	}
end

local function point_is_in_rig_foundation(bounds, x, y)
	return not (x < bounds.left or x >= bounds.right or y < bounds.top or y >= bounds.bottom)
end

local function boxes_intersect(a, b)
	return not (a.right <= b.left or b.right <= a.left or a.bottom <= b.top or b.bottom <= a.top)
end

local function get_tile_name_for_position(cfg, bounds, x, y)
	local edge_thickness = cfg.edge_thickness or 1
	local dist = math.min(x - bounds.left, (bounds.right - 1) - x, y - bounds.top, (bounds.bottom - 1) - y)

	if dist == 0 then
		return cfg.edge_outer_tile or cfg.foundation_tile
	elseif dist == 1 and edge_thickness >= 2 then
		return cfg.edge_inner_tile or cfg.edge_outer_tile or cfg.foundation_tile
	elseif dist < edge_thickness then
		return cfg.edge_inner_tile or cfg.edge_outer_tile or cfg.foundation_tile
	else
		return cfg.foundation_tile
	end
end

local function apply_rig_foundation(rig, cfg, bounds)
	if not (rig and rig.valid) then
		return
	end

	local surface = rig.surface
	local tiles = {}
	local i = 1

	for x = bounds.left, bounds.right - 1 do
		for y = bounds.top, bounds.bottom - 1 do
			if point_is_in_rig_foundation(bounds, x, y) then
				tiles[i] = {
					name = get_tile_name_for_position(cfg, bounds, x, y),
					position = { x, y },
				}
				i = i + 1
			end
		end
	end

	if i > 1 then
		surface.set_tiles(tiles, true, false, false)
	end
end

local function any_active_rig_covers_tile(surface_index, x, y)
	for _, rig_data in pairs(storage.pelagos_oilrig_foundation) do
		if rig_data.surface_index == surface_index and rig_data.bounds then
			if point_is_in_rig_foundation(rig_data.bounds, x, y) then
				return true
			end
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- shared build/remove
-------------------------------------------------------------------------------
local function on_built_any_oil_rig(event)
	local rig = event.entity or event.created_entity
	if not (rig and rig.valid) then
		return
	end
	if not rig.unit_number then
		return
	end

	local cfg = RIGS[rig.name]
	if not cfg then
		return
	end

	local bounds = get_rig_bounds(rig, cfg)
	if not bounds then
		return
	end

	local surface = rig.surface
	local surface_index = surface.index

	for x = bounds.left, bounds.right - 1 do
		for y = bounds.top, bounds.bottom - 1 do
			if point_is_in_rig_foundation(bounds, x, y) then
				local key = tile_key(surface_index, x, y)
				if not storage.pelagos_oilrig_tiles[key] then
					local old = surface.get_tile(x, y)
					storage.pelagos_oilrig_tiles[key] = {
						name = old.name,
						position = { x, y },
						surface_index = surface_index,
					}
				end
			end
		end
	end

	storage.pelagos_oilrig_foundation[rig.unit_number] = {
		surface_index = surface_index,
		rig_name = rig.name,
		position = { x = rig.position.x, y = rig.position.y },
		bounds = bounds,
	}

	apply_rig_foundation(rig, cfg, bounds)
end

local function on_removed_any_oil_rig(event)
	local e = event.entity
	if not (e and e.valid) then
		return
	end
	if not e.unit_number then
		return
	end
	if not RIGS[e.name] then
		return
	end

	local data = storage.pelagos_oilrig_foundation[e.unit_number]
	if not data then
		return
	end

	local surface = game.surfaces[data.surface_index]
	if not (surface and surface.valid and data.bounds) then
		storage.pelagos_oilrig_foundation[e.unit_number] = nil
		return
	end

	storage.pelagos_oilrig_foundation[e.unit_number] = nil

	local restore_tiles = {}
	local i = 1

	for x = data.bounds.left, data.bounds.right - 1 do
		for y = data.bounds.top, data.bounds.bottom - 1 do
			if point_is_in_rig_foundation(data.bounds, x, y) then
				local key = tile_key(data.surface_index, x, y)
				local old = storage.pelagos_oilrig_tiles[key]
				if old then
					restore_tiles[i] = {
						name = old.name,
						position = { x, y },
					}
					i = i + 1
				end
			end
		end
	end

	if i > 1 then
		surface.set_tiles(restore_tiles, true, true, true)
	end

	for _, other in pairs(storage.pelagos_oilrig_foundation) do
		if
			other.surface_index == data.surface_index
			and other.bounds
			and boxes_intersect(other.bounds, data.bounds)
		then
			local other_entity = surface.find_entity(other.rig_name, other.position)
			if other_entity and other_entity.valid then
				local cfg = RIGS[other_entity.name]
				if cfg then
					apply_rig_foundation(other_entity, cfg, other.bounds)
				end
			end
		end
	end

	for x = data.bounds.left, data.bounds.right - 1 do
		for y = data.bounds.top, data.bounds.bottom - 1 do
			if point_is_in_rig_foundation(data.bounds, x, y) then
				if not any_active_rig_covers_tile(data.surface_index, x, y) then
					local key = tile_key(data.surface_index, x, y)
					storage.pelagos_oilrig_tiles[key] = nil
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
	local e = event.created_entity or event.entity
	if not e then
		return
	end
	on_built_any_oil_rig(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	local e = event.created_entity or event.entity
	if not e then
		return
	end
	on_built_any_oil_rig(event)
end)

script.on_event(defines.events.on_space_platform_built_entity, function(event)
	local e = event.entity
	if not (e and e.valid) then
		return
	end
	on_built_any_oil_rig(event)
end)

script.on_event(
	{ defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity },
	function(event)
		local e = event.entity
		if not e then
			return
		end
		on_removed_any_oil_rig(event)
	end
)
