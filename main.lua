--!strict
local run_service: RunService = game:GetService("RunService")

local debounce_tick: number = 0 

local function do_options(tabl, options)
	if type(tabl) ~= "table" then
		tabl = options
	else
		for i,v in pairs(options) do
			local val do
				if type(tabl[i]) ~= "nil" then
					val = tabl[i]
				else
					val = options[i]
				end
			end
	
			tabl[i] = val
		end
	end

	return tabl
end

local net_module = {
	Version = "1.2.0"
}

net_module.sim_rad = function(plr: Player): RBXScriptConnection
	pcall(function() setscriptable(plr, "SimulationRadius", true) end)
	
	return run_service["Heartbeat"]:Connect(function()
		plr.SimulationRadius = 1e+10
		plr.MaximumSimulationRadius = 1e+10
		--Noticed that math.huge does interger overflow, so just in case I do 1e+10.
	end)
end

net_module.movedir_calc = function(move_dir: Vector3, amplifier: number): Vector3
	return move_dir * amplifier
end

net_module.rotvel_calc = function(rot_vel: Vector3, amplifier: number): Vector3
	return rot_vel * amplifier
end

net_module.calculate_vel = function(hum: Humanoid?, rotvel: Vector3?, options: table?): Vector3
	options = do_options(options,
		{
			st_vel = Vector3.new(0,50,0), --Stational Velocity
			dv_debounce = .05, --Dynamic Velocity debounce
			dv_amplifier = 50, --Dynamic Velocity apmplifier
			rv_amplifier = 5,  --Rotational Velocity apmplifier
			dynamic_vel = hum and true or false, --If dynamic velocity is enabled
			calc_rotvel = rotvel and true or false, --If rotvel calculation is enabled(otherwise 0,0,0)
		}
	)
	
	local vel, rotvel: Vector3 do
		local debounce_tick: number = 0 

		if not options.dynamic_vel or hum.MoveDirection.Magnitude == 0 then
			if tick() - debounce_tick < options.dv_debounce then
				vel = net_module.movedir_calc(hum.MoveDirection, options.dv_amplifier) + (Vector3.new(0,1,0) * options.st_vel) / 6
			else
				vel = options.st_vel
			end
		else
			vel = net_module.movedir_calc(hum.MoveDirection, options.dv_amplifier) + (Vector3.new(0,1,0) * options.st_vel) / 2

			debounce_tick = tick()
		end

		if options.calc_rotvel then
			rotvel = net_module.rotvel_calc(options.calc_rotvel and rotvel or Vector3.zero, options.rv_amplifier)
		else
			rotvel = Vector3.zero
		end
	end
	
	return vel,rotvel
end

local function radless(part: BasePart, hum: Humanoid?, options: table?): RBXScriptConnection
	options = do_options(options,
		{
			st_vel = Vector3.new(0,50,0), --Static Velocity
			dv_debounce = .05, --Dynamic Velocity debounce
			dv_amplifier = 50, --Dynamic Velocity amplifier
			dynamic_vel = hum and true or false
		}
	)
	
	return run_service["Heartbeat"]:Connect(function()
		local vel,rotvel: Vector3 = net_module.calculate_vel(
			options.dynamic_vel and hum or nil,
			nil,
			options
		)
		
		part:ApplyImpulse(vel)
		part.AssemblyLinearVelocity = vel

		part:ApplyAngularImpulse(rotvel)
		part.RotVelocity = rotvel --RotVelocity is built different
	end)
end

net_module.stabilize = function(part: BasePart, part_to: BasePart, hum: Humanoid, options: table?): RBXScriptConnection
	options = do_options(options,
		{
			cf_offset = CFrame.new(0,0,0), --For offseting...
			st_vel = Vector3.new(0,50,0), --Stational Velocity
			dv_debounce = .05, --Dynamic Velocity debounce
			dv_amplifier = 50, --Dynamic Velocity apmplifier
			rv_amplifier = 5,  --Rotational Velocity apmplifier
			dynamic_vel = hum and true or false, --If dynamic velocity is enabled
			calc_rotvel = true, --If rotvel calculation is enabled(otherwise 0,0,0)
			apply_vel = true --Apply velocity to stabilized part
		}
	)

	local rs_con, hb_con: RBXScriptConnection do
		rs_con = run_service["Heartbeat"]:Connect(function()
			part.CFrame = part_to.CFrame * options.cf_offset
		end)

		if options.apply_vel then
			hb_con = run_service["Heartbeat"]:Connect(function()
				part.CFrame = part_to.CFrame * options.cf_offset

				local vel, rotvel: Vector3 = net_module.calculate_vel(
					options.dynamic_vel and hum or nil,
					options.calc_rotvel and part_to.AssemblyAngularVelocity,
					options
				)

				part:ApplyImpulse(vel)
				part.AssemblyLinearVelocity = vel

				part:ApplyAngularImpulse(rotvel)
				part.RotVelocity = rotvel --RotVelocity is built different
			end)
		end
	end

	return rs_con, hb_con --Disconnect on reanim end for no mem leak gawd dammit!
end

net_module.part_tweaks = function(part: BasePart, options: table?, cpp_options: table?)
	options = do_options(options,
		{
			can_touch = false, --Cannot fire .Touched
			can_query = false, --Cannot be RayCasted
			root_priority = 127 --Part priority as root
		}
	)
	
	cpp_options = do_options(options,
		{
			density = math.huge, --density
			friction = math.huge, --friction
			elasticity = 0, --elasticity
			friction_weight = math.huge, --friction weight
			elasticity_weight = 0 --elasticity weight
		}
	)

	part.CanTouch = options.can_touch
	part.CanQuery = options.can_query

	part.RootPriority = options.root_priority

	part.CustomPhysicalProperties = PhysicalProperties.new(
		cpp_options.density,         
		cpp_options.friction,        
		cpp_options.elasticity,      
		cpp_options.friction_weight, 
		cpp_options.elasticity_weight
	)
	--some of these factors should in theory help with not loosing network ownership.
	
	pcall(function() 
		sethiddenproperty(
			part,
			"NetworkOwnershipRule",
			Enum.NetworkOwnership.Manual
		)
	end)
end

net_module.physics_tweaks = function(hum: Humanoid?)
	pcall(function()
		if hum then 
			sethiddenproperty(hum,
				"InternalBodyScale",
				Vector3.new(9e99,9e99,9e99)
			)
		end

		sethiddenproperty(workspace,
			"InterpolationThrottling", 
			Enum.InterpolationThrottlingMode.Disabled
		)
		
		sethiddenproperty(workspace,
			"PhysicsSimulationRate", 
			Enum.PhysicsSimulationRate.Fixed240Hz
		)
	
		sethiddenproperty(workspace,
			"PhysicsSteppingMethod", 
			Enum.PhysicsSteppingMethod.Fixed
		)

		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		settings().Physics.AllowSleep = false
		settings().Rendering.EagerBulkExecution = true
		settings().Physics.ForceCSGv2 = false
		settings().Physics.DisableCSGv2 = true
		settings().Physics.UseCSGv2 = false
	end)
end

net_module.set_hum_state = function(hum: Humanoid, hum_state_type: Enum)
	hum_state_type = hum_state_type or Enum.HumanoidStateType.Physics

	for _,v in pairs(Enum.HumanoidStateType:GetEnumItems()) do
		if v == hum_state_type then continue end

		pcall(function()
			hum:SetStateEnabled(v, false)
		end)
	end

	hum:SetStateEnabled(hum_state_type, true)

	hum:ChangeState(hum_state_type)
end

net_module.disable_collisions_model = function(model: Model, options: table): RBXScriptConnection
    options = do_options(options,
        {
            noclip_hats = true, --Tries getting handle of accessories.
            do_getdescendants = false --Does get descendants.
        }
    )

    local st_loop: RBXScriptConnection do
        if options.do_getdescendants then
            st_loop = run_service["Stepped"]:Connect(function()
                for _,v in pairs(model:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end)
        else
            st_loop = run_service["Stepped"]:Connect(function()
                for _,v in pairs(model:GetChildren()) do
                    if v:IsA("Accessory") and options.noclip_hats then
                        local handle = v:FindFirstChildWhichIsA("BasePart")

                        if handle then handle.CanCollide = false end
                    elseif v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        end
    end

    return st_loop
end

return net_module
