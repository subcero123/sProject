extends Node

var enemy_data = {}

var player_data = {
    # Estadísticas básicas
    "hp": 100,
    "stress": 0,
    "max_hp": 100,
    "max_stress": 100,
    
    # Nuevas estadísticas base
    "strength": 5,     # Fuerza base (afecta daño físico)
    "dexterity": 3,    # Destreza (afecta precisión y evasión)
    "intelligence": 4, # Inteligencia (afecta habilidades especiales)
    
    # Estadísticas derivadas
    "critical_chance": 5,  # Porcentaje base de crítico (5%)
    "evasion": 10,         # Porcentaje base de evasión (10%)
    "damage_reduction": 0, # Reducción de daño base
    
    # Nivel del jugador
    "level": 1,
    "experience": 0
}

var last_battle_result = ""
var defeated_enemies = {}
var enemy_defeated = false
var player_defeated = false

# Nueva función para calcular daño basado en estadísticas
func calculate_player_damage(attack_type):
    var base_damage = 0
    var critical_mult = 1.0
    var variance = randf_range(0.9, 1.1)  # +/- 10% variación
    
    # Determinar el daño base según el tipo de ataque
    match attack_type:
        "heavy_hit":
            base_damage = 5 + (player_data["strength"] * 2)
        "fatigue_hit": 
            base_damage = 2 + player_data["intelligence"]
        "normal_attack":
            base_damage = 3 + player_data["strength"]
    
    # Verificar golpe crítico
    if randf() * 100 <= player_data["critical_chance"]:
        critical_mult = 1.5
        print("¡Golpe crítico!")
    
    # Calcular daño final
    var final_damage = round(base_damage * critical_mult * variance)
    return final_damage

# Nueva función para calcular estrés infligido
func calculate_player_stress_attack(attack_type):
    var base_stress = 0
    
    match attack_type:
        "heavy_hit":
            base_stress = 5 + (player_data["strength"] * 0.5)
        "fatigue_hit":
            base_stress = 15 + (player_data["intelligence"] * 1.5)
        "normal_attack":
            base_stress = 5 + (player_data["dexterity"] * 0.5)
    
    return round(base_stress)