-- player name -> car lua entity (that's being configured)
local config = {}
function show_automobile_config(player_name)
	local entity = config[player_name]
	local color = entity.color
	local decal = entity.decal
	local front = entity.front
	local back = entity.back
	local wheel = entity.wheel
	--local texture = config[player_name]:get_properties().textures[1]

	-- parse index vars
	--[[local s_end
	local s_start
	-- color
	_, s_end = texture:find(".png")
	color = texture:sub(1,s_end)

	-- backs
	_, s_start = texture:find("=", s_end)
	_, s_end = texture:find(".png", s_end)
	back = texture:sub(s_start + 1, s_end)

	-- fronts
	_, s_start = texture:find("=", s_end)
	_, s_end = texture:find(".png", s_end)
	front = texture:sub(s_start + 1, s_end)

	-- wheels
	_, s_start = texture:find("=", s_end)
	_, s_end = texture:find(".png", s_end)
	wheel = texture:sub(s_start + 1, s_end)	

	-- decal
	_, s_start = texture:find("=", s_end)
	_, s_end = texture:find(".png", s_end)
	decal = texture:sub(s_start + 1, s_end)]]

	--[[formspec = formspec .. "label[0,0;color:]"
	.. "dropdown[0,1;2;color;"
	for _, value in pairs(colors) do
		formspec = formspec .. value .. ","
	end
	formspec = formspec .. ";" .. color .. "]"]]
	local auto_type = entity.automobile_type
	local num_wheels = 8

	local formspec = "size[10,7.5]button_exit[9,0;1,1;quit;X]"
	-- colors
	formspec = formspec .. "label[0,0;color:]"
	for i = 1, entity.num_colors do
		formspec = formspec .. "image_button[" .. (i - 1) .. ",0.5;1,1;automobiles_" .. auto_type .. "_color_" .. i .. "_preview.png;color_automobiles_" .. auto_type .. "_color_".. i ..".png;;true;true;]"
	end
	-- decals
	formspec = formspec .. "label[0,1.5;decal:]"
	for i = 1, entity.num_decals do
		formspec = formspec .. "image_button[" .. (i - 1) .. ",2;1,1;automobiles_" .. auto_type .. "_decal_" .. i .. "_preview.png;decal_automobiles_" .. auto_type .. "_decal_".. i ..".png;;true;true;]"
	end
	-- fronts
	formspec = formspec .. "label[0,3;front:]"
	for i = 1, entity.num_fronts do
		formspec = formspec .. "image_button[" .. (i - 1) .. ",3.5;1,1;automobiles_" .. auto_type .. "_front_" .. i .. "_preview.png;front_automobiles_" .. auto_type .. "_front_".. i ..".png;;true;true;]"
	end
	-- backs
	formspec = formspec .. "label[0,4.5;back:]"
	for i = 1, entity.num_backs do
		formspec = formspec .. "image_button[" .. (i - 1) .. ",5;1,1;automobiles_" .. auto_type .. "_back_" .. i .. "_preview.png;back_automobiles_" .. auto_type .. "_back_".. i ..".png;;true;true;]"
	end
	-- wheels
	formspec = formspec .. "label[0,6;wheels:]"
	for i = 1, num_wheels do
		formspec = formspec .. "image_button[" .. (i - 1) .. ",6.5;1,1;automobiles_wheel_" .. i .. "_preview.png;wheel_automobiles_wheel_" .. i .. ".png;;true;true;]"
	end
	--formspec = formspec .. "box[2,;1,1;red]"
	--formspec = formspec .. "image_button[0,0;1,1;automobiles_config_tool.png;button;;true;true;automobiles_car_inv.png]"
	--formspec = formspec .. "image_button[2,2;1,1;automobiles_config_tool.png;button;;true;false;automobiles_car_inv.png]"
	minetest.show_formspec(player_name, "automobiles:config", formspec)
end
minetest.register_tool("automobiles:config_tool",{
	description = "Automobile Configuration Tool",
	inventory_image = "automobiles_config_tool.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "object" and not pointed_thing.ref:is_player() then
			local entity = pointed_thing.ref:get_luaentity()
			--[[for key,value in pairs(entity) do
				minetest.chat_send_all(key)
			end]]
			if entity.automobile_type then
				if entity.owner_name ~= user:get_player_name() then
					minetest.chat_send_player(user:get_player_name(), "This " .. entity.automobile_type .. " is owned by " .. entity.owner_name)
					return
				end
				--local texture = pointed_thing.ref:get_properties().textures[1]

				--[[ parse index vars
				local s_end
				local s_start

				-- color
				_, s_end = texture:find(".png")
				local color = texture:sub(1,s_end)

				-- back
				_, s_start = texture:find("=", s_end)
				_, s_end = texture:find(".png", s_end)
				local back = texture:sub(s_start + 1, s_end)

				-- front
				_, s_start = texture:find("=", s_end)
				_, s_end = texture:find(".png", s_end)
				local front = texture:sub(s_start + 1, s_end)

				-- wheel
				_, s_start = texture:find("=", s_end)
				_, s_end = texture:find(".png", s_end)
				local wheel = texture:sub(s_start + 1, s_end)	

				-- decal
				_, s_start = texture:find("=", s_end)
				_, s_end = texture:find(".png", s_end)
				local decal = texture:sub(s_start + 1, s_end)]]
				config[user:get_player_name()] = entity
				show_automobile_config(user:get_player_name())
			end
		end
	end,
})
minetest.register_craft({
	output = "automobiles:config_tool",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "default:steel_ingot", ""},
		{"", "", "default:steel_ingot"}
	},
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "automobiles:config" then
		for str, _ in pairs(fields) do
			if str == "quit" then
				config[player:get_player_name()] = nil
			else
				local texture_type
				local texture
				local devider
				local entity = config[player:get_player_name()]
				_, devider = str:find("_")
				texture_type = str:sub(1, devider - 1)
				texture = str:sub(devider + 1)
				--minetest.chat_send_all(texture_type)
				entity[texture_type] = texture

				local entity_props = entity.object:get_properties()
				-- recompile texure
				entity_props.textures = { entity.compile_texture(entity.color, entity.wheel, entity.decal, entity.back, entity.front) }
				entity.object:set_properties(entity_props)
			end
		end
		return true
	end
	return false
end)