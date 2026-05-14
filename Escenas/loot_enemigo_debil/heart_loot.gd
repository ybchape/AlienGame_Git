extends Area2D

func _ready() -> void:
	# conecta la señal de colisión
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# verfica si es el jugador
	if body.is_in_group("player"):
		# accede directamente a la vida del GameManager
		# clamp para no pasarse de la vida maxima (100)
		GameManager.vida_jugador = clamp(GameManager.vida_jugador + 5, 0, GameManager.vida_maxima)
		
		print("Corazón recolectado.", GameManager.vida_jugador)
		queue_free() # desaparece el corazon
