extends CharacterBody2D

var vida_maxima = 50
var reduccion_frenesi = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Lo metemos en un grupo para que el jugador lo identifique al chocar
	add_to_group("enemigos")
	
	# NUEVO: Si mi nombre ya está en la lista de vencidos, desaparezco del mapa
	if name in GameManager.enemigos_derrotados:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ALERTA: Algo tocó el Area2D. Nombre del objeto: ", body.name)
	if body.name == "player": 
		# GUARDAMOS LA POSICIÓN: memoriza dónde está el jugador ahora mismo
		GameManager.posicion_jugador_en_mapa = body.global_position
		
		print("¡ÉXITO! Reconoció al jugador. Pasando a escena de combate...")
		call_deferred("_preparar_combate")
	else:
		print("FALLO: Tocó algo, pero su nombre no es 'player'. Es: ", body.name)

#"Lenamos" de datos el autoload can los datos del enemigo
func _preparar_combate():
	GameManager.enemigo_actual_datos = {
		"nombre_en_escena": name,# GUARDAMOS EL NOMBRE para saber a quién borrar luego
		"tipo_enemigo":"debil",
		"vida": vida_maxima, 
		"frenesi": reduccion_frenesi,
		"Daño_fijo": 10,
		"daño_poder": 25,
		"textura": preload("res://assets/icon.svg")
	}
	#Cambio a la escena de combate
	get_tree().change_scene_to_file("res://escenas/escena_combate/escena_combate.tscn")

func _otorgar_recompensa():
# Reducimos el frenesí biológico obligatoriamente al ganar
	GameManager.actualizar_frenesi(-reduccion_frenesi)
	var suerte = randf()
	if suerte < 0.5:
#llamar a la funcion global del jugador
		print("aumento de vida")
	else:
		#llamar a la funcion global de la mejora de pala
		print("mejor pala")
