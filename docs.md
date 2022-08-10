# Documentation
---
Note:
When there is **?** mext to for example: table?
That means it is optional and it doesn't need to be passed.

if there is : Runservice after finishing function, that means that is the type
that will be returned.

---
## module.sim_rad
```lua
function module.sim_rad(player: Player): Runservice
```
Connects Heartbeat loop which sets SimulationRadius and MaximumSimulationRadius to 1e+10

### Parameters

*`player` - `: Player` on whom connection is used.

### Example
```lua
local sim_rad_connection = module.sim_rad(plr)
```
---
## module.movedir_calc
```lua
function module.movedir_calc(move_dir: Vector3, amplifier: number): Vector3
```
used to amplify `MoveDirection` Of humanoid.

### Parameters

*`move_dir` - `: Vector3` MoveDirection from `Humanoid`
*`amplifier` - `: number` by whom `move_dir` is amplified(configurable, will be seen further down)

### Example
```lua
local calculated_velocity = module.movedir_calc(move_dir, 50)
```
---
