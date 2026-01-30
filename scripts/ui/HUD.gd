extends CanvasLayer

@onready var player_name_label: Label = $Panel/VBoxContainer/PlayerNameLabel
@onready var gold_label: Label = $Panel/VBoxContainer/GoldLabel
@onready var reputation_label: Label = $Panel/VBoxContainer/ReputationLabel
@onready var level_label: Label = $Panel/VBoxContainer/LevelLabel
@onready var attribute_points_label: Label = $Panel/VBoxContainer/AttributePointsLabel
@onready var strength_label: Label = $Panel/VBoxContainer/AttributesContainer/StrengthLabel
@onready var agility_label: Label = $Panel/VBoxContainer/AttributesContainer/AgilityLabel
@onready var dexterity_label: Label = $Panel/VBoxContainer/AttributesContainer/DexterityLabel

func _ready() -> void:
	# 连接信号
	PlayerData.gold_changed.connect(_update_gold)
	PlayerData.attribute_changed.connect(_update_attributes)
	PlayerData.level_up.connect(_on_level_up)
	PlayerData.reputation_changed.connect(_update_reputation)
	
	# 初始化显示
	_update_all()
	
	print("HUD initialized")

func _update_all() -> void:
	player_name_label.text = "玩家: " + PlayerData.player_name
	_update_gold(PlayerData.gold)
	_update_reputation(PlayerData.reputation)
	_update_level()
	_update_attributes()

func _update_gold(amount: int) -> void:
	gold_label.text = "💰 金币: " + str(amount)
	_pulse_label(gold_label, Color.GOLD)

func _update_reputation(amount: int) -> void:
	var tier = PlayerData.get_reputation_tier()
	reputation_label.text = "⭐ 声望: " + str(amount) + " (" + tier + ")"
	_pulse_label(reputation_label, Color.MEDIUM_PURPLE)

func _update_level() -> void:
	var exp_needed = PlayerData.level * 500
	level_label.text = "📊 等级: " + str(PlayerData.level) + " (EXP: " + str(PlayerData.experience) + "/" + str(exp_needed) + ")"

func _update_attributes() -> void:
	strength_label.text = "💪 力量: " + str(PlayerData.strength)
	agility_label.text = "⚡ 敏捷: " + str(PlayerData.agility)
	dexterity_label.text = "✋ 灵巧: " + str(PlayerData.dexterity)
	
	# 显示可分配属性点
	if PlayerData.attribute_points > 0:
		attribute_points_label.text = "🎯 可分配属性点: " + str(PlayerData.attribute_points)
		attribute_points_label.visible = true
	else:
		attribute_points_label.visible = false

func _on_level_up(new_level: int, points: int) -> void:
	print("HUD: Level up notification - Level ", new_level)
	_update_level()
	_update_attributes()
	_pulse_label(level_label, Color.GOLD)
	if is_instance_valid(CameraEffects):
		CameraEffects.shake(3.0, 0.3)
		CameraEffects.flash(Color(1, 0.85, 0, 0.2), 0.3)

var _label_tweens: Dictionary = {}

func _pulse_label(label: Label, _color: Color) -> void:
	if not is_instance_valid(label):
		return
	if _label_tweens.has(label) and is_instance_valid(_label_tweens[label]):
		_label_tweens[label].kill()
	label.scale = Vector2(1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_IN)
	_label_tweens[label] = tween
