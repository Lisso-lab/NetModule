# Documentation
---
Note:
When there is **?** next to for example: table?
That means it is optional and it doesn't need to be passed.

`options` which are passed in functions don't need to be passed, or there can be
passed only one argument. It is written this way.

if there is : Runservice after finishing function, that means that is the type
that will be returned.

---
## module.sim_rad
```lua
function module.sim_rad(player: Player): Runservice
```
Connects Heartbeat loop which sets SimulationRadius and MaximumSimulationRadius to 1e+10

### Parameters

* `player` - `: Player` on whom connection is used.

### Example
```lua
local sim_rad_connection = module.sim_rad(plr)
```
---
## module.movedir_calc
```lua
function module.movedir_calc(move_dir: Vector3, amplifier: number): Vector3
```
used to amplify `MoveDirection` of humanoid.

### Parameters

* `move_dir` - `: Vector3` MoveDirection from `Humanoid`
* `amplifier` - `: number` by whom `move_dir` is amplified(configurable, will be seen further down)

### Example
```lua
local amplified_velocity = module.movedir_calc(move_dir, 50)
--move_dir * amplifier
```
---
## module.rotvel_calc
```lua
function module.rotvel_calc(rot_vel: Vector3, amplifier: number): Vector3
```
used to amplify `AssemblyAngularVelocity` of desired part.

### Parameters

* `rot_vel` - `: Vector3` RotVelocity from desired part
* `amplifier` - `: number` by whom `rot_vel` is amplified(configurable, will be seen further down)

### Example
```lua
local amplified_rotvel = module.rotvel_calc(move_dir, 50)
--rot_vel * amplifier
```
---
## module.calculate_vel
```lua
function module.calculate_vel(hum: Humanoid, rotvel: Vector3, options: table?): Vector3
```
used to calculate `Static velocity`, `Dynamic velocity` and `RotVelocity` (mostly optional).

### Parameters

* `hum` - `: Humanoid?` Humanoid used for `Dynamic velocity`(optional).
* `rotvel` - `: Vector3?` Passed for amplifying `RotVelocity` (for `module.stabilize`, optional).
* `options` - `: table` options for customizing various variables (options shown in example).

### Example
```lua
local options = {
	st_vel = Vector3.new(0,50,0), --Stational Velocity
	dv_debounce = .05, --Dynamic Velocity debounce
	dv_amplifier = 50, --Dynamic Velocity apmplifier
	rv_amplifier = 5,  --Rotational Velocity apmplifier
	dynamic_vel = hum and true or false, --If dynamic velocity is enabled
	calc_rotvel = rotvel and true or false, --If rotvel calculation is enabled(otherwise 0,0,0)
}
--default options in functions.

local calculated_velocity = module.calculate_velocity(
	hum,
	nil, --RotVelocity, if passed nil, <calc_rotvel> in options will be disabled(seen above)
	{
		st_vel = Vector3.new(30,0,0)
	} --one option can be set, or all of them.
)
```
---
## module.radless
```lua
function module.radless(part: BasePart, hum: Humanoid?, options: table?): Vector3
```
used to simply add velocity to one part. `Dynamic velocity` is optional.
returns Heartbeat connection with velocity being applied inside.

### Parameters

* `part` - `: BasePart` part to whom `Velocity` is applied.
* `hum` - `: Humanoid` used for doing Dynamic velocity(optional).
* `options` - `: table` options for customizing various variables (options shown in example).

### Example
```lua
local options = {
	st_vel = Vector3.new(0,50,0), --Static Velocity
	dv_debounce = .05, --Dynamic Velocity debounce
	dv_amplifier = 50, --Dynamic Velocity amplifier
	dynamic_vel = hum and true or false
}
--default options in functions.

local radless_connection = module.radless(
	part,
	hum,
	{
		st_vel = Vector3.new(30,0,0)
	} --one option can be set, or all
)
--returns Heartbeat connection.
```
---
## module.stabilize
```lua
function module.stabilize(part: BasePart, part_to: BasePart, hum: Humanoid?, options: table?): RunService
```
Stabilizes one part to another, with(optionaly) velocity being applied,
Uses `CFrame`'s to stabilize parts. Also has offset option `: CFrame`.

### Parameters

* `part` - `: BasePart` part, which is stabilized to `part_to`.
* `part_to` - `: BasePart` part, to whom is stabilized `part`.
* `hum` - `: Humanoid` used for calculating dynamic velocity(optional).
* `options` - `: table` options for customizing various variables (options shown in example).

### Example
```lua
local options = {
	cf_offset = CFrame.new(0,0,0), --For offseting...
	st_vel = Vector3.new(0,50,0), --Stational Velocity
	dv_debounce = .05, --Dynamic Velocity debounce
	dv_amplifier = 50, --Dynamic Velocity apmplifier
	rv_amplifier = 5,  --Rotational Velocity apmplifier
	dynamic_vel = hum and true or false, --If dynamic velocity is enabled
	calc_rotvel = true, --If rotvel calculation is enabled(otherwise 0,0,0)
	apply_vel = true --Apply velocity to stabilized part
}
--Default options in function.

local stabilize_connection = module.stabilize(
	part, 
	part1,
	hum, 
	{
		cf_offset = CFrame.new(1,0,0),
		st_vel = Vector3.new(0,0,30)
	}
)
--Returns renderstepped and heartbeat connection.
```
---
## module.part_tweaks
```lua
function module.part_tweaks(part: BasePart, options: table?, cpp_options: table?)
```
used to tweak properties of parts for better `NetworkOwnership`.

### Parameters

* `part` - `: BasePart` part to whom tweaks are applied.
* `options` - `: table` options for customizing which properties get disabled (optional, options shown in example).
* * `cpp_options` - `: table` `CustomPhysicalProperties` options for custom settings(optional, options shown in example).

### Example
```lua
local options = {
	can_touch = false, --Cannot fire .Touched
	can_query = false, --Cannot be RayCasted
	root_priority = 127 --Part priority as root
}
--Default options in function

local cpp_options = {
	density = math.huge, --density
	friction = math.huge, --friction
	elasticity = 0, --elasticity
	friction_weight = math.huge, --friction weight
	elasticity_weight = 0 --elasticity weight
}
--Default options in function

module.part_tweaks(
	part,
	{
		CanQuery = true
	},{
		elasticity = math.huge
	}
)
```
---
## module.physics_tweaks
```lua
function module.physics_tweaks(hum: Humanoid?)
```
Physics tweaks, which tweak client side physics settings.

### Parameters

* `hum` - `: Humanoid` `hum` is used for one of the physical tweaks(optional).

### Example
```lua
module.physics_tweaks(
	hum
)
--No options provided, because I see no reason why.
```
---
## module.set_hum_state
```lua
function module.set_hum_physics_state(hum: Humanoid, hum_state_type: Enum.HumanoidStateType?)
```
function for changing humanoid state, which disables all other states of humanoid.

### Parameters

* `hum` - `: Humanoid` humanoid whom is used to set `HumanoidStateType`.
* `hum_state_type` - `: Enum.HumanoidStateType` optional setting for setting specific `HumanoidStateType`.

### Example
```lua
module.set_hum_state(
	hum,
	nil
)
--Default HumanoidStateType is Physics
```
---
