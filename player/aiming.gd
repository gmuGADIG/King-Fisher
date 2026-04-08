extends Node3D

var player: Player

## How far away from the player the player can aim.
@export var max_aim_distance := 5.
@export var max_throw_distance := 10
#var is_throwing : bool

var _aim_pos := Vector2.ZERO

func _ready() -> void:
	assert(get_parent() is Player)
	player = get_parent()
	%AimIndicator.hide()

func _process(_delta: float) -> void:
	%AimRayCast.position.x = _aim_pos.x
	%AimRayCast.position.z = _aim_pos.y

	%AimRayCast.force_raycast_update()
	if %AimRayCast.is_colliding():
		%AimIndicator.position = to_local(%AimRayCast.get_collision_point())

func _input(event: InputEvent) -> void:
	if player.aim_mode == Player.AimMode.NONE: return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var dv: Vector2 = event.relative
		dv *= 0.075
		dv *= Options.mouse_sensitivity
		dv = dv.rotated(deg_to_rad(-player.camera_yaw))

		_aim_pos.x += dv.x
		_aim_pos.y += dv.y
		match player.aim_mode:
			Player.AimMode.FISHING_ROD:
				_aim_pos = _aim_pos.limit_length(max_aim_distance)
			Player.AimMode.ITEM:
				_aim_pos = _aim_pos.limit_length(max_throw_distance)

func start_aiming(mode : Player.AimMode = Player.AimMode.FISHING_ROD) -> void:
	player.aim_mode = mode
	%AimIndicator.show()
	_aim_pos = Vector2.ZERO

func stop_aiming() -> void:
	player.aim_mode = Player.AimMode.NONE
	%AimIndicator.hide()

## Get where the player is aiming at in global coordinates
func get_aim_pos() -> Vector3:
	return %AimIndicator.global_position
