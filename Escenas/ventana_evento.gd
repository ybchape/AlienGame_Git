extends CanvasLayer

var datos_del_evento

func configurar(data):
	# le permite a la ventana procesar siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	datos_del_evento = data
	$Titulo.text = data.titulo
	$Descripcion.text = data.descripcion
	$VBoxContainer/BotonA.text = data.opcion_a
	$VBoxContainer/BotonB.text = data.opcion_b

	# desconecta las señales por si queda algo colgado
	if $VBoxContainer/BotonA.pressed.is_connected(_on_boton_a_pressed):
		$VBoxContainer/BotonA.pressed.disconnect(_on_boton_a_pressed)
	if $VBoxContainer/BotonB.pressed.is_connected(_on_boton_b_pressed):
		$VBoxContainer/BotonB.pressed.disconnect(_on_boton_b_pressed)

	# conecta las señales a sus respectivas funciones nativas
	$VBoxContainer/BotonA.pressed.connect(_on_boton_a_pressed)
	$VBoxContainer/BotonB.pressed.connect(_on_boton_b_pressed)

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

# fun para el dialogo del evento cofre trampa
func mostrar_texto_intermedio(nuevo_texto: String, texto_boton: String, nueva_opcion_id: String):
	# cambia el texto principal de la descripción por la del cofre trampa
	$Descripcion.text = nuevo_texto 

	# configura el Botón A para que sea el de avanzar al combate
	$VBoxContainer/BotonA.text = texto_boton
	
	# Desconectamos la función nativa original antes de enlazar al GameManager
	if $VBoxContainer/BotonA.pressed.is_connected(_on_boton_a_pressed):
		$VBoxContainer/BotonA.pressed.disconnect(_on_boton_a_pressed)
	
	if $VBoxContainer/BotonA.pressed.is_connected(GameManager.procesar_eleccion):
		$VBoxContainer/BotonA.pressed.disconnect(GameManager.procesar_eleccion)

	# Este clic va a llamar a procesar_eleccion("cofre_trampa", "combate_mimic")
	$VBoxContainer/BotonA.pressed.connect(GameManager.procesar_eleccion.bind("cofre_trampa", nueva_opcion_id))

# oculta el boton de la opcion b porque hay una sola opcion.
	if has_node("BotonB"):
		$VBoxContainer/BotonB.hide()
