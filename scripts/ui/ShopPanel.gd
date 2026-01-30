extends CanvasLayer

# 工具商店数据：5类工具，每类4-5个品牌
const SHOP_TOOLS = {
	"shovel": {
		"category_name": "铲子",
		"items": [
			{"name": "普通铲子", "price": 0, "efficiency": 1.0},
			{"name": "钢制铲子", "price": 200, "efficiency": 1.3},
			{"name": "合金铲子", "price": 500, "efficiency": 1.6},
			{"name": "钛合金铲子", "price": 1200, "efficiency": 2.0},
			{"name": "大师铲子", "price": 3000, "efficiency": 2.5},
		]
	},
	"mower": {
		"category_name": "剪草机",
		"items": [
			{"name": "手动推剪", "price": 0, "efficiency": 1.0},
			{"name": "电动推剪", "price": 300, "efficiency": 1.4},
			{"name": "汽油割草机", "price": 800, "efficiency": 1.8},
			{"name": "骑乘式割草机", "price": 2000, "efficiency": 2.3},
		]
	},
	"broom": {
		"category_name": "扫帚",
		"items": [
			{"name": "塑料扫帚", "price": 0, "efficiency": 1.0},
			{"name": "竹扫帚", "price": 150, "efficiency": 1.2},
			{"name": "工业扫帚", "price": 400, "efficiency": 1.5},
			{"name": "电动清扫机", "price": 1000, "efficiency": 2.0},
			{"name": "专业清扫车", "price": 2500, "efficiency": 2.5},
		]
	},
	"level": {
		"category_name": "水平仪",
		"items": [
			{"name": "传统水平仪", "price": 0, "efficiency": 1.0, "accuracy": 0},
			{"name": "铝合金水平仪", "price": 250, "efficiency": 1.3, "accuracy": 1},
			{"name": "数字水平仪", "price": 600, "efficiency": 1.6, "accuracy": 2},
			{"name": "激光水平仪", "price": 1500, "efficiency": 2.0, "accuracy": 3},
		]
	},
	"hammer": {
		"category_name": "锤子",
		"items": [
			{"name": "木柄锤", "price": 0, "efficiency": 1.0},
			{"name": "钢柄锤", "price": 180, "efficiency": 1.3},
			{"name": "橡胶锤", "price": 450, "efficiency": 1.5},
			{"name": "气动锤", "price": 1100, "efficiency": 2.0},
			{"name": "专业气锤", "price": 2800, "efficiency": 2.5},
		]
	}
}

var panel: Panel
var category_list: VBoxContainer
var item_list: VBoxContainer
var gold_label: Label
var equipped_label: Label
var close_button: Button
var current_category: String = "shovel"

func _ready() -> void:
	add_to_group("shop_panel")

	panel = get_node_or_null("CenterContainer/Panel")
	if panel:
		var vbox = panel.get_node_or_null("MarginContainer/VBoxContainer")
		if vbox:
			gold_label = vbox.get_node_or_null("GoldLabel")
			equipped_label = vbox.get_node_or_null("EquippedLabel")
			close_button = vbox.get_node_or_null("CloseButton")

			var content = vbox.get_node_or_null("ContentHBox")
			if content:
				category_list = content.get_node_or_null("CategoryList")
				var scroll = content.get_node_or_null("ScrollContainer")
				if scroll:
					item_list = scroll.get_node_or_null("ItemList")

			if close_button:
				close_button.pressed.connect(_on_close_pressed)

	hide()
	print("ShopPanel initialized")

func show_panel() -> void:
	_build_categories()
	_show_category("shovel")
	_update_gold()
	_update_equipped()
	show()

func _build_categories() -> void:
	if not category_list:
		return
	for child in category_list.get_children():
		child.queue_free()

	for cat_key in SHOP_TOOLS:
		var btn = Button.new()
		btn.text = SHOP_TOOLS[cat_key].category_name
		btn.custom_minimum_size = Vector2(100, 35)
		btn.pressed.connect(_show_category.bind(cat_key))
		category_list.add_child(btn)

func _show_category(cat_key: String) -> void:
	current_category = cat_key
	if not item_list:
		return

	for child in item_list.get_children():
		child.queue_free()

	var cat = SHOP_TOOLS[cat_key]
	for tool_data in cat.items:
		var row = HBoxContainer.new()

		var name_label = Label.new()
		name_label.text = tool_data.name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var eff_label = Label.new()
		eff_label.text = "效率: x" + str(tool_data.efficiency)
		eff_label.custom_minimum_size = Vector2(100, 0)
		row.add_child(eff_label)

		var price_label = Label.new()
		price_label.text = str(tool_data.price) + "金"
		price_label.custom_minimum_size = Vector2(80, 0)
		row.add_child(price_label)

		var btn = Button.new()
		# Check if already equipped
		var equipped = PlayerData.equipped_tools.get(cat_key, {})
		if equipped.get("name", "") == tool_data.name:
			btn.text = "已装备"
			btn.disabled = true
		elif tool_data.price == 0:
			btn.text = "装备"
			btn.pressed.connect(_equip_tool.bind(cat_key, tool_data))
		elif PlayerData.gold < tool_data.price:
			btn.text = "金币不足"
			btn.disabled = true
		else:
			btn.text = "购买"
			btn.pressed.connect(_buy_tool.bind(cat_key, tool_data))

		btn.custom_minimum_size = Vector2(80, 30)
		row.add_child(btn)

		item_list.add_child(row)

func _buy_tool(cat_key: String, tool_data: Dictionary) -> void:
	if PlayerData.spend_gold(tool_data.price):
		_equip_tool(cat_key, tool_data)

func _equip_tool(cat_key: String, tool_data: Dictionary) -> void:
	PlayerData.equip_tool(cat_key, tool_data.duplicate())
	_show_category(current_category)
	_update_gold()
	_update_equipped()

func _update_gold() -> void:
	if gold_label:
		gold_label.text = "金币: " + str(PlayerData.gold)

func _update_equipped() -> void:
	if equipped_label:
		var parts = []
		for key in PlayerData.equipped_tools:
			parts.append(PlayerData.equipped_tools[key].get("name", "无"))
		equipped_label.text = "当前装备: " + ", ".join(parts)

func _on_close_pressed() -> void:
	hide()
