extends Node2D

#TODO: Score, high score

# obstacles and coins, first loaded, then placed in an array later
@export var coin_scene_1 : PackedScene
@export var coin_scene_2 : PackedScene
@export var coin_scene_3 : PackedScene
@export var spike_scene_1 : PackedScene
@export var spike_scene_2 : PackedScene
@export var spike_scene_3 : PackedScene
var coin_arr = []
var spike_arr = []

# music players
@onready var menu_music = $Music/MenuMusic
@onready var game_music = $Music/GameMusic
@onready var game_over_music = $Music/GameOverMusic
@onready var dead_sound = $Music/DeadSound

# game signals
signal game_start
var game_active : bool = false

# score and counter
var score = 00000
var highscore = 50000
var framecounter : int = 0

func _process(_delta):
	framecounter += 1
	if game_active and framecounter % 30 == 0:
		score += 10
	$HUD/Score/HBoxContainer/ScoreNum.text = str(score)

# resets all variables, starts new game
func new_game():
	framecounter = 0
	score = 00000
	menu_music.stop()
	game_over_music.stop()
	game_active = true
	game_start.emit()
	$Background.show()
	$Player.show()
	$Floor.show()
	$MenuBackground.hide()
	game_music.play()
	$CoinTimer.difficulty_lvl = 0.0
	$SpikeTimer.difficulty_lvl = 0.0
	$HUD/Title.hide()
	$HUD/Button.hide()
	$HUD/Score/HBoxContainer.show()
	$HUD/HighScore/HBoxContainer.show()

# called when game ends, logs score, triggers game over screen
func game_over():
	game_active = false
	game_music.stop()
	dead_sound.play()
	await dead_sound.finished
	game_over_music.play()
	$Background.hide()
	$Player.hide()
	$Floor.hide()
	$MenuBackground.show()
	if score > highscore:
		$HUD/Title.text = "HIGH SCORE!\nSCORE: " + str(score) + "\nGAME OVER\nPLAY AGAIN?"
		highscore = score
	else:
		$HUD/Title.text = "SCORE: " + str(score) + "\nGAME OVER\nPLAY AGAIN?"
	$HUD/Title.show()
	$HUD/Button.show()

# called at start, adds scenes to an array to be randomly spawned during play
func _ready():
	coin_arr = [coin_scene_1, coin_scene_2, coin_scene_3]
	spike_arr = [spike_scene_1, spike_scene_2, spike_scene_3]
	menu_music.play()
	$HUD/Title.show()
	$HUD/Button.show()
	$MenuBackground.show()
	$Floor.hide()
	$Player.hide()
	$Background.hide()
	$HUD/Score/HBoxContainer.hide()
	$HUD/HighScore/HBoxContainer.hide()

func _on_coin_timer_timeout():
	if game_active:
		spawn_coins()

func _on_spike_timer_timeout():
	if game_active:
		spawn_spikes()

# chooses randomly from array created earlier which spikes to spawn, spawns on a timer that gradually gets shorter the longer the game is played
func spawn_spikes():
	var index = randi_range(0, 2)
	var spike = spike_arr[index].instantiate()
	var spike_spawn_location = get_node("SpawnPath/SpawnLocation")
	spike_spawn_location.progress_ratio = randf()
	spike.position = spike_spawn_location.position
	add_child(spike)

# same as above, but for coins
func spawn_coins():
	var index = randi_range(0, 2)
	var coin = coin_arr[index].instantiate()
	var coin_spawn_location = get_node("SpawnPath/SpawnLocation")
	coin_spawn_location.progress_ratio = randf()
	coin.position = coin_spawn_location.position
	add_child(coin)

func _on_player_dead_signal():
	game_over()

func _on_button_button_up():
	new_game()

func _on_player_coin_pickup():
	if game_active:
		score += 100
