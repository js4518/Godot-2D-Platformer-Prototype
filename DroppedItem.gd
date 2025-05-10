extends KinematicBody2D

var item_tileset
var item_info = []

var gravity_acc = 600
var velocity = Vector2(0,0)
var speed = 50
var moving_to_character = 0


func _ready():
	item_tileset = [$BlockAsset.get_tileset(),$ConsumeAsset.get_tileset(),$WeaponAsset.get_tileset()]

func start(p,s,c,a):
	item_tileset = [$BlockAsset.get_tileset(),$ConsumeAsset.get_tileset(),$WeaponAsset.get_tileset()]
	$Sprite.texture = item_tileset[s].tile_get_texture(0)
	var tile_pos = item_tileset[s].tile_get_region(c).position
	$Sprite.set_region_rect(Rect2(tile_pos,Vector2(64,64)))
	item_info = [s,c,a]
	position = p

func _physics_process(delta):
	if moving_to_character:
		var direc = ($"../Character".position - position).angle()
		velocity = Vector2(speed,0).rotated(direc)
		velocity = move_and_slide(velocity)
		speed = clamp(speed+2.5,50,400)
	else:
		velocity.x = 0
		speed = 50
		velocity.y += gravity_acc * delta
		velocity = move_and_slide(velocity)

func _on_pickup_area_body_entered(body):
	if body.is_in_group("character"):
		moving_to_character = 1


func _on_pickup_area_body_exited(body):
	if body.is_in_group("character"):
		moving_to_character = 0


func _on_get_area_body_entered(body):
	if body.is_in_group("character"):
		print($"../Inventory".add_item(item_info[0],item_info[1],item_info[2]))
		queue_free()
