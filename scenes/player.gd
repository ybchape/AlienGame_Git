extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100.0
var last_direction = "down"


func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	print (input_direction)
	velocity = input_direction * speed
	move_and_slide()
	
func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)
