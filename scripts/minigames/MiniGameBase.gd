extends CanvasLayer

# 小游戏基类
signal minigame_completed(score: float)  # 0.0 - 1.0

var is_active: bool = false
var dexterity_bonus: float = 0.0

func _ready() -> void:
	# 灵巧属性加成：每点增加2%容错
	dexterity_bonus = PlayerData.dexterity * 0.02
	hide()

func start_minigame() -> void:
	is_active = true
	show()

func end_minigame(score: float) -> void:
	is_active = false
	hide()
	minigame_completed.emit(clampf(score, 0.0, 1.0))
