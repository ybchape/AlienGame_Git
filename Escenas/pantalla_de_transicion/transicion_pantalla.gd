extends CanvasLayer

@onready var fondo_negro = $ColorRect



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Nos aseguramos de que el telón esté invisible al arrancar el juego
	fondo_negro.color.a = 0.0

func cambiar_escena(ruta_nueva_escena: String) -> void:
	# 1. Pausamos todo para que los enemigos no te maten mientras se oscurece
	get_tree().paused = true
	
	# Buscamos la cámara actual del jugador automáticamente
	var camara = get_viewport().get_camera_2d()
	
	# Creamos el animador por código (Tween)
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Para que funcione aunque el juego esté pausado
	tween.set_parallel(true) # Para que el zoom y el fundido pasen AL MISMO TIEMPO
	
	# 2. Animamos el fondo hacia negro puro (alpha 1.0) durante 1.5 segundos
	tween.tween_property(fondo_negro, "color:a", 1.0, 1.5)
	
	# 3. Animamos la cámara para hacer el Zoom In (si es que hay una cámara)
	if camara:
		# Multiplicamos el zoom por 2.5 (se acerca bastante)
		tween.tween_property(camara, "zoom", camara.zoom * 2.5, 1.5)
	
	# Esperamos a que termine el efecto
	await tween.finished
	
	# 4. Cambiamos de mapa
	get_tree().change_scene_to_file(ruta_nueva_escena)
	
	# Le damos una milésima de segundo a Godot para que cargue el mapa nuevo
	await get_tree().create_timer(0.1).timeout
	
	# 5. FUNDIDO DE VUELTA A LA NORMALIDAD EN EL MAPA NUEVO
	var camara_nueva = get_viewport().get_camera_2d()
	var tween_vuelta = get_tree().create_tween()
	tween_vuelta.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_vuelta.set_parallel(true)
	
	# Aclaramos la pantalla de nuevo a transparente (alpha 0.0)
	tween_vuelta.tween_property(fondo_negro, "color:a", 0.0, 1.5)
	
	# Hacemos el Zoom Out en el nuevo mapa
	if camara_nueva:
		var zoom_normal = camara_nueva.zoom # Guardamos el zoom ideal del mapa
		camara_nueva.zoom = zoom_normal * 2.5 # Arrancamos re cerca...
		tween_vuelta.tween_property(camara_nueva, "zoom", zoom_normal, 1.5) # ...y nos alejamos a la normalidad
		
	await tween_vuelta.finished
	
	# 6. Despausamos y a jugar
	get_tree().paused = false
