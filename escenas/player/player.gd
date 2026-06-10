extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray = $RayCast2D # Nodo para calcular la distancia de los bloques en base al rayo que tiene (flecha)
@onready var filtro_rojo: ColorRect = $CanvasLayer/FiltroRojo 

var tiempo_titileo = 0.0
var speed_normal = 70.0
var speed_lento = 30.0
var speed = speed_normal
var last_direction = "down"
var is_digging = false # variable para cavar

@onready var tilemap_suelo: TileMapLayer = get_parent().get_node("Mapa")



#Chape
func _ready() -> void:
	add_to_group("player")
	# Si venimos de ganar un combate, el GameManager tendrá nuestra última posición
	if GameManager.posicion_jugador_en_mapa != Vector2.ZERO:
		global_position = GameManager.posicion_jugador_en_mapa
#-------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not is_digging:
		verificar_suelo()
		get_input()
		move_and_slide()
		
		manejar_titileo_frenesi(delta)
		# LÓGICA DE LA VISIÓN PROGRESIVA 
		# Se verifica si se está desplazando
		#if velocity != Vector2.ZERO:
			#if GameManager.radio_vision_actual < GameManager.vision_maxima:
				#GameManager.radio_vision_actual += GameManager.velocidad_crecimiento
				# Se actualiza el nodo PointLight2D 
				#$PointLight2D.texture_scale = GameManager.radio_vision_actual
	#else:
		#velocity = Vector2.ZERO
		#move_and_slide()

func verificar_suelo():
	if tilemap_suelo:
		# Convierte la posición global de los pies del jugador a coordenadas de celda
		var celda = tilemap_suelo.local_to_map(tilemap_suelo.to_local(global_position))
		var data = tilemap_suelo.get_cell_tile_data(celda)
		
		# Si esta pisando un tile válido y tiene la propiedad "es_virus"
		if data and data.get_custom_data("es_virus"):
			speed = speed_lento
		else:
			speed = speed_normal
	else:
		speed = speed_normal


func get_input():
	# Detect movement
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# Detecta direccion de movimiento
	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		if not is_digging: # Si no esta cavando: "idle"
			update_animation("idle")

	else:
		GameManager.actualizar_frenesi(0.05) #Aumenta el frenesi al explorar, se detiene cuando está quieto
	# lógica de direcciones de movimiento
		if abs (input_direction.x) > abs(input_direction.y):
			# Movimiento horizontal
			last_direction = "right" if input_direction.x > 0 else "left"
		else:
			last_direction = "down" if input_direction.y > 0 else "up"

		update_animation("walk")
		# ultiplica la velocidad base por el modificador de velocidad del GameManager
		velocity = input_direction * (speed * GameManager.modificador_velocidad)

func _unhandled_key_input(event: InputEvent):
	# Tecla "E" para romper bloque
	if event.is_action_pressed("break_block"):
		is_digging = true
		ejecutar_cavar()

	if event.is_action_released("break_block"):
		is_digging = false

# Conectar esta función con el autoload del mapa
func ejecutar_cavar():

	match last_direction:
		#update de hacia donde apunta el rayo antes de romper el bloque segun hacia donde mire el pj
		"up": ray.target_position = Vector2(0, -10)
		"down": ray.target_position = Vector2(0, 10)
		"left": ray.target_position = Vector2(-10, 0)
		"right": ray.target_position = Vector2(10, 0)

	ray.force_raycast_update() 

	if ray.is_colliding():
		var objeto = ray.get_collider()
		#El bloque es parte del TileMapLayer 
		if objeto is TileMapLayer:
			var col_point = ray.get_collision_point()
			var dir = (ray.target_position).normalized()
			# Empujamos el punto de detección dentro del bloque
			var pos_ajustada = col_point + (dir * 4) 
			
			# Convertimos posición global a celda del mapa
			var celda = objeto.local_to_map(objeto.to_local(pos_ajustada))
			#  Obtenemos los datos del tile en esa celda
			var data = objeto.get_cell_tile_data(celda)
			#  Si existe el tile y tiene la propiedad "es_rompible" en true, lo borramos
			if data and data.get_custom_data("es_rompible"):
				# ANOTAMOS LA CELDA EN EL CEREBRO GLOBAL
				if not celda in GameManager.bloques_destruidos:
					GameManager.bloques_destruidos.append(celda)
			# Borramos la celda (-1 elimina el tile)
				objeto.set_cell(celda, -1)
				print("Celda eliminada en: ", celda)

# update animations. Si state es "idle" y last_direction = "down", se reproduce la anim. "idle_down"
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
	#basta, estoy cansada! y triste :c
	
func manejar_titileo_frenesi(delta: float):
	# Usamos tu variable global del GameManager que detecta el descontrol total
	if GameManager.esta_en_descontrol: 
		tiempo_titileo += delta * 12.0 # Velocidad del parpadeo (un toque más lento para que no moleste tanto a los ojos)
		
		# La onda matemática 'sin' genera valores entre -1 y 1. 
		# Con esto la transformamos para que oscile suavemente entre 0.0 (transparente) y 0.35 (rojo suave)
		var opacidad = (sin(tiempo_titileo) + 1.0) / 2.0 * 0.35 
		
		# Aplicamos el cambio al filtro
		filtro_rojo.color.a = opacidad
	else:
		# Si ya no está en descontrol, la opacidad vuelve a 0 de forma limpia y progresiva
		filtro_rojo.color.a = move_toward(filtro_rojo.color.a, 0.0, delta * 2.0)
		tiempo_titileo = 0.0
