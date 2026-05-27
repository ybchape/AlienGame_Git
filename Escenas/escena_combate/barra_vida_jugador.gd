extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Al arrancar el mapa, toma los valores actuales
	max_value = RunManager.vida_maxima
	value = RunManager.vida_jugador


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Se mantiene actualizada si un evento te cura o el veneno te quita vida
	value = RunManager.vida_jugador
