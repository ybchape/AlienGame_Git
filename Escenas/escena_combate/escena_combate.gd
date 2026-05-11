extends Control
var molde_carta = preload("res://escenas/carta/carta_ui.tscn")
@onready var mano_visual = $ManoCartas
@onready var label_energia = $LabelEnergia
@onready var barra_vida_enemigo = $BarraVidaEnemigo
@onready var barra_vida_jugador = $BarraVidaJugador
@onready var sprite_enemigo = $SpriteEnemigo
@onready var label_mazo = $TextureRect/LabelMazo
@onready var label_descarte =$TextureRect2/LabelDescarte
@onready var label_escudo =$LabelEscudo
@onready var label_escudo_enemigo = $LabelEscudoEnemigo
@onready var label_intencion = $LabelIntencion

#Pantalla de victoria/derrota
@onready var panel_final = $CapaFinal/Panel # Asegurate que la ruta sea correcta
@onready var label_resultado = $CapaFinal/Panel/Label
@onready var boton_final = $CapaFinal/Panel/Continuar

var victoria = false

var energia_actual = 3
var mazo_principal = [] 
var mano_actual = []
var mazo_descarte = []
var escudo_actual = 0
var escudo_enemigo_actual = 0
var proxima_accion_enemigo = 0
var es_turno_jugador = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Cargar datos del enemigo
	sprite_enemigo.texture = GameManager.enemigo_actual_datos["textura"]
	barra_vida_enemigo.max_value = GameManager.enemigo_actual_datos["vida"]
	barra_vida_enemigo.value = GameManager.enemigo_actual_datos["vida"]
	
	barra_vida_jugador.max_value = 80 
	barra_vida_jugador.value = GameManager.vida_jugador
	
	# 2. Preparar mano (Mezclar y Robar 5)
	mazo_principal = GameManager.mazo_jugador.duplicate()
	mazo_principal.shuffle() #mescla las cartas
	# Limpia el descarte por seguridad
	mazo_descarte.clear()
	
	#El enemigo decide su primera acción
	planear_proxima_accion()
	
	repartir_cartas(4)
	actualizar_ui()
	
func robar_una_carta():
	# Si el mazo está vacío, pasamos el descarte al mazo y mezclamos
	if mazo_principal.is_empty():
		if mazo_descarte.is_empty():
			print("No quedan cartas en ninguna pila")
			return
		
		mazo_principal = mazo_descarte.duplicate()
		mazo_principal.shuffle()
		mazo_descarte.clear()
		print("Mazo reciclado desde el descarte")

	# Sacamos la carta y la creamos visualmente
	var datos = mazo_principal.pop_front()
	var nueva_carta = molde_carta.instantiate()
	mano_visual.add_child(nueva_carta)
	nueva_carta.configurar(datos)
	
func repartir_cartas(cantidad):
	for i in range(cantidad):
		robar_una_carta()

func _jugar_carta(nodo, datos):
	if energia_actual >= datos["coste"]:
		energia_actual -= datos["coste"]
		# 1. Aplicar DAÑO al enemigo
		if datos.has("daño") and datos["daño"] > 0:
			var dano_a_realizar = datos["daño"]
			
			if escudo_enemigo_actual >= dano_a_realizar:
				escudo_enemigo_actual -= dano_a_realizar # El escudo absorbe todo
			else:
				var dano_sobrante = dano_a_realizar - escudo_enemigo_actual
				escudo_enemigo_actual = 0 # Rompiste su escudo
				barra_vida_enemigo.value -= dano_sobrante # Le restás a su vida
		
		# 2. Aplicar ESCUDO a ti misma
		if datos.has("escudo") and datos["escudo"] > 0:
			escudo_actual += datos["escudo"]
			
		# 3. NUEVO: Habilidad de ROBAR cartas
		if datos.has("roba") and datos["roba"] > 0:
			print("Usaste una habilidad. Robando ", datos["roba"], " carta(s) extra.")
			repartir_cartas(datos["roba"]) # Llama a la función que ya tenés para sacar del mazo
		
		# La carta jugada va al descarte
		mazo_descarte.append(datos)
		nodo.queue_free() #Quita la carta de la mano
		actualizar_ui()
		
		if barra_vida_enemigo.value <= 0:
			print("Victoria")
			mostrar_resultado(true) # Llamamos al panel en lugar de cambiar de escena
	else:
		print("Energía insuficiente")
		nodo.volver_a_mano()

func terminar_turno():
	es_turno_jugador = false # Cerramos el candado del boton
	# 1. Las cartas que sobraron en la mano van al descarte
	for carta in mano_visual.get_children():
		mazo_descarte.append(carta.datos_carta)
		carta.queue_free()
		
	actualizar_ui()
	
	# Llamamos a la fase del enemigo
	turno_del_enemigo()

func actualizar_ui():
	# Actualiza el texto de energía
	label_energia.text = "Energía: " + str(energia_actual) + "/3"
	# Muestra cuántas cartas quedan para robar (Mazo a la izquierda)
	label_mazo.text = "Mazo: " + str(mazo_principal.size())
	# Muestra cuántas cartas ya usaste o descartaste (Descarte a la derecha)
	label_descarte.text = "Descarte: " + str(mazo_descarte.size())
	label_escudo.text = "Escudo: " + str(escudo_actual)
	label_escudo_enemigo.text = "Escudo Enemigo: " + str(escudo_enemigo_actual)
	#barras de salud
	barra_vida_jugador.value = GameManager.vida_jugador

func turno_del_enemigo():
	print("Turno del enemigo...")
	
	# Leemos qué tipo de enemigo es (si no tiene tipo, asumimos "debil")
	var tipo = GameManager.enemigo_actual_datos.get("tipo_enemigo", "debil")
	var dano_enemigo = 0
	escudo_enemigo_actual = 0
	
	# Usamos la acción que ya planeó antes
	var decision = proxima_accion_enemigo
	
	match tipo:
		"debil":
			# IA DEL ENEMIGO DÉBIL 
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El enemigo débil ataca por: ", dano_enemigo)
			elif decision == 1:
				escudo_enemigo_actual += 7
				print("El enemigo débil se protege.")
			else: 
				#Ejecuta el poder
				dano_enemigo = GameManager.enemigo_actual_datos["daño_poder"]
				print("El enemigo débil usa Poder por: ", dano_enemigo)
		
		"medio":
			# IA DEL ENEMIGO MEDIO
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El enemigo medio ataca por: ", dano_enemigo)
			elif decision == 1:
				escudo_enemigo_actual += 12 # Se pone más escudo que el débil
				print("El enemigo medio se protege.")
			else:
				dano_enemigo = GameManager.enemigo_actual_datos["daño_poder"]
				print("El enemigo medio usa Poder por: ", dano_enemigo)
		
		"jefe":
			# IA DEL JEFE (Ataques especiales)
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El Jefe ataca normal por: ", dano_enemigo)
			elif decision == 1:
				escudo_enemigo_actual += 10
				print("El Jefe se pone un mega escudo.")
			else:
				# ATAQUE ESPECIAL
				dano_enemigo = GameManager.enemigo_actual_datos["daño_especial"]
				print("¡EL JEFE USA SU ATAQUE ESPECIAL por: ", dano_enemigo, "!")
# --- LÓGICA DE RECIBIR EL DAÑO (Es igual para todos) ---
	if dano_enemigo > 0:
		if escudo_actual >= dano_enemigo:
			escudo_actual -= dano_enemigo
			print("Tu escudo absorbió todo el golpe.")
		else:
			var dano_restante = dano_enemigo - escudo_actual
			escudo_actual = 0
			GameManager.vida_jugador -= dano_restante
			print("Daño recibido tras escudo: ", dano_restante)
			
			# --- ACÁ AGREGAMOS LA CONDICIÓN DE DERROTA ---
			if GameManager.vida_jugador <= 0:
				print("¡Derrota! Tu vida llegó a 0.")
				mostrar_resultado(false) # Llamamos al panel en lugar de cambiar de escena
				return # El return es crucial: evita que el código siga y te pase de turno estando muerta

	# ACTUALIZAMOS QUÉ VA A HACER EL PRÓXIMO TURNO
	planear_proxima_accion()
	
	actualizar_ui()
	await get_tree().create_timer(1.2).timeout
	iniciar_nuevo_turno_jugador()

func planear_proxima_accion():
	# Leemos el tipo de enemigo (por defecto "debil")
	var tipo = GameManager.enemigo_actual_datos.get("tipo_enemigo", "debil")
	# Ahora TODOS (débil, medio, jefe) eligen entre 3 opciones
	# 0 = Ataque Normal, 1 = Escudo, 2 = Poder
	proxima_accion_enemigo = randi() % 3 
		
	# Mostramos la intención visualmente con Emojis
	if proxima_accion_enemigo == 0:
		var dano = GameManager.enemigo_actual_datos["Daño_fijo"]
		label_intencion.text = "⚔️ Atacará (" + str(dano) + ")"
	elif proxima_accion_enemigo == 1:
		label_intencion.text = "🛡️"
	else:
		# Buscamos el daño de poder
		var dano_poder = GameManager.enemigo_actual_datos.get("daño_poder", 0)
		label_intencion.text = "🔥 (" + str(dano_poder) + ")"

func iniciar_nuevo_turno_jugador():
	print("--- Inicio de tu turno ---")
	es_turno_jugador = true # Abrimos el candado
	
	# 1. Los escudos viejos se limpian (regla de Slay the Spire)
	escudo_actual = 0
	
	# 2. Se recupera la energía total
	energia_actual = 3
	
	# 3. Robás tu nueva mano (en tu caso, 4 cartas como tenés configurado)
	repartir_cartas(4)
	
	# 4. Actualizamos todo visualmente
	actualizar_ui()

func _on_button_pressed() -> void:
	if es_turno_jugador: # Solo funciona si es tu turno
		terminar_turno()


# Pantalla de victoria/Derrota
func mostrar_resultado(gano: bool):
	victoria = gano
	panel_final.visible = true

	if gano:
		
		# ANOTAMOS AL ENEMIGO EN LA LISTA NEGRA
		var nombre_enemigo = GameManager.enemigo_actual_datos.get("nombre_en_escena", "")
		if nombre_enemigo != "" and not nombre_enemigo in GameManager.enemigos_derrotados:
			GameManager.enemigos_derrotados.append(nombre_enemigo)
		
		label_resultado.text = "¡EXPLORACIÓN EXITOSA! \n El enemigo fue derrotado"
		boton_final.text = "Volver al Mapa"
	else:
		label_resultado.text = "SISTEMAS CRÍTICOS... \n El enemigo te gano fracasado"
		boton_final.text = "Reintentar desde el Inicio"

# CONECTÁ EL BOTÓN DEL PANEL A ESTA FUNCIÓN:

func _on_button_final_pressed() -> void:
	if victoria:
		# Si ganó: vuelve al mapa (GameManager mantiene la vida actual)
		get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
	else:
		# Si perdió: reinicia vida y vuelve al inicio
		GameManager.vida_jugador = 80 
		# Reseteamos la posición para que aparezca en el spawn inicial
		GameManager.posicion_jugador_en_mapa = Vector2.ZERO 
		get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
