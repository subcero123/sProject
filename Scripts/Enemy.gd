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

@onready var sprite := $AnimatedSprite2D

func _ready():
	start_position = position
	sprite.play("walk")

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
		start_position = position  # Reiniciar punto de patrullaje

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
	}

	get_tree().change_scene_to_file("res://Scenes/battleScene.tscn")

	# 🟢 Esto evita el error:
	call_deferred("queue_free")
