require("prototypes.advanced_oil_rig")
data:extend({
	{
		type = "technology",
		name = "advanced-oil-rig",
		icon = "__advanced_oil_rig__/graphics/advanced_oil_rig.png",
		icon_size = 512,
		effects = {
			{ type = "unlock-recipe", recipe = "advanced-oil-rig" },
		},
		prerequisites = {
			"production-science-pack",
			"deep_sea_oil_extraction",
			"automated_water_transport",
		},
		unit = {
			count_formula = "2000",
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
			time = 60,
		},
	},
	{
		type = "recipe",
		name = "advanced-oil-rig",
		category = "advanced-crafting",
		order = "b[fluids]-c[zil_rig]",
		enabled = false,
		allow_productivity = false,
		energy_required = 25,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 300 },
			{ type = "item", name = "engine-unit", amount = 100 },
			{ type = "item", name = "iron-gear-wheel", amount = 50 },
			{ type = "item", name = "pipe", amount = 150 },
			{ type = "item", name = "oil_rig", amount = 1 },
			{ type = "item", name = "concrete", amount = 1000 },
		},
		results = {
			{ type = "item", name = "advanced-oil-rig", amount = 1 },
		},
		crafting_machine_tint = {
			primary = { r = 0.860, g = 0.770, b = 0.590, a = 1.000 },
			secondary = { r = 0.720, g = 0.520, b = 0.260, a = 1.000 },
			tertiary = { r = 0.860, g = 0.770, b = 0.590, a = 1.000 },
			quaternary = { r = 0.720, g = 0.520, b = 0.260, a = 1.000 },
		},
	},
})
