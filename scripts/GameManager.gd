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
var esta_en_descontrol = false
var tiempo_dano_frenesi: float = 0.0
var en_combate: bool = false
var corazon_escena = preload("res://Escenas/loot_enemigo_debil/heart_loot.tscn")
var escena_combate: Node = null #para que funcione close combate con esta var

var bloques_destruidos = [] # Guardaremos las coordenadas (x, y) de los azulejos
var eventos_completados = [] # Guardaremos los nombres de los eventos ya usados

var total_enemigos_en_mapa: int = 8
var penalizacion_tiempo_aspiradora: float = 1.0 #(significa al 100%)
var multiplicador_velocidad_laberinto: float = 1.0 # 1.0 es la velocidad normal del player

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
	},
	{
		"titulo": "Necrosis Celular",
		"texto": "Una de tus extremidades mutadas comienza a supurar un líquido negro. Sientes un dolor agudo, pero la vieja estructura celular muerta finalmente se desprende, despejando tu sistema.",
		"op_a_txt": "Extirpar tejido (Elimina una carta de tu mazo)",
		"op_b_txt": "Ignorar (No pasa nada)",
		"id": "necrosis_celular"
	},
	{
	"titulo": "Derrumbe de Capas Subterráneas",
	"texto": "Las vibraciones de tus pasos hacen que el suelo baboso ceda debido a una bolsa de gas vírico. Caes a un túnel inferior completamente a oscuras e infestado de esporas.",
	"op_a_txt": "Soportar el impacto (Caer al sub-laberinto: +20% Frenesí / Revela Boss y Medios)",
	"op_b_txt": "Agarrarse de las paredes (Evitar la caída con cuidado / No pasa nada)",
	"id": "derrumbe_capas"
},
{
"titulo": "Fósil Robotizado Antiguo",
	"texto": "Desentierras los restos semienterrados de us los restos semienterrados de una baliza corporativa cubierta de membrana alienígena. Logras piratear sus celdas de energía para sobrecargar los propulsores de tu traje, aunque el pulso electromagnético daña tus sistemas de combate.",
	"op_a_txt": "Sobrecarga Motriz (+30% velocidad al caminar / Añade carta 'Interferencia')",
	"op_b_txt": "Ignorar (Dejar la tecnología en paz)",
	"id": "fosil_antiguo"
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
		# Evento: "Fósil Robotizado Antiguo"
		"fosil_antiguo":
			if opcion == "A":
				# Aumenta la velocidad de movimiento un 20%
				multiplicador_velocidad_laberinto = 1.2

				# Añade la maldición
				var carta_maldicion = {"nombre": "Interferencia", "tipo": "Maldición", "coste": 99, "daño": 0, "escudo": 0, "roba": 0}
				agregar_carta(carta_maldicion)
				print("Evento: Sobrecarga motriz activa (+20% velocidad). Mazo infectado.")
			else:
				print("Decidiste ignorar el fósil antiguo.")
			get_tree().paused = false
	
		# Evento: "Derrumbe de capas subtrráneas"
		"derrumbe_capas":
			# Ambas opciones aplican el derrumbe (caer por el suelo baboso)
			# efecto negativo: aumenta el frenesí un 20% 
			actualizar_frenesi(20.0) 
			print("Evento: Caíste por el suelo baboso. El virus se altera (+20% Frenesí).")

			# efecto positivo: El estruendo revela Enemigos Medios y Boss en el HUD
			revelar_enemigos_importantes()
			get_tree().paused = false

		# Evento: "Fósil Robotizado Antiguo"
		"fosil_antiguo":
			if opcion == "A":
				# BENEFICIO: La linterna se expande al máximo de forma fija en este loop
				#bonus_vision_laberinto = true#
				
				# DESVENTAJA: Añade la carta maldición "Interferencia" a tu mazo
				var carta_maldicion = {
					"nombre": "Interferencia", 
					"tipo": "Maldición", 
					"coste": 99, 
					"daño": 0, 
					"escudo": 0, 
					"roba": 0
				}
				agregar_carta(carta_maldicion)
				print("Evento: Mapas descargados. Linterna al máximo, mazo infectado.")
			else:
				print("Decidiste ignorar el fósil antiguo.")
			get_tree().paused = false
		# Evento: "Necrosis celular"
		"necrosis_celular":
			if opcion == "A":
				# call a una ui para elegirque carta borrar (el sistema no esta creado todavia)
				abrir_interfaz_eliminar_carta()
			else:
				print("Decidiste ignorar la necrosis. El virus se mantiene estable.")
				# Si ignora, reanudamos el juego directamente aca.
				get_tree().paused = false

		#Evento: "Suministros de Oxígeno"
		"oxigeno":
			if opcion == "A":
				# clamp que limita el valor entre 0 y la vida maxima
				vida_jugador = clamp(vida_jugador + 20,0, vida_maxima)
				print("Vida curada. Total: ", vida_jugador)
			else:
				agregar_carta({"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 10, "roba": 0})

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
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 12, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 12, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 12, "escudo": 0, "roba": 0},
	{"nombre": "Golpe de Chatarra", "tipo": "Ataque", "coste": 1, "daño": 12, "escudo": 0, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 8, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 8, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 8, "roba": 0},
	{"nombre": "Escudo de Emergencia", "tipo": "Capacidad", "coste": 1, "daño": 0, "escudo": 8, "roba": 0},
	{"nombre": "Instinto de Presa", "tipo": "Poder", "coste": 2, "daño": 25, "escudo": 0, "roba": 0},
	{"nombre": "Análisis de Bioma", "tipo": "Capacidad", "coste": 0, "daño": 0, "escudo": 0, "roba": 1}
]

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(cantidad: float):
	frenesi_actual += cantidad
	frenesi_actual = clamp(frenesi_actual, 0, frenesi_maximo)
	#Le avisa al juego si entraste en modo Descontrol(frenesi)
	esta_en_descontrol = (frenesi_actual >= frenesi_maximo)
	
	print("Frenesí biológico en: ", frenesi_actual)
	
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
	
func _process(delta: float) -> void:
	# Lógica para perder vida en el mapa poco a poco si el frenesí está al máximo
	if esta_en_descontrol and not get_tree().paused and not en_combate:
		tiempo_dano_frenesi += delta
		
		# Cada 2 segundos en el mapa, pierdes 5 de vida (podés ajustar estos números)
		if tiempo_dano_frenesi >= 2.0: 
			vida_jugador -= 5
			tiempo_dano_frenesi = 0.0
			print("El virus te daña mientras exploras. Vida actual: ", vida_jugador)
			
			if vida_jugador <= 0:
				morir_definitivamente()

func morir_definitivamente():
	print("¡Has muerto! Tus sistemas colapsaron.")
	
	# 1. RESETEAMOS TODAS LAS VARIABLES GLOBALES PARA EVITAR BUGS Y BUCLES
	vida_jugador = vida_maxima
	frenesi_actual = 0.0
	esta_en_descontrol = false
	tiempo_dano_frenesi = 0.0
	penalizacion_escudo = 0
	penalizacion_energia = 0
	bonus_doble_dano = false
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

func abrir_interfaz_eliminar_carta():
	# Instancia una pantalla temporal para mostrar el mazo (a implementar)
	# print para robar si funciona la logica por consola:
	print("--- ELIGE UNA CARTA PARA ELIMINAR (Mazo Actual: ", mazo_jugador.size(), " cartas) ---")
	
	# Muestra el mazo en la consola 
	for i in range(mazo_jugador.size()):
		print("[Index: ", i, "] -> ", mazo_jugador[i]["nombre"])
	
	# Eejemplo de prueba (esto se va cuando tengamos la pantalla del mazo de cartas)
	# elimina la primera carta básica de "Golpe de Chatarra" que encuentre (índice 0)
	if mazo_jugador.size() > MAZO_MINIMO:
		eliminar_carta(0) 
	else:
		print("Acción cancelada de forma segura: Tu mazo ya está en el límite mínimo.")

	# despausa el juego
	get_tree().paused = false

 # new func para revelar enemigo (eventos)
func revelar_enemigos_importantes():
	print("Revelando enemigos en el mapa")
	# Busca a todos los enemigos en el mapa usando el grupo "enemigos".
	var enemigos_en_mapa = get_tree().get_nodes_in_group("enemigos")
	for enemigo in enemigos_en_mapa:
		# Verifica el tipo de enemigo (debil, medio o boss)
		if enemigo.has_method("_preparar_combate") or "boss" in enemigo.name.to_lower():
			print("Amenaza detectada y marcada en coordenadas: ", enemigo.global_position)
