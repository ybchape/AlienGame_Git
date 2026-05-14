extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_button_pressed() -> void:
	# Recargamos la escena principal (El GameManager ya habrá limpiado los datos)
	get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
