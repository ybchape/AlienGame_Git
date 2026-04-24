extends CharacterBody2D
@export var velocidad := 220.0
@export var fuerza_salto := -450.0

var gravedad = 100



func _physics_process(delta):

	# Movimiento horizontal
	var x = Input.get_axis("movimiento_izquierda", "movimiento_derecha")
	velocity.x = x * velocidad

	# Movimiento vertical arriba / abajo
	var y = Input.get_axis("movimiento_arriba", "movimiento_abajo")
	velocity.y = y * velocidad

	# Gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Salto
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = fuerza_salto

	move_and_slide()
	
