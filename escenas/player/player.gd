extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray = $RayCast2D # Nodo para calcular la distancia de los bloques en base al rayo que tiene (flecha)

var speed = 70.0
var last_direction = "down"
var is_digging = false # variable para cavar

#Chape
func _ready() -> void:
	add_to_group("player")
	# Si venimos de ganar un combate, el GameManager tendrá nuestra última posición
	if GameManager.posicion_jugador_en_mapa != Vector2.ZERO:
		global_position = GameManager.posicion_jugador_en_mapa
#-------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if not is_digging:
		get_input()
		move_and_slide()
		
		# LÓGICA DE LA VISIÓN PROGRESIVA 
		# Se verifica si se está desplazando
		if velocity != Vector2.ZERO:
			if GameManager.radio_vision_actual < GameManager.vision_maxima:
				GameManager.radio_vision_actual += GameManager.velocidad_crecimiento
				# Se actualiza el nodo PointLight2D 
				$PointLight2D.texture_scale = GameManager.radio_vision_actual
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func get_input():
	# Detect movement
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# Detecta direccion de movimiento
	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		if not is_digging: # Si no esta cavando: "idle"
			update_animation("idle")

	else:
		GameManager.actualizar_frenesi(0.02) #Aumenta el frenesi al explorar, se detiene cuando está quieto
	# lógica de direcciones de movimiento
		if abs (input_direction.x) > abs(input_direction.y):
			# Movimiento horizontal
			last_direction = "right" if input_direction.x > 0 else "left"
		else:
			last_direction = "down" if input_direction.y > 0 else "up"

		update_animation("walk")
		# Multiplica la velocidad base por el modificador de velocidad del evento
		var velocidad_final = speed * GameManager.multiplicador_velocidad_laberinto
		velocity = input_direction * velocidad_final

func _unhandled_key_input(event: InputEvent):
	# Tecla "espacio" para romper bloque
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
		# El bloque es parte del TileMapLayer 
		if objeto is TileMapLayer:
			var col_point = ray.get_collision_point()
			var dir = (ray.target_position).normalized()
			# Empujamos el punto de detección dentro del bloque
			var pos_ajustada = col_point + (dir * 4) 
			
			# Convierte la posición global a celda del mapa
			var celda = objeto.local_to_map(objeto.to_local(pos_ajustada))
			#  Obtenemos los datos del tile en esa celda
			var data = objeto.get_cell_tile_data(celda)
			#  Si existe el tile y tiene la propiedad "es_rompible" en true, lo borramos
			if data and data.get_custom_data("es_rompible"):

	# tiempo base en segundos que tarda en romperse un bloque de forma normal
				var tiempo_romper_base = 0.4

				# Lo multiplica por la penalización global (si no hubo evento vale 1.0, si hubo vale 1.2)
				var tiempo_final = tiempo_romper_base * GameManager.penalizacion_tiempo_aspiradora

				# Bloquea el movimiento poniendo is_digging en true y reproducimos animación
				is_digging = true
				update_animation("walk") # Aca tiene que ir la animación de cavar (o no)

				# Crea un timer rápido y espera a que termine
				await get_tree().create_timer(tiempo_final).timeout

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
