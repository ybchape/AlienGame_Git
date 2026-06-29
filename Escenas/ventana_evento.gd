extends CanvasLayer

var datos_del_evento
var tamano_maximo_panel: Vector2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$MusicaEvento.volume_linear = 0.3
	
	# Guarda cuánto mide el panel configurado en el editor antes de achicarlo
	tamano_maximo_panel = $Panel.size
	_preparar_fade_in()
	
func _preparar_fade_in() -> void:
# Usa 0.01 en vez de 0.0 para que Godot no destruya el layout de los botones
	$Panel.scale = Vector2(0.01, 0.01)
	
	if has_node("FondoNegroTutorial"):
		$FondoNegroTutorial.modulate.a = 0.0
		
func animar_apertura():
	var tween = create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	var tiempo_apertura = 0.4
	
	# Fuerza que empiece en el tamaño microscópico antes de agrandarse
	$Panel.scale = Vector2(0.01, 0.01)
	
	# Anima de vuelta a la escala original (1.0) con el rebote elástico
	tween.tween_property($Panel, "scale", Vector2.ONE, tiempo_apertura).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# El fondo negro hace su Fade In suave normalmente
	if has_node("FondoNegroTutorial") and $FondoNegroTutorial.visible:
		tween.tween_property($FondoNegroTutorial, "modulate:a", 1.0, tiempo_apertura)
	
func configurar(data):
	# Le permite a la ventana procesar siempre aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	datos_del_evento = data
	
	
	$Panel/Titulo.text = data.titulo
	$Panel/Descripcion.text = data.descripcion
	$Panel/VBoxContainer/BotonA.text = data.opcion_a
	$Panel/VBoxContainer/BotonB.text = data.opcion_b

	# Desconecta las señales previas por seguridad usando las nuevas rutas
	if $Panel/VBoxContainer/BotonA.pressed.is_connected(_on_boton_a_pressed):
		$Panel/VBoxContainer/BotonA.pressed.disconnect(_on_boton_a_pressed)
	if $Panel/VBoxContainer/BotonB.pressed.is_connected(_on_boton_b_pressed):
		$Panel/VBoxContainer/BotonB.pressed.disconnect(_on_boton_b_pressed)

	# Conecta las señales a sus respectivas funciones nativas
	$Panel/VBoxContainer/BotonA.pressed.connect(_on_boton_a_pressed)
	$Panel/VBoxContainer/BotonB.pressed.connect(_on_boton_b_pressed)

	# VALIDACIÓN EXCLUSIVA PARA EL TUTORIAL:
	# Oculta el BotonB únicamente si el título coincide con el del tutorial
	if data.titulo == "¡ALERTA DE BIOCONTAMINACIÓN!":
		$Panel/VBoxContainer/BotonB.hide()
	else:
		# En cualquier otro evento, nos aseguramos de que vuelva a estar visible
		$Panel/VBoxContainer/BotonB.show()

	# Lanzamos la animación elástica desde el centro con la interfaz ya acomodada
	animar_apertura()
	
func _on_boton_a_pressed() -> void:
	print("[UI] Se hizo clic en el Botón A")
	# Le mandamos TODA la responsabilidad al GameManager
	GameManager.procesar_eleccion(datos_del_evento.id, "A")
	

func _on_boton_b_pressed() -> void:
	print("Se hizo click en el Botón B")
# Le mandamos TODA la responsabilidad al GameManager
	GameManager.procesar_eleccion(datos_del_evento.id, "B")

# fun para el dialogo del evento cofre trampa
func mostrar_texto_intermedio(nuevo_texto: String, texto_boton: String, nueva_opcion_id: String):
	$Panel/Descripcion.text = nuevo_texto 
	$Panel/VBoxContainer/BotonA.text = texto_boton
	
	if $Panel/VBoxContainer/BotonA.pressed.is_connected(_on_boton_a_pressed):
		$Panel/VBoxContainer/BotonA.pressed.disconnect(_on_boton_a_pressed)
	
	if $Panel/VBoxContainer/BotonA.pressed.is_connected(GameManager.procesar_eleccion):
		$Panel/VBoxContainer/BotonA.pressed.disconnect(GameManager.procesar_eleccion)

	$Panel/VBoxContainer/BotonA.pressed.connect(GameManager.procesar_eleccion.bind("cofre_trampa", nueva_opcion_id))

	if has_node("Panel/VBoxContainer/BotonB"):
		$Panel/VBoxContainer/BotonB.hide()
