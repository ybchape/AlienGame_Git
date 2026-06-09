extends Area2D

var cantidad_curacion:float = 5.0 

func _ready() -> void:
	# conecta la señal de colisión
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# verfica si es el jugador
	if body.is_in_group("player"):
		# accede directamente a la vida del GameManager
		# clamp para no pasarse de la vida maxima (100)
		RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + cantidad_curacion, 0, RunManager.run_data.vida_maxima)
		
		print("Corazón recolectado. Curación recibida: +", cantidad_curacion, " | Vida actual: ", RunManager.run_data.vida_jugador)
		queue_free() # desaparece el corazon
