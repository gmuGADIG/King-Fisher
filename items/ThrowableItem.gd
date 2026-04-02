class_name ThrowableItem extends Item

var thrown := false;
var targetPosition = Vector3(0,0,0)
var targetDirection = Vector3(0,0,0)
enum type{
	IMPACT,
	LINGER
}
@export var throwType := type.IMPACT

@export var speed : float = 2.0

func _process(delta: float) -> void:
	if(thrown):
		global_position += targetDirection * speed * delta
		if(abs(targetPosition - global_position) < Vector3(0.1,0.1,0.1)):
			thrown = false
			reparent(get_tree().current_scene,true)
	else:
		if(throwType == type.IMPACT):
			end_throwable()
		if(throwType == type.LINGER):
			pass
				

func use_throwable(targetPos) -> void:
	thrown = true
	targetPosition = targetPos
	targetDirection = targetPosition - global_position
	
	
func end_throwable() -> void:
	## do impact code
	queue_free()
