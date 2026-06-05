extends Control
var molde_carta = preload("res://Escenas/carta/carta_ui.tscn")
@onready var mano_visual = $ManoCartas
@onready var label_energia = $TextureRect3/LabelEnergia
@onready var barra_vida_enemigo = $BarraVidaEnemigo
@onready var barra_vida_jugador = $BarraVidaJugador
@onready var sprite_enemigo = $SpriteEnemigo
@onready var sprite_jugador = $player
@onready var label_mazo = $TextureRect/LabelMazo
@onready var label_descarte =$TextureRect2/LabelDescarte
@onready var label_escudo =$LabelEscudo
@onready var label_escudo_enemigo = $LabelEscudoEnemigo
@onready var label_intencion = $LabelIntencion
@onready var label_veneno_enemigo = $LabelVenenoEnemigo

#vida referencia
@onready var label_vida_jugador = $BarraVidaJugador/LabelVidaJugador
@onready var label_vida_enemigo = $BarraVidaEnemigo/LabelVidaEnemigo

#Pantalla de victoria/derrota
@onready var panel_final = $CapaFinal/Panel # Asegurate que la ruta sea correcta
@onready var label_resultado = $CapaFinal/Panel/Label
@onready var boton_final = $CapaFinal/Panel/Continuar

#NODOS PARA RECOMPENZA
@onready var btn_carta_1 = $CapaFinal/Panel/BtnCarta1
@onready var btn_carta_2 = $CapaFinal/Panel/BtnCarta2

#Max y Min Escudo
var escudo_maximo_jugador = 0
var escudo_maximo_enemigo = 0

#ESTADOS DE COMBATE 
var jugador_aturdido:bool = false
var enemigo_veneno_turnos: int = 0
var enemigo_veneno_dano: int = 0
var enemigo_debil_turnos: int = 0
var turnos_retener_escudo: int = 0
#var retener_escudo: bool = false
var cartas_jugadas_este_turno: int = 0
var enemigo_aturdido: bool = false

# Elementos permanentes de combate
var buff_dano_basico_actual: int = 0
var cura_por_ataque_actual: int = 0
var energia_extra_base: int = 0
var escudo_fijo_por_turno: int = 0

#Eleccion de cartas enemigo medio
var carta_opcion_1: RecursoCarta
var carta_opcion_2: RecursoCarta

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
	
	# Reseteo de estados por si venimos de otra pelea
	enemigo_veneno_turnos = 0
	enemigo_veneno_dano = 0
	enemigo_debil_turnos = 0
	turnos_retener_escudo = 0 # NUEVO
	buff_dano_basico_actual = 0
	cura_por_ataque_actual = 0
	energia_extra_base = 0
	escudo_fijo_por_turno = 0 # NUEVO
	jugador_aturdido = false
	enemigo_aturdido = false
	
	# --- AVISAMOS AL JUEGO QUE EMPEZÓ EL COMBATE ---
	GameManager.en_combate = true
	
	# aplica eventos
	# penalizacion de energia
	energia_actual = 3 - RunManager.run_data.penalizacion_energia
	# reset energia a 3
	RunManager.run_data.penalizacion_energia = 0
	
	# 1. Cargar datos del enemigo
	sprite_enemigo.texture = GameManager.enemigo_actual_datos["textura"]
	barra_vida_enemigo.max_value = GameManager.enemigo_actual_datos["vida"]
	barra_vida_enemigo.value = GameManager.enemigo_actual_datos["vida"]
	
	barra_vida_jugador.max_value = RunManager.run_data.vida_maxima 
	barra_vida_jugador.value = RunManager.run_data.vida_jugador
	
	# 2. Preparar mano (Mezclar y Robar 5)
	mazo_principal = RunManager.run_data.mazo_actual.duplicate()
	mazo_principal.shuffle() #mescla las cartas
	# Limpia el descarte por seguridad
	mazo_descarte.clear()
	
	#El enemigo decide su primera acción
	planear_proxima_accion()
	
	repartir_cartas(4)
	actualizar_ui()
	
	# Conectamos los botones (con chequeo para evitar los errores rojos)
	if not btn_carta_1.pressed.is_connected(_on_btn_carta_1_pressed):
		btn_carta_1.pressed.connect(_on_btn_carta_1_pressed)
		
	if not btn_carta_2.pressed.is_connected(_on_btn_carta_2_pressed):
		btn_carta_2.pressed.connect(_on_btn_carta_2_pressed)
	btn_carta_1.visible = false
	btn_carta_2.visible = false
	
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
	
	#SI HAY UN BUFF ACTIVO, LA CARTA NACE ACTUALIZADA
	#if nueva_carta.has_method("actualizar_buffs"):
	#	nueva_carta.actualizar_buffs(buff_dano_basico_actual)
	#NO LO BORRE POR LAS DUDAS
func repartir_cartas(cantidad):
	for i in range(cantidad):
		robar_una_carta()

func _jugar_carta(nodo, datos):
	#Calculamos el costo de la carta
	var coste_real = datos.coste
	
	#Si la barra está llena y es una carta de Ataque, es gratis
	if GameManager.esta_en_descontrol and datos.tipo == "Ataque":
		coste_real = 0
		print("¡Frenesí Biológico! Ataque a coste 0.")
	
	# Cambiamos datos.coste por coste_real en la validación y resta
	if energia_actual >= coste_real:
		energia_actual -= coste_real
		
		#verificamos si ya jugamos 1 carta, le sumamos 1
		var es_primera_carta = (cartas_jugadas_este_turno == 0)
		cartas_jugadas_este_turno += 1
		
		#PODERES PERMANENTES (Solo se aplican 1 vez)
		if datos.es_poder_permanente:
			buff_dano_basico_actual += datos.buff_dano_basico
			energia_extra_base += datos.energia_base_extra
			cura_por_ataque_actual += datos.cura_por_ataque
			
			# AVISARLE A LAS CARTAS DE LA MANO QUE CAMBIEN
			#for carta_en_mano in mano_visual.get_children():
			#	if carta_en_mano.has_method("actualizar_buffs"):
			#		carta_en_mano.actualizar_buffs(buff_dano_basico_actual)
			#POR LAS DUDAS NO LO BORRE
			
		energia_actual += datos.ganancia_energia
		if es_primera_carta:
			energia_actual += datos.energia_si_primera
		
		if datos.curacion > 0:
			RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + datos.curacion, 0, RunManager.run_data.vida_maxima)
			
		if datos.dano_a_jugador > 0:
			RunManager.run_data.vida_jugador -= datos.dano_a_jugador
			if RunManager.run_data.vida_jugador <= 0:
				mostrar_resultado(false)
				return
		
		# 1. Aplicar DAÑO al enemigo
		if datos.daño > 0:
			var dano_a_realizar = datos.daño
			
			#Efecto de cartas
			if enemigo_veneno_turnos > 0:
				dano_a_realizar += datos.dano_extra_veneno
			if mano_visual.get_child_count() == 1:
				dano_a_realizar += datos.dano_extra_ultima_carta
			if datos.name == "Golpe de Chatarra" or datos.name == "Instinto de Presa":
				dano_a_realizar += buff_dano_basico_actual
			
			# efecto de evento doble daño
			if RunManager.run_data.bonus_doble_dano:
				dano_a_realizar*= 2 #aplica el multiplicador de daño x2
				RunManager.run_data.bonus_doble_dano = false
				print ("Doble daño aplicado y agotado")
			
			if escudo_enemigo_actual >= dano_a_realizar:
				escudo_enemigo_actual -= dano_a_realizar # El escudo absorbe todo
			else:
				var dano_sobrante = dano_a_realizar - escudo_enemigo_actual
				escudo_enemigo_actual = 0 # Rompiste su escudo
				barra_vida_enemigo.value -= dano_sobrante # Le restás a su vida
			
			if cura_por_ataque_actual > 0:
				RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + cura_por_ataque_actual, 0, RunManager.run_data.vida_maxima)
			
		# 2. Aplicar ESCUDO a ti misma
		if datos.escudo > 0:
			if datos.es_poder_permanente:
				# INYECCIÓN DE ADRENALINA: Se convierte en un motor fijo por turno
				escudo_fijo_por_turno += datos.escudo
				escudo_actual += datos.escudo # Te da los primeros 10 en este mismo turno
				print("Motor de escudo activado: +", datos.escudo, " por turno.")
			else:
				# Escudos normales (Espuma Selladora, Escudo de Emergencia)
				var escudo_final = datos.escudo - RunManager.run_data.penalizacion_escudo
				escudo_actual += max(0,escudo_final)
			
			#GUARDAMOS EL MÁXIMO HISTÓRICO DEL TURNO
			if escudo_actual > escudo_maximo_jugador:
				escudo_maximo_jugador = escudo_actual
			
		if datos.retiene_escudo:
			turnos_retener_escudo = 1 # 1 significa: "Sobrevive hasta el PRÓXIMO turno" # Espuma Selladora (dura 1 turno)
		
		# --- APLICAR ESTADOS AL ENEMIGO ---
		if datos.aplica_veneno > 0:
			enemigo_veneno_dano += datos.aplica_veneno
			enemigo_veneno_turnos = datos.turnos_veneno
		if datos.aplica_debilidad > 0:
			enemigo_debil_turnos += datos.aplica_debilidad
			
			planear_proxima_accion()
		#Aturdir al enemigo
		if datos.aturde_enemigo:
			enemigo_aturdido = true
			print("¡Aturdiste al enemigo!")
			
			# FEEDBACK VISUAL ENMIGO ATURDIDO
			# Forzamos el cartel de intención al instante
			label_intencion.text = "😵 Aturdido"
			
			
		# 3. Habilidad de ROBAR cartas
		#if datos.roba > 0:
		#	print("Usaste una habilidad. Robando ", datos.roba, " carta(s) extra.")
		#	repartir_cartas(datos.roba) # Llama a la función que ya tenés para sacar del mazo
		
		var total_a_robar = datos.roba
		if datos.robo_si_vida_baja > 0 and RunManager.run_data.vida_jugador < 50:
			total_a_robar += datos.robo_si_vida_baja
			
		if total_a_robar > 0:
			repartir_cartas(total_a_robar)
		
		# La carta jugada va al descarte
		if not datos.es_poder_permanente:
			mazo_descarte.append(datos)# Las normales van al descarte
		else:
			print("Carta de Poder consumida por el resto del combate.")	
		
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
	label_energia.text = str(energia_actual) + "/3"
	# Muestra cuántas cartas quedan para robar (Mazo a la izquierda)
	label_mazo.text = "Mazo: " + str(mazo_principal.size())
	# Muestra cuántas cartas ya usaste o descartaste (Descarte a la derecha)
	label_descarte.text = "Descarte: " + str(mazo_descarte.size())
	
	#Escudo
	if escudo_maximo_jugador > 0:
		label_escudo.text = "🛡️ Escudo: " + str(escudo_actual) + " / " + str(escudo_maximo_jugador)
	else:
		label_escudo.text = "🛡️ Escudo: 0"
	
	if enemigo_aturdido:
		label_intencion.text = "😵 Aturdido"
	
	elif proxima_accion_enemigo == 1:
		label_intencion.text = "🛡️ " + str(escudo_enemigo_actual) + " / " + str(escudo_maximo_enemigo)
	
	
	#label_escudo.text = "Escudo: " + str(escudo_actual)
	#label_escudo_enemigo.text = "Escudo Enemigo: " + str(escudo_enemigo_actual)
	
	#veneno enemigo
	if enemigo_veneno_turnos > 0:
		label_veneno_enemigo.text = "🧪" + str(enemigo_veneno_dano) + " [Turno: " + str(enemigo_veneno_turnos) + " ]"
		label_veneno_enemigo.visible = true
	else:
		label_veneno_enemigo.visible = false # Se esconde si no está bajo el efecto
	
	#barras de salud
	barra_vida_jugador.value = RunManager.run_data.vida_jugador
	
	#Texto de vida
	# Jugador: Mostramos Vida Actual / Vida Máxima (ej. "45/100")
	label_vida_jugador.text = str(int(RunManager.run_data.vida_jugador)) + "/" + str(int(RunManager.run_data.vida_maxima))
	
	# Enemigo: Mostramos Vida Actual / Vida Máxima
	label_vida_enemigo.text = str(int(barra_vida_enemigo.value)) + "/" + str(int(barra_vida_enemigo.max_value))
	
	#  ESCÁNER DINÁMICO DE CARTAS 
	# Contamos cuántas cartas "vivas" hay en la mano (ignorando las que se están borrando)
	var cartas_reales = 0
	for c in mano_visual.get_children():
		if not c.is_queued_for_deletion():
			cartas_reales += 1
			
	# Le pasamos la información fresca a todas las cartas
	for carta in mano_visual.get_children():
		if not carta.is_queued_for_deletion() and carta.has_method("actualizar_buffs"):
			carta.actualizar_buffs(buff_dano_basico_actual, cartas_reales)
	
func turno_del_enemigo():
	print("Turno del enemigo...")
	escudo_enemigo_actual = 0 
	escudo_maximo_enemigo = 0
	
	escudo_enemigo_actual = 0
	
	# VENENO (Se aplica antes de que el enemigo haga nada)
	if enemigo_veneno_turnos > 0:
		barra_vida_enemigo.value -= enemigo_veneno_dano
		enemigo_veneno_turnos -= 1
		print("El enemigo sufre ", enemigo_veneno_dano, " por veneno.")
		
		actualizar_ui()
		
		if barra_vida_enemigo.value <= 0:
			mostrar_resultado(true)
			return
	#CHEQUEO DE ATURDIMIENTO DEL ENEMIGO
	if enemigo_aturdido:
		print("El enemigo está aturdido y pierde su turno.")
		label_intencion.text = "😵 Aturdido"
		enemigo_aturdido = false # Se cura del stun para su próximo turno
		
		# Planea qué hará en el próximo turno y te devuelve el control a vos
		planear_proxima_accion()
		actualizar_ui()
		await get_tree().create_timer(1.2).timeout
		iniciar_nuevo_turno_jugador()
		return
	
	# Leemos qué tipo de enemigo es (si no tiene tipo, asumimos "debil")
	var tipo = GameManager.enemigo_actual_datos.get("tipo_enemigo", "debil")
	var dano_enemigo = 0
	
	#escudo_enemigo_actual = 0
	
	# Usamos la acción que ya planeó antes
	var decision = proxima_accion_enemigo
	
	match tipo:
		"debil", "debil2":
			# IA DEL ENEMIGO DÉBIL 
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El enemigo débil ataca por: ", dano_enemigo)
			elif decision == 1:
				#escudo_enemigo_actual += 8
				print("El enemigo débil se queda en guardia.")
			else: 
				#Ejecuta el poder
				dano_enemigo = GameManager.enemigo_actual_datos["daño_poder"]
				print("El enemigo débil usa Poder por: ", dano_enemigo)
		
		"medio", "medio2":
			# IA DEL ENEMIGO MEDIO
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El enemigo medio ataca por: ", dano_enemigo)
			elif decision == 1:
				#escudo_enemigo_actual += 15 # Se pone más escudo que el débil
				print("El enemigo medio se queda en guardia.")
			else:
				dano_enemigo = GameManager.enemigo_actual_datos["daño_poder"]
				print("El enemigo medio usa Poder por: ", dano_enemigo, " y te ATURDE!")
				jugador_aturdido = true
		
		"jefe", "jefe2":
			# IA DEL JEFE (Ataques especiales)
			if decision == 0:
				dano_enemigo = GameManager.enemigo_actual_datos["Daño_fijo"]
				print("El Jefe ataca normal por: ", dano_enemigo)
			elif decision == 1:
				#escudo_enemigo_actual += 25
				print("El Jefe se queda en guardia detrás de su mega escudo.")
			else:
				# ATAQUE ESPECIAL
				dano_enemigo = GameManager.enemigo_actual_datos["daño_especial"]
				print("¡EL JEFE USA SU ATAQUE ESPECIAL por: ", dano_enemigo, "y te aturde")
				jugador_aturdido = true
				
				
	# REDUCCIÓN DE DAÑO POR DEBILIDAD (Niebla Tóxica)
	if dano_enemigo > 0 and enemigo_debil_turnos > 0:
		dano_enemigo = int(dano_enemigo / 2)
		enemigo_debil_turnos -= 1
		print("Enemigo debilitado, daño reducido a: ", dano_enemigo)
				
# --- LÓGICA DE RECIBIR EL DAÑO (Es igual para todos) ---
	if dano_enemigo > 0:
		if escudo_actual >= dano_enemigo:
			escudo_actual -= dano_enemigo
			print("Tu escudo absorbió todo el golpe.")
		else:
			var dano_restante = dano_enemigo - escudo_actual
			escudo_actual = 0
			RunManager.run_data.vida_jugador -= dano_restante
			print("Daño recibido tras escudo: ", dano_restante)
			
		# --- ACÁ AGREGAMOS LA CONDICIÓN DE DERROTA ---
		if RunManager.run_data.vida_jugador <= 0:
			print("¡Derrota! Tu vida llegó a 0.")
			mostrar_resultado(false) # Llamamos al panel en lugar de cambiar de escena
			return # El return es crucial: evita que el código siga y te pase de turno estando muerta
				
		# reset de escudo para los eventos
		if RunManager.run_data.penalizacion_escudo >0: 
			RunManager.run_data.penalizacion_escudo = 0
 
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
	
	# 1. Reseteamos el color por defecto (para que vuelva a la normalidad si se le pasa el efecto)
	label_intencion.remove_theme_color_override("font_color")
	
	# --- ATAQUE NORMAL ---
	if proxima_accion_enemigo == 0:
		var dano = GameManager.enemigo_actual_datos.get("Daño_fijo", 0)
		
		# Si está debilitado, calculamos la mitad y cambiamos color
		if enemigo_debil_turnos > 0:
			var dano_reducido = int(dano / 2)
			label_intencion.text = "⚔️" + str(dano_reducido)
			label_intencion.add_theme_color_override("font_color", Color.MEDIUM_TURQUOISE)
		else:
			label_intencion.text = "⚔️" + str(dano)
	
	#	Escudo
	elif proxima_accion_enemigo == 1:
		# Calculamos cuánto escudo se va a poner según quién sea
		var cantidad_escudo = 0
		#MAPA 1
		if tipo == "debil":
			cantidad_escudo = 8
		elif tipo == "medio":
			cantidad_escudo = 15
		elif tipo == "jefe":
			cantidad_escudo = 25
		
		#MAPA2
		elif tipo == "debil2": cantidad_escudo = 10
		elif tipo == "medio2": cantidad_escudo = 16
		elif tipo == "jefe2": cantidad_escudo = 26
		
		escudo_enemigo_actual = cantidad_escudo
		escudo_maximo_enemigo = cantidad_escudo
		label_intencion.text = "🛡️" + str(escudo_enemigo_actual) + " / " + str(escudo_maximo_enemigo)
	
	#Es la acción de PODER
	else:
		if tipo == "medio" or tipo == "medio2":
			var dano_poder = GameManager.enemigo_actual_datos.get("daño_poder", 0)
			if enemigo_debil_turnos > 0 and dano_poder > 0:
				var dano_reducido = int(dano_poder / 2)
				label_intencion.text = "🔥" + str(dano_reducido) + " + 😵 Aturdir"
				label_intencion.add_theme_color_override("font_color", Color.MEDIUM_TURQUOISE)
			else:
				label_intencion.text = "🔥" + str(dano_poder) + " + 😵 Aturdir"
		
		elif tipo == "jefe" or tipo == "jefe2":
			# El jefe tiene una variable distinta llamada "daño_especial"
			var dano_especial = GameManager.enemigo_actual_datos.get("daño_especial", 0)
			if enemigo_debil_turnos > 0 and dano_especial > 0:
				var dano_reducido = int(dano_especial / 2)
				label_intencion.text = "🔥" + str(dano_reducido) + " + 😵 Aturdir"
				label_intencion.add_theme_color_override("font_color", Color.MEDIUM_TURQUOISE)
			else:
				label_intencion.text = "🔥" + str(dano_especial) + " + 😵 Aturdir"
			
		else:
			# Para el enemigo débil
			var dano_poder = GameManager.enemigo_actual_datos.get("daño_poder", 0)
			if enemigo_debil_turnos > 0 and dano_poder > 0:
				var dano_reducido = int(dano_poder / 2)
				label_intencion.text = "🔥: " + str(dano_reducido)
				label_intencion.add_theme_color_override("font_color", Color.MEDIUM_TURQUOISE)
			else:
				label_intencion.text = "🔥: " + str(dano_poder)

func iniciar_nuevo_turno_jugador():
	print("--- Inicio de tu turno ---")
	
	cartas_jugadas_este_turno = 0
	
	#Tu escudo baja a 0 ANTES de chequear si estás aturdida
	if turnos_retener_escudo > 0:
		print("Tu escudo se mantiene por la Espuma Selladora.")
		turnos_retener_escudo -= 1
		escudo_maximo_jugador = escudo_actual 
	else:
		escudo_actual = 0
		escudo_maximo_jugador = 0
	
	#cHEQUEO DE STUN/ATURNIR
	if jugador_aturdido:
		print("¡Estás aturdida! Pierdes tu turno.")
		label_escudo.text = "😵 Aturdido"
		jugador_aturdido = false # Te curas del stun para el próximo
		
		# 2. Esperamos 1.5 segundos para que leas el aviso
		await get_tree().create_timer(1.5).timeout
		
		# 3. Devolvemos el texto a la normalidad mostrando tu escudo actual
		label_escudo.text = "🛡️" + str(escudo_actual)

		terminar_turno() # Le devuelve el turno al enemigo
		return # Crucial: sale de la función para no darte cartas ni energía
	
	es_turno_jugador = true # Abrimos el candado
	
	# riesgo del frenesi (pierdo vida)
	if GameManager.esta_en_descontrol:
		RunManager.run_data.vida_jugador -= 5
		print("El virus te consume: -5 PV. Vida restante: ", RunManager.run_data.vida_jugador)
		if RunManager.run_data.vida_jugador <=0:
			mostrar_resultado(false)
			return
		
	# Te inyectamos el escudo automático de la Adrenalina
	if escudo_fijo_por_turno > 0:
		escudo_actual += escudo_fijo_por_turno
		escudo_maximo_jugador += escudo_fijo_por_turno
		print("Adrenalina: Regeneras ", escudo_fijo_por_turno, " de escudo.")
		
	# LÓGICA METABOLISMO ACELERADO (energia)
	energia_actual = 3 + energia_extra_base
	
	# 3. Robás tu nueva mano (en tu caso, 4 cartas como tenés configurado)
	repartir_cartas(4)
	
	# 4. Actualizamos todo visualmente
	actualizar_ui()


	
func _on_button_pressed() -> void:
	if es_turno_jugador: # Solo funciona si es tu turno
		terminar_turno()

# Pantalla de victoria/Derrota
func mostrar_resultado(gano: bool):
	# reset de eventos
	RunManager.run_data.penalizacion_escudo = 0
	RunManager.run_data.bonus_doble_dano = false
	victoria = gano
	panel_final.visible = true
	btn_carta_1.visible = false 
	btn_carta_2.visible = false 
	boton_final.visible = true
	if gano:
		var tipo_enemigo = GameManager.enemigo_actual_datos.get("tipo_enemigo", "debil")
		
		# Recuperamos vida
		#RunManager.run_data.vida_jugador = clamp(RunManager.run_data.vida_jugador + 8,0, RunManager.run_data.vida_maxima)
		#Esto lo hacen los corazones de coral
		#Redusimos el frenesi
		var reduccion = GameManager.enemigo_actual_datos.get("reduccion_frenesi",15)
		GameManager.actualizar_frenesi(-reduccion)
		
		# ANOTAMOS AL ENEMIGO EN LA LISTA NEGRA
		var nombre_enemigo = GameManager.enemigo_actual_datos.get("nombre_en_escena", "")
		if nombre_enemigo != "" and not nombre_enemigo in GameManager.enemigos_derrotados:
			GameManager.enemigos_derrotados.append(nombre_enemigo)
		
		#Chequeamos si ganamos el juego
		if GameManager.enemigos_derrotados.size() >= GameManager.total_enemigos_en_mapa:
			label_resultado.text = "¡VICTORIA TOTAL! \n Eliminaste la amenaza del mapa."
			boton_final.text = "Volver a Jugar"
		else:
			# Agregamos este 'if' para separar al débil de los demás
			if tipo_enemigo == "debil" or tipo_enemigo == "debil2":
				label_resultado.text = "¡EXPLORACIÓN EXITOSA! \n El enemigo fue derrotado"
				boton_final.text = "Volver al Mapa"
			
			#SI ES EL JEFE FINAL
			elif tipo_enemigo == "jefe" or tipo_enemigo == "jefe2":
				label_resultado.text = "¡AMENAZA ELIMINADA! \n Reclama tu recompensa de élite:"
				boton_final.visible = false # Ocultamos el botón de volver hasta que elija
				btn_carta_1.visible = true  # Mostramos el primer slot
				btn_carta_2.visible = false # ¡OCULTAMOS el segundo slot porque es una sola carta!
				
				# Limpiamos cartas visuales anteriores por seguridad
				for nodo in btn_carta_1.get_children(): nodo.queue_free()
				for nodo in btn_carta_2.get_children(): nodo.queue_free()
				btn_carta_1.text = ""
				btn_carta_2.text = ""
				
				# Cargamos la carta de Stun directamente desde tus archivos
				# (Asegurate de que esta ruta coincida con el nombre y carpeta de tu .tres)
				carta_opcion_1 = preload("uid://c235mt3xp01k5")
				
				# Instanciamos la carta en el botón 1
				var visual_carta_1 = molde_carta.instantiate()
				btn_carta_1.add_child(visual_carta_1)
				visual_carta_1.configurar(carta_opcion_1)
				visual_carta_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
				visual_carta_1.position = Vector2.ZERO
			else:
				# Solo entra acá si es Enemigo Medio 1 y 2
				label_resultado.text = "¡AMENAZA ELIMINADA! \n Elige una recompensa:"
				boton_final.visible = false # Ocultamos el "Volver al Mapa"
				btn_carta_1.visible = true  # Mostramos las cartas
				btn_carta_2.visible = true  
				
				# Pedimos las cartas al RunManager
				var opciones = RunManager.obtener_opciones_recompensa()
				carta_opcion_1 = opciones[0]
				carta_opcion_2 = opciones[1]
				
				# Limpiamos cartas visuales anteriores (por si peleaste antes)
				for nodo in btn_carta_1.get_children():
					nodo.queue_free()
				for nodo in btn_carta_2.get_children():
					nodo.queue_free()
				
				# QUITAMOS EL TEXTO
				btn_carta_1.text = ""
				btn_carta_2.text = ""
				
				# --- INSTANCIAMOS LA CARTA 1 ---
				var visual_carta_1 = molde_carta.instantiate()
				btn_carta_1.add_child(visual_carta_1) # La metemos adentro del botón
				visual_carta_1.configurar(carta_opcion_1) # Le pasamos los datos
				
				# TRUCO DE GODOT: Hacemos que la carta visual ignore el mouse 
				# para que el clic pase de largo y active el botón que está atrás
				visual_carta_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				# --- INSTANCIAMOS LA CARTA 2 ---
				var visual_carta_2 = molde_carta.instantiate()
				btn_carta_2.add_child(visual_carta_2)
				visual_carta_2.configurar(carta_opcion_2)
				visual_carta_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				# Ajustamos la posición para que queden centradas en el botón (opcional)
				visual_carta_1.position = Vector2.ZERO
				visual_carta_2.position = Vector2.ZERO
	else:
		label_resultado.text = "SISTEMAS CRÍTICOS... \n El enemigo te gano fracasado"
		boton_final.text = "Reintentar desde el Inicio"

	actualizar_ui()

# CONECTÁ EL BOTÓN DEL PANEL A ESTA FUNCIÓN:
func _on_button_final_pressed() -> void:
	# Apagamos el interruptor antes de salir
	GameManager.en_combate = false
	if victoria:
		if GameManager.enemigos_derrotados.size() >= GameManager.total_enemigos_en_mapa:
			RunManager.run_data.vida_jugador = RunManager.run_data.vida_maxima
			GameManager.posicion_jugador_en_mapa = Vector2.ZERO 
			GameManager.enemigos_derrotados.clear() # Limpiamos la lista negra
			GameManager.bloques_destruidos.clear() 
			GameManager.eventos_completados.clear()
			get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")
		
		else:
			# genera el loot + cierra combate
			GameManager.finalizar_combate(true)
			
			
	else:
		# Si perdió: reinicia vida y vuelve al inicio
		#RunManager.run_data.vida_jugador = RunManager.run_data.vida_maxima
		#RunManager.run_data.frenesi_actual = 0.0
		#GameManager.esta_en_descontrol = false
		#GameManager.bloques_destruidos.clear()
		#GameManager.eventos_completados.clear()
		#GameManager.enemigos_derrotados.clear()
		# Reseteamos la posición para que aparezca en el spawn inicial
		#GameManager.posicion_jugador_en_mapa = Vector2.ZERO 
		GameManager.morir_definitivamente()
		#get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")


func _on_btn_carta_1_pressed() -> void:
	RunManager.agregar_carta(carta_opcion_1)
	print("Se añadió la carta: ", carta_opcion_1.name)
	_on_button_final_pressed()


func _on_btn_carta_2_pressed() -> void:
	RunManager.agregar_carta(carta_opcion_2)
	print("Se añadió la carta: ", carta_opcion_2.name)
	_on_button_final_pressed()
