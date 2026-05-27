extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = RunManager.frenesi_actual
	max_value = RunManager.frenesi_maximo #Cambiamos el valor de la barra de frenesi
	pass
