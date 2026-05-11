extends Node
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var frenesi_actual: float = 0.0
var vida_jugador: int = 80
# ACA EMPIEZA EL CODIGO DE CORI!!!!!#
var eventos_disponibles = [
	{
		"titulo": "Suministros de Oxígeno",
		"texto": "Encuentras una cápsula antigua. ¿Qué extraes?",
		"op_a_txt": "Tanque (Curar 20PV)",
		"op_b_txt": "Escudo (Nueva Carta)",
		"id": "Oxígeno"
	},
	{
		"titulo": "Radiación Alienígena",
		"texto": "Un brillo extraño emana de este contenedor.",
		"op_a_txt": "Mutar (+20 Frenesí)",
		"op_b_txt": "Analizar (+5 PV)",
		"id": "radiacion"
	}
]
# Función para abrir la ventana nueva
func abrir_ventana_evento():
		var evento_aleatorio = eventos_disponibles.pick_random()

		# load scene the ui 
		var interfaz = load (direccion de la carpeta)
		get_tree().root_add_child(interfaz)
		interfaz.configurar(evento_aleatorio)
		
		# pausa el juego para que el jugador pueda leer tranquilo
	get_tree().paused = true

# Función para procesar la elección del jugador
func procesar_eleccion(id_evento, opcion):
	match id_evento:
		"oxigeno":
			if opcion == "A":
				vida_jugador += 20
				print("Vida curada. Total: ", vida_jugador)
			else:
				agregar_carta({"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 5, "roba": 0})
		
		"radiacion":
			if opcion == "A":
				actualizar_frenesi(20)
			else:
				vida_jugador += 5
	
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
func actualizar_frenesi(valor):
	frenesi_actual = clamp(frenesi_actual + valor, 0, 100)
	print("Frenesí biológico en: ", frenesi_actual)

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
	
