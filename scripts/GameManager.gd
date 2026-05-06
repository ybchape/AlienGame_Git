extends Node
#Guarda los datos del enemigo que tocaste para que la pantalla de combate sepa qué mostrar
var enemigo_actual_datos = {}
var frenesi_actual: float = 0.0

func _ready() -> void:
	pass # Replace with function body.

# Función para que cualquier objeto pueda alterar el frenesí
func actualizar_frenesi(valor):
	frenesi_actual = clamp(frenesi_actual + valor, 0, 100)
	print("Frenesí biológico en: ", frenesi_actual)
	
 # Funcion global para cavar/romper bloques
func romper_bloque(player_position: Vector2, direccion: String):
	var espacio = get_tree().current_scene
	# Busca objetos del grupo "bloques"
	for bloque in espacio.get_tree().get_nodes_in_group("bloques"):
		# Si hay uno cerca del player a menos de 20 px lo elimina e imprime bloque roto.
		var distancia = bloque.global_position.distance_to(player_position)
		if distancia < 20:
			print ("Bloque roto")
			bloque.queue_free()
			return
		print ("No hay bloque cerca")

	#print("Player cavando desde:", player_position)
	#print ("Dirección", direccion)
	
