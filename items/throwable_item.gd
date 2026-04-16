class_name ThrowableItem extends Item

const TWEEN_TIME_MULTIPLIER : float = 0.1
const Y_EXTRA_HEIGHT : float = 2.0
var thrown := false;
var targetPosition = Vector3(0,0,0)
var targetDirection = Vector3(0,0,0)
enum type{
	IMPACT,
	LINGER
}

#func _process(delta: float) -> void:
	#if(abs(targetPosition - global_position) < Vector3(0.1,0.1,0.1)):
		#reparent(get_tree().current_scene,true)
		#if(throwType == type.IMPACT):
			#end_throwable()
		#if(throwType == type.LINGER):
			#pass
				


func use_throwable(targetPos) -> void:
	reparent(get_tree().current_scene,true)
	show()
	targetPosition = targetPos
	
	var dist : float = global_position.distance_to(targetPosition)
	var throw_time : float = TWEEN_TIME_MULTIPLIER * dist
	var midpoint : Vector3 = global_position + 0.5*(targetPosition-global_position)
	midpoint.y += Y_EXTRA_HEIGHT
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position:x", midpoint.x, 0.5*throw_time)
	tween.tween_property(self, "global_position:z", midpoint.z, 0.5*throw_time)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", midpoint.y, 0.5*throw_time)
	await tween.finished
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position:x", targetPos.x, 0.5*throw_time)
	tween.tween_property(self, "global_position:z", targetPos.z, 0.5*throw_time)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", targetPos.y, 0.5*throw_time)
	await tween.finished
	
	_on_land()
	
	
func _on_land() -> void:
	## do impact code
	print("Death")
	queue_free()
