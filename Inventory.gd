extends CanvasLayer


var block_list = [["잔디흙",64,0],["흙",64,0]]
var consume_list = [["체력포션",8,0],["마나포션",8,0]]
var weapon_list = [["칼",1,0],["총",1,0],["활",1,0]]
var item_list = [block_list,consume_list,weapon_list]
var current_inven = [[0,0,64],[0,0,64],[0,1,5],[1,1,2],[2,0,1],[0,0,64],[1,0,7]]

var active = false
var check = 0

func _ready():
	pass

func open_inventory():
	if active == true:
		active = false
	else:
		active = true

func update_display():
	$ItemDisplay.update()

func update_total_amount():
	for l in item_list.size():
		for i in item_list[l].size():
			item_list[l][i][2] = 0
	
	for l in item_list.size():
		for i in item_list[l].size():
			for k in current_inven:
				if (k[0] == l) and (k[1] == i):
					item_list[l][i][2] += k[2]

func add_item(s,c,a):
	if a == 0 : return false
	
	if current_inven.size() == 64: 
		if current_inven[63][2] == item_list[current_inven[63][0]][current_inven[63][1]][1]:
			return false
	
	var max_amount = item_list[s][c][1]
	
	var have = 0
	for i in range(1,max_amount+1):
		if [s,c,i] in current_inven:
			have = 1
			break
	if a <= max_amount:
		if not have:
			current_inven.append([s,c,a])
		else:
			var lack_idx
			for i in range(1,max_amount+1):
				lack_idx = current_inven.find_last([s,c,i])
				if lack_idx != -1:
					break
			var current_amount = current_inven[lack_idx][2]
			if current_amount + a <= max_amount:
				current_amount += a
			else:
				current_inven.append([s,c,a-(max_amount-current_amount)])
				current_amount = max_amount
			current_inven[lack_idx][2] = current_amount
	else:
		if not have:
			current_inven.append([s,c,max_amount])
			add_item(s,c,a-max_amount)
		else:
			var lack_idx
			for i in range(1,max_amount+1):
				lack_idx = current_inven.find_last([s,c,i])
				if lack_idx != -1:
					break
			var current_amount = current_inven[lack_idx][2]
			var bundle_amount = int((a - (max_amount - current_amount)) / max_amount)
			var remain_amount = (a - (max_amount - current_amount)) % max_amount
			current_amount = max_amount
			for _i in range(bundle_amount):
				current_inven.append([s,c,max_amount])
			if remain_amount != 0:
				current_inven.append([s,c,remain_amount])
			current_inven[lack_idx][2] = current_amount
	update_total_amount()
	return true

func consume_item(s,c,a):
	if a == 0 : return false
	var max_amount = item_list[s][c][1]
	
	var have = 0
	for i in range(1,max_amount+1):
		if [s,c,i] in current_inven:
			have = 1
			break
	if have:
		var change_idx
		for i in range(1,max_amount+1):
			change_idx = current_inven.find_last([s,c,i])
			if change_idx != -1:
				break
		var current_amount = current_inven[change_idx][2]
		if current_amount > a:
			current_amount -= a
			current_inven[change_idx][2] = current_amount
			update_total_amount()
			return true
		elif current_amount == a:
			current_inven.remove(change_idx)
			update_total_amount()
			return true
		elif current_amount < a:
			if item_list[s][c][2] >= a:
				current_inven.remove(change_idx)
				consume_item(s,c,a-current_amount)
			else:
				update_total_amount()
				return false
	else:
		return false
			
func _process(_delta):
	if active:
		$Window.visible = true
		update_display()
		#print(current_inven)
		#print(item_list)
	else:
		$Window.visible = false
