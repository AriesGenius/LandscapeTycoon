extends CharacterBody2D

@export var base_speed: float = 150.0

var current_speed: float = 150.0
var nearby_building: Area2D = null

func _ready() -> void:
	add_to_group("player")
	_update_speed()
	print("Player ready! Speed: ", current_speed)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_interaction()

func _handle_movement(delta: float) -> void:
	# 获取输入
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()

	# 应用移动
	if input_vector != Vector2.ZERO:
		velocity = input_vector * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed * delta * 10)

	move_and_slide()

func _handle_interaction() -> void:
	if Input.is_action_just_pressed("interact") and nearby_building:
		_interact_with_building()

func _interact_with_building() -> void:
	if not nearby_building:
		return

	print("Interacting with: ", nearby_building.building_name)

	match nearby_building.building_type:
		"task_center":
			# 打开任务面板
			var task_panel = get_tree().get_first_node_in_group("task_panel")
			if task_panel:
				task_panel.show_panel()
		"company":
			# 打开属性面板
			var attr_panel = get_tree().get_first_node_in_group("attribute_panel")
			if attr_panel:
				attr_panel.show_panel()
			else:
				print("AttributePanel not found in scene tree")
		"shop":
			# 打开工具商店面板
			var shop_panel = get_tree().get_first_node_in_group("shop_panel")
			if shop_panel:
				shop_panel.show_panel()
			else:
				print("ShopPanel not found in scene tree")
		"material_shop":
			# 打开材料商店面板（花店/建材市场）
			var mat_panel = get_tree().get_first_node_in_group("material_shop")
			if mat_panel:
				# 如果有活动任务，为该任务选择材料
				if not TaskManager.active_task.is_empty():
					mat_panel.show_for_task(TaskManager.active_task)
				else:
					print("请先接取任务再购买材料")
					if is_instance_valid(NotificationSystem):
						NotificationSystem.show_toast("请先接取任务再购买材料", Color.ORANGE_RED)
			else:
				print("MaterialShopPanel not found")
		"client":
			# 开始工作
			if TaskManager.active_task.is_empty():
				print("请先接取任务！")
			else:
				print("Starting work at client house")
				GameManager.start_work()

func _update_speed() -> void:
	# 敏捷影响移动速度
	var agility_bonus = 1.0 + (PlayerData.agility / 100.0)
	current_speed = base_speed * agility_bonus
	print("Speed updated: ", current_speed, " (agility: ", PlayerData.agility, ")")

# 由建筑物调用
func set_nearby_building(building: Area2D) -> void:
	nearby_building = building

func clear_nearby_building(building: Area2D) -> void:
	if nearby_building == building:
		nearby_building = null
