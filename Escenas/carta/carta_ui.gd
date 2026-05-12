extends TextureButton

var datos_carta = {}
var arrastrando = false
var mouse_offset = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func configurar(datos: Dictionary):
	# 'datos' es el diccionario que viene del GameManager
	datos_carta = datos 
	# El nombre que pusiste en el diccionario (ej: "Golpe de Chatarra")
	# debe ser igual al nombre del archivo en tu carpeta de Arte.
	var ruta = "res://assets/cartas/" + datos["nombre"] + ".jpg"
	if FileAccess.file_exists(ruta):
		# Godot carga la misma imagen para todas las cartas que tengan ese nombre
		texture_normal = load(ruta)
	else:
		print("Falta el arte para: ", datos["nombre"])
# Esta función de Godot detecta todo lo que haces con el mouse sobre el botón
func _gui_input(event: InputEvent) -> void:
	# 1. Detectar el clic izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# EMPEZAR A ARRASTRAR
			arrastrando = true
			# Guardamos la distancia entre el mouse y la esquina de la carta para que no salte
			mouse_offset = global_position - get_global_mouse_position()
			top_level = true 
			z_index = 10
		else:
			# SOLTAR EL CLIC
			arrastrando = false
			z_index = 0
			if global_position.y < 350: 
				get_parent().get_parent()._jugar_carta(self, datos_carta)
			else:
				volver_a_mano()
			
			# Si soltamos la carta en la mitad de arriba de la pantalla (ej Y menor a 350)
			if global_position.y < 350: 
				# Le avisamos a la escena de combate que queremos jugarla
				get_parent().get_parent()._jugar_carta(self, datos_carta)
			else:
				# Si la soltamos muy abajo, se arrepiente y vuelve a la mano
				volver_a_mano()
	if event is InputEventMouseMotion and arrastrando:
		# Sumamos el offset para que el arrastre sea fluido y desde donde hiciste clic
		global_position = get_global_mouse_position() + mouse_offset

# Función para que la carta vuelva a su lugar
func volver_a_mano():
	top_level = false # Al volver a pegarse, el HBoxContainer la reacomoda sola automáticamente

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
