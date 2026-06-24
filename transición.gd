extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texto_carga: Label = $TextoCarga # <-- Vinculamos el texto nuevo

func _ready() -> void:
	$MusicaTransicion.volume_linear = 0.3

func viajar_a_siguiente_mapa(ruta_siguiente_mapa: String) -> void:
	#Hacemos visible la capa y nos aseguramos de que el texto empiece oculto
	show()
	texto_carga.hide()
	
	#Arranca la animación de la nave
	animation_player.play("transicion_nave")
	
	#Esperamos exactamente 1 segundo (cuando el ColorRect negro ya tapó todo)
	await get_tree().create_timer(1.0).timeout
	
	#Mostramos el cartel justo cuando la pantalla está negra
	texto_carga.show()
	
	#Cambiamos el mapa de fondo en secreto
	get_tree().change_scene_to_file(ruta_siguiente_mapa)
	
	#Esperamos a que la nave termine todo su recorrido de 3 segundos
	await animation_player.animation_finished
	
	#Ocultamos el texto y toda la transición para poder jugar el Mapa 2
	texto_carga.hide()
	hide()
