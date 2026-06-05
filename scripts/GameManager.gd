extends Node

# Enemigos
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var enemigos_derrotados = [] # Lista de nombres de enemigos vencidos

# Vision
var radio_vision_actual: float = 0.7  # Tamaño inicial de la luz
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

# ACA EMPIEZA EL CODIGO DE CORI!!!!!#
var eventos_disponibles = [
	{
		"titulo": "Necrosis Celular",
		"texto": "Una de las extremidades mutadas del astronauta comienza a supurar un líquido negro. Se experimenta un dolor agudo, la estructura celular muerta se desprende, purgando el sistema biológico del personaje.",
		"op_a_txt": "Extirpar tejido (Elimina una carta básica de tu mazo)",
		"op_b_txt": "Ignorar",
		"id": "necrosis_celular"
	},
	{
		"titulo": "Derrumbe de Capas Subterráneas",
		"texto": "Las vibraciones de tus pasos hacen que el suelo baboso ceda debido a una bolsa de gas vírico. Caes a un túnel inferior completamente a oscuras e infestado de esporas.",
		"op_a_txt": "Soportar el impacto (Caer al sub-laberinto: +20% Frenesí / Revela Amenazas)",
		"op_b_txt": "Agarrarse de las paredes (Evitar la caída con cuidado / No pasa nada)",
		"id": "derrumbe_capas"
	},
	{
		"titulo": "Fósil Robotizado Antiguo",
		"texto": "Desentierras los restos semienterrados de una baliza corporativa cubierta de membrana alienígena. Logras piratear sus celdas de energía para sobrecargar los propulsores de tu traje, aunque el pulso electromagnético daña tus sistemas de combate.",
		"op_a_txt": "Sobrecarga Motriz (+30% velocidad al caminar / Añade carta 'Interferencia')",
		"op_b_txt": "Ignorar (Dejar la tecnología en paz)",
		"id": "fosil_antiguo"
	},
	{
		"titulo": "Criostasis Natural",
		"texto": "Tropiezas con una grieta de donde emana un gas criogénico alienígena. Tu metabolismo alterado absorbe el frío, ralentizando tus funciones vitales pero agudizando tus reflejos mecánicos.",
		"op_a_txt": "Absorber el gas (Próximo combate: Enemigo salta turno 1 / Inicias con 2 Energía)",
		"op_b_txt": "Evitar la grieta (No pasa nada)",
		"id": "criostasis_natural"
	},
	{
		"titulo": "Sangre Hirviente",
		"texto": "Tu virus detecta una amenaza ambiental invisible y hace que tu sangre hierva dentro del traje. Sientes que puedes soportar cualquier golpe, pero a un coste biológico altísimo.",
		"op_a_txt": "Activar persistencia (No mueres por 2 combates / Frenesí al 80% al ganar)",
		"op_b_txt": "Calmar el sistema (No arriesgarse)",
		"id": "sangre_hirviente"
	},
	{
		"titulo": "Restos del Satélite de Comunicaciones",
		"texto": "Encuentras una baliza de señal de la corporación que te abandonó. Sigue emitiendo datos encriptados. Puedes usar la terminal para descargar mapas topográficos o piratear el sistema de soporte vital del traje.",
		"op_a_txt": "Datos de Navegación (Revela eventos ocultos en el HUD)",
		"op_b_txt": "Sobrecarga Bio-eléctrica (Robas el doble de cartas en el turno 1 de este loop)",
		"id": "satelite_comunicaciones"
	},
	{
		"titulo": "Núcleo de Fisión Inestable",
		"texto": "Entre los restos del accidente de tu nave, encuentras una batería de fisión dañada que gotea radiación. El virus en tu cuerpo reacciona con violencia ante la energía nuclear.",
		"op_a_txt": "Absorber radiación (Ciclado rápido de mazo / Añade 2 cartas de 'Maldición por Quemadura')",
		"op_b_txt": "Sellar el contenedor (Ignorar el peligro)",
		"id": "nucleo_fision"
	},
	{
		"titulo": "Suministros de Oxígeno",
		"texto": "Encuentras una cápsula antigua. ¿Qué extraes?",
		"op_a_txt": "Tanque (Curar 20PV)",
		"op_b_txt": "Escudo (Nueva Carta)",
		"id": "oxigeno"
	},
	{
		"titulo": "Radiación Extraña",
		"texto": "Una grieta espacial emite partículas brillantes sobre tu traje.",
		"op_a_txt": "Exponerse: Tu siguiente ataque infligirá el doble de daño, pero pierdes 5 de defensa.",
		"op_b_txt": "Usar Escudo: Bloqueas la radiación (siguente ataque) pero gastas una carga de energía.",
		"id": "radiacion_1"
	},
	{
		"titulo": "Radiación Alienígena",
		"texto": "Un brillo extraño emana de este contenedor.",
		"op_a_txt": "Mutar (+20 Frenesí)",
		"op_b_txt": "Analizar (+5 PV)",
		"id": "radiacion_2"
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
	# search  ventana que disparó el evento para poder interactuar con ella
	var ventana_actual = get_tree().root.find_child("VentanaEvento", true, false)
	
	match id_evento:
		"necrosis_celular":
			if opcion == "A":
				if ventana_actual:
					abrir_interfaz_eliminar_carta(ventana_actual)
					return # frena para que el mazo se dibuje encima
			else:
				print("Decidiste ignorar la necrosis.")
		
		"oxigeno":
			if opcion == "A":
				RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + 20, 0, RunManager.run_data.vida_maxima)
				print("Vida curada. Total: ", RunManager.run_data.vida_jugador)
			else:
				agregar_carta(RunManager.SET_DE_CARTAS.ESCUDO_EMERGENCIA)
	# si no fue la opción A de necrosis, cse cierra la ui del evento común y despausa
	if ventana_actual:
		ventana_actual.queue_free()
	get_tree().paused = false

func activar_powerup_fosil():
	print("¡Sobrecarga Motriz activada! Velocidad +20%")
	modificador_velocidad = 1.2
	sobrecarga_activa = true
	
	# carga el recurso .tres 
	if has_node("/root/RunManager"):
		var run_manager = get_node("/root/RunManager")
		if "run_data" in run_manager and "mazo_actual" in run_manager.run_data:

			var recurso_maldicion = load("res://recursos/cartas/analisis_bioma.tres")
			
			if recurso_maldicion:
				run_manager.run_data.mazo_actual.append(recurso_maldicion)
				print("Recurso de 'Interferencia' añadido con éxito al mazo.")
			else:
				print(" No se encontró el archivo de recurso .tres en la ruta especificada.")

# muestra la carta grande mientras el player puede moverse
	var capa_visual = CanvasLayer.new()
	capa_visual.name = "BannerMaldicion"
	get_tree().root.add_child(capa_visual)
	
	var sprite_carta = TextureRect.new()
	sprite_carta.texture = load("res://Assets/cartas/Análisis de Bioma.jpg") 
	
	# 1. Definimos el tamaño de la carta
	var tamano_carta = Vector2(200, 280)
	sprite_carta.custom_minimum_size = tamano_carta
	sprite_carta.size = tamano_carta
	
	sprite_carta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_carta.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 2. Metemos la carta dentro de la capa visual
	capa_visual.add_child(sprite_carta)
	
	# 3. Calculamos el centro usando la capa visual (que ya está en el árbol de nodos)
	var tamano_pantalla = capa_visual.get_viewport().get_visible_rect().size
	sprite_carta.position = (tamano_pantalla / 2) - (tamano_carta / 2)
	
	print(" Sprite de 'Interferencia' mostrado en el CENTRO de la pantalla.")
	
	# 4. Espera 2.5 segundos sin frenar el juego
	await get_tree().create_timer(2.5).timeout
	
	# 5. Borramos TODA la capa (así se lleva el sprite con ella)
	capa_visual.queue_free()
	print("-> [GAME MANAGER] El banner de la carta desapareció. La velocidad sigue activa.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("consola funcionando: El juego se inició correctamente")
	pass # Replace with function body.

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(cantidad: float):
	RunManager.run_data.frenesi_actual += cantidad
	RunManager.run_data.frenesi_actual = clamp(RunManager.run_data.frenesi_actual, 0, RunManager.run_data.frenesi_maximo)
	#Le avisa al juego si entraste en modo Descontrol(frenesi)
	esta_en_descontrol = (RunManager.run_data.frenesi_actual >= RunManager.run_data.frenesi_maximo)
	
	print("Frenesí biológico en: ", RunManager.run_data.frenesi_actual)
	
func morir_por_frenesi():
	print("El virus de descontroló")
	get_tree().reload_current_scene() #Reinicia el juego si el frenesi llega a su máximo

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
	
	# 1. RESETEAMOS TODAS LAS VARIABLES GLOBALES PARA EVITAR BUGS Y BUCLES
	RunManager.run_data.vida_jugador = RunManager.run_data.vida_maxima
	RunManager.run_data.frenesi_actual = 0.0
	esta_en_descontrol = false
	tiempo_dano_frenesi = 0.0
	RunManager.reiniciar_modificadores_temporales()
	en_combate = false
	posicion_jugador_en_mapa = Vector2.ZERO
	GameManager.eventos_completados = []
	GameManager.bloques_destruidos = []
	# 2. Despausamos por si moriste por un evento
	get_tree().paused = false
	
	# 3. Recargamos la escena GameOver (Volvés a aparecer en el inicio)
	get_tree().change_scene_to_file("res://Escenas/PantallaGameOver/pantalla_game_over.tscn")

func finalizar_combate(victoria: bool):
	var posicion_enemigo = enemigo_actual_datos["posicion"]
	# vuelve al mapa
	get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
	# esperamos un frame para que cargue el mapa
	await get_tree().create_timer(0.2).timeout
	if victoria:
		# marca enemigo como derrotado
		enemigos_derrotados.append(
			enemigo_actual_datos["nombre_en_escena"]
		)
		
		# new logica de loot heart
		# busca el tipo de enemigo "tipo_enemigo". Si NO es "jefe", loot corazón.
		if enemigo_actual_datos.get("tipo_enemigo") != "jefe":
			var nuevo_corazon = corazon_escena.instantiate()
			get_tree().current_scene.add_child(nuevo_corazon)
			nuevo_corazon.global_position = posicion_enemigo
			print("Corazón looteado (Enemigo común derrotado).")
		else:
			# si es el boss ("jefe"), ignora el instanciar el corazón
			print("Combate ganado contra el Jefe: ¡No se lootea corazón!")

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
	
	interfaz.get_node("BotonA").hide()
	interfaz.get_node("BotonB").hide()

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
