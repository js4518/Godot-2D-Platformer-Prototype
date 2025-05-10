extends KinematicBody2D

var velocity = Vector2()
var speed = 150
var damage
var character_previous_position

func _ready():
	character_previous_position = $"../Character".position

func start(pos,rot):
	position = pos
	rotation = rot
	velocity = Vector2(speed,0).rotated(rotation)

func _physics_process(delta):
	if speed == 150:
		position += $"../Character".position - character_previous_position
	position += velocity * delta
	character_previous_position = $"../Character".position

func _on_Area2D_body_entered(body):
	if body.is_in_group("mobs"):
		body.hp -= damage
		if $"../Character".sp <= 98:
			$"../Character".sp += 2
		if speed == 150:
			body.knockback(velocity)
		else:
			body.knockback(velocity / 2)
	if body.is_in_group("enemy_attacks"):
		body.velocity = velocity.normalized() * body.velocity.length()
		body.remove_from_group("enemy_attacks")
		body.add_to_group("character_attacks")
		if body.has_method("change_to_character_attack"):
			body.change_to_character_attack()
			body.damage *= 2

func _on_delete_timer_timeout():
	queue_free()
