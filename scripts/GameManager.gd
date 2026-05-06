extends Node
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var frenesi_actual: float = 0.0
var vida_jugador: int = 80


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
	{"nombre": "Instinto de Presa", "tipo": "Ataque", "coste": 2, "daño": 10, "escudo": 0, "roba": 0},
	{"nombre": "Análisis de Bioma", "tipo": "Capacidad", "coste": 0, "daño": 0, "escudo": 0, "roba": 1}
]

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(valor):
	frenesi_actual = clamp(frenesi_actual + valor, 0, 100)
	print("Frenesí biológico en: ", frenesi_actual)
	
 # Funcion global para cavar/romper bloques
func romper_bloque(player_position: Vector2, direccion: String):
	print("Player cavando desde:", player_position)
	print ("Dirección", direccion)
	
