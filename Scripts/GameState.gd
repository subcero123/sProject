extends Node

var enemy_data = {}

var player_data = {
	"hp": 100,
	"stress": 0,
	"max_hp": 100,
	"max_stress": 100,
}

var last_battle_result = ""
var defeated_enemies = {}
var enemy_defeated = false
var player_defeated = false