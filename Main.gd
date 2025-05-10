extends Node

var MeleeMob = preload("res://MeleeMob.tscn")
var RangeMob = preload("res://RangeMob.tscn")
var score = 0

var mobs_attack_active = true
var mobs_detect_active = true


func _ready():
	randomize()

func disable_mob_attacked(id):
	var inst = instance_from_id(id)
	yield(get_tree().create_timer(5),"timeout")
	if is_instance_valid(inst):
		inst.state_attacked = false

func _process(_delta):
	
	if Input.is_action_just_pressed("open_inventory"):
		$Inventory.open_inventory()
	
	if not $Character.dead:
		
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
		
		if Input.is_action_just_pressed("mob_spawn"):
			for _i in range(2):
				var m = MeleeMob.instance()
				var r = RangeMob.instance()
				add_child(m)
				add_child(r)
				$Path2D/PathFollow2D.offset = rand_range(0,740)
				m.start($Path2D/PathFollow2D.position,0)
				$Path2D/PathFollow2D.offset = rand_range(0,740)
				r.start($Path2D/PathFollow2D.position,0)
		
		if Input.is_action_just_pressed("mob_active"):
			if mobs_attack_active == true:
				mobs_attack_active = false
			else:
				mobs_attack_active = true


# 인벤토리 및 아이템 : 아이템 버리기(드랍)/옮기기
# 문 만들기
# 스킬 추가
# 다른 맵 추가(씬 교체보다는 그냥 메인 씬 내에서 다른 위치로 이동하게만 하면 되긴 함)(물론 씬 교체도 실험해봐야함 변수 유지 공부 필요하니)
# 캐릭터 모양 제대로

func _on_MapScale_body_exited(body):
	if body.is_in_group("character_attacks") or body.is_in_group("enemy_attacks"):
		body.queue_free()
