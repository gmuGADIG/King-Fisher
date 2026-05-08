extends Node
class_name PlayerTextureManager


@export var target_mesh: MeshInstance3D
@onready var mat := target_mesh.material_override as StandardMaterial3D
