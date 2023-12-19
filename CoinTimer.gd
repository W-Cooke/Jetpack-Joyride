extends Timer

@onready var timer = $"."
var difficulty_lvl = 0.0

# on timeout the timer resets with a random duration. depending on the
# difficulty timer, this duration gets shorter the longer the game is played
func _on_timeout():
	var rand_length = randf_range(1, 2.0) - difficulty_lvl
	if rand_length < 0:
		rand_length = 0.1
	timer.start(rand_length)

func _on_difficulty_timer_timeout():
	difficulty_lvl += 0.2
