extends Node

# --- LÍMITES DEL MAZO ---
const MAZO_MINIMO = 5
const MAZO_MAXIMO = 15

# Preload de recursos cartas
@onready var SET_DE_CARTAS: Dictionary[String, RecursoCarta] = {
	ANALISIS_BIOMA = preload("uid://bi33x01ts37m7"),
	ESCUDO_EMERGENCIA = preload("uid://c7b1hkdue8x06"),
	GOLPE_CHATARRA = preload("uid://buccpoqsgoy3v"),
	INSTINTO_PRESA = preload("uid://djby3b8r4clho"),
	
	
	#Nuevas cartas
	GOLPE_DE_PRECISION = preload("uid://drry24tyuk0r4"),
	#TAJO_INFECTADO = preload("uid://d4dfy563sxeay"),
	#ESPUMA_SELLADORA = preload("uid://dgd7526w7vtu5"),
	#INYECCION_DE_ADRENALINA = preload("uid://cvx33pnx04v40"),
	#SOBRECARGA_DE_NUCLEA = preload("uid://cbimiemxdu6qf"), #TE DA 2 DE ENERGUIA PERO TE QUITA 3 DE VIDA.
	#CORTE_QUIRURGICO = preload("uid://dpuo3hofeasu7"),
	BIO_MUTACION = preload("uid://cafln321vsbki")
}

var run_data: RunData

func _ready() -> void:
	inicializar_run()

func inicializar_run():
	run_data = RunData.new()
	#El mazo inicial que va a tener el jugador
	run_data.mazo_actual = [
		SET_DE_CARTAS.GOLPE_CHATARRA,
		SET_DE_CARTAS.GOLPE_CHATARRA,
		SET_DE_CARTAS.GOLPE_CHATARRA,
		SET_DE_CARTAS.GOLPE_CHATARRA,
		SET_DE_CARTAS.ESCUDO_EMERGENCIA,
		SET_DE_CARTAS.ESCUDO_EMERGENCIA,
		SET_DE_CARTAS.ESCUDO_EMERGENCIA,
		SET_DE_CARTAS.ESCUDO_EMERGENCIA,
		SET_DE_CARTAS.INSTINTO_PRESA,
		SET_DE_CARTAS.ANALISIS_BIOMA
	]
	run_data.vida_jugador = 100
	run_data.vida_maxima = 100
	run_data.frenesi_actual = 0.0
	run_data.frenesi_maximo = 100.0
	run_data.mejoras_permanentes = []
	run_data.penalizacion_escudo = 0
	run_data.bonus_doble_dano = false
	run_data.penalizacion_energia = 0
	run_data.loop_actual = 1

func pasar_al_siguiente_loop():
	run_data.loop_actual += 1
	# Limpiar los modificadores temporales que sean necesarios
	reiniciar_modificadores_temporales()

func reiniciar_modificadores_temporales():
	run_data.bonus_doble_dano = false # ?
	run_data.penalizacion_escudo = 0 # ?
	run_data.penalizacion_energia = 0 # ?

func agregar_carta(carta: RecursoCarta):
	run_data.mazo_actual.append(carta)

func eliminar_carta(indice: int):
	run_data.mazo_actual.remove_at(indice)
	

# A futuro guardar y cargar partida usando directamente el recurso en la variable run_data
func guardar_estado_de_run():
	var error = ResourceSaver.save(run_data, "user://save_game.tres") # si cambiamos el formato .tres por .bin el archivo se guarda en formato binario (para dificultar la lectura)
	if error == OK:
		print("Game saved successfully!")
	else:
		print("Failed to save game. Error code: ", error)
	pass

func cargar_estado_de_run():
	var path = "user://save_game.tres"
	if ResourceLoader.exists(path):
		var datos_guardados: RunData = load(path) as RunData
		if datos_guardados:
			run_data = datos_guardados
			

#EMPIEZA CHAPE
# Función para que la pantalla de victoria pida 2 opciones exclusivas de botín
func obtener_opciones_recompensa() -> Array:
	var opciones_disponibles = []
	
	# Cartas que NO queremos que salgan de premio
	var cartas_basicas = [
		SET_DE_CARTAS.GOLPE_CHATARRA, 
		SET_DE_CARTAS.ESCUDO_EMERGENCIA, 
		SET_DE_CARTAS.ANALISIS_BIOMA, 
		SET_DE_CARTAS.INSTINTO_PRESA
	]
	
	# Guardamos solo las cartas nuevas y que no estan en el mazo
	for carta in SET_DE_CARTAS.values():
		if not carta in cartas_basicas and not carta in run_data.mazo_actual:
			opciones_disponibles.append(carta)
	
	# Mezclamos las cartas premium
	opciones_disponibles.shuffle() 
	
	# Seguro anticrasheos por si hay menos de 2 cartas nuevas creadas
	if opciones_disponibles.size() < 2:
		print("ADVERTENCIA: Faltan cartas nuevas. Usando básicas de relleno.")
		var relleno = SET_DE_CARTAS.values()
		relleno.shuffle()
		return [relleno[0], relleno[1]]
	
	# Devuelve las dos opciones
	return [opciones_disponibles[0], opciones_disponibles[1]]
