class_name RunData
extends Resource

# Run
@export var loop_actual: int = 1
# Cartas
@export var mazo_actual: Array = []

# Jugador
@export var vida_jugador: float = 100
@export var vida_maxima: float = 100
@export var frenesi_actual: float = 0.0
@export var frenesi_maximo: float = 100.0

# Modificadores permanentes
@export var mejoras_permanentes: Array = [] # Todavía no tenemos creo / cuando se defina como, hablar sobre como estructurarlos

# Modificadores Temporales
@export var bonus_doble_dano = false
@export var penalizacion_escudo: int = 0 # var para el efecto de escudo en los eventos
@export var penalizacion_energia: int = 0 # var para la penalizacion de energia en eventos
