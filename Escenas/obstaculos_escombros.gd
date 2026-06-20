extends StaticBody2D

@onready var area_deteccion = $CollisionShape2D/Area2D
@onready var texto_interfaz = $Label

func _ready():
	# Escondemos el mensaje de texto al arrancar el mapa
	texto_interfaz.visible = false
	
	# COMPROBACIÓN INSTANTÁNEA:
	# Si en tu GameManager ya marcaste que el camino corto está desbloqueado,
	# el obstáculo se elimina de la partida antes de que el jugador lo vea.
	if GameManager.camino_corto_desbloqueado:
		queue_free()
	else:
		# Conectamos las señales para prender y apagar el texto en pantalla
		area_deteccion.body_entered.connect(_on_body_entered)
		area_deteccion.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Comparamos con "player" o tu grupo para saber si es tu astronauta
	if body.name == "player" or body.is_in_group("player"):
		texto_interfaz.visible = true

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		texto_interfaz.visible = false
