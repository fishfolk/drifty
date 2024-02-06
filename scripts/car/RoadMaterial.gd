class_name RoadMaterial
extends Resource


## Objects included in a group with this name
## will be considered as having this material.
## Lower-case only.
@export var group_name : String 


## Is this material affected by the "off-road" stat?
##
## [br]The off-road stat diminishes drag from all such terrains,
## like dirt, grass, sand, rocks. Ice is not off-road.
##
@export var is_offroad : bool = false




## How much speed is lost by free-rolling.
## 
## [br]Higher drag may also make perceived car power
## seem lower than usual, decreasing top speed.
##
## [br][br]Use 0.05 for tarmac, 0.5 for grass or dirt, 0.05 for ice.
@export var drag : float = 0.05




## How hard it is to slide over this material.
## 
## [br]In addition to drag, slide drag will prevent the car
## from going sideways. This number is further modified by the
## "traction" stat cars may have.
##
## [br][br]Use 10 to 8 for tarmac, 3 for grass or dirt, 0.05 for ice.
@export var slide_drag : float = 8




## How bumpy or rough the terrain is.
## 
## [br]Bumpiness will lift up the wheels to simulate
## driving over rough terrain like sand, dirt or rocks.
##
## [br][br]Use 0 for tarmac, 0.1 for bricks, 0.6 for grass, 2 for rocks.
@export var bumpiness : float = 0
