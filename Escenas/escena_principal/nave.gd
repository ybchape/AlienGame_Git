extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_portal_salida_body_entered(body: Node2D) -> void:
	# 1. Verificamos si el que tocó la nave es el jugador
	if body.name == "player":
		
		# 2. Verificamos si la llave del Jefe 1 ya fue activada
		if GameManager.jefe_derrotado == true:
			print("¡Despegando! Viajando al Mapa 2...")
			
			# --- LÍNEA NUEVA: Llamamos a la función del profe para curarte y mantener el mazo ---
			RunManager.pasar_al_siguiente_loop()
			
			# Limpiamos el progreso para arrancar frescos en el Mapa 2
			GameManager.enemigos_derrotados.clear()
			GameManager.bloques_destruidos.clear()
			GameManager.eventos_completados.clear()
			GameManager.posicion_jugador_en_mapa = Vector2.ZERO # Reseteamos el spawn para el mapa 2
			GameManager.jefe_derrotado = false # Apagamos el motor para el futuro
			
			# Viaje a la segunda escena
			get_tree().change_scene_to_file("res://Escenas/segunda_escena/segunda_escena.tscn")
			
		else:
			# Si toca la nave pero todavía no mató al jefe
			print("La nave está bloqueada. Debes eliminar al Jefe de la zona primero.")
