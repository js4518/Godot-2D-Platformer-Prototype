extends KinematicBody2D

var velocity = Vector2()
#var collision_stack = 0
var speed
var damage
var rebound

func _ready():
	pass
	
func start(pos,rot,type):
	var character_bullet_type = $character_bullet_sprite.frames.get_animation_names()
	var enemy_bullet_type = $enemy_bullet_sprite.frames.get_animation_names()
	position = pos
	rotation = rot + rebound
	if is_in_group("character_attacks"):
		$character_bullet_sprite.visible = true
		$enemy_bullet_sprite.visible = false
		$character_bullet_sprite.animation = character_bullet_type[type - 2]
	elif is_in_group("enemy_attacks"):
		$character_bullet_sprite.visible = false
		$enemy_bullet_sprite.visible = true
		$enemy_bullet_sprite.animation = enemy_bullet_type[0]
	velocity = Vector2(speed,0).rotated(rotation)

func change_to_character_attack():
	$character_bullet_sprite.visible = true
	$enemy_bullet_sprite.visible = false
	$character_bullet_sprite.animation = "bullet_1"

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		queue_free()
	
	#if collision:
	#	velocity = velocity.bounce(collision.normal)
	#	collision_stack += 1
	#if collision_stack == 2:
	#	queue_free()
