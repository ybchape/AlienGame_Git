extends Node
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar

var enemigo_actual_datos = {}
var frenesi_actual: float = 0.0
var frenesi_maximo: float = 100.0
var vida_jugador: int = 100
var radio_vision_actual: float = 0.7  # Tamaño inicial de la luz
var vision_maxima: float = 2.0        # El límite de cuánto puede crecer
var velocidad_crecimiento: float = 0.0002 # Qué tan rápido aumenta 
var enemigos_derrotados = [] # Lista de nombres de enemigos vencidos
var posicion_jugador_en_mapa = Vector2.ZERO # Para recordar dónde estábamos
var vida_maxima: int = 100 #new variable eventos
var penalizacion_escudo: int = 0 # var para el efecto de escudo en los eventos
var bonus_doble_dano = false
var penalizacion_energia: int = 0 # var para la penalizacion de energia en eventos
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
				vida_jugador = clamp(vida_jugador + 20,0, vida_jugador)
				print("Vida curada. Total: ", vida_jugador)
			else:
				agregar_carta({"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0})
		# Evento: "Radiación Extraña"
		"radiacion_1":
			if opcion == "A":
				# ademas del daño doble, aplica penalizacion de escudo
				bonus_doble_dano = true
				penalizacion_escudo = 5
				print ("Evento:  Se aplica el doble dano y la penalizacion de escudo -5")
			else:
				penalizacion_energia = 1
				print ("Combatiendo con -1 enegia")

		# Evento: "Radiación Alienígena"
		"radiacion_2":
			if opcion == "A":
				# +20 frenesi
				frenesi_actual = clamp(frenesi_actual + 20,0,frenesi_maximo)
			else:
				# +5 vida
				vida_jugador = clamp(vida_jugador + 5,0,vida_maxima)

	# Reanuda el juego
	get_tree().paused = false
# ACA TERMINA EL CODIGO DE CORI!!!!!#

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# --- LÍMITES DEL MAZO ---
const MAZO_MINIMO = 5
const MAZO_MAXIMO = 15
#El mazo inicial que va a tener el jugador
var mazo_jugador = [
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 6, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 6, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 6, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 6, "escudo": 0, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0},
	{"nombre": "Instinto de Presa", "tipo": "Poder", "coste": 2, "daño": 10, "escudo": 0, "roba": 0},
	{"nombre": "Análisis de Bioma", "tipo": "Capacidad", "coste": 0, "daño": 0, "escudo": 0, "roba": 1}
]

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(cantidad: float):
	frenesi_actual += cantidad
	frenesi_actual = clamp(frenesi_actual, 0, frenesi_maximo)
	print("Frenesí biológico en: ", frenesi_actual)
	
	if frenesi_actual >= frenesi_maximo:
		morir_por_frenesi()
		
func morir_por_frenesi():
	print("El virus de descontroló")
	get_tree().reload_current_scene() #Reinicia el juego si el frenesi llega a su máximo

	# Agregar carta cuando se necesite
func agregar_carta(nueva_carta: Dictionary):
	if mazo_jugador.size() < MAZO_MAXIMO:
		mazo_jugador.append(nueva_carta)
		print("Nueva carta añadida al mazo. Total actual: ", mazo_jugador.size())
	else:
		print("Mazo lleno. Alcanzaste el límite máximo de ", MAZO_MAXIMO, " cartas.")

#Eminimar carta cuando se necesite
func eliminar_carta(indice: int):
	if mazo_jugador.size() > MAZO_MINIMO:
		mazo_jugador.remove_at(indice)
		print("Carta eliminada del mazo. Total actual: ", mazo_jugador.size())
	else:
		print("Acción bloqueada: Tu mazo no puede tener menos de ", MAZO_MINIMO, " cartas.")

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
