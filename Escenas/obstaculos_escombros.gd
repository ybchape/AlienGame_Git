extends StaticBody2D

@export var mostrar_texto: bool = true
@export var texto_personalizado: String = "Camino bloqueado.\n Derrota al boss"
# Esta variable va a buscar el Label único que está en la escena principal
# Usamos absolute path o % si es un nodo único, pero la forma más segura en Godot 4 es buscarlo en el padre:
@onready var label_principal = get_node_or_null("/root/Escena Principal/TextoInterfazPrincipal")
@onready var area_deteccion = $CollisionShape2D/Area2D
#@onready var texto_interfaz = $Label

func _ready():
	
	
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
	#if body.name == "player" or body.is_in_group("player"):
		#texto_interfaz.visible = true
	if body.name == "player" or body.is_in_group("player"):
		if label_principal != null:
			label_principal.text = texto_personalizado
			label_principal.visible = true

func _on_body_exited(body):
	#if body.name == "player" or body.is_in_group("player"):
		#texto_interfaz.visible = false
	if body.name == "player" or body.is_in_group("player"):
		if label_principal != null:
			label_principal.visible = false
