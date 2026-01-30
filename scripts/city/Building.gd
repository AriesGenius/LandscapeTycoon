extends Area2D

@export var building_name: String = "建筑"
@export_enum("company", "shop", "task_center", "client", "material_shop") var building_type: String = "generic"
@export var manual_texture: Texture2D = null
@export var shop_category: String = ""  # 材料商店用: "grass_seed", "flowers", "bricks", "fence"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = null

func _ready() -> void:
	# 优先使用手动纹理，否则根据类型自动加载
	if manual_texture:
		if sprite:
			sprite.texture = manual_texture
			print("Building: 使用手动纹理 for ", building_name)
	else:
		_load_texture_by_type()
	# 创建标签（如果没有子节点Label）
	if not has_node("Label"):
		label = Label.new()
		add_child(label)
		label.position = Vector2(-30, -40)  # 在建筑上方
	else:
		label = $Label
	
	label.text = building_name
	label.visible = false
	label.add_theme_font_size_override("font_size", 14)
	
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 任务目标高亮检测
	add_to_group("buildings")

	print("Building ready: ", building_name, " (", building_type, ")")

func _process(_delta: float) -> void:
	# 如果此建筑是当前任务的目标客户，闪烁高亮
	if building_type == "client" and not TaskManager.active_task.is_empty():
		var target = TaskManager.active_task.get("client_name", "")
		if target == building_name:
			# 黄色脉冲高亮
			var t = fmod(Time.get_ticks_msec() / 500.0, TAU)
			var pulse = 0.7 + 0.3 * sin(t)
			if sprite:
				sprite.modulate = Color(1.0, 1.0, pulse, 1.0)
			return
	# 恢复正常颜色
	if sprite and building_type == "client":
		sprite.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = true
		body.set_nearby_building(self)
		
		# 显示互动提示
		var prompt = get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.show_prompt("按 E 进入 " + building_name)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = false
		body.clear_nearby_building(self)
		
		# 隐藏互动提示
		var prompt = get_tree().get_first_node_in_group("interaction_prompt")
		if prompt:
			prompt.hide_prompt()

func _load_texture_by_type() -> void:
	"""根据建筑类型自动加载对应的纹理"""
	if not sprite:
		push_warning("Building: Sprite2D 节点未找到")
		return
	
	var texture_path = ""
	
	match building_type:
		"company":
			texture_path = "res://assets/sprites/company.svg"
		"task_center":
			texture_path = "res://assets/sprites/task_center.svg"
		"client":
			texture_path = "res://assets/sprites/client_house.svg"
		"shop":
			texture_path = "res://assets/sprites/shop.svg"
		_:
			push_warning("Building: 未知的建筑类型 ", building_type)
			return
	
	# 检查文件是否存在
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
		print("Building: 已加载纹理 ", texture_path, " for ", building_name)
	else:
		push_warning("Building: 纹理文件不存在 ", texture_path)
