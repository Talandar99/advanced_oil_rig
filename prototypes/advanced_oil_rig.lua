local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")
local simulations = require("__base__.prototypes.factoriopedia-simulations")
local item_sounds = require("__base__.prototypes.item_sounds")

local advanced_oil_rig_concrete = util.table.deepcopy(data.raw["tile"]["concrete"])
advanced_oil_rig_concrete.name = "advanced-oil-rig-concrete"
advanced_oil_rig_concrete.minable = nil
advanced_oil_rig_concrete.allows_being_covered = false
data:extend({ advanced_oil_rig_concrete })

local advanced_oil_rig_hazard_concrete = util.table.deepcopy(data.raw["tile"]["hazard-concrete-left"])
advanced_oil_rig_hazard_concrete.name = "advanced-oil-rig-hazard-concrete-left"
advanced_oil_rig_hazard_concrete.minable = nil
advanced_oil_rig_hazard_concrete.allows_being_covered = false
data:extend({ advanced_oil_rig_hazard_concrete })

local advanced_oil_rig_refined_concrete = util.table.deepcopy(data.raw["tile"]["refined-concrete"])
advanced_oil_rig_refined_concrete.name = "advanced-oil-rig-refined-concrete"
advanced_oil_rig_refined_concrete.minable = nil
advanced_oil_rig_refined_concrete.allows_being_covered = false
data:extend({ advanced_oil_rig_refined_concrete })

local advanced_oil_rig_refined_hazard_concrete = util.table.deepcopy(data.raw["tile"]["refined-hazard-concrete-left"])
advanced_oil_rig_refined_hazard_concrete.name = "advanced-oil-rig-refined-hazard-concrete-left"
advanced_oil_rig_refined_hazard_concrete.minable = nil
advanced_oil_rig_refined_hazard_concrete.allows_being_covered = false
data:extend({ advanced_oil_rig_refined_hazard_concrete })

data:extend({
	{
		type = "item",
		name = "advanced-oil-rig",
		icon = "__advanced_oil_rig__/graphics/advanced_oil_rig_64.png",
		subgroup = "extraction-machine",
		order = "b[fluids]-b[pumpjack]",
		inventory_move_sound = item_sounds.pumpjack_inventory_move,
		pick_sound = item_sounds.pumpjack_inventory_pickup,
		drop_sound = item_sounds.pumpjack_inventory_move,
		place_result = "advanced-oil-rig",
		stack_size = 20,
		weight = 1000 * kg,
	},
	{
		type = "mining-drill",
		name = "advanced-oil-rig",
		icon = "__advanced_oil_rig__/graphics/advanced_oil_rig_64.png",
		flags = { "placeable-neutral", "player-creation", "not-rotatable" },
		minable = { mining_time = 0.5, result = "advanced-oil-rig" },
		resource_categories = { "offshore-fluid" },
		max_health = 200,
		corpse = "pumpjack-remnants",
		dying_explosion = "pumpjack-explosion",
		collision_mask = { layers = { object = true, train = true } },
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		damaged_trigger_effect = hit_effects.entity(),
		drawing_box_vertical_extension = 1,
		energy_source = {
			type = "fluid",
			burns_fluid = true, -- fluid used as power
			scale_fluid_usage = true,
			fluid_box = {
				pipe_picture = assembler3pipepictures(),
				pipe_covers = pipecoverspictures(),
				always_draw_covers = false,
				volume = 100,
				pipe_connections = {
					{
						direction = defines.direction.west,
						position = { -2, 1 },
						flow_direction = "input",
					},
					{
						direction = defines.direction.north,
						position = { -1, -2 },
						flow_direction = "input",
					},
					{
						direction = defines.direction.east,
						position = { 2, -1 },
						flow_direction = "input",
					},
					{
						direction = defines.direction.south,
						position = { 1, 2 },
						flow_direction = "input",
					},
				},
				production_type = "input",
			},
			smoke = {
				{
					name = "smoke",
					frequency = 10,
					position = { 0, 0 },
					starting_vertical_speed = 0.06, --base 0.08
					starting_frame_deviation = 60,
				},
			},
			emissions_per_minute = { pollution = 10 }, --12 is burner drill ,10 is electric drill
		},
		--energy_source = {
		--	type = "electric",
		--	emissions_per_minute = { pollution = 10 },
		--	usage_priority = "secondary-input",
		--},
		output_fluid_box = {
			volume = 1000,
			--pipe_covers = pipecoverspictures(),
			--pipe_connections = {
			--	{
			--		direction = defines.direction.north,
			--		positions = { { 1, -1 }, { 1, -1 }, { -1, 1 }, { -1, 1 } },
			--		flow_direction = "output",
			--	},
			--},
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			always_draw_covers = true,
			pipe_connections = {
				{
					direction = defines.direction.west,
					position = { -2, -1 },
					flow_direction = "output",
				},
				{
					direction = defines.direction.north,
					position = { 1, -2 },
					flow_direction = "output",
				},
				{
					direction = defines.direction.east,
					position = { 2, 1 },
					flow_direction = "output",
				},
				{
					direction = defines.direction.south,
					position = { -1, 2 },
					flow_direction = "output",
				},
			},
		},
		energy_usage = "1MW",
		mining_speed = 2,
		--resource_searching_radius = 0.49,
		resource_searching_radius = 1.49,
		vector_to_place_result = { 0, 0 },
		module_slots = 4,
		radius_visualisation_picture = {
			filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
			width = 12,
			height = 12,
		},
		monitor_visualization_tint = { 78, 173, 255 },
		base_render_layer = "object",
		base_picture = {
			sheets = {
				{
					filename = "__advanced_oil_rig__/graphics/pumpjack-base.png",
					priority = "extra-high",
					width = 273,
					height = 273,
					shift = util.by_pixel(0, -2),
					scale = 0.57,
					frames = 1,
				},
				--{
				--	filename = "__base__/graphics/entity/pumpjack/pumpjack-base-shadow.png",
				--	width = 220,
				--	height = 220,
				--	scale = 0.6,
				--	draw_as_shadow = true,
				--	shift = util.by_pixel(6, 0.5),
				--},
			},
		},
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							priority = "high",
							filename = "__advanced_oil_rig__/graphics/pumpjack-horsehead.png",
							animation_speed = 0.5,
							scale = 0.6,
							line_length = 8,
							width = 206,
							height = 202,
							frame_count = 40,
							shift = util.by_pixel(-4, -24),
						},
						{
							priority = "high",
							filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
							animation_speed = 0.5,
							draw_as_shadow = true,
							line_length = 8,
							width = 309,
							height = 82,
							frame_count = 40,
							scale = 0.6,
							shift = util.by_pixel(17.75, 14.5),
						},
					},
				},
			},
		},
		open_sound = { filename = "__base__/sound/open-close/pumpjack-open.ogg", volume = 0.5 },
		close_sound = { filename = "__base__/sound/open-close/pumpjack-close.ogg", volume = 0.5 },
		working_sound = {
			sound = { filename = "__base__/sound/pumpjack.ogg", volume = 0.7, audible_distance_modifier = 0.6 },
			max_sounds_per_prototype = 3,
			fade_in_ticks = 4,
			fade_out_ticks = 10,
		},

		circuit_connector = circuit_connector_definitions["pumpjack"],
		circuit_wire_max_distance = default_circuit_wire_max_distance,
	},
})
