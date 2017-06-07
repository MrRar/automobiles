minetest.register_entity("automobiles:car", {
	-- custom props
	num_colors = 7,
	num_decals = 5,
	num_fronts = 6,
	num_backs = 7,
	automobile_type = "car",
	turn_speed = 2, -- turn speed radians per second
	acceler = 20, -- acceleration per second
	gravity = 10, -- gravity per second
	decell = 0.2, -- decelleration per second
	traction = 1.5, -- traction per second
	rider_pos = {x=-4, y=13, z=-2},
	rider_eye_offset = {x=0, y=-4, z=0},

	visual = "mesh",
	mesh = "car.b3d",
	get_staticdata = automobile_get_staticdata,
	on_activate = automobile_on_activate,
	textures = {
		"automobiles_car_color_1.png"
		.. "^[combine:256x256:0,0=automobiles_wheel_1.png:0,0=automobiles_car_decal_1.png"
		.. "^[combine:256x256:3,178=automobiles_car_back_1.png:3,39=automobiles_car_front_1.png"
	},
	stepheight = 1.1,
	hp_max = 20,
	physical = true,
	collisionbox = {-1, 0, -1, 1, 1.55, 1},
	on_rightclick = automobile_on_rightclick,
	on_punch = automobile_on_punch,
	on_step = automobile_on_step,
	compile_texture = function(color, wheel, decal, back, front)
		return color .. "^[combine:256x256:0,0=" .. wheel .. ":0,0=" .. decal .. "^[combine:256x256:3,178=" .. back .. ":3,39=" .. front
	end,
})
minetest.register_craftitem("automobiles:car_spawner", {
	description = "Car",
	inventory_image = "automobiles_car_inv.png",
	on_place = function(item, placer, pointed_thing)
		--local dir = placer:get_look_dir();
		local playerpos = placer:getpos()
		pointed_thing.above.y = pointed_thing.above.y - 0.5 -- no floating automobiles!
		local obj = minetest.env:add_entity(pointed_thing.above, "automobiles:car")
		local entity = obj:get_luaentity()
		obj:setyaw(placer:get_look_yaw() - math.pi / 2)
		entity.decal = "automobiles_car_decal_1.png"
		entity.wheel = "automobiles_wheel_1.png"
		entity.color = "automobiles_car_color_1.png"
		entity.back = "automobiles_car_back_1.png"
		entity.front = "automobiles_car_front_1.png"
		entity.automobile_type = "car"
		entity.owner_name = placer:get_player_name()
		if not minetest.setting_getbool("creative_mode") then item:take_item() end
		return item
	end,
})
minetest.register_craft({
	output = "automobiles:car_spawner",
	recipe = {
		{"", "default:glass", ""},
		{"default:steelblock", "default:steelblock", "default:steelblock"}
	},
})