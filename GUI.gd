extends CanvasLayer

var MeleeMob = preload("res://MeleeMob.tscn")
var RangeMob = preload("res://RangeMob.tscn")
var screen_size

func _ready():
	pass

func _process(_delta):
	screen_size = $"../Character".screen_size
	$DeadColor.rect_size = screen_size
	if not $"../Character".dead:
		$Labels/SettingInfoBox/velocity_x.text = "속도(x) : " + str(int($"../Character".velocity.x))
		$Labels/SettingInfoBox/velocity_y.text = "속도(y) : " + str(int($"../Character".velocity.y))
		$Labels/SettingInfoBox/is_mobs_active.text = "몹 공격 : " + str(get_parent().mobs_attack_active)
		$Labels/WeaponInfoBox/HBoxContainer/weapon_amount.text = str($"../Character".weapon_amount[$"../Character".present_weapon-1][0]) + "/" + str($"../Character".weapon_amount[$"../Character".present_weapon-1][1])
		$Labels/WeaponInfoBox/HBoxContainer/present_weapon.text = "[" + str($"../Character".present_weapon) + "] " + str($"../Character".weapon_name[$"../Character".present_weapon-1])
		if $"../Character"/reload_timer.time_left > 0:
			$Labels/WeaponInfoBox/weapon_reloading.text = "장전중... " + str(stepify($"../Character"/reload_timer.time_left,0.1))
		else:
			$Labels/WeaponInfoBox/weapon_reloading.text = ""
		$Labels/SettingInfoBox/score.text = str(get_parent().score)
		$Bars/HP/HPBar/HPBarText.text = str($Bars/HP/HPBar.value) + "%"
		$Bars/MarginContainer/SP/SPBar/SPBarText.text = str($Bars/MarginContainer/SP/SPBar.value) + "%"
		
		$Labels/WeaponInfoBox.visible = true
		$Labels/SettingInfoBox.visible = true
		$Bars.visible = true
		$DeadInfo/dead.visible = false
		$DeadInfo/restart.visible = false
		$DeadColor.visible = false
	
	else:
		$Bars/HP/HPBar/HPBarText.text = "0%"
		
		$Labels/WeaponInfoBox.visible = false
		$Labels/SettingInfoBox.visible = false
		$Bars.visible = false
		$DeadInfo/dead.visible = true
		$DeadInfo/restart.visible = true
		
		if ($Tween.is_active() == false) and ($DeadColor.visible == false):
			$DeadColor.visible = true
			$Tween.interpolate_property($DeadColor,"color:a",0,0.9,4)
			$Tween.start()


func _on_MeleeSummon_pressed():
	var m = MeleeMob.instance()
	get_parent().add_child(m)
	$"../Path2D/PathFollow2D".offset = rand_range(0,740)
	m.start($"../Path2D/PathFollow2D".position,0)


func _on_RangeSummon_pressed():
	var r = RangeMob.instance()
	get_parent().add_child(r)
	$"../Path2D/PathFollow2D".offset = rand_range(0,740)
	r.start($"../Path2D/PathFollow2D".position,0)
