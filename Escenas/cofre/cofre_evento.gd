extends Area2D

func _ready():
	# Señal que detecta cuando algo toca el cofre
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verfica que sea el jugadorde grupo "player"
	if body.is_in_gropu("player"):
		print ("Toque el cofre!")
		# call GameManager 
		GameManager.abrir_ventana_evento()
		# delete chest del mapa para que no se vuelva a usar
		queue_free()
