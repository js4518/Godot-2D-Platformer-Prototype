extends KinematicBody2D

var velocity = Vector2()
var collision_stack = 0
var speed = 500
var damage = 10

func _ready():
	pass
	
func start(pos,rot,type):
	var bullet_type = $AnimatedSprite.frames.get_animation_names()
	position = pos
	rotation = rot
	$AnimatedSprite.animation = bullet_type[type - 1]
	velocity = Vector2(speed,0).rotated(rotation)
	
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		collision_stack += 1
	if collision_stack == 2:
		queue_free()
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
