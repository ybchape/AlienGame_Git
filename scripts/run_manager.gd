extends Node

# --- LÍMITES DEL MAZO ---
const MAZO_MINIMO = 5
const MAZO_MAXIMO = 15

# Preload de recursos cartas
@onready var SET_DE_CARTAS: Dictionary[String,RecursoCarta] = {
	ANALISIS_BIOMA = preload("uid://bi33x01ts37m7"),
	ESCUDO_EMERGENCIA = preload("uid://c7b1hkdue8x06"),
	GOLPE_CHATARRA = preload("uid://buccpoqsgoy3v"),
	INSTINTO_PRESA = preload("uid://djby3b8r4clho"),
	ESCUDO_EMERGENCIA_2 = preload("uid://g6vea8wrg53m")
}

# Run
var loop_actual: int = 1
# Cartas
var mazo_actual: Array = []

# Jugador
var vida_jugador: float = 100
var vida_maxima: float = 100
var frenesi_actual: float = 0.0
var frenesi_maximo: float = 100.0

# Modificadores permanentes
var mejoras_permanentes: Array = [] # Todavía no tenemos creo / cuando se defina como, hablar sobre como estructurarlos

# Modificadores Temporales
var bonus_doble_dano = false
var penalizacion_escudo: int = 0 # var para el efecto de escudo en los eventos
var penalizacion_energia: int = 0 # var para la penalizacion de energia en eventos


func _ready() -> void:
	inicializar_run()

func inicializar_run():
	#El mazo inicial que va a tener el jugador
	mazo_actual = [
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
	vida_jugador = 100
	vida_maxima = 100
	frenesi_actual = 0.0
	frenesi_maximo = 100.0
	mejoras_permanentes = []
	penalizacion_escudo = 0
	bonus_doble_dano = false
	penalizacion_energia = 0
	loop_actual = 1

func pasar_al_siguiente_loop():
	loop_actual += 1
	# Limpiar los modificadores temporales que sean necesarios
	reiniciar_modificadores_temporales()

func reiniciar_modificadores_temporales():
	bonus_doble_dano = false # ?
	penalizacion_escudo = 0 # ?
	penalizacion_energia = 0 # ?

func agregar_carta(carta: RecursoCarta):
	mazo_actual.append(carta)

func eliminar_carta(indice: int):
	mazo_actual.remove_at(indice)
	

# A futuro guardar y cargar partida
func guardar_estado_de_run():
	pass

func cargar_estado_de_run():
	pass
