extends Node2D

var icon = preload("res://asset/item_img_test.png")

var current_inven
var item_position = []
var item_tileset

func _ready():
	current_inven = get_parent().current_inven
	item_tileset = [$BlockAsset.get_tileset(),$ConsumeAsset.get_tileset(),$WeaponAsset.get_tileset()]
	for i in range(40,600+1,80):
		for k in range(40,600+1,80):
			item_position.append(Vector2(k,i))

func _draw():
	for i in item_position.size():
		draw_rect(Rect2(item_position[i] - Vector2(32,32),Vector2(64,64)),Color(0.082353, 0.082353, 0.082353, 0.45098))
	var s = 0
	for k in current_inven:
		var font = $Control.get_font("font")
		var string_length = font.get_string_size(str(current_inven[s][2]))
		var tile_pos = item_tileset[k[0]].tile_get_region(k[1]).position
		draw_texture_rect_region(item_tileset[k[0]].tile_get_texture(0),Rect2(item_position[s] - Vector2(32,32),Vector2(64,64)),Rect2(tile_pos,Vector2(64,64)))
		draw_string(font,item_position[s] + Vector2(10,26) + Vector2(20-string_length.x,0),str(current_inven[s][2]))
		s += 1

func _process(_delta):
	current_inven = get_parent().current_inven
	if get_parent().active == true:
		visible = true
	else:
		visible = false
