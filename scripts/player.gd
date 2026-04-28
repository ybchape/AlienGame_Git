extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed = 70.0
var last_direction = "down"
var is_digging = false # variable para cavar


func _physics_process(_delta: float) -> void:
	if not is_digging:
		get_input()
		move_and_slide()
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
	print("Intentando cavar hacia:", last_direction)
	# llamamos al autoload de chape. No funciona porque no mergeamos a main y aca no sta declarada la func romper_bloque
	#if GameManager:
		#GameManager.romper_bloque(global_position, last_direction)

# update animations. Si state es "idle" y last_direction = "down", se reproduce la anim. "idle_down"
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
