extends Control

@onready var strength_label = $StatsContainer/StrengthLabel
@onready var dexterity_label = $StatsContainer/DexterityLabel
@onready var intelligence_label = $StatsContainer/IntelligenceLabel
@onready var critical_label = $StatsContainer/CriticalLabel
@onready var evasion_label = $StatsContainer/EvasionLabel

@onready var available_points_label = $PointsContainer/AvailablePoints

var available_points = 3  # Puntos disponibles para asignar

func _ready():
    update_ui()
    
    # Conectar botones
    $StatsContainer/StrengthPlus.pressed.connect(func(): add_stat("strength"))
    $StatsContainer/DexterityPlus.pressed.connect(func(): add_stat("dexterity"))
    $StatsContainer/IntelligencePlus.pressed.connect(func(): add_stat("intelligence"))

func update_ui():
    strength_label.text = "Fuerza: %d" % GameState.player_data["strength"]
    dexterity_label.text = "Destreza: %d" % GameState.player_data["dexterity"]
    intelligence_label.text = "Inteligencia: %d" % GameState.player_data["intelligence"]
    critical_label.text = "Prob. Crítico: %d%%" % GameState.player_data["critical_chance"]
    evasion_label.text = "Evasión: %d%%" % GameState.player_data["evasion"]
    
    available_points_label.text = "Puntos disponibles: %d" % available_points

func add_stat(stat_name):
    if available_points <= 0:
        return
        
    GameState.player_data[stat_name] += 1
    available_points -= 1
    
    # Actualizar estadísticas derivadas
    if stat_name == "dexterity":
        GameState.player_data["evasion"] = 10 + (GameState.player_data["dexterity"] * 2)
        GameState.player_data["critical_chance"] = 5 + GameState.player_data["dexterity"]
    
    update_ui()