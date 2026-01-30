extends CanvasLayer

# 材料数据：4类材料，各3-4个等级
const MATERIALS = {
	"grass_seed": {
		"category_name": "草籽",
		"task_types": ["lawn"],
		"items": [
			{"name": "普通草籽", "grade": 1, "price_mult": 1.0, "quality_bonus": 0.0, "required_reputation": 0},
			{"name": "优质草籽", "grade": 2, "price_mult": 1.5, "quality_bonus": 0.05, "required_reputation": 50},
			{"name": "进口草籽", "grade": 3, "price_mult": 2.5, "quality_bonus": 0.10, "required_reputation": 200},
			{"name": "顶级草籽", "grade": 4, "price_mult": 4.0, "quality_bonus": 0.15, "required_reputation": 500},
		]
	},
	"flowers": {
		"category_name": "花卉",
		"task_types": ["plant"],
		"items": [
			{"name": "普通花苗", "grade": 1, "price_mult": 1.0, "quality_bonus": 0.0, "required_reputation": 0},
			{"name": "精选花苗", "grade": 2, "price_mult": 1.8, "quality_bonus": 0.05, "required_reputation": 100},
			{"name": "名贵花种", "grade": 3, "price_mult": 3.0, "quality_bonus": 0.12, "required_reputation": 300},
		]
	},
	"bricks": {
		"category_name": "砖块",
		"task_types": ["brick"],
		"items": [
			{"name": "普通红砖", "grade": 1, "price_mult": 1.0, "quality_bonus": 0.0, "required_reputation": 0},
			{"name": "烧结砖", "grade": 2, "price_mult": 1.6, "quality_bonus": 0.05, "required_reputation": 100},
			{"name": "仿古砖", "grade": 3, "price_mult": 2.8, "quality_bonus": 0.10, "required_reputation": 300},
			{"name": "大理石砖", "grade": 4, "price_mult": 5.0, "quality_bonus": 0.18, "required_reputation": 600},
		]
	},
	"fence": {
		"category_name": "围栏",
		"task_types": ["fence"],
		"items": [
			{"name": "木质围栏", "grade": 1, "price_mult": 1.0, "quality_bonus": 0.0, "required_reputation": 0},
			{"name": "铁艺围栏", "grade": 2, "price_mult": 2.0, "quality_bonus": 0.08, "required_reputation": 300},
			{"name": "不锈钢围栏", "grade": 3, "price_mult": 3.5, "quality_bonus": 0.15, "required_reputation": 600},
		]
	}
}

var panel: Panel
var item_list: VBoxContainer
var close_button: Button
var selected_material: Dictionary = {}
var pending_task: Dictionary = {}

signal material_selected(task: Dictionary, material: Dictionary)

func _ready() -> void:
	add_to_group("material_shop")

	panel = get_node_or_null("CenterContainer/Panel")
	if panel:
		var vbox = panel.get_node_or_null("MarginContainer/VBoxContainer")
		if vbox:
			var scroll = vbox.get_node_or_null("ScrollContainer")
			if scroll:
				item_list = scroll.get_node_or_null("ItemList")
			close_button = vbox.get_node_or_null("CloseButton")
			if close_button:
				close_button.pressed.connect(_on_close_pressed)

	hide()
	print("MaterialShopPanel initialized")

func show_for_task(task: Dictionary) -> void:
	pending_task = task
	_populate_materials(task)
	show()

func _populate_materials(task: Dictionary) -> void:
	if not item_list:
		return

	for child in item_list.get_children():
		child.queue_free()

	var task_type = task.get("type", "")
	var found = false

	for mat_key in MATERIALS:
		var mat_cat = MATERIALS[mat_key]
		if task_type in mat_cat.task_types:
			found = true
			var header = Label.new()
			header.text = "--- " + mat_cat.category_name + " ---"
			header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			item_list.add_child(header)

			for item in mat_cat.items:
				var row = HBoxContainer.new()

				var name_label = Label.new()
				name_label.text = item.name
				name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(name_label)

				var cost = int(task.material_cost * item.price_mult)
				var cost_label = Label.new()
				cost_label.text = str(cost) + "金"
				cost_label.custom_minimum_size = Vector2(80, 0)
				row.add_child(cost_label)

				var bonus_label = Label.new()
				bonus_label.text = "+" + str(int(item.quality_bonus * 100)) + "%质量"
				bonus_label.custom_minimum_size = Vector2(80, 0)
				row.add_child(bonus_label)

				var btn = Button.new()
				if item.required_reputation > PlayerData.reputation:
					btn.text = "声望不足(" + str(item.required_reputation) + ")"
					btn.disabled = true
				elif PlayerData.gold < cost:
					btn.text = "金币不足"
					btn.disabled = true
				else:
					btn.text = "选择"
					btn.pressed.connect(_on_material_selected.bind(item, cost))
				btn.custom_minimum_size = Vector2(100, 30)
				row.add_child(btn)

				item_list.add_child(row)

	if not found:
		# No specific material needed, use default
		var label = Label.new()
		label.text = "此任务使用基础材料"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_list.add_child(label)

		var btn = Button.new()
		btn.text = "使用基础材料"
		btn.pressed.connect(_on_material_selected.bind({"name": "基础材料", "quality_bonus": 0.0, "price_mult": 1.0}, task.material_cost))
		item_list.add_child(btn)

func _on_material_selected(material: Dictionary, actual_cost: int) -> void:
	selected_material = material
	pending_task["actual_material_cost"] = actual_cost
	pending_task["material_quality_bonus"] = material.get("quality_bonus", 0.0)
	pending_task["material_name"] = material.get("name", "基础材料")
	material_selected.emit(pending_task, material)
	hide()

func _on_close_pressed() -> void:
	hide()
