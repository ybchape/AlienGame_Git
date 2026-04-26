extends CharacterBody2D

@export_group("Movimiento")
@export var walk_speed := 260.0

@export_group("Interacción")
@export var break_distance := 50.0 # distancia para romper bloque

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_interaction()
	move_and_slide()

 # it is not currently in use
func handle_movement(_delta: float) -> void: 
	# obtener dirección en x e y
	var _direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

func handle_interaction() -> void:
	if Input.is_action_just_pressed("break_block"): 
		break_block()

func break_block() -> void:
	print("trying to break block") 
