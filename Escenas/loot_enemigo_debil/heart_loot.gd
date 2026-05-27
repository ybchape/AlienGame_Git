extends Area2D

func _ready() -> void:
	# conecta la señal de colisión
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# verfica si es el jugador
	if body.is_in_group("player"):
		# accede directamente a la vida del GameManager
		# clamp para no pasarse de la vida maxima (100)
		RunManager.vida_jugador = clamp(RunManager.vida_jugador + 5, 0, RunManager.vida_maxima)
		
		print("Corazón recolectado.", RunManager.vida_jugador)
		queue_free() # desaparece el corazon
