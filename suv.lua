minetest.register_entity("automobiles:suv", {
	-- custom props
	num_colors = 2,
	num_decals = 1,
	num_fronts = 1,
	num_backs = 1,
	automobile_type = "suv",
	turn_speed = 2, -- turn speed per second
	acceler = 30, -- acceleration per second
	gravity = 10, -- gravity per second
	decell = 0.2, -- decelleration per second
	traction = 1.5, -- traction per second
	rider_pos = {x=-5, y=13, z=0},
	rider_eye_offset = {x=0, y=-4, z=0},

	visual = "mesh",
	mesh = "suv.b3d",
	get_staticdata = automobile_get_staticdata,
	on_activate = automobile_on_activate,
	textures = {
		"automobiles_suv_color_1.png"
		.. "^[combine:256x256:0,0=automobiles_wheel_1.png:0,0=automobiles_suv_decal_1.png"
		.. "^[combine:256x256:0,43=automobiles_suv_back_1.png:0,187=automobiles_suv_front_1.png"
	},
	stepheight = 1.1,
	hp_max = 20,
	physical = true,
	collisionbox = {-1, 0, -1, 1, 1.55, 1},
	on_rightclick = automobile_on_rightclick,
	on_punch = automobile_on_punch,
	on_step = automobile_on_step,
	compile_texture = function(color, wheel, decal, back, front)
		return color .. "^[combine:256x256:0,0=" .. wheel .. ":0,0=" .. decal .. "^[combine:256x256:0,43=" .. back .. ":0,187=" .. front
	end,
})
minetest.register_craftitem("automobiles:suv_spawner", {
	description = "SUV",
	inventory_image = "automobiles_suv_inv.png",
	on_place = function(item, placer, pointed_thing)
		--local dir = placer:get_look_dir();
		local playerpos = placer:getpos();
		pointed_thing.above.y = pointed_thing.above.y - 0.5 -- no floating automobiles!
		local obj = minetest.env:add_entity(pointed_thing.above, "automobiles:suv")
		local entity = obj:get_luaentity()
		obj:setyaw(placer:get_look_yaw() - math.pi / 2)
		entity.decal = "automobiles_suv_decal_1.png"
		entity.wheel = "automobiles_wheel_1.png"
		entity.color = "automobiles_suv_color_1.png"
		entity.back = "automobiles_suv_back_1.png"
		entity.front = "automobiles_suv_front_1.png"
		entity.owner_name = placer:get_player_name()
		if not minetest.setting_getbool("creative_mode") then item:take_item() end
		return item
	end,
})
minetest.register_craft({
	output = "automobiles:suv_spawner",
	recipe = {
		{"default:glass", "default:glass", ""},
		{"default:steelblock", "default:steelblock", "default:steelblock"}
	},
})