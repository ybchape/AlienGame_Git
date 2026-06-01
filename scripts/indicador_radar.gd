extends Node

var enemigos_rastreados: Array = []
var flechas: Dictionary = {}
var timers_parpadeo: Dictionary = {}

# Buscamos al jugador directamente en el grupo para no depender de variables del GameManager
@onready var jugador = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	print("--- RADAR INICIADO EN ESCENA ---")
	
	# Forzamos a que el radar se dibuje por encima de la interfaz pase lo que pase
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	enemigos_rastreados = get_tree().get_nodes_in_group("enemigos")
	print("Radar detectó esta cantidad de bichos activos: ", enemigos_rastreados.size())
	
	for enemigo in enemigos_rastreados:
		if is_instance_valid(enemigo):
			_crear_flecha_para(enemigo)

func _crear_flecha_para(enemigo: Node2D):
	# Creamos un indicador visual gigante y bien rojo para asegurarnos de verlo en los testeos
	var flecha = Polygon2D.new()
	# Un triángulo grande apuntando a la derecha
	flecha.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(24, 0),
		Vector2(0, 12),
		Vector2(6, 0)
	])
	flecha.color = Color(1.0, 0.0, 0.0, 1.0) # Rojo puro brillante, sin transparencias
	flecha.z_index = 200 # Ultra alto: pasa cualquier niebla, TileMap o sombra
	flecha.top_level = true
	
	add_child(flecha)
	flechas[enemigo] = flecha
	
	# Timer para el parpadeo
	var timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 0.5
	timer.timeout.connect(func(): flecha.visible = !flecha.visible)
	add_child(timer)
	timer.start()
	timers_parpadeo[enemigo] = timer

func _process(_delta: float) -> void:
	# Si el jugador murió o no se encuentra, no procesamos nada
	if not is_instance_valid(jugador): 
		jugador = get_tree().get_first_node_in_group("player")
		return
		
	# Obtenemos el centro de la pantalla y sus dimensiones reales actuales
	var canvas_transform = get_viewport().get_canvas_transform()
	var posicion_pantalla_centro = -canvas_transform.origin / canvas_transform.get_scale()
	var tamaño_pantalla = get_viewport().get_visible_rect().size / canvas_transform.get_scale()
	
	var limite_izq = posicion_pantalla_centro.x + 30.0
	var limite_der = posicion_pantalla_centro.x + tamaño_pantalla.x - 30.0
	var limite_sup = posicion_pantalla_centro.y + 30.0
	var limite_inf = posicion_pantalla_centro.y + tamaño_pantalla.y - 30.0
	
	for enemigo in enemigos_rastreados:
		if not is_instance_valid(enemigo) or not enemigo in flechas:
			_limpiar_indicador(enemigo)
			continue
			
		var flecha = flechas[enemigo]
		var timer = timers_parpadeo[enemigo]
		
		# CALCULAMOS LA DISTANCIA DIRECTA ENTRE EL CUERPO DEL PLAYER Y EL BICHO
		var distancia_real = jugador.global_position.distance_to(enemigo.global_position)
		
		# Multiplicamos el radio de visión actual (ej: 0.7) por el tamaño estimado de tu luz en píxeles (ej: 140)
		var rango_luz_pixels = GameManager.radio_vision_actual * 140.0
		
		# REGLA DE VISIÓN: Si tu linterna ya toca al enemigo, la flecha se borra sola
		if distancia_real <= rango_luz_pixels:
			_limpiar_indicador(enemigo)
			continue
			
		# CONTROL DE PARPADEO POR DISTANCIA REAL
		if distancia_real < 180.0:
			# Alerta máxima: El bicho está pegado a tu pared o pasillo siguiente
			if timer.wait_time != 0.07: timer.wait_time = 0.07
		elif distancia_real < 350.0:
			# Distancia media: Parpadeo estándar de advertencia
			if timer.wait_time != 0.25: timer.wait_time = 0.25
		else:
			# Está lejísimos en otra punta del laberinto: Flecha fija y tranquila
			if timer.wait_time != 1.0:
				timer.wait_time = 1.0
				flecha.visible = true
		
		# CALCULAMOS LA POSICIÓN EN LOS BORDES
		# Forzamos a que la flecha flote en los límites de tu monitor siguiendo el movimiento
		var punto_x = clamp(enemigo.global_position.x, limite_izq, limite_der)
		var punto_y = clamp(enemigo.global_position.y, limite_sup, limite_inf)
		
		flecha.global_position = Vector2(punto_x, punto_y)
		
		# Rotamos el triángulo para que apunte hacia las coordenadas del bicho
		flecha.rotation = (enemigo.global_position - flecha.global_position).angle()

func _limpiar_indicador(enemigo: Node):
	if enemigo in flechas and is_instance_valid(flechas[enemigo]):
		flechas[enemigo].queue_free()
	flechas.erase(enemigo)
	
	if enemigo in timers_parpadeo and is_instance_valid(timers_parpadeo[enemigo]):
		timers_parpadeo[enemigo].queue_free()
	timers_parpadeo.erase(enemigo)
	
	enemigos_rastreados.erase(enemigo)
