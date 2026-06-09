extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
# 1. IMPORTANTÍSIMO: Usamos la función de tu profe para empezar de cero
	RunManager.inicializar_run()
	
	# 2. Limpiamos cualquier rastro de partidas anteriores en el GameManager
	GameManager.enemigos_derrotados.clear()
	GameManager.jefe_derrotado = false
	GameManager.posicion_jugador_en_mapa = Vector2.ZERO
	
	# 3. Vamos al Mapa 1
	get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")

func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/escena_controles/escena_controles.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit() # Cierra el juego
