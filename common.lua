local function vector_to_angle(X, Y)
	if X > 0 then
		if Y > 0 then
			return math.pi * 1.5 + math.atan2(Y, X) -- 270deg
		else
			Y = -Y
			return math.pi + math.atan2(X, Y) -- 180deg
		end
	else
		if Y > 0 then
			X = -X
			return math.atan2(X, Y) -- 0deg
		else
			X = -X
			Y = -Y
			return math.pi * 0.5 + math.atan2(Y, X) -- 90deg
		end
	end
end
function automobile_on_activate(entity, staticdata)
	local props = minetest.deserialize(staticdata)
	entity.object:setvelocity({x = 0, y = 0, z = 0}) -- stop car (this is necessary if game exits while player is driving)
	if props then
		-- we offer backup data in case minetest lost our data
		entity.color = props.color or "automobiles_" .. entity.automobile_type .. "_color_1.png"
		entity.owner_name = props.owner_name or "singleplayer"
		entity.wheel = props.wheel or "automobiles_wheel_1.png"
		entity.back = props.back or "automobiles_" .. entity.automobile_type .. "_back_1.png"
		entity.front = props.front or "automobiles_" .. entity.automobile_type .. "_front_1.png"
		entity.decal = props.decal or "automobiles_" .. entity.automobile_type .. "_decal_1.png"
		local entity_props = entity.object:get_properties()
		-- recompile texure
		entity_props.textures = { entity.compile_texture(entity.color, entity.wheel, entity.decal, entity.back, entity.front) }
		entity.object:set_properties(entity_props)
	end
end
function automobile_get_staticdata(entity)
	return minetest.serialize({
		color = entity.color,
		wheel = entity.wheel,
		back = entity.back,
		front = entity.front,
		decal = entity.decal,
		owner_name = entity.owner_name
	})
end
function automobile_on_step(entity, dtime)

	if entity.driver then
		local ctrl = entity.driver:get_player_control()
		local velo = entity.object:getvelocity()
		local entity_decell = entity.decell
		local entity_yaw = entity.object:getyaw()
		local turn_speed = entity.turn_speed
		local acceler = entity.acceler
		local speed = math.abs(math.sqrt(velo.z * velo.z + velo.x * velo.x))
		local dir = { -- direction automobile is faceing
			x = -math.sin(entity_yaw),
			z = math.cos(entity_yaw)
		}
		local going_yaw = vector_to_angle(velo.x, velo.z)

		local yaw_diff = math.abs(entity_yaw - going_yaw)
		if yaw_diff > math.pi then yaw_diff = math.pi - (yaw_diff - math.pi) end

		if yaw_diff > (math.pi * 0.5) then -- going backward
			turn_speed = -turn_speed
			if entity.going_forward then
				entity.going_forward = false
				local range, _, _, _ = entity.object:get_animation()
				entity.object:set_animation(range, -10, 0)
			end
		else
			if not entity.going_forward then
				entity.going_forward = true
				local range, _, _, _ = entity.object:get_animation()
				entity.object:set_animation(range, 10, 0)
			end
		end

		-- e key (extra acceleration)
		if ctrl.aux1 then
			acceler = acceler * 3;
		end

		-- space key (brake)
		if ctrl.jump then
			entity_decell = entity_decell * 40
		end

		if -- are we going slow?
			speed < 0.2
		then
			if entity.going then
				entity.going = false
				local range, _, _, _ = entity.object:get_animation()
				range.y = range.x
				entity.object:set_animation(range, 10, 0)
			end
			turn_speed = 0
		else entity.going = true end

		-- gravity
		velo.y = velo.y - entity.gravity * dtime

		-- stearing
		if ctrl.left then
			if not entity.going_left then
				if entity.going then
					if entity.going_forward then
						entity.object:set_animation({x = 11, y = 21}, 10, 0)
					else
						entity.object:set_animation({x = 11, y = 21}, -10, 0)
					end
				else
					entity.object:set_animation({x = 11, y = 11}, 10, 0)
				end
				entity.going_left = true
			end
			entity_yaw = entity_yaw + turn_speed * dtime
		else entity.going_left = false end
		if ctrl.right then
			if not entity.going_right then
				if entity.going then
					if entity.going_forward then
						entity.object:set_animation({x = 22, y = 32}, 10, 0)
					else
						entity.object:set_animation({x = 22, y = 32}, -10, 0)
					end
				else
					entity.object:set_animation({x = 22, y = 22}, 10, 0)
				end
				entity.going_right = true
			end
			entity_yaw = entity_yaw - turn_speed * dtime
		else entity.going_right = false end

		if ctrl.right or ctrl.left then
			-- normalize yaw if necessary
			if entity_yaw > (math.pi * 2) then
				entity_yaw = entity_yaw - (math.pi * 2)
			elseif entity_yaw < 0 then
				entity_yaw = entity_yaw + (math.pi * 2)
			end
			entity.object:setyaw(entity_yaw)
		end

		if entity.going_left == entity.going_right then -- if both right and left are being pressed or none
			if not entity.going_straight then
				if entity.going then
					if entity.going_forward then
						entity.object:set_animation({x = 0, y = 10}, 10, 0)
					else
						entity.object:set_animation({x = 0, y = 10}, -10, 0)
					end
				else
					entity.object:set_animation({x = 0, y = 0}, 10, 0)
				end
				entity.going_straight = true
			end
		else entity.going_straight = false end

		-- movement
		-- go forward
		if ctrl.up then
			velo.x = velo.x + dir.x * acceler * dtime
			velo.z = velo.z + dir.z * acceler * dtime
			if not entity.going then
				entity.going = true
				local range, _, _, _ = entity.object:get_animation()
				range.y = range.y + 10
				if entity.going_forward then
					entity.object:set_animation(range, 10, 0)
				else
					entity.object:set_animation(range, -10, 0)
				end
			end
		end
		-- go backward
		if ctrl.down then
			velo.x = velo.x - dir.x * acceler * dtime
			velo.z = velo.z - dir.z * acceler * dtime
			if not entity.going then
				entity.going = true
				local range, _, _, _ = entity.object:get_animation()
				range.y = range.y + 10
				if entity.going_forward then
					entity.object:set_animation(range, 10, 0)
				else
					entity.object:set_animation(range, -10, 0)
				end
			end
		end

		-- activation
		--[[if ctrl.sneak then
			entity.on_activate(entity, dtime)
		end]]

		-- apply decell
		if yaw_diff > math.pi * 0.5 then
			yaw_diff = math.pi * 0.5 - (yaw_diff - math.pi * 0.5) 
		end
		local decell = entity_decell + yaw_diff * math.pi * entity.traction
		velo.x = velo.x * (1 - decell * dtime)
		velo.z = velo.z * (1 - decell * dtime)
		--velo.x = velo.x * (1 - entity.decell * dtime)
		--velo.z = velo.z * (1 - entity.decell * dtime)
		entity.object:setvelocity(velo)

		-- sounds
		-- are we going fast?
		if speed > 2 then
			if not entity.going_fast then -- see if this is the first time
				minetest.sound_stop(entity.sound)
				entity.sound = minetest.sound_play("fast_running", {
					object = entity.object,
					gain = 1.0,
					max_hear_distance = 32,
					loop = true,
				})
				entity.going_fast = true
			end
		-- we're going slowly!
		elseif entity.going_fast then -- see if this is the first time going slow
			minetest.sound_stop(entity.sound)
			entity.sound = minetest.sound_play("running", {
				object = entity.object,
				gain = 1.0,
				max_hear_distance = 32,
				loop = true,
			})
			entity.going_fast = false
		end
	end
end
function automobile_on_punch(entity, puncher)
	if entity.owner_name == puncher:get_player_name() then
		if entity.driver == puncher then
			automobile_object_detach(entity, entity.driver)
		end

		if not minetest.setting_getbool("creative_mode") then
			puncher:get_inventory():add_item("main", ItemStack("automobiles:" .. entity.automobile_type .. "_spawner"))
		end
		if entity.sound then
			minetest.sound_stop(entity.sound)
		end
		entity.object:remove()
	else
		-- random players can't kill cars
		entity.object:set_hp(entity.hp_max)
	end
end
function automobile_object_attach(entity, player)
	--force_detach(player)
	player:set_attach(entity.object, "", entity.rider_pos, {x=0, y=0, z=0})
	player:set_eye_offset(
		entity.rider_eye_offset,
		{x = entity.rider_eye_offset.x, y = entity.rider_eye_offset.y+1, z = -40}
	)
	default.player_attached[player:get_player_name()] = true
	minetest.after(0.2, function() -- we must do this because of bug
		default.player_set_animation(player, "sit" , 1)
	end)
end
function automobile_object_detach(entity, player)
	entity.driver = nil
	entity.object:setvelocity({x=0, y=0, z=0})
	player:set_detach()
	default.player_attached[player:get_player_name()] = false
	default.player_set_animation(player, "stand" , 30)
	player:set_properties({visual_size = {x=1, y=1}})
	player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	--[[local pos = player:getpos()
	pos = {x = pos.x + offset.x, y = pos.y + 0.2 + offset.y, z = pos.z + offset.z}
	minetest.after(0.2, function()
		player:setpos(pos)
	end)]]
end
function automobile_on_rightclick(entity, clicker)
	if entity.owner_name ~= clicker:get_player_name() then
		minetest.chat_send_player(clicker:get_player_name(), "This " .. entity.automobile_type .. " is owned by " .. entity.owner_name)
		return
	end
	if entity.driver and clicker == entity.driver then
		entity.object:set_animation({x = 0, y = 0}, 10, 0) -- quit animating
		minetest.sound_stop(entity.sound)
		automobile_object_detach(entity, clicker, {x=1, y=0, z=1})
	elseif not entity.driver then
		--entity.object:set_animation({x = 0, y = 0}, 10, 0) -- start animating
		entity.driver = clicker
		automobile_object_attach(entity, clicker)
		minetest.sound_play("start", {
			object = entity.object,
			gain = 1.0,
			max_hear_distance = 32,
			loop = false,
		})
		entity.sound = minetest.sound_play("running", {
			object = entity.object,
			gain = 1.0,
			max_hear_distance = 32,
			loop = true,
		})
		--[[minetest.after(1, function()
			if entity.driver then
				entity.sound = minetest.sound_play(
					"running",
					{to_player = entity.driver:get_player_name(), gain = 4, max_hear_distance = 1, loop = true}
				)
			end
		end)]]
	end
end