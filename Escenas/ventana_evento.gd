extends CanvasLayer

var datos_del_evento

func configurar(data):
	datos_del_evento = data
	$Titulo.text = data.titulo
	$Descricpion.text = data.texto
	$BotonA.text = data.op_a_txt
	$BotonB.text = data.op_b_txt

func _on_boton_a_pressed() -> void:
	GameManager.procesar_eleccion(datos_del_evento.id, "A")
	queue_free() # close ventana

func _on_boton_b_pressed() -> void:
	GameManager.procesar_eleccion(datos_del_evento.id, "B")
	queue_free() # close ventana
