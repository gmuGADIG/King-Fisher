extends Label

func _ready() -> void:
	_process(0.)

func _process(_delta: float) -> void:
	if DonorDrive.active:
		queue_free()
