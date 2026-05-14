extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Recorremos la lista de bloques que el jugador ya rompió
	for celda in GameManager.bloques_destruidos:
		# Los volvemos a borrar
		set_cell(celda, -1)
	print("Mapa restaurado: bloques eliminados.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
