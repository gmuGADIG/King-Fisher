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
	if(abs(targetPosition - global_position) < Vector3(0.1,0.1,0.1)):
		reparent(get_tree().current_scene,true)
		if(throwType == type.IMPACT):
			end_throwable()
		if(throwType == type.LINGER):
			pass
				

func use_throwable(targetPos) -> void:
	targetPosition = targetPos
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", targetPos, 1.0)
	
	
	
func end_throwable() -> void:
	## do impact code
	queue_free()
