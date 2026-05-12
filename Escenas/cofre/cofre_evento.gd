extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Señal que detecta cuando algo toca el cofre
	body_entered.connect(_on_body_entered)
	# play animacion idle
	sprite.play("chest_idle")

func _on_body_entered(body):
	# Verfica que sea el jugadorde grupo "player"
	if body.is_in_group("player"):
		print ("Toque el cofre!")

# Desactiva colisiones para evitar que se ejecute varias veces
		set_deferred("monitoring", false)

		# Cambia a la animación de open
		sprite.play("chest_open")

		# Wait que la animación termine antes de seguir
		# Con AnimatedSprite2D usamos la señal 'animation_finished' del sprite
		await sprite.animation_finished

		# call GameManager ui
		GameManager.abrir_ventana_evento()

		# Delete cofre
		queue_free()
