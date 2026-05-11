extends CanvasLayer

var datos_del_evento

func configurar(data):
	datos_del_evento = data
	$Panel/Titulo.text = data.titulo
	$Panel/Descripcion.text = data.texto
	$Panel/BotonA.text = data.op_a_txt
	$Panel/BotonB.text = data.op_b_txt
	

func _on_boton_a_pressed() -> void:
	GameManager.procesar_eleccion(datos_del_evento.id, "A")
	queue_free() # close ventana

func _on_boton_b_pressed() -> void:
	GameManager.procesar_eleccion(datos_del_evento.id, "B")
	queue_free() # close ventana
