class_name RecursoCarta
extends Resource

@export var name: String = ""
@export_enum("Ataque", "Capacidad", "Poder") var tipo: String
@export var coste: int = 1
@export var daño: int = 12
@export var escudo: int = 0
@export var roba: int = 0
@export var ruta: Texture

#Chape
@export_multiline var descripcion: String = ""
