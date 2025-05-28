extends Node
var enemy_data_list = [
	{
		"id": "enemigo_001",
		"name": "Sicario joven",
		"hp": 1,
		"stress": 0,
		"position": Vector2(200, 0),
		"animation": "enemy"
	},
	{
		"id": "enemigo_002",
		"name": "Halconcito",
		"hp": 2,
		"stress": 0,
		"position": Vector2(300, 0),
		"animation": "enemy"
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
        enemy.animation_type = enemy_data["animation"] # Guardamos el tipo de animación
        enemy.position = enemy_data["position"]

        # Solo cambia la animación que se reproduce en el nivel
        if enemy.has_node("AnimatedSprite2D"):
            var sprite = enemy.get_node("AnimatedSprite2D")
            var anim_name = enemy_data["animation"] + "_walk"
            if sprite.sprite_frames.has_animation(anim_name):
                sprite.play(anim_name)
            else:
                print("⚠ Animación no encontrada: ", anim_name)

        add_child(enemy_instance)