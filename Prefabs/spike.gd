extends Area2D

@export var spike_speed = -10.0

signal spike_hit

# process moves the spike right to left across the screen
func _process(_delta):
	position.x = position.x + spike_speed

# despawn spike when it reaches outside the play area
func _on_area_entered(area):
	if area.is_in_group("bounds"):
		queue_free()
