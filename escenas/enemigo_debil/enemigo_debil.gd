extends CharacterBody2D

var vida_maxima = 40
var reduccion_frenesi = 15

var jugador_objetivo: Node2D = null # Acá guardaremos al jugador cuando lo veamos
var velocidad_persecucion: float = 20.0 # Qué tan rápido corre el enemigo

const ESCENA_COMBATE = preload("uid://df0wos767uxby") #ruta de la escena con los codigos de godot raros

@onready var timer_memoria = $TimerMemoria # Conectamos el reloj al script

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	# Lo metemos en un grupo para que el jugador lo identifique al chocar
	add_to_group("enemigos")
	
	# NUEVO: Si mi nombre ya está en la lista de vencidos, desaparezco del mapa
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
			$AnimatedSprite2D.flip_h = true # Mira a la izquierda
		else:
			$AnimatedSprite2D.flip_h = false # Mira a la derecha (ajustá esto según tus sprites)
			
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

#"Lenamos" de datos el autoload can los datos del enemigo
func _preparar_combate():
	GameManager.enemigo_actual_datos = {
		"nombre_en_escena": name,# GUARDAMOS EL NOMBRE para saber a quién borrar luego
		"tipo_enemigo":"debil",
		"vida": vida_maxima, 
		"frenesi": reduccion_frenesi,
		"Daño_fijo": 14,
		"daño_poder": 20,
		"sprite_frames": $AnimatedSprite2D.sprite_frames,
		"posicion": global_position # guarda la posicion del enemigo	
	}
	#Cambio a la escena de combate
	get_tree().change_scene_to_packed(ESCENA_COMBATE)

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

func _on_timer_memoria_timeout() -> void:
# Pasaron los 2 segundos y no te volvió a ver. Ahora sí se rinde.
	jugador_objetivo = null
	velocity = Vector2.ZERO


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
