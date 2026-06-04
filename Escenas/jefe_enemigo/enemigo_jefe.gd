extends CharacterBody2D
var vida_maxima: int = 100

var reduccion_frenesi: int = 25 # El jefe baja mucho más frenesí

const ESCENA_COMBATE =preload("uid://df0wos767uxby")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemigos")
	if name in GameManager.enemigos_derrotados:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player": 
		GameManager.posicion_jugador_en_mapa = body.global_position
		call_deferred("_preparar_combate")

func _preparar_combate():
	GameManager.enemigo_actual_datos = {
		"nombre_en_escena": name,
		"tipo_enemigo": "jefe",
		"vida": vida_maxima, 
		"reduccion_frenesi": reduccion_frenesi,
		"Daño_fijo": 24,          # El golpe básico del jefe
		"daño_especial": 25,      # El golpe devastador del jefe
		"textura": preload("res://Assets/icon.svg"), 
		"posicion": global_position 
	}
	get_tree().change_scene_to_packed(ESCENA_COMBATE)
	
