extends Node
var enemy_data_list = [
	{
		"id": "enemigo_001",
		"name": "Sicario joven",
		"hp": 50,
		"stress": 0,
		"position": Vector2(200, 300)
	},
	{
		"id": "enemigo_002",
		"name": "Halconcito",
		"hp": 40,
		"stress": 0,
		"position": Vector2(500, 200)
	},
]

func _ready():
	for enemy_data in enemy_data_list:
		if GameState.defeated_enemies.has(enemy_data["id"]):
			continue  # Ya fue derrotado
		var enemy = preload("res://Scenes/enemy.tscn").instantiate()
		enemy = enemy.get_node("CharacterBody2D")  # Ajusta el nombre si es distinto
		enemy.enemy_id = enemy_data["id"]
		enemy.enemy_name = enemy_data["name"]
		enemy.hp = enemy_data["hp"]
		enemy.stress = enemy_data["stress"]
		enemy.position = enemy_data["position"]
		add_child(enemy)
