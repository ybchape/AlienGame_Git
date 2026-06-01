extends CanvasLayer

var datos_del_evento

func configurar(data):
	# Corrección de la palabra PROCESS y el modo
	process_mode = PROCESS_MODE_ALWAYS
	datos_del_evento = data
	
	$Titulo.text = data.titulo
	$Descripcion.text = data.texto
	$BotonA.text = data.op_a_txt
	$BotonB.text = data.op_b_txt
	
	# Conexión manual ultra segura
	if $BotonA.pressed.is_connected(_on_boton_a_pressed):
		$BotonA.pressed.disconnect(_on_boton_a_pressed)
	if $BotonB.pressed.is_connected(_on_boton_b_pressed):
		$BotonB.pressed.disconnect(_on_boton_b_pressed)
		
	$BotonA.pressed.connect(_on_boton_a_pressed)
	$BotonB.pressed.connect(_on_boton_b_pressed)

func _on_boton_a_pressed() -> void:
	print("-> [INTERFAZ] Se hizo clic real en el Botón A")
	GameManager.procesar_eleccion(datos_del_evento.id, "A")

func _on_boton_b_pressed() -> void:
	print("-> [INTERFAZ] Se hizo clic real en el Botón B")
	GameManager.procesar_eleccion(datos_del_evento.id, "B")
