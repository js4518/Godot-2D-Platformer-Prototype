extends KinematicBody2D

var Bullet = preload("res://Bullet.tscn")
var screen_size


# 이동 관련 변수
var velocity = Vector2()
var speed = 150
var jump_speed = -600
var gravity_acc = 1200

# 체력 관련 변수
var hp = 100
var state_attack_active = true

# 탐지 상태/이동패턴/공격받음
var state_detect = false
var state_attacked = false
var pattern_speed = [100,75,-100,-75]
var pattern_current_speed
var knockbacked = false

func _ready():
	screen_size = get_viewport_rect().size

func start(pos,rot):
	position = pos
	rotation = rot

func knockback(v):
	knockbacked = true
	velocity = v * 2.5 + velocity * 0.5
	$knockback_timer.start()
	

func _physics_process(delta):
	# 이동 관련
	if not knockbacked:
		if state_detect or state_attacked:
			if not $"../Character".dead:
				$pattern_change_timer.stop()
				$jump_timer.wait_time = 1.5
				if $close_move_timer.is_stopped():
					if $"../Character".position.x > position.x: velocity.x = speed
					elif $"../Character".position.x < position.x: velocity.x = -speed
					
					if ($"../Character".position.x - position.x < 16) and ($"../Character".position.x - position.x > -16):
						$close_move_timer.start()
				else:
					velocity.x = 0
		else:
			if $pattern_change_timer.is_stopped():
				pattern_current_speed = pattern_speed[randi() % len(pattern_speed)]
				$pattern_change_timer.start()
				$jump_timer.wait_time = 3
			velocity.x = pattern_current_speed
	
	velocity.y += gravity_acc * delta
	velocity = move_and_slide(velocity, Vector2(0,-1))
	
	# 체력 관련
	$HPbar.value = hp
	if hp <= 0:
		queue_free()
		get_parent().score += 1
	# 애니메이션
	if state_detect or state_attacked:
		if $"../Character".position.x - position.x >= 0:
			$AnimatedSprite.animation = "right_detect"
		elif $"../Character".position.x - position.x < 0:
			$AnimatedSprite.animation = "left_detect"
	else:
		if velocity.x >= 0:
			$AnimatedSprite.animation = "right"
		elif velocity.x < 0:
			$AnimatedSprite.animation = "left"
	# 공격 활성화(외부 설정)
	state_attack_active = get_parent().mobs_attack_active

# 총알 피격 판정
func _on_Area2D_body_entered(body):
	if body.is_in_group("character_attacks"):
		hp -= body.damage
		body.free()

# 장애물 있을시 점프
func _on_obstacle_checkbox_body_entered(body):
	if body.get_collision_layer() == 1:
		if is_on_floor():
			velocity.y = jump_speed

# 일정 시간마다 자동 점프
func _on_jump_timer_timeout():
	if is_on_floor():
			velocity.y = jump_speed

# 일정 시간마다 공격
func _on_attack_timer_timeout():
	if (not $"../Character".dead) and state_attack_active and (state_detect or state_attacked):
		var b = Bullet.instance()
		var dir = ($"../Character".position - global_position).angle()
		b.speed = 500
		b.damage = 5
		b.rebound = 0
		b.add_to_group("enemy_attacks")
		b.start(position,dir,3)
		get_parent().add_child(b)

# 캐릭터 탐지
func _on_detect_checkbox_body_entered(body):
	if body.is_in_group("character"):
		state_detect = true

func _on_detect_checkbox_body_exited(body):
	if body.is_in_group("character"):
		state_detect = false

# 미탐지 상태에서 일정 시간마다 이동속도 변화
func _on_pattern_change_timer_timeout():
	pattern_current_speed = pattern_speed[randi() % len(pattern_speed)]


func _on_attacked_checkbox_body_entered(body):
	if body.is_in_group("character_attacks"):
		state_attacked = true
		get_parent().disable_mob_attacked(get_instance_id())


func _on_knockback_timer_timeout():
	knockbacked = false
