extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray = $RayCast2D # Nodo para calcular la distancia de los bloques en base al rayo que tiene (flecha)

var speed = 70.0
var last_direction = "down"
var is_digging = false # variable para cavar

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
		velocity = input_direction * speed

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
		if objeto.is_in_group("bloques"):
			objeto.queue_free()
			print("Bloque roto con nodo raycast")

# update animations. Si state es "idle" y last_direction = "down", se reproduce la anim. "idle_down"
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
	#basta, estoy cansada! y triste :c
