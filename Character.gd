extends KinematicBody2D

var Bullet = preload("res://Bullet.tscn")
var SwordAttack = preload("res://SwordAttack.tscn")
var Arrow = preload("res://Arrow.tscn")
var HPLabel = preload("res://HPLabel.tscn")

var screen_size
var scene_reloading = false
var current_tile

# 이동 관련 변수
var velocity = Vector2()
var speed = 200
var jump_speed = -600
var wall_jump_speed = -500
var gravity_acc = 1200
var jump_stack = 0
var direc = 0
var previous_direc = 0
var rushing = 0
var rush_cooltime_check = 0
var knockbacked = false
# 무기 관련 변수
var weapon_name = ["검","연사총","활"]
var weapon_amount = [[0,0],[24,24],[1,1]]
var weapon_speed = [0,1200,1200]
var weapon_cooltime = [0.2,0.08,0.5]
var weapon_reloadtime = [1,2,0.5]
var weapon_damage = [30,20,80]
var weapon_rebound = [1,48,1]
var present_rebound
var weapon_reloading = 0
var present_weapon = 1
var previous_weapon = -1
var weapon_cooltime_check = 0
var weapon_sprite
var sword_attacking = false
var gun_attacking = false
var charge_time = 0
# 체력,기력 등 변수
var hp = 100
var sp = 100
var dead = 0
var hp_labels = []

func _ready():
	screen_size = get_viewport_rect().size
	
	if present_weapon == 1: 
		weapon_sprite = $Sword
		$Sword.visible = true
		$Gun.visible = false
		$Bow.visible = false
	elif present_weapon == 2:
		weapon_sprite = $Gun
		$Sword.visible = false
		$Gun.visible = true
		$Bow.visible = false
	elif present_weapon == 3:
		weapon_sprite = $Bow
		$Sword.visible = false
		$Gun.visible = false
		$Bow.visible = true
		
	present_rebound = PI / weapon_rebound[present_weapon-1]
	current_tile = $"../Tiles/TileMap".get_cellv($"../Tiles/TileMap".world_to_map(position))
	$AnimatedSprite.play()

func knockback(v):
	knockbacked = true
	velocity = v * 1.5 + velocity * 0.5
	$knockback_timer.start()

func hp_vary(h):
	hp += h
	
	# font의 draw 기능 사용 가능할지도..
	var l = HPLabel.instance()
	get_parent().add_child(l)
	hp_labels.append(l)
	if hp_labels.size() >= 6:
		var label_to_remove = hp_labels[0]
		hp_labels.remove(0)
		if is_instance_valid(label_to_remove):
			label_to_remove.queue_free()
			
	if h > 0: l.get_node("Label").text = "+" + str(h)
	else: l.get_node("Label").text = str(h)
	
	l.position = Vector2(position.x + rand_range(-50,50), position.y + rand_range(-50,50))
	
	yield(get_tree().create_timer(1.5),"timeout")
	if is_instance_valid(l):
		l.queue_free()

func sp_vary(s):
	sp += s

func input_process():
	# 키 입력
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_just_pressed("ui_select")
	var rush = Input.is_action_just_pressed("rush")
	var left_mouse
	var reload = Input.is_action_just_pressed("reload")
	var weapon_1 = Input.is_action_just_pressed("weapon_1")
	var weapon_2 = Input.is_action_just_pressed("weapon_2")
	var weapon_3 = Input.is_action_just_pressed("weapon_3")
	if present_weapon == 1: # 왜인지 버그발생구간임.. 1이랑 2 합치지말기
		left_mouse = Input.is_action_just_pressed("left_mouse")
	elif present_weapon == 2:
		left_mouse = Input.is_action_pressed("left_mouse")
	elif present_weapon == 3:
		left_mouse = Input.is_action_just_pressed("left_mouse")
	# 입력 처리
	if (not rushing) and (not knockbacked):
		velocity.x = 0
		if left: velocity.x -= speed
		if right: velocity.x += speed
		if up: 
			if current_tile == 67:
				position.y -= 5
				velocity.y = 0
			elif current_tile == 66:
				jump_stack = 1
				velocity.y = -300
		if down: 
			if is_on_floor():
				position.y += 1
		if rush and (left or right) and ($rush_timer.time_left == 0): rush()
	
	if weapon_1: 
		present_weapon = 1
		present_rebound = PI / weapon_rebound[present_weapon-1]
	elif weapon_2 and (not $AnimationPlayer.is_playing()): 
		present_weapon = 2
		present_rebound = PI / weapon_rebound[present_weapon-1]
	elif weapon_3 and (not $AnimationPlayer.is_playing()): 
		present_weapon = 3
		present_rebound = PI / weapon_rebound[present_weapon-1]
	
	if left_mouse:
		if present_weapon == 1:
			if $sword_charge_timer.is_stopped():
				$sword_charge_timer.start()
				$sp_heal_timer.start()
				$sword_charge_particle.amount = 8
		elif present_weapon == 2:
			shoot()
		elif present_weapon == 3:
			if $arrow_charge_timer.is_stopped():
				$arrow_charge_timer.start()
				$sp_heal_timer.start()
			
	if (present_weapon == 1) and (Input.is_action_just_released("left_mouse")):
		attack(charge_time)
		$sword_charge_timer.stop()
		charge_time = 0
		$sword_charge_particle.emitting = false
		$sword_charge_particle.amount = 1
	
	if (present_weapon == 3) and (Input.is_action_just_released("left_mouse")):
		discharge(charge_time)
		$arrow_charge_timer.stop()
		charge_time = 0
	
	$reload_timer.wait_time = weapon_reloadtime[present_weapon - 1]
	#----------입력시에만 처리해야하는 애니메이션 설정 관련---------------------------
	if weapon_1:
		weapon_sprite = $Sword
		$Sword.visible = true
		$Gun.visible = false
		$Bow.visible = false
	elif weapon_2 and (not $AnimationPlayer.is_playing()):
		weapon_sprite = $Gun
		$Sword.visible = false
		$Gun.visible = true
		$Bow.visible = false
	elif weapon_3 and (not $AnimationPlayer.is_playing()):
		weapon_sprite = $Bow
		$Sword.visible = false
		$Gun.visible = false
		$Bow.visible = true
	#--------------------------------------------------------------------------------
	if reload: reload()

	# 재장전중 무기 변경 여부 확인 / 차징 초기화
	if present_weapon != previous_weapon:
		$reload_timer.stop()
		weapon_reloading = 0
		
		$sword_charge_timer.stop()
		charge_time = 0
		$sword_charge_particle.emitting = false
		$sword_charge_particle.amount = 1
		
		$arrow_charge_timer.stop()
		
	previous_weapon = present_weapon
	
	# 점프 처리
	if not rushing:
		if is_on_floor(): jump_stack = 0
		if jump and is_on_wall():
			velocity.y = wall_jump_speed
			jump_stack = 2
		elif jump and jump_stack < 2:
			velocity.y = jump_speed
			jump_stack += 1

func reload():
	if (weapon_amount[present_weapon-1][0] != weapon_amount[present_weapon-1][1]) and (weapon_reloading == 0):
		$reload_timer.start()
		weapon_reloading = 1
		yield($reload_timer,"timeout")
		weapon_reloading = 0
		weapon_amount[present_weapon-1][0] = weapon_amount[present_weapon-1][1]
		if weapon_sprite == $Bow:
			$Bow/Arrow.visible = true

func attack(t):
	if t > 1:
		if (weapon_cooltime_check == 0) and (sp >= 15):
			sp_vary(-15)
			$sp_heal_timer.start()
			var a = SwordAttack.instance()
			var pos = $Sword/attack_start_pos.global_position
			var dir = (get_global_mouse_position() - global_position).angle()
			a.damage = weapon_damage[present_weapon-1] * 2.5
			a.speed *= 6
			a.scale.x *= 2
			a.scale.y *= 2.5
			a.get_node("AnimatedSprite").animation = "charge"
			a.get_node("delete_timer").wait_time *= 1.5
			a.start(pos,dir)
			get_parent().add_child(a)
			$weapon_timer.wait_time = weapon_cooltime[present_weapon-1]
			weapon_cooltime_check = 1
			$weapon_timer.start()
			sword_attacking = true
			if (direc < (PI / 2)) and (direc > (-PI / 2)):
				$Sword.visible = false; $Sword_swing.visible = true
				$AnimationPlayer.play("swing_right")
			else:
				$Sword.visible = false; $Sword_swing.visible = true
				$AnimationPlayer.play("swing_left")
	else:
		if (weapon_cooltime_check == 0) and (sp >= 8):
			sp_vary(-8)
			$sp_heal_timer.start()
			var a = SwordAttack.instance()
			var pos = $Sword/attack_start_pos.global_position
			var dir = (get_global_mouse_position() - global_position).angle()
			a.damage = weapon_damage[present_weapon-1]
			a.start(pos,dir)
			get_parent().add_child(a)
			$weapon_timer.wait_time = weapon_cooltime[present_weapon-1]
			weapon_cooltime_check = 1
			$weapon_timer.start()
			sword_attacking = true
			if (direc < (PI / 2)) and (direc > (-PI / 2)):
				$Sword.visible = false; $Sword_swing.visible = true
				$AnimationPlayer.play("swing_right")
			else:
				$Sword.visible = false; $Sword_swing.visible = true
				$AnimationPlayer.play("swing_left")

func shoot():
	if (weapon_amount[present_weapon-1][0] > 0) and (weapon_cooltime_check == 0) and (weapon_reloading == 0):
		var b = Bullet.instance()
		var pos = $Gun/bullet_start_pos.global_position
		var dir
		if (direc < (PI / 2)) and (direc > (-PI / 2)):
			dir = $Gun.rotation
		else:
			dir = $Gun.rotation - PI
		b.speed = weapon_speed[present_weapon-1]
		b.damage = weapon_damage[present_weapon-1]
		b.rebound = present_rebound
		b.add_to_group("character_attacks")
		b.start(pos,dir,present_weapon)
		get_parent().add_child(b)
		gun_attacking = true
		$Gun.rotation += present_rebound
		weapon_amount[present_weapon-1][0] -= 1
		$weapon_timer.wait_time = weapon_cooltime[present_weapon-1]
		weapon_cooltime_check = 1
		$weapon_timer.start()

func discharge(t):
	if (weapon_amount[present_weapon-1][0] > 0) and (weapon_cooltime_check == 0) and (weapon_reloading == 0) and (sp >= 15):
		sp_vary(-15)
		
		var a = Arrow.instance()
		var pos = $Bow.global_position
		var dir
		if (direc < (PI / 2)) and (direc > (-PI / 2)):
			dir = $Bow.rotation
		else:
			dir = $Bow.rotation - PI
	
		if t < 0.2:
			a.speed = weapon_speed[present_weapon-1] - 900
			a.damage = weapon_damage[present_weapon-1] - 60
		elif (t >= 0.2) and (t < 0.5):
			a.speed = weapon_speed[present_weapon-1] - 700
			a.damage = weapon_damage[present_weapon-1] - 40
		elif (t >= 0.5) and (t < 0.7):
			a.speed = weapon_speed[present_weapon-1] - 300
			a.damage = weapon_damage[present_weapon-1] - 20
		elif t >= 0.7:
			a.speed = weapon_speed[present_weapon-1] # 1200
			a.damage = weapon_damage[present_weapon-1] # 80
	
		a.add_to_group("character_attacks")
		a.start(pos,dir)
		get_parent().add_child(a)
		weapon_amount[present_weapon-1][0] -= 1
		$weapon_timer.wait_time = weapon_cooltime[present_weapon-1]
		weapon_cooltime_check = 1
		$weapon_timer.start()
		$Bow/Arrow.visible = false
		reload()

func rush():
	if (sp >= 5):
		sp_vary(-5)
		$rush_timer.start()
		rushing = 1
		if Input.is_action_pressed("ui_left"):
			velocity.x = -500; velocity.y = 0
			$AnimatedSprite.animation = "left_rush"
		elif Input.is_action_pressed("ui_right"):
			velocity.x = 500; velocity.y = 0
			$AnimatedSprite.animation = "right_rush"
		yield(get_tree().create_timer(0.2),"timeout")
		rushing = 0

func _physics_process(delta):
	screen_size = get_viewport_rect().size
	# 키 입력과 캐릭터 이동
	if not dead:
		if not rushing:
			velocity.y += gravity_acc * delta
		current_tile = $"../Tiles/TileMap".get_cellv($"../Tiles/TileMap".world_to_map(position))
		input_process()
		velocity = move_and_slide(velocity, Vector2(0,-1))
		
		# 애니매이션 변화 및 총 위치/회전 설정	
		direc = (get_global_mouse_position() - global_position).angle()
		
		if ((weapon_sprite == $Sword) and sword_attacking == false) or (weapon_sprite == $Gun and gun_attacking == false) or (weapon_sprite == $Bow): 
			if (direc > 0) and (direc < PI / 2): weapon_sprite.rotation = direc
			elif (direc > PI / 2) and (direc < PI): weapon_sprite.rotation = -PI + direc
			elif (direc > -PI) and (direc < -PI / 2): weapon_sprite.rotation = PI + direc
			elif (direc > -PI / 2) and (direc < 0): weapon_sprite.rotation = direc
		
		if (weapon_sprite == $Gun and gun_attacking == true):
			if (direc > 0) and (direc < PI / 2): 
				var gap = weapon_sprite.rotation - direc
				weapon_sprite.rotation -= clamp(gap,-PI / 2,PI / 2) / 5
			elif (direc > PI / 2) and (direc < PI):
				var gap = weapon_sprite.rotation + PI - direc
				weapon_sprite.rotation -= clamp(gap,-PI / 2,PI / 2) / 5
			elif (direc > -PI) and (direc < -PI / 2):
				var gap = weapon_sprite.rotation - PI - direc
				weapon_sprite.rotation -= clamp(gap,-PI / 2,PI / 2) / 5
			elif (direc > -PI / 2) and (direc < 0):
				var gap = weapon_sprite.rotation - direc
				weapon_sprite.rotation -= clamp(gap,-PI / 2,PI / 2) / 5
			$Gun.animation = "shooting"
		else:
			$Gun.animation = "normal"
		
		if (direc < (PI / 2)) and (direc > (-PI / 2)):
			if not rushing:
				$AnimatedSprite.animation = "right"
			if weapon_sprite == $Sword:
				$AnimationPlayer.get_animation("swing_right").track_set_key_value(0,0,(direc * 180 / PI)-75)
				$AnimationPlayer.get_animation("swing_right").track_set_key_value(0,1,(direc * 180 / PI)+75)
				weapon_sprite.flip_h = false
				weapon_sprite.position = Vector2(25,15)
				weapon_sprite.offset = Vector2(36,0)
				$Sword/attack_start_pos.position = Vector2(70,0)
				$Sword/particle_start_pos.position = Vector2(50,0)
				
			elif weapon_sprite == $Gun:
				weapon_sprite.flip_h = false
				weapon_sprite.position = Vector2(35,12)
				weapon_sprite.offset = Vector2(12,0)
				$Gun/bullet_start_pos.position = Vector2(40,-7)
				
			elif weapon_sprite == $Bow:
				weapon_sprite.flip_h = false
				weapon_sprite.position = Vector2(40,8)
				$Bow/Arrow.flip_h = false
				
			
		else:
			if not rushing:
				$AnimatedSprite.animation = "left"
			if weapon_sprite == $Sword:
				$AnimationPlayer.get_animation("swing_left").track_set_key_value(0,0,(direc * 180 / PI)+75-180)
				$AnimationPlayer.get_animation("swing_left").track_set_key_value(0,1,(direc * 180 / PI)-75-180)
				weapon_sprite.flip_h = true
				weapon_sprite.position = Vector2(-25,15)
				weapon_sprite.offset = Vector2(-36,0)
				$Sword/attack_start_pos.position = Vector2(-70,0)
				$Sword/particle_start_pos.position = Vector2(-50,0)
				
			elif weapon_sprite == $Gun:
				weapon_sprite.flip_h = true
				$Gun.position = Vector2(-35,12)
				$Gun.offset = Vector2(-12,0)
				$Gun/bullet_start_pos.position = Vector2(-40,-7)
			
			elif weapon_sprite == $Bow:
				weapon_sprite.flip_h = true
				weapon_sprite.position = Vector2(-40,8)
				$Bow/Arrow.flip_h = true
		
		if charge_time < 0.2:
			$Bow.animation = "normal"
		elif (charge_time >= 0.2) and (charge_time < 0.5):
			$Bow.animation = "charge1"
		elif (charge_time >= 0.5) and (charge_time < 0.7):
			$Bow.animation = "charge2"
		elif charge_time >= 0.7:
			$Bow.animation = "charge3"
		
		$Sword_swing.flip_h = $Sword.flip_h
		$Sword_swing.position = $Sword.position
		$Sword_swing.offset = $Sword.offset
		
		$sword_charge_particle.global_position = $Sword/particle_start_pos.global_position
		previous_direc = direc
		
		# 카메라 설정
		if weapon_sprite == $Sword:
			$Camera2D.position.x = (get_global_mouse_position().x - position.x) / 3
			$Camera2D.position.y = (get_global_mouse_position().y - position.y) / 1.5
		elif (weapon_sprite == $Gun) or (weapon_sprite == $Bow):
			$Camera2D.position.x = (get_global_mouse_position().x - position.x) / 1.5
			$Camera2D.position.y = (get_global_mouse_position().y - position.y)
		
		# 체력,기력 관련
		$"../GUI/Bars/HP/HPBar".value = hp
		if hp <= 0:
			dead = 1
			
		if $sp_heal_timer.is_stopped():
			if sp < 100:
				sp = clamp(sp+0.5,0,100)
		$"../GUI/Bars/MarginContainer/SP/SPBar".value = sp
	else:
		$AnimatedSprite.animation = "dead"
		$Gun.visible = false
		velocity.x = 0
		velocity.y += gravity_acc * delta
		velocity = move_and_slide(velocity, Vector2(0,-1))
		if Input.is_action_just_pressed("reload") and scene_reloading == false:
			scene_reloading = true
			yield(get_parent().disable_mob_attacked(0),"completed")
			get_tree().reload_current_scene()

func _on_weapon_timer_timeout():
	weapon_cooltime_check = 0
	if weapon_sprite == $Sword:
		sword_attacking = false
	if weapon_sprite == $Gun:
		gun_attacking = false

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemy_attacks"):
		hp_vary(-body.damage)
		if body.is_in_group("bullets"):
			body.free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "swing_right" or "swing_left":
		$Sword.visible = true; $Sword_swing.visible = false


func _on_rebound_timer_timeout():
	var new_rebound = present_rebound * rand_range(-1.5,1.5)
	if new_rebound > 0: new_rebound = clamp(new_rebound,PI / weapon_rebound[present_weapon-1] * 0.5,PI / weapon_rebound[present_weapon-1] * 1.5)
	else: new_rebound = clamp(new_rebound,-PI / weapon_rebound[present_weapon-1] * 1.5,-PI / weapon_rebound[present_weapon-1] * 0.5)
	present_rebound = new_rebound


func _on_knockback_timer_timeout():
	knockbacked = false


func _on_sword_charge_timer_timeout():
	charge_time += 0.1
	if charge_time >= 1:
		$sword_charge_particle.emitting = true

func _on_arrow_charge_timer_timeout():
	charge_time += 0.1
