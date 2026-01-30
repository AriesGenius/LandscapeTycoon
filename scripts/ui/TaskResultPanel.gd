extends CanvasLayer

var title_label: Label
var rating_label: Label
var reward_label: Label
var reputation_label: Label
var experience_label: Label
var continue_button: Button

func _ready() -> void:
	# 安全获取节点
	var vbox = get_node_or_null("CenterContainer/Panel/MarginContainer/VBoxContainer")
	if vbox:
		title_label = vbox.get_node_or_null("TitleLabel")
		rating_label = vbox.get_node_or_null("RatingLabel")
		reward_label = vbox.get_node_or_null("RewardLabel")
		reputation_label = vbox.get_node_or_null("ReputationLabel")
		experience_label = vbox.get_node_or_null("ExperienceLabel")
		continue_button = vbox.get_node_or_null("ContinueButton")
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	
	hide()
	print("TaskResultPanel initialized")

func show_result(result: Dictionary) -> void:
	if result.is_empty():
		print("TaskResultPanel: Empty result!")
		return
	
	# 设置标题
	if title_label:
		title_label.text = "任务完成！"
	
	# 设置评分
	var stars = ""
	for i in range(result.rating):
		stars += "⭐"
	
	if rating_label:
		rating_label.text = "评分: " + stars + " (" + str(result.rating) + "星)"
		# 根据评分设置颜色
		if result.rating >= 4:
			rating_label.add_theme_color_override("font_color", Color.GOLD)
		elif result.rating >= 3:
			rating_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
		else:
			rating_label.add_theme_color_override("font_color", Color.GRAY)
	
	# 设置奖励信息
	if reward_label:
		reward_label.text = "💰 获得: " + str(result.reward) + " 金"
	if reputation_label:
		reputation_label.text = "⭐ 声望: +" + str(result.reputation)
	if experience_label:
		experience_label.text = "📊 经验: +" + str(result.experience)
	
	show()
	print("TaskResultPanel shown with rating: ", result.rating)

func _on_continue_pressed() -> void:
	print("Returning to city...")
	GameManager.return_to_city()
