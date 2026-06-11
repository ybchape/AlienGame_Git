extends TextureButton
@onready var label_nombre = $Titulo
@onready var label_coste =$Label
@onready var label_descripcion: Label = %LabelDescripcion

var datos_carta: RecursoCarta
var arrastrando = false
var mouse_offset = Vector2.ZERO
var mi_lugar_en_la_mano = 0
var posicion_global_inicial = Vector2.ZERO # NUEVO: Para recordar la coordenada exacta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func configurar(datos: RecursoCarta):
	# 'datos' es el diccionario que viene del GameManager
	datos_carta = datos 
	# Escribimos el título y el coste
	label_nombre.text = str(datos.tipo)
	
	# LÓGICA DE FRENESÍ VISUAL 
	if GameManager.esta_en_descontrol and datos.tipo == "Ataque":
		label_coste.text = "0"
		label_coste.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	else:
		label_coste.text = str(datos.coste)
		label_coste.remove_theme_color_override("font_color")
	
	#ESTO HAY QUE BORRAR SI ANDA-----------------
	#label_coste.text = str(datos.coste)
	#label_nombre.text = str(datos["tipo"])
	#label_coste.text = str(datos["coste"])
	#--------------------------------------------------
	
	#cargamos la desripccion
	if datos.descripcion != null:
		label_descripcion.text = str(datos.descripcion)
	else:
		label_descripcion.text = ""
	
	# El nombre que pusiste en el diccionario (ej: "Golpe de Chatarra")
	# debe ser igual al nombre del archivo en tu carpeta de Arte.
	if datos.ruta != null:
		# Godot carga la misma imagen para todas las cartas que tengan ese nombre
		texture_normal = datos.ruta
	else:
		print("Falta el arte para: ", datos["nombre"])
		
		
# Esta función de Godot detecta todo lo que haces con el mouse sobre el botón
func _gui_input(event: InputEvent) -> void:
	# 1. Detectar el clic izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 1. Antes de moverla, memorizamos qué lugar ocupa en la mano
			mi_lugar_en_la_mano = get_index()
			# 2. Memorizamos la coordenada en la pantalla antes de moverla
			posicion_global_inicial = global_position
			
			# EMPEZAR A ARRASTRAR
			arrastrando = true
			mouse_offset = global_position - get_global_mouse_position()
			top_level = true 
			z_index = 10
			
			# Esto evita que la carta "salte" antes de que el mouse se mueva.
			global_position = get_global_mouse_position() + mouse_offset

		else:

			# SOLTAR EL CLIC
			arrastrando = false
			z_index = 0
				
			# --- NUEVA COMPROBACIÓN DE SEGURIDAD ---
			# Preguntamos si la escena "abuela" tiene la función de combate
			if get_parent().get_parent().has_method("_jugar_carta"):
				if global_position.y < 200:
					get_parent().get_parent()._jugar_carta(self, datos_carta)
				else:
					volver_a_mano()
			else:
				# Si estamos en un evento (no hay combate), simplemente la devolvemos a su lugar
				# para que no quede flotando si el jugador la intentó arrastrar por error.
				volver_a_mano()
			
			#if global_position.y < 200:
			#	get_parent().get_parent()._jugar_carta(self, datos_carta)
			#else:
			#	volver_a_mano()

	if event is InputEventMouseMotion and arrastrando:
		global_position = get_global_mouse_position() + mouse_offset

# Función para que la carta vuelva a su lugar
func volver_a_mano():
	# 1. Hacemos la animación MIENTRAS la carta sigue libre
	var tween = create_tween()
	# Viaja a la coordenada que memorizó en 0.2 segundos de forma suave
	tween.tween_property(self, "global_position", posicion_global_inicial, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 2. Le decimos al código que espere a que termine la animación
	await tween.finished
	
	# 3. EL TRUCO INFALIBLE: Una vez que llegó, ejecutamos lo que ya funciona 
	# para que el contenedor la absorba y la trabe en su lugar.
	top_level = false
	var mano = get_parent()
	if mano: # Verificamos que la mano exista por las dudas
		mano.remove_child(self)
		mano.add_child(self)
		mano.move_child(self, mi_lugar_en_la_mano)
		
#Actualiza los nuevos datos por las bonificaciones de las cartas ejemplo 1 +2= muestra 3
func actualizar_buffs(buff_dano_basico: int, cartas_en_mano: int):
	var dano_final = datos_carta.daño
	var tiene_buff = false

	# 1. Chequeamos la Bio-Mutación
	if datos_carta.name == "Golpe de Chatarra" or datos_carta.name == "Instinto de Presa":
		dano_final += buff_dano_basico
		if buff_dano_basico > 0:
			tiene_buff = true

	# 2. Chequeamos el Impacto de Precisión
	if datos_carta.name == "Impacto de Precisión" and cartas_en_mano == 1:
		dano_final += datos_carta.dano_extra_ultima_carta
		tiene_buff = true

	# 3. Reescribimos la descripción desde cero para no pisar números viejos
	if datos_carta.descripcion != null:
		label_descripcion.text = str(datos_carta.descripcion).replace(str(datos_carta.daño), str(dano_final))

	# 4. Cambiamos el color si está potenciada, o la devolvemos a la normalidad
	if tiene_buff:
		label_descripcion.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	else:
		label_descripcion.remove_theme_color_override("font_color")
	
