extends CanvasLayer

var datos_del_evento

func configurar(data):
	# le permite a la ventana procesar siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	datos_del_evento = data
	$Titulo.text = data.titulo
	$Descripcion.text = data.texto
	$BotonA.text = data.op_a_txt
	$BotonB.text = data.op_b_txt

	# desconecta las señales por si queda algo colgado
	if $BotonA.pressed.is_connected(_on_boton_a_pressed):
		$BotonA.pressed.disconnect(_on_boton_a_pressed)
	if $BotonB.pressed.is_connected(_on_boton_b_pressed):
		$BotonB.pressed.disconnect(_on_boton_b_pressed)

	# conteca las señales a sus respectivas funciones nativas
	$BotonA.pressed.connect(_on_boton_a_pressed)
	$BotonB.pressed.connect(_on_boton_b_pressed)

func _on_boton_a_pressed() -> void:
	print("[UI] Se hizo clic en el Botón A")
	
	# verifica si el evento actual en pantalla es el del Fósil Antiguo
	if datos_del_evento.id == "fosil_antiguo":
		# devuelve el tiempo al juego para que el jugador se mueva al instante
		get_tree().paused = false
		# dispara la velocidad, el mazo y la carta flotante en el GameManager
		GameManager.activar_powerup_fosil()
		# cierra la ventana para limpiar la pantalla
		queue_free()
	else:
		# si es otro evento (como el oxígeno o necrosis), corre la lógica comun
		GameManager.procesar_eleccion(datos_del_evento.id, "A")

func _on_boton_b_pressed() -> void:
	print("Se hizo click en el Botón B")
	
	# si se ignora el fósil, simplemente despausa y cierra
	if datos_del_evento.id == "fosil_antiguo":
		get_tree().paused = false
		queue_free()
	else:
		GameManager.procesar_eleccion(datos_del_evento.id, "B")
