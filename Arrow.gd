extends KinematicBody2D

var velocity = Vector2()
var speed
var damage
var pierce_amount = 0
var gravity_acc = 900

func start(pos,rot):
	position = pos + Vector2(20,0).rotated(rot)
	rotation = rot
	velocity = Vector2(speed,0).rotated(rotation)

func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity_acc * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		queue_free()
	rotation = velocity.angle()
	
	if pierce_amount >= 3:
		free()
