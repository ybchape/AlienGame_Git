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

@export var curacion: int = 0                   # Para Extracción Sanguínea
@export var ganancia_energia: int = 0           # Para Sobrecarga de Núcleo y Golpe de Ímpetu
@export var dano_a_jugador: int = 0             # Para Sobrecarga de Núcleo (te quita vida)
@export var aplica_veneno: int = 0              # Cuánto daño por veneno aplica (Tajo Infectado)
@export var turnos_veneno: int = 0              # Cuántos turnos dura el veneno
@export var retiene_escudo: bool = false        # Para Espuma Selladora
@export var dano_extra_veneno: int = 0          # Para Corte Quirúrgico
@export var dano_extra_ultima_carta: int = 0    # Para Impacto de Precisión
@export var es_poder_permanente: bool = false   # Para marcar cartas como Bio-Mutación
@export var buff_dano_basico: int = 0           # Para Bio-Mutación (suma daño a ataques iniciales)
@export var energia_base_extra: int = 0         # Para Metabolismo Acelerado
@export var robo_si_vida_baja: int = 0          # Para Inyección de Adrenalina, DESCARTADO
@export var aplica_debilidad: int = 0           # Para Niebla Tóxica
@export var energia_si_primera: int = 0         # Para Golpe de Ímpetu
@export var cura_por_ataque: int = 0            # Para Simbiosis Parasitaria
@export var buff_escudo_basico: int = 0         # Para Inyección de Adrenalina
@export var aturde_enemigo: bool = false        # Para tu nueva carta de aturdimiento
