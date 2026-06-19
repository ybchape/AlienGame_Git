extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var vida_maxima: int = 75
var reduccion_frenesi: int = 20

var jugador_objetivo: Node2D = null # Acá guardaremos al jugador cuando lo veamos
var velocidad_persecucion: float = 20.0 # Qué tan rápido corre el enemigo

@onready var timer_memoria = $TimerMemoria # Conectamos el reloj al script

const ESCENA_COMBATE = preload("uid://df0wos767uxby")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle")
	add_to_group("enemigos")
	# Persistencia: Si ya lo mataste, no vuelve a aparecer
	if name in GameManager.enemigos_derrotados:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Si tenemos un objetivo al cual perseguir...
	if jugador_objetivo != null:
		# Calculamos la dirección exacta en 360 grados hacia el jugador
		var direccion = global_position.direction_to(jugador_objetivo.global_position)
		
		# Movemos al enemigo en esa dirección
		velocity = direccion * velocidad_persecucion
		
		# Opcional: Para que la animación mire hacia donde camina
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = false # Mira a la izquierda
		else:
			$AnimatedSprite2D.flip_h = true # Mira a la derecha (ajustá esto según tus sprites)
			
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ALERTA: Algo tocó el Area2D. Nombre del objeto: ", body.name)
	if body.name == "player": 
		# GUARDAMOS LA POSICIÓN: memoriza dónde está el jugador ahora mismo
		GameManager.posicion_jugador_en_mapa = body.global_position
		
		print("¡ÉXITO! Reconoció al jugador. Pasando a escena de combate...")
		call_deferred("_preparar_combate")
	else:
		print("FALLO: Tocó algo, pero su nombre no es 'player'. Es: ", body.name)

func _preparar_combate():
	GameManager.enemigo_actual_datos = {
		"nombre_en_escena": name,
		"tipo_enemigo": "medio", # Clave para que la escena de combate sepa cómo actúa
		"vida": vida_maxima, 
		"reduccion_frenesi": reduccion_frenesi,
		"Daño_fijo": 18,          
		"daño_poder": 14,         
		"sprite_frames": $AnimatedSprite2D.sprite_frames, # Cambiar por el arte de Lucía
		"posicion": global_position 
	}
	get_tree().change_scene_to_packed(ESCENA_COMBATE)
	


func _on_zona_deteccion_body_entered(body: Node2D) -> void:
		# Si te ve, te fija como objetivo
	if body.name == "player" or body.is_in_group("player"):
		jugador_objetivo = body
		# Si volvió a entrar a tu zona, cancelamos el reloj de rendirse
		timer_memoria.stop()



func _on_zona_deteccion_body_exited(body: Node2D) -> void:
		# Si el jugador se sale de la zona, NO lo borramos todavía. ¡Arrancamos el reloj!
	if body == jugador_objetivo:
		timer_memoria.start()


func _on_timer_memoria_timeout() -> void:
	# Pasaron los 2 segundos y no te volvió a ver. Ahora sí se rinde.
	jugador_objetivo = null
	velocity = Vector2.ZERO
