extends CharacterBody2D

@export var GRAVITY = 500.00
@export var jetpack_strength : float = -600
var current_animation = ""
var is_alive = true

signal dead_signal
signal coin_pickup

@onready var animation = $AnimatedSprite2D
@onready var sparkles = $GPUParticles2D

# apply gravity and stop the particles from emitting
func _ready():
	velocity.y = GRAVITY
	sparkles.emitting = false

func _physics_process(_delta):
	move_and_slide()
	handle_movement()
	clamp_to_viewport()

func handle_movement():
	# first check makes sure player can only control character when he's alive
	if is_alive:
		if Input.is_action_pressed("space"):
			velocity.y = jetpack_strength
			sparkles.emitting = true
			animation_manager("jump_up")
		elif Input.is_action_just_released("space"):
			#using input just released here so this is only called on one frame, instead of constantly
			velocity.y = GRAVITY
			sparkles.emitting = false
			animation_manager("falling")
		else:
			# ramping fall speed helps the game feel less floaty
			velocity.y += 50
		if is_on_floor() and current_animation != "running":
			#this check to make sure that the correct animation is playing when appropriate
			animation_manager("running")
	# finally, animation manager for when the player is dead
	# different animations play whether the player is in the air or on the ground
	elif not is_alive and not is_on_floor():
		animation_manager("dead_in_air")
		velocity.y = GRAVITY
		sparkles.emitting = false
	elif not is_alive and is_on_floor():
		animation_manager("dead_on_ground")

# prevents character from flying above the visible play area
func clamp_to_viewport():
	var viewport_rect = get_viewport_rect().size
	var clamped_position = global_position.clamp(Vector2.ZERO, Vector2(viewport_rect.x, viewport_rect.y))
	global_position = clamped_position

# method for streamlining animations, this prevents an animation being called once per frame
# which would restart the animation. with this check, if the current animation is the one playing
# nothing will happen
func animation_manager(string):
	if current_animation == string:
		pass
	else:
		animation.play(string)
		current_animation = string

# pretty self explanitory
func die():
	is_alive = false
	dead_signal.emit()

# method for handling objects that collide with the player
func _on_area_2d_area_entered(area):
	if area.is_in_group("coins"):
		coin_pickup.emit()
	elif area.is_in_group("spike"):
		die()

# revives the player character when a new game starts or after a game over
func _on_main_game_start():
	is_alive = true
