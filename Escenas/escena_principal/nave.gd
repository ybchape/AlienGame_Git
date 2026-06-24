extends Sprite2D

var deteccion_activa: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Esperamos medio segundo antes de activar los motores de detección
	await get_tree().create_timer(0.5).timeout
	deteccion_activa = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_portal_salida_body_entered(body: Node2D) -> void:
	# Si la escena se está cargando y todavía no pasó el medio segundo, ignoramos el toque
	if not deteccion_activa:
		return
	# 1. Verificamos si el que tocó la nave es el jugador
	if body.name == "player" or body.is_in_group("player"):
		
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
			
			Transicion.viajar_a_siguiente_mapa("res://Escenas/segunda_escena/segunda_escena.tscn")
			
			
		else:
			# Si toca la nave pero todavía no mató al jefe
			print("La nave está bloqueada. Debes eliminar al Jefe de la zona primero.")
