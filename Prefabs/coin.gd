extends Area2D

@export var coin_speed = -10.0
@onready var coin_sound = $AudioStreamPlayer

var pickedup : bool = false

# moves the coin right to left
func _process(_delta):
	position.x = position.x + coin_speed

# if the coin gets to the end of the screen without being picked up, it will despawn
func _on_area_entered(area):
	if area.is_in_group("bounds") and not pickedup:
		queue_free()

# if the coin is picked up, the sprite will be hidden and a sound will play.
# only after the sound has finished will the coin despawn
# since the pickedup bool is true, it will not despawn when leaving the screenspace
func _on_body_entered(body):
	if body.is_in_group("player"):
		$AnimatedSprite2D.hide()
		pickedup = true
		coin_sound.play()
		await coin_sound.finished
		queue_free()
