extends CharacterBody2D

var vida_maxima = 55
var reduccion_frenesi = 25

const ESCENA_COMBATE = preload("uid://df0wos767uxby")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemigos")
	
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
