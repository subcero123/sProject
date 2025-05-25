extends Node

@onready var enemy_sprite = $EnemySprite
@onready var player_sprite = $PlayerSprite
@onready var player_hp_label = $PlayerSprite/PlayerStats/PlayerHP
@onready var player_stress_label = $PlayerSprite/PlayerStats/PlayerStress
@onready var enemy_hp_label = $EnemySprite/EnemyStats/EnemyHP
@onready var enemy_stress_label = $EnemySprite/EnemyStats/EnemyStress

@onready var attack_button = $CanvasLayer/UI/ActionMenu/AttackButton
@onready var action_options = $CanvasLayer/UI/ActionMenu/ActionOptions
@onready var heavy_hit_button = $CanvasLayer/UI/ActionMenu/ActionOptions/HeavyHitButton
@onready var fatigue_hit_button = $CanvasLayer/UI/ActionMenu/ActionOptions/FatigueHitButton
@onready var fade_rect = $CanvasLayer/FadeRect

var player_turn := true
var original_camera_position := Vector2.ZERO



func _ready():
	update_ui()
	action_options.visible = false
	await fade_in()


	attack_button.pressed.connect(_on_attack_pressed)
	heavy_hit_button.pressed.connect(_on_heavy_hit)
	fatigue_hit_button.pressed.connect(_on_fatigue_hit)

	# Camara
	original_camera_position = $Camera2D.global_position


	var enemy_data = GameState.enemy_data  # <- desde singleton
	
	if enemy_data.has("name"):
		var anim_name = enemy_data["name"] + "_idle"
		
		if enemy_sprite.sprite_frames and enemy_sprite.sprite_frames.has_animation(anim_name):
			enemy_sprite.play(anim_name)
		else:
			print("⚠ Animación no encontrada: ", anim_name)

	if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation("idle"):
		player_sprite.play("idle")

func update_ui():
	enemy_hp_label.text = "HP: %d" % GameState.enemy_data["hp"] 
	enemy_stress_label.text = "St: %d" % GameState.enemy_data["stress"]
	player_hp_label.text = "HP: %d" % GameState.player_data["hp"]
	player_stress_label.text = "St: %d" % GameState.player_data["stress"]

func _on_attack_pressed():
	action_options.visible = true
	attack_button.disabled = true

func _on_heavy_hit():
	var damage = randi_range(10, 15)
	focus_on(enemy_sprite)
	await camera_shake()
	GameState.enemy_data["hp"] = max(GameState.enemy_data["hp"] - damage, 0)
	end_turn("Golpe Contundente")

func _on_fatigue_hit():
	var stress = randi_range(20, 30)
	GameState.enemy_data["stress"] = min(GameState.enemy_data["stress"] + stress, 100)
	end_turn("Golpe de Cansancio")

func end_turn(log := ""):
	print("[Jugador]:", log)
	action_options.visible = false
	attack_button.disabled = true
	update_ui()
	check_enemy_defeated()

	if GameState.enemy_data["hp"] > 0 and GameState.enemy_data["stress"] < 100:
		await get_tree().create_timer(1.3).timeout
		await enemy_turn()

func enemy_turn():
	print("[Enemigo]: Ataca al jugador.")

	var damage = randi_range(5, 10)
	var stress = randi_range(10, 20)

	apply_player_damage(damage, stress)
	focus_on(player_sprite)
	await camera_shake()

	check_player_state()

	await get_tree().create_timer(1.0).timeout
	enable_player_turn()

func enable_player_turn():
	player_turn = true
	attack_button.disabled = false

func apply_player_damage(dmg, stress):
	GameState.player_data["hp"] = max(GameState.player_data["hp"] - dmg, 0)
	GameState.player_data["stress"] = min(GameState.player_data["stress"] + stress, 100)
	update_ui()


func check_enemy_defeated():
	if GameState.enemy_data["hp"] <= 0:
		print("⚰ El enemigo ha sido derrotado.")
		GameState.last_battle_result = "victory"
		GameState.enemy_defeated = true
		GameState.defeated_enemies[GameState.enemy_data[1]] = true
		await return_to_main_scene()
	elif GameState.enemy_data["stress"] >= 100:
		print("🧠 El enemigo colapsa por estrés.")
		GameState.last_battle_result = "victory"
		GameState.enemy_defeated = true
		GameState.defeated_enemies[GameState.enemy_data[1]] = true
		await return_to_main_scene()

func check_player_state():
	if GameState.player_data["hp"] <= 0:
		print("☠ El jugador colapsa físicamente.")
	elif GameState.player_data["stress"] >= 100:
		print("🧠 El jugador entra en crisis.")

func return_to_main_scene():
	await fade_out()  # Opcional, si quieres efecto de fade antes de salir
	get_tree().change_scene_to_file("res://Scenes/level.tscn")  # Ajusta la ruta a tu escena principal


#Funciones visuales 

func fade_in():
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
	fade_rect.visible = false  # 👈 Esto lo hace "clic-through"

func fade_out():
	fade_rect.visible = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

func camera_shake(amount := 5, duration := 0.3):
	var timer := 0.0
	while timer < duration:
		$Camera2D.offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		await get_tree().create_timer(0.02).timeout
		timer += 0.02
	$Camera2D.offset = Vector2.ZERO

func focus_on(target_node: Node2D):
	var tween = create_tween()
	tween.tween_property($Camera2D, "global_position", target_node.global_position, 0.2)
	# esperar a que termine el tween y luego volver a la posición original
	await get_tree().create_timer(0.5).timeout

	var return_tween = create_tween()
	return_tween.tween_property($Camera2D, "global_position", original_camera_position, 0.3)
	await return_tween.finished
