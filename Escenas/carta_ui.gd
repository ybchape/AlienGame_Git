extends TextureButton

var datos_carta = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func configurar_diseño(datos: Dictionary):
	# 'datos' es el diccionario que viene del GameManager
	datos_carta = datos 
	# El nombre que pusiste en el diccionario (ej: "Golpe de Chatarra")
	# debe ser igual al nombre del archivo en tu carpeta de Arte.
	
	var ruta = "res://Assets/cartas/" + datos["nombre"] + ".jpg"
	if FileAccess.file_exists(ruta):
		# Godot carga la misma imagen para todas las cartas que tengan ese nombre
		texture_normal = load(ruta)
	else:
		print("Error: No existe el archivo ", ruta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
