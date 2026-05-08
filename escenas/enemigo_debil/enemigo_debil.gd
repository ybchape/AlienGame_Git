extends CharacterBody2D

var vida_maxima = 50
var reduccion_frenesi = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Lo metemos en un grupo para que el jugador lo identifique al chocar
	add_to_group("enemigos")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ALERTA: Algo tocó el Area2D. Nombre del objeto: ", body.name)
	if body.name == "player": 
		print("¡ÉXITO! Reconoció al jugador. Pasando a escena de combate...")
		call_deferred("_preparar_combate")
	else:
		print("FALLO: Tocó algo, pero su nombre no es 'player'. Es: ", body.name)

#"Lenamos" de datos el autoload can los datos del enemigo
func _preparar_combate():
	GameManager.enemigo_actual_datos = {
		"tipo_enemigo":"debil",
		"vida": vida_maxima, 
		"frenesi": reduccion_frenesi,
		"Daño_fijo": 10,
		"daño_poder": 25,
		"textura": preload("res://Assets/icon.svg")
	}
	#Cambio a la escena de combate
	get_tree().change_scene_to_file("res://Escenas/escena_combate/escena_combate.tscn")

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
