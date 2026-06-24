extends Node

# Enemigos
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var enemigos_derrotados = [] # Lista de nombres de enemigos vencidos

# Vision
var radio_vision_actual: float = 0.7 # Tamaño inicial de la luz
var vision_maxima: float = 2.0        # El límite de cuánto puede crecer
var velocidad_crecimiento: float = 0.0002 # Qué tan rápido aumenta ek radio de vision

# modificadores
var esta_en_descontrol = false
var tiempo_dano_frenesi: float = 0.0
var modificador_velocidad: float = 1.0
var sobrecarga_activa: bool = false # Controla si la sobrecarga del fósil está encendida

# Mapa
var posicion_jugador_en_mapa = Vector2.ZERO # Para recordar dónde estábamos
var en_combate: bool = false
var mimic_revelado: bool = false
var jefe_derrotado: bool = false
var corazon_escena = preload("res://Escenas/loot_enemigo_debil/heart_loot.tscn")
var escena_combate: Node = null #para que funcione close combate con esta var
var bloques_destruidos = [] # Guardaremos las coordenadas (x, y) de los azulejos
var eventos_completados = [] # Guardaremos los nombres de los eventos ya usados
var total_enemigos_en_mapa: int = 8
# Sistema de eventos - variables de control
var enemigo_congelado_proximo_combate: bool = false # Evento 4 (Criostasis)
var combates_con_persistencia: int = 0 # Evento 5 (Sangre Hirviente)
var bonus_revelar_eventos: bool = false # Evento 6 (Satélite A)
var sobrecarga_robo_primer_turno: bool = false # Evento 6 (Satélite B)
var barajar_al_final_del_turno: bool = false # Evento 7 (Fisión)
var camino_corto_desbloqueado: bool = false

# ACA EMPIEZA EL CODIGO DE CORI!!!!!#
var eventos_disponibles = [
	
	{
		"id": "santuario_sangre",
		"titulo": "Santuario de Sangre",
		"descripcion": "Ofrece tu vitalidad a cambio de poder. ¿Estás dispuesto a mutilar tu cuerpo para infligir más dolor?",
		"opcion_a": "Ofrecer sangre (-5 PV / +3 daño permanente)",
		"opcion_b": "Alejarse (Mantenerse intacto)"
	},
	{
		"id": "cofre_trampa",
		"titulo": "Un Contenedor Abandonado",
		"descripcion": "Encuentras un cofre con el logo de una antigua expedición. Parece intacto.",
		"opcion_a": "Abrir el contenedor",
		"opcion_b": "Inspeccionar"
	},
	{
		"id": "necrosis_celular",
		"titulo": "Necrosis Celular",
		"descripcion": "Una de las extremidades mutadas del astronauta comienza a supurar un líquido negro. Se experimenta un dolor agudo, la estructura celular muerta se desprende, purgando el sistema biológico del personaje.",
		"opcion_a": "Extirpar tejido (Elimina una carta básica de tu mazo)",
		"opcion_b": "Ignorar"
	},
	{
		"id": "fosil_antiguo",
		"titulo": "Fósil Antiguo",
		"descripcion": "Encontraste un fosil ¡Descubre que te ofrece!",
		"opcion_a": "Sobrecarga Motriz (+20% velocidad al caminar / Añade carta 'Interferencia')",
		"opcion_b": "Ignorar"
	},
	{
		"id": "oxigeno",
		"titulo": "Cápsula de Oxígeno",
		"descripcion": "Encuentras una cápsula antigua. ¿Qué extraes?",
		"opcion_a": "Tanque (Curar 20PV)",
		"opcion_b": "Escudo (Nueva Carta)"
	},
	{
		"id": "radiacion_1",
		"titulo": "Radiación Cósmica",
		"descripcion": "Una grieta espacial emite partículas brillantes sobre tu traje.",
		"opcion_a": "Exponerse: Tu siguiente ataque infligirá el doble de daño, pero pierdes 5 de defensa.",
		"opcion_b": "Usar Escudo: Bloqueas la radiación (siguiente ataque) pero gastas una carga de energía."
	},
	{
		"id": "radiacion_2",
		"titulo": "Contenedor Irradiado",
		"descripcion": "Un brillo extraño emana de este contenedor.",
		"opcion_a": "Mutar (+20 Frenesí)",
		"opcion_b": "Analizar (+5 PV)"
	}
]
var eventos_pendientes = []

# Función para abrir la ventana de eventos
func abrir_ventana_evento():
	# si la lista de eventos pendientes está vacía, se recarga con todos los eventos
	if eventos_pendientes.is_empty():
		eventos_pendientes = eventos_disponibles.duplicate()
		# mezcla la lista para que el orden cambie cada vez que se terminen
		eventos_pendientes.shuffle()

	# saca el último evento de la lista, así no se repite 
	var evento_aleatorio = eventos_pendientes.pop_back()

	# carga la interfaz
	var interfaz = load("res://Escenas/ventana_evento.tscn").instantiate()
	get_tree().root.add_child(interfaz)
	interfaz.configurar(evento_aleatorio)
	
	get_tree().paused = true

# Función para procesar la elección del jugador
func procesar_eleccion(id_evento: String, opcion: String):
	print("-> [test] procesar_eleccion recibido! ID: ", id_evento, " | Opción: ", opcion)
	# search  ventana que disparó el evento para poder interactuar con ella
	var ventana_actual = get_tree().root.find_child("VentanaEvento", true, false)
	
	match id_evento:
		"tutorial_frenesi":
			print("El jugador leyó el contexto del juego.")
		
				
		"necrosis_celular":
			if opcion == "A":
				if ventana_actual:
					abrir_interfaz_eliminar_carta(ventana_actual)
					return # frena para que el mazo se dibuje encima
			else:
				print("Decidiste ignorar la necrosis.")
		
		"oxigeno":
			if opcion == "A":
				RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + 5, 0, RunManager.run_data.vida_maxima)
				print("Vida curada. Total: ", RunManager.run_data.vida_jugador)
			else:
				agregar_carta(RunManager.SET_DE_CARTAS.ESCUDO_EMERGENCIA)

		"fosil_antiguo":
			if opcion == "A":
				if ventana_actual:
					activar_powerup_fosil(ventana_actual)
					return
			else:
				print("Ignoraste el evento, aburridooo!")
		# evento que otorga +2 de daño permanente
		"santuario_sangre":
			if opcion == "A":
				# reduce la vida máxima en los datos de la Run actual
				RunManager.run_data.vida_jugador -= 6

				# safe por si la vida baja a 0 o menos para que muera
				if RunManager.run_data.vida_jugador <= 0:
					morir_definitivamente()
					return

				# suma el daño al nuevo export permanente de RunData
				RunManager.run_data.dano_permanente_eventos += 3
				
				print("[SANTUARIO] Trato aceptado. Nueva vida actual: ", RunManager.run_data.vida_jugador, " | Daño Extra: +", RunManager.run_data.dano_permanente_eventos)
			else:
				print("[SANTUARIO] Decidiste ignorar la mejora.")

		# add evento "cofre trampa"
		"cofre_trampa":
			# 1. Si es la primera vez que toca (A o B), le mostramos la trampa
			if mimic_revelado == false:
				if opcion == "A" or opcion == "B":
					mimic_revelado = true # Activamos la memoria de la trampa
					
					if ventana_actual and ventana_actual.has_method("mostrar_texto_intermedio"):
						ventana_actual.mostrar_texto_intermedio(
							"¡Caíste en la trampa! ¡Ahora tienes que vencerme!", 
							"Pelear", 
							"combate_mimic"
						)
					return # Frenamos acá para que lea
					
			# 2. Si la trampa ya estaba revelada, CUALQUIER botón que toque inicia el combate
			else:
				mimic_revelado = false # Lo apagamos por si vuelve a jugar desde el menú
				print("¡Combate trampa activado!")
				en_combate = true
				
				# TRUCO NINJA---------------------------------------------------------------------------- PARA SABER QUE HICIMOS
				# 1. Cargamos la escena de tu enemigo débil invisiblemente en memoria
				var enemigo_temp = preload("res://Escenas/enemigo_debil/enemigo_debil.tscn").instantiate()
				
				# 2. Le "robamos" su archivo de animaciones
				var animaciones_mimic = enemigo_temp.get_node("AnimatedSprite2D").sprite_frames
				# ------------------------------------------
				
				# Seteamos las estadísticas del Mimic
				enemigo_actual_datos = {
					"nombre_en_escena": "mimic_evento", 
					"tipo_enemigo": "debil",           
					"vida": 40,
					"frenesi": 15,
					"Daño_fijo": 14,
					"daño_poder": 20,
					"posicion": posicion_jugador_en_mapa,
					"sprite_frames": animaciones_mimic # <--- ACÁ PONEMOS LAS ANIMACIONES
				}

				# 3. Borramos el clon temporal de la memoria para no gastar recursos
				enemigo_temp.free()

				# Cerramos la ventana del evento y despausamos
				if ventana_actual:
					ventana_actual.queue_free()
				get_tree().paused = false
				
				# Viaje al combate seguro con call_deferred
				get_tree().call_deferred("change_scene_to_file", "res://Escenas/escena_combate/escena_combate.tscn")
				return
# FIN EVENTO TRAMPA TRUCO NINJA---------------------------------------------------------------------------------------------------- 

	# si no fue la opción A de necrosis o el texto intermedio del mimic, se cierra la ui y despausa
	if ventana_actual:
		ventana_actual.queue_free()
	get_tree().paused = false

	# si no fue la opción A de necrosis, cse cierra la ui del evento común y despausa
	if ventana_actual:
		ventana_actual.queue_free()
	get_tree().paused = false

func activar_powerup_fosil(interfaz_existente: CanvasLayer):
	var recurso_carta = RunManager.SET_DE_CARTAS.INTERFERENCIA
	
	if not recurso_carta:
		print("ERROR: No se encontró la carta INTERFERENCIA.")
		interfaz_existente.queue_free()
		get_tree().paused = false
		return
		
	# 1. Preparamos la interfaz (igual que en necrosis)
	var interfaz = interfaz_existente
	interfaz.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Cambiamos los textos de la ventana
	interfaz.get_node("Titulo").text = "SOBRECARGA MOTRIZ"
	interfaz.get_node("Descripcion").text = "HAZ CLIC EN LA CARTA PARA AÑADIRLA A TU MAZO"
	
	# Ocultamos los botones A y B
	interfaz.get_node("VBoxContainer/BotonA").hide()
	interfaz.get_node("VBoxContainer/BotonB").hide()
	
	# 2. Instanciamos la carta interactiva
	var panel_base = interfaz.get_node("Panel")
	var escena_carta_ui = load("res://Escenas/carta/carta_ui.tscn")
	
	if escena_carta_ui:
		var instancia_carta = escena_carta_ui.instantiate()
		instancia_carta.process_mode = Node.PROCESS_MODE_ALWAYS
		panel_base.add_child(instancia_carta)
		
		# Le pasamos los datos de Interferencia
		instancia_carta.configurar(recurso_carta)
		instancia_carta.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Centramos la carta en el medio del panel gris
		# (Ajustá el 200 y 280 si el tamaño de tus cartas es diferente)
		var tamano_carta = Vector2(200, 280) 
		var offset_hacia_abajo = Vector2(0, 100)
		instancia_carta.position = (panel_base.size / 2) - (tamano_carta / 2 - offset_hacia_abajo)
		
		# 3. Conectamos el clic para confirmar y cerrar
		instancia_carta.pressed.connect(func():
			_confirmar_carta_fosil(recurso_carta, interfaz)
		)

# Func que ejecuta la recompensa cuando haces clic en la carta del Fósil
func _confirmar_carta_fosil(carta_a_agregar: RecursoCarta, nodo_ui: CanvasLayer):
	# 1. Aplicamos el buff de velocidad
	print("¡Sobrecarga Motriz activada! Velocidad +20%")
	modificador_velocidad = 1.2
	sobrecarga_activa = true
	
	# 2. Agregamos la carta al mazo
	agregar_carta(carta_a_agregar)
	print("Carta 'Interferencia' añadida con éxito.")
	
	# 3. Cerramos la ventana y despausamos el juego
	nodo_ui.queue_free()
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("consola funcionando: El juego se inició correctamente")

func mostrar_tutorial_inicial() -> void:
	await get_tree().create_timer(0.2).timeout
	
	var intro_contexto = {
		"id": "tutorial_frenesi",
		"titulo": "¡ALERTA DE BIOCONTAMINACIÓN!",
		"descripcion": "Sistemas del traje comprometidos. Un virus alienígena se ha filtrado en tu organismo.\n\nLa primera barra es el indicador de FRENESÍ que aumentará al explorar y mutar. Si llega al 100%, entrarás en DESCONTROL y perderás vida en el mapa poco a poco.",
		"opcion_a": "Estabilizar traje y comenzar",
		"opcion_b": ""
	}
	
	var interfaz = load("res://Escenas/ventana_evento.tscn").instantiate()
	get_tree().root.add_child(interfaz)
	
	# PRENDEMOS EL FONDO SOLO PARA ESTA OCASIÓN 
	if interfaz.has_node("FondoNegroTutorial"):
		interfaz.get_node("FondoNegroTutorial").show()
	
	interfaz.configurar(intro_contexto)
	
	if interfaz.has_node("VBoxContainer/BotonB"):
		interfaz.get_node("VBoxContainer/BotonB").hide()
		
	get_tree().paused = true

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(cantidad: float):
	RunManager.run_data.frenesi_actual += cantidad
	RunManager.run_data.frenesi_actual = clamp(RunManager.run_data.frenesi_actual, 0, RunManager.run_data.frenesi_maximo)
	#Le avisa al juego si entraste en modo Descontrol(frenesi)
	esta_en_descontrol = (RunManager.run_data.frenesi_actual >= RunManager.run_data.frenesi_maximo)
	
	print("Frenesí biológico en: ", RunManager.run_data.frenesi_actual)
	
func morir_por_frenesi():
	print("El virus de descontroló")
	morir_definitivamente()

# Agregar carta cuando se necesite
func agregar_carta(nueva_carta: RecursoCarta):
	if RunManager.run_data.mazo_actual.size() < RunManager.MAZO_MAXIMO:
		RunManager.agregar_carta(nueva_carta)
		print("Nueva carta añadida al mazo. Total actual: ", RunManager.run_data.mazo_actual.size())
	else:
		print("Mazo lleno. Alcanzaste el límite máximo de ", RunManager.MAZO_MAXIMO, " cartas.")

#Eminimar carta cuando se necesite
func eliminar_carta(indice: int):
	if RunManager.run_data.mazo_actual.size() > RunManager.MAZO_MINIMO:
		RunManager.eliminar_carta(indice)
		print("Carta eliminada del mazo. Total actual: ", RunManager.run_data.mazo_actual.size())
	else:
		print("Acción bloqueada: Tu mazo no puede tener menos de ", RunManager.MAZO_MINIMO, " cartas.")

# Funcion global para cavar/romper bloques
func romper_bloque(player_position: Vector2, direccion: String):
	# Calcula posición del player + 16px a la direccfion indicada y busca un bloque ahi
	var offset = Vector2.ZERO
	var distancia_cavar = 16 # 16px

	match direccion:
		"up":
			offset = Vector2(0, -distancia_cavar)
		"down":
			offset = Vector2(0, distancia_cavar)
		"left":
			offset = Vector2(-distancia_cavar, 0)
		"right":
			offset = Vector2(distancia_cavar, 0)

	var punto_objetivo = player_position + offset

	print("Buscando bloque en:", punto_objetivo)

	for bloque in get_tree().get_nodes_in_group("bloques"):
		var distancia = bloque.global_position.distance_to(punto_objetivo)
		if distancia < 12:
			print("Bloque roto hacia:", direccion)
			bloque.queue_free()
			return

	print("No hay bloque en esa dirección")
	
func _process(delta: float) -> void:
	# Lógica para perder vida en el mapa poco a poco si el frenesí está al máximo
	if esta_en_descontrol and not get_tree().paused and not en_combate:
		tiempo_dano_frenesi += delta
		
		# Cada 2 segundos en el mapa, pierdes 5 de vida (podés ajustar estos números)
		if tiempo_dano_frenesi >= 2.0: 
			RunManager.run_data.vida_jugador -= 5
			tiempo_dano_frenesi = 0.0
			print("El virus te daña mientras exploras. Vida actual: ", RunManager.run_data.vida_jugador)
			
			if RunManager.run_data.vida_jugador <= 0:
				morir_definitivamente()

func morir_definitivamente():
	print("¡Has muerto! Tus sistemas colapsaron.")
	
	# 1. USAMOS LA FUNCIÓN DEL PROFE PARA REINICIAR MAZO Y VIDA:
	RunManager.inicializar_run()
	
	# 2. Vaciamos la memoria del mapa para que reaparezcan los enemigos
	enemigos_derrotados.clear()
	bloques_destruidos.clear()
	eventos_completados.clear()
	
	# 3. Reseteamos las variables del GameManager
	esta_en_descontrol = false
	tiempo_dano_frenesi = 0.0
	en_combate = false
	posicion_jugador_en_mapa = Vector2.ZERO
	jefe_derrotado = false
	
	get_tree().paused = false
	
	
	# 3. Recargamos la escena GameOver (Volvés a aparecer en el inicio)
	PantallaDeTransicion.cambiar_escena("res://Escenas/PantallaGameOver/pantalla_game_over.tscn")
	#get_tree().change_scene_to_file("res://Escenas/PantallaGameOver/pantalla_game_over.tscn")

func finalizar_combate(victoria: bool):
	var posicion_enemigo = enemigo_actual_datos["posicion"]
	
	if victoria:
		# print temporal para ver si funciona
		print("[DEBUG] Datos del enemigo derrotado en combate: ", enemigo_actual_datos)
		
		# marca enemigo como derrotado
		enemigos_derrotados.append(
			enemigo_actual_datos["nombre_en_escena"]
		)

		# logica del boss
		# procesa si es el boss para asegurarse de guardar el desbloqueo ANTES del cambio de escena
		var tipo = enemigo_actual_datos.get("tipo_enemigo", "").to_lower()
		if tipo == "jefe" or tipo == "jefe_enemigo" or tipo == "boss":
			camino_corto_desbloqueado = true
			print("¡Jefe derrotado! Pasillo de escombros liberado para siempre.")
		
		# new logica de loot heart
		# busca el tipo de enemigo "tipo_enemigo". Si NO es "jefe", loot corazón.
		if tipo != "jefe" and tipo != "jefe_enemigo" and tipo != "boss":
			var nuevo_corazon = corazon_escena.instantiate()
			
			# --- DETERMINAMOS CUÁNTO CURA SEGÚN EL ENEMIGO ---
			if tipo == "debil" or tipo == "debil2":
				nuevo_corazon.cantidad_curacion = 5.0 # Recompensa chica
			elif tipo == "medio" or tipo == "medio2":
				nuevo_corazon.cantidad_curacion = 15.0 # ¡Recompensa grande por el esfuerzo!
			
			# Metemos el corazón en el mapa con su curación ya asignada
			get_tree().current_scene.add_child(nuevo_corazon)
			nuevo_corazon.global_position = posicion_enemigo
			
			print("Corazón looteado. Tipo: ", tipo, " | Curación seteada en: ", nuevo_corazon.cantidad_curacion)
		else:
			print("Combate ganado contra el Jefe: ¡No se lootea corazón!")

	# --- CAMBIO DE ESCENA AL FINAL ---
	# Cambiamos de mapa al final de procesar toda la lógica para que los datos viajen limpios
	if RunManager.run_data.loop_actual == 1:
		get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
	elif RunManager.run_data.loop_actual == 2:
		get_tree().change_scene_to_file("res://Escenas/segunda_escena/segunda_escena.tscn")

# func para el evento de necrosis
func abrir_interfaz_eliminar_carta(interfaz_existente: CanvasLayer):
	if RunManager.run_data.mazo_actual.size() <= RunManager.MAZO_MINIMO:
		print("Mazo en el límite mínimo. No se pueden eliminar más cartas.")
		interfaz_existente.queue_free()
		get_tree().paused = false
		return

	var interfaz = interfaz_existente
	interfaz.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# busca los nodos directamente en la interfaz, no en el panel
	interfaz.get_node("Titulo").text = "NECROSIS CELULAR"
	interfaz.get_node("Descripcion").text = "ELIGE LA CARTA QUE QUIERES ELIMINAR"
	
	interfaz.get_node("VBoxContainer/BotonA").hide()
	interfaz.get_node("VBoxContainer/BotonB").hide()

	# usa el Panel gris de fondo para meter el scroll adentro
	var panel_base = interfaz.get_node("Panel")

	# configuración de la caja de Scroll
	var panel_scroll = ScrollContainer.new()
	var scroll_ancho = 880
	var scroll_alto = 350
	panel_scroll.custom_minimum_size = Vector2(scroll_ancho, scroll_alto)
	panel_scroll.size = Vector2(scroll_ancho, scroll_alto)
	
	panel_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	
	# Mete el scroll adentro del panel
	panel_base.add_child(panel_scroll)
	
	# centrado usando el tamaño del Panel gris
	var centro_x = (panel_base.size.x - scroll_ancho) / 2
	panel_scroll.position = Vector2(centro_x, 240)

	# estructura de cuadrícula para las cartas
	var cuadricula_cartas = GridContainer.new()
	cuadricula_cartas.columns = 4
	cuadricula_cartas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cuadricula_cartas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# espaciado de 40px para que no queden comprimidas
	cuadricula_cartas.add_theme_constant_override("h_separation", 40)
	cuadricula_cartas.add_theme_constant_override("v_separation", 40)
	panel_scroll.add_child(cuadricula_cartas)

	var mazo = RunManager.run_data.mazo_actual
	var escena_carta_ui = load("res://Escenas/carta/carta_ui.tscn")
	
	for i in range(mazo.size()):
		var carta_recurso = mazo[i]
		
		if escena_carta_ui:
			var instancia_carta = escena_carta_ui.instantiate()
			instancia_carta.process_mode = Node.PROCESS_MODE_ALWAYS
			# Eliminamos las líneas que apagaban el input para que Godot no se tilde en la pausa
			
			cuadricula_cartas.add_child(instancia_carta)
			instancia_carta.configurar(carta_recurso)
			instancia_carta.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

			# Conexión al hacer clic para eliminar
			instancia_carta.pressed.connect(func():
				_confirmar_eliminacion_carta(i, interfaz)
			)

# func que ejecuta la eliminación de la carta elegida
func _confirmar_eliminacion_carta(indice: int, nodo_ui: CanvasLayer):
	var carta_eliminada = RunManager.run_data.mazo_actual[indice]
	RunManager.eliminar_carta(indice)
	print("Carta destruida con éxito de los datos: ", carta_eliminada)
	
	nodo_ui.queue_free()
	get_tree().paused = false
