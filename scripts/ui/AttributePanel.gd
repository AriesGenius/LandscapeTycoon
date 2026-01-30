extends CanvasLayer

var panel: Panel
var strength_label: Label
var agility_label: Label
var dexterity_label: Label
var points_label: Label
var reputation_label: Label
var stats_label: Label
var str_button: Button
var agi_button: Button
var dex_button: Button
var close_button: Button

func _ready() -> void:
	add_to_group("attribute_panel")

	panel = get_node_or_null("CenterContainer/Panel")
	if panel:
		var vbox = panel.get_node_or_null("MarginContainer/VBoxContainer")
		if vbox:
			points_label = vbox.get_node_or_null("PointsLabel")
			reputation_label = vbox.get_node_or_null("ReputationLabel")
			stats_label = vbox.get_node_or_null("StatsLabel")

			var str_row = vbox.get_node_or_null("StrengthRow")
			if str_row:
				strength_label = str_row.get_node_or_null("StrengthLabel")
				str_button = str_row.get_node_or_null("StrengthButton")
				if str_button:
					str_button.pressed.connect(_on_strength_pressed)

			var agi_row = vbox.get_node_or_null("AgilityRow")
			if agi_row:
				agility_label = agi_row.get_node_or_null("AgilityLabel")
				agi_button = agi_row.get_node_or_null("AgilityButton")
				if agi_button:
					agi_button.pressed.connect(_on_agility_pressed)

			var dex_row = vbox.get_node_or_null("DexterityRow")
			if dex_row:
				dexterity_label = dex_row.get_node_or_null("DexterityLabel")
				dex_button = dex_row.get_node_or_null("DexterityButton")
				if dex_button:
					dex_button.pressed.connect(_on_dexterity_pressed)

			close_button = vbox.get_node_or_null("CloseButton")
			if close_button:
				close_button.pressed.connect(_on_close_pressed)

	hide()
	print("AttributePanel initialized")

func show_panel() -> void:
	_update_display()
	show()

func _update_display() -> void:
	if strength_label:
		strength_label.text = "力量: " + str(PlayerData.strength)
	if agility_label:
		agility_label.text = "敏捷: " + str(PlayerData.agility)
	if dexterity_label:
		dexterity_label.text = "灵巧: " + str(PlayerData.dexterity)
	if points_label:
		points_label.text = "可分配属性点: " + str(PlayerData.attribute_points)
	if reputation_label:
		var tier = PlayerData.get_reputation_tier()
		reputation_label.text = "声望: " + str(PlayerData.reputation) + " (" + tier + ")"
	if stats_label:
		var avg = PlayerData.get_average_rating()
		stats_label.text = "已完成任务: " + str(PlayerData.completed_tasks) + " | 平均评分: " + ("%.1f" % avg) + " | 五星: " + str(PlayerData.five_star_tasks)

	var has_points = PlayerData.attribute_points > 0
	if str_button:
		str_button.disabled = not has_points
	if agi_button:
		agi_button.disabled = not has_points
	if dex_button:
		dex_button.disabled = not has_points

func _on_strength_pressed() -> void:
	PlayerData.allocate_attribute("strength")
	_update_display()

func _on_agility_pressed() -> void:
	PlayerData.allocate_attribute("agility")
	_update_display()

func _on_dexterity_pressed() -> void:
	PlayerData.allocate_attribute("dexterity")
	_update_display()

func _on_close_pressed() -> void:
	hide()
