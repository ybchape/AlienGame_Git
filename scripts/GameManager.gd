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

# Mapa
var posicion_jugador_en_mapa = Vector2.ZERO # Para recordar dónde estábamos
var en_combate: bool = false
var corazon_escena = preload("res://Escenas/loot_enemigo_debil/heart_loot.tscn")
var escena_combate: Node = null #para que funcione close combate con esta var
var bloques_destruidos = [] # Guardaremos las coordenadas (x, y) de los azulejos
var eventos_completados = [] # Guardaremos los nombres de los eventos ya usados
var total_enemigos_en_mapa: int = 8

# ACA EMPIEZA EL CODIGO DE CORI!!!!!#
var eventos_disponibles = [
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

# Función para abrir la ventana nueva
func abrir_ventana_evento():
	# Si la lista de eventos pendientes está vacía, se recarga con todos los eventos
	if eventos_pendientes.is_empty():
		eventos_pendientes = eventos_disponibles.duplicate()
		# Mezclar la lista para que el orden cambie cada vez que se terminen
		eventos_pendientes.shuffle()

	# Saca el último evento de la lista, así no se repite 
	var evento_aleatorio = eventos_pendientes.pop_back()

	# Carga la interfaz
	var interfaz = load("res://Escenas/ventana_evento.tscn").instantiate()
	get_tree().root.add_child(interfaz)
	interfaz.configurar(evento_aleatorio)
	
	get_tree().paused = true

# Función para procesar la elección del jugador
func procesar_eleccion(id_evento, opcion):
	match id_evento:
		#Evento: "Suministros de Oxígeno"
		"oxigeno":
			if opcion == "A":
				# clamp que limita el valor entre 0 y la vida maxima
				RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + 20,0, RunManager.run_data.vida_jugador)
				print("Vida curada. Total: ", RunManager.run_data.vida_jugador)
			else:
				agregar_carta(RunManager.SET_DE_CARTAS.ESCUDO_EMERGENCIA_2)
		# Evento: "Radiación Extraña"
		"radiacion_1":
			if opcion == "A":
				# ademas del daño doble, aplica penalizacion de escudo
				RunManager.run_data.bonus_doble_dano = true
				RunManager.run_data.penalizacion_escudo = 5
				print ("Evento:  Se aplica el doble dano y la penalizacion de escudo -5")
			else:
				RunManager.run_data.penalizacion_energia = 1
				print ("Combatiendo con -1 enegia")

		# Evento: "Radiación Alienígena"
		"radiacion_2":
			if opcion == "A":
				# +20 frenesi
				RunManager.run_data.frenesi_actual = clamp(RunManager.run_data.frenesi_actual + 20,0,RunManager.run_data.frenesi_maximo)
			else:
				# +5 vida
				RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + 5,0,RunManager.run_data.vida_maxima)

	# Reanuda el juego
	get_tree().paused = false
# ACA TERMINA EL CODIGO DE CORI!!!!!#

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		# instanciamos el corazón
		var nuevo_corazon = corazon_escena.instantiate()
		get_tree().current_scene.add_child(nuevo_corazon)
		nuevo_corazon.global_position = posicion_enemigo
		print("Corazón looteado.")
