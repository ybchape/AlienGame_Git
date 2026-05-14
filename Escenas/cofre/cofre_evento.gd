extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	# sistema para controlar los eventos
	#Si el nombre ya se agrego a la lista lo borramos
	if name in GameManager.eventos_completados:
		queue_free()
		return
	
	# Señal que detecta cuando algo toca el cofre
	body_entered.connect(_on_body_entered)
	# play animacion idle
	sprite.play("chest_idle")

func _on_body_entered(body):
	# Verfica que sea el jugadorde grupo "player"
	if body.is_in_group("player"):
		print ("Toque el cofre!")
		
		#Anotamos el nombre del evento en la lista global
		if not name in GameManager.eventos_completados:
			GameManager.eventos_completados.append(name)
	
		#Guarmados la posicion del jugador para que no spawnee en el inicio
		GameManager.posicion_jugador_en_mapa = body.global_position

		
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
