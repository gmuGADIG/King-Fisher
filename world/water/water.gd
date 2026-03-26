extends Node3D
var shadows: Array[Node3D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_fish()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for shadow in shadows:
		shadow.rotation += Vector3.UP * delta * 10  # replace with shadow handling or smt idk


func _on_child_entered_tree(node: Node) -> void:
	if node is FishShadow:
		shadows.append(node)


# Basic implementation, update this with fish spawning logic
func _spawn_fish():
	var first_fish = load("res://world/water/fish_shadow.tscn").instantiate()
	add_child(first_fish)
