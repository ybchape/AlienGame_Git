extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed = 70.0
var last_direction = "down"


func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()


func get_input():
	# Detect movement
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# Detecta direccion de movimiento
	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return

	if abs (input_direction.x) > abs(input_direction.y):
		# Movimiento horizontal
		if input_direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if input_direction.y > 0:
			last_direction = "down"
		else: 
			last_direction = "up"

	update_animation("walk")
	velocity = input_direction * speed

# update animations. Si state es "idle" y last_direction = "down", se reproduce la anim. "idle_down"
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
