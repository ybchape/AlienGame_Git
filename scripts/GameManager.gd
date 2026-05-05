extends Node
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var frenesi_actual: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(valor):
	frenesi_actual = clamp(frenesi_actual + valor, 0, 100)
	print("Frenesí biológico en: ", frenesi_actual)
	
 # Funcion global para cavar/romper bloques
func romper_bloque(player_position: Vector2, direccion: String):
	print("Player cavando desde:", player_position)
	print ("Dirección", direccion)
	
