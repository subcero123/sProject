extends Node
var enemy_data_list = [
	{
		"id": "enemigo_001",
		"name": "Sicario joven",
		"hp": 50,
		"stress": 0,
		"position": Vector2(200, 0),
		"animation": "enemy",
		# Nuevas estadísticas base
		"strength": 3,     # Fuerza base (afecta daño físico)
		"dexterity": 4,    # Destreza (afecta precisión y evasión)
		"intelligence": 2, # Inteligencia (afecta habilidades especiales)
		# Estadísticas derivadas
		"critical_chance": 4,  # Porcentaje base de crítico
		"evasion": 8,         # Porcentaje base de evasión
		"damage_reduction": 0 # Reducción de daño base
	},
	{
		"id": "enemigo_002",
		"name": "Halconcito",
		"hp": 40,
		"stress": 0,
		"position": Vector2(300, 0),
		"animation": "enemy",
		# Nuevas estadísticas base
		"strength": 2,     # Menos fuerza
		"dexterity": 6,    # Más destreza (es ágil)
		"intelligence": 3, # Inteligencia media
		# Estadísticas derivadas
		"critical_chance": 6,  # Mayor probabilidad de crítico
		"evasion": 12,        # Mayor evasión
		"damage_reduction": 1 # Reducción de daño pequeña
	},
]

func _ready():
	for enemy_data in enemy_data_list:
		if GameState.defeated_enemies.has(enemy_data["id"]):
			continue  # Ya fue derrotado
		var enemy_instance = preload("res://Scenes/enemy.tscn").instantiate()
		var enemy = enemy_instance.get_node("CharacterBody2D")  # Solo obtenemos referencia
		
		# Configuramos el CharacterBody2D con TODOS los datos
		enemy.enemy_id = enemy_data["id"]
		enemy.enemy_name = enemy_data["name"]
		enemy.hp = enemy_data["hp"]
		enemy.stress = enemy_data["stress"]
		enemy.animation_type = enemy_data["animation"]
		enemy.position = enemy_data["position"]
		
		# Nuevas estadísticas
		enemy.strength = enemy_data["strength"]
		enemy.dexterity = enemy_data["dexterity"]
		enemy.intelligence = enemy_data["intelligence"]
		enemy.critical_chance = enemy_data["critical_chance"]
		enemy.evasion = enemy_data["evasion"]
		enemy.damage_reduction = enemy_data["damage_reduction"]

		# Solo cambia la animación que se reproduce en el nivel
		if enemy.has_node("AnimatedSprite2D"):
			var sprite = enemy.get_node("AnimatedSprite2D")
			var anim_name = enemy_data["animation"] + "_walk"
			if sprite.sprite_frames.has_animation(anim_name):
				sprite.play(anim_name)
			else:
				print("⚠ Animación no encontrada: ", anim_name)

		add_child(enemy_instance)
