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
@onready var battle_log = $CanvasLayer/UI/BattleLog

var player_turn := true
var original_camera_position := Vector2.ZERO

func _ready():
	# Configuración inicial
	update_ui()
	action_options.visible = false
	await fade_in()

	# Conectar señales de botones
	attack_button.pressed.connect(_on_attack_pressed)
	heavy_hit_button.pressed.connect(_on_heavy_hit)
	fatigue_hit_button.pressed.connect(_on_fatigue_hit)

	# Guardar posición de cámara
	original_camera_position = $Camera2D.global_position

	# Configurar animaciones basadas en los datos
	var enemy_data = GameState.enemy_data
	if enemy_data.has("animation"):
		var anim_name = enemy_data["animation"] + "_idle"
		if enemy_sprite.sprite_frames.has_animation(anim_name):
			enemy_sprite.play(anim_name)
		else:
			print("⚠ Animación de batalla no encontrada: ", anim_name)
			if enemy_sprite.sprite_frames.has_animation("enemy_idle"):
				enemy_sprite.play("enemy_idle")
	
	if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation("idle"):
		player_sprite.play("idle")

# ACCIONES DEL JUGADOR

func _on_attack_pressed():
	# Mostrar opciones de ataque
	action_options.visible = true
	attack_button.disabled = true

func _on_heavy_hit():
	# Ataque fuerte (basado en fuerza)
	var damage = GameState.calculate_player_damage("heavy_hit")
	var stress = GameState.calculate_player_stress_attack("heavy_hit")
	
	# Efectos visuales
	focus_on(enemy_sprite)
	await camera_shake()
	
	# Aplicar daño
	GameState.enemy_data["hp"] = max(GameState.enemy_data["hp"] - damage, 0)
	GameState.enemy_data["stress"] = min(GameState.enemy_data["stress"] + stress, 100)
	
	# Finalizar turno
	end_turn("Golpe Contundente: %d daño, %d estrés" % [damage, stress])

func _on_fatigue_hit():
	# Ataque mental (basado en inteligencia)
	var damage = GameState.calculate_player_damage("fatigue_hit")
	var stress = GameState.calculate_player_stress_attack("fatigue_hit")
	
	# Efectos visuales (más sutiles para ataque mental)
	focus_on(enemy_sprite)
	await camera_shake(3, 0.2)
	
	# Aplicar daño
	GameState.enemy_data["hp"] = max(GameState.enemy_data["hp"] - damage, 0)
	GameState.enemy_data["stress"] = min(GameState.enemy_data["stress"] + stress, 100)
	
	# Finalizar turno
	end_turn("Golpe de Cansancio: %d daño, %d estrés" % [damage, stress])

# TURNO DEL ENEMIGO

func enemy_turn():
	print("[Enemigo]: Ataca al jugador.")
	# Selección inteligente de ataque basada en estadísticas
	var attack_types = ["normal_attack", "heavy_attack", "stress_attack"]
	var attack_weights = [60, 20, 20] # Probabilidad base
	
	# Enemigos más inteligentes eligen mejor sus ataques
	if GameState.enemy_data["intelligence"] >= 5:
		attack_weights = [40, 30, 30]
	
	# Sistema de selección ponderada
	var total_weight = attack_weights.reduce(func(a, b): return a + b)
	var choice = randi_range(1, total_weight)
	var attack_type = "normal_attack"
	
	var accumulated = 0
	for i in range(attack_weights.size()):
		accumulated += attack_weights[i]
		if choice <= accumulated:
			attack_type = attack_types[i]
			break
	
	# Cálculo de daño según estadísticas
	var damage = GameState.calculate_enemy_damage(attack_type)
	var stress = GameState.calculate_enemy_stress_attack(attack_type)
	
	# Sistema de evasión
	if randf() * 100 <= GameState.player_data["evasion"]:
		print("¡El jugador evade el ataque!")
		battle_log.text = "El jugador evadió el ataque del enemigo"
		await get_tree().create_timer(1.0).timeout
		enable_player_turn()
		return
	
	# Aplicar reducción de daño basada en estadísticas
	var final_damage = max(damage - GameState.player_data["damage_reduction"], 1)
	
	# Aplicar daño y mostrar mensaje (sin llamar a end_turn)
	apply_player_damage(final_damage, stress)
	focus_on(player_sprite)
	await camera_shake()
	
	# Mostrar mensaje directamente sin llamar a end_turn
	var attack_names = {
		"normal_attack": "Ataque normal",
		"heavy_attack": "Golpe contundente",
		"stress_attack": "Ataque de tensión"
	}
	
	# Solo mostrar el mensaje, NO llamar a end_turn
	if battle_log:
		battle_log.text = "%s del enemigo: %d daño, %d estrés" % [attack_names[attack_type], final_damage, stress]
	
	# Verificar estado del jugador
	check_player_state()
	
	# Si el jugador sigue vivo, devolver el control
	if GameState.player_data["hp"] > 0 and GameState.player_data["stress"] < 100:
		await get_tree().create_timer(1.0).timeout
		enable_player_turn()

# GESTIÓN DE TURNOS Y ESTADOS

func end_turn(log := ""):
	print("[Batalla]:", log)
	if battle_log:
		battle_log.text = log
	
	action_options.visible = false
	attack_button.disabled = true
	update_ui()
	check_enemy_defeated()

	# Pasar al turno del enemigo si no ha sido derrotado
	if GameState.enemy_data["hp"] > 0 and GameState.enemy_data["stress"] < 100:
		player_turn = false # Indicar explícitamente que no es turno del jugador
		await get_tree().create_timer(1.3).timeout
		enemy_turn() # Quitar el await aquí
	else:
		# Si el enemigo fue derrotado, habilitar turno del jugador
		enable_player_turn()

func enable_player_turn():
	player_turn = true
	attack_button.disabled = false
	if battle_log:
		battle_log.text = "Tu turno"

func apply_player_damage(dmg, stress):
	GameState.player_data["hp"] = max(GameState.player_data["hp"] - dmg, 0)
	GameState.player_data["stress"] = min(GameState.player_data["stress"] + stress, 100)
	update_ui()

func check_enemy_defeated():
	if GameState.enemy_data["hp"] <= 0:
		print("⚰ El enemigo ha sido derrotado.")
		GameState.last_battle_result = "victory"
		GameState.enemy_defeated = true
		GameState.defeated_enemies[GameState.enemy_data["id"]] = true
		
		# Recompensas por victoria
		GameState.player_data["experience"] += 25 + (GameState.enemy_data["strength"] * 5)
		
		await return_to_main_scene()
	elif GameState.enemy_data["stress"] >= 100:
		print("🧠 El enemigo colapsa por estrés.")
		GameState.last_battle_result = "victory"
		GameState.enemy_defeated = true
		GameState.defeated_enemies[GameState.enemy_data["id"]] = true
		
		# Recompensas por victoria (más exp por victoria por estrés)
		GameState.player_data["experience"] += 35 + (GameState.enemy_data["intelligence"] * 5)
		
		await return_to_main_scene()

func check_player_state():
	if GameState.player_data["hp"] <= 0:
		print("☠ El jugador colapsa físicamente.")
		GameState.last_battle_result = "defeat"
		GameState.player_defeated = true
		await return_to_main_scene()
	elif GameState.player_data["stress"] >= 100:
		print("🧠 El jugador entra en crisis.")
		GameState.last_battle_result = "defeat"
		GameState.player_defeated = true
		await return_to_main_scene()

func return_to_main_scene():
	await fade_out()
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func update_ui():
	enemy_hp_label.text = "HP: %d" % GameState.enemy_data["hp"]
	enemy_stress_label.text = "St: %d" % GameState.enemy_data["stress"]
	player_hp_label.text = "HP: %d" % GameState.player_data["hp"]
	player_stress_label.text = "St: %d" % GameState.player_data["stress"]

# EFECTOS VISUALES

func fade_in():
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
	fade_rect.visible = false

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
	await get_tree().create_timer(0.5).timeout
	var return_tween = create_tween()
	return_tween.tween_property($Camera2D, "global_position", original_camera_position, 0.3)
	await return_tween.finished
