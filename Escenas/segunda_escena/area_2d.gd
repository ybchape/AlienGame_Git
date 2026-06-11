extends Area2D

@onready var cartel = $Panel # Asegurate de que este nombre sea igual a tu nodo de texto

func _ready() -> void:
	# 1. Al iniciar el mapa, el cartel se vuelve invisible
	cartel.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		# ¡LA MAGIA ACÁ! Solo lo mostramos si viene caminando hacia la DERECHA
		if body.last_direction == "right":
			cartel.show()

func _on_body_exited(body: Node2D) -> void:
	# 3. Cuando el jugador se aleja de la pared, el cartel desaparece
	if body.name == "player" or body.is_in_group("player"):
		cartel.hide()
