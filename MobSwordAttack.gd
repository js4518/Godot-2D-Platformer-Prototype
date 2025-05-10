extends KinematicBody2D

var velocity = Vector2()
var speed = 150
var damage
var mob_previous_position
var inst

func _ready():
	pass

func start(pos,rot,id):
	position = pos + Vector2(20,0).rotated(rot)
	mob_previous_position = pos
	rotation = rot
	inst = instance_from_id(id)
	velocity = Vector2(speed,0).rotated(rotation)

func _physics_process(delta):
	if is_instance_valid(inst):
		position += inst.position - mob_previous_position
		mob_previous_position = inst.position
	position += velocity * delta


func _on_Area2D_body_entered(body):
	if body.is_in_group("character"):
		body.knockback(velocity)

func _on_delete_timer_timeout():
	queue_free()
