extends CharacterBody2D

@export var speed := 40
@export var gravity := 850
@export var patrol_distance := 100

var direction := 1
var start_position := Vector2.ZERO

var enemy_id = ""
var enemy_name = ""
var hp = 30
var stress = 0
var animation_type = "enemy" # Valor por defecto

# Nuevas estadísticas base
var strength = 3      # Fuerza base (afecta daño físico)
var dexterity = 3     # Destreza (afecta precisión y evasión)
var intelligence = 2  # Inteligencia (afecta habilidades especiales)

# Estadísticas derivadas
var critical_chance = 5  # Porcentaje base de crítico
var evasion = 8          # Porcentaje base de evasión
var damage_reduction = 0 # Reducción de daño base

@onready var sprite := $AnimatedSprite2D

func _ready():
	start_position = position

	# Usar el tipo de animación del enemigo para la animación correcta
	var anim_name = animation_type + "_walk"
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		# Si no encuentra la animación específica, intenta con la genérica
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		else:
			print("⚠ Ninguna animación de caminar encontrada para: ", animation_type)

func _physics_process(delta):
	velocity.x = direction * speed

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Verificar si se alcanzó la distancia de patrullaje
	if abs(position.x - start_position.x) >= patrol_distance:
		direction *= -1
		sprite.flip_h = direction < 0
		start_position = position # Reiniciar punto de patrullaje

	move_and_slide()


func _on_hitbox_body_entered(body: Node2D):
	if body.name == "Player":
		# Difiere la llamada para evitar conflicto con el sistema de física
		call_deferred("start_battle")


func start_battle():
	GameState.enemy_data = {
		"id": enemy_id,
		"name": enemy_name,
		"hp": hp,
		"stress": stress,
		"animation": animation_type,
		# Pasar todas las estadísticas
		"strength": strength,
		"dexterity": dexterity,
		"intelligence": intelligence,
		"critical_chance": critical_chance,
		"evasion": evasion,
		"damage_reduction": damage_reduction
	}

	get_tree().change_scene_to_file("res://Scenes/battleScene.tscn")

	# 🟢 Esto evita el error:
	call_deferred("queue_free")
