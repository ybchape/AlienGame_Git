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
	ESCUDO_EMERGENCIA_2 = preload("uid://g6vea8wrg53m")
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
