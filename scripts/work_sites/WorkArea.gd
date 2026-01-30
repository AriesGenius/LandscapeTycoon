extends Area2D

signal work_completed

@export var base_work_time: float = 5.0  # 基础工作时间（秒）

var work_type: String = "strength"  # strength, agility, dexterity
var is_working: bool = false
var work_progress: float = 0.0
var player_in_area: bool = false
var is_completed: bool = false
var minigame_active: bool = false
var current_minigame: Node = null
var _sprite_tween: Tween = null

# 小游戏脚本（按需加载，减少初始内存占用）
var LevelAlignMinigame: GDScript = null
var BrickPuzzleMinigame: GDScript = null
var RhythmHammerMinigame: GDScript = null

func _load_minigame_scripts() -> void:
	if LevelAlignMinigame == null:
		LevelAlignMinigame = load("res://scripts/minigames/LevelAlignMinigame.gd")
		BrickPuzzleMinigame = load("res://scripts/minigames/BrickPuzzleMinigame.gd")
		RhythmHammerMinigame = load("res://scripts/minigames/RhythmHammerMinigame.gd")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	progress_bar.value = 0
	progress_bar.max_value = 100
	label.text = "按 E 开始工作"
	label.visible = false

	print("WorkArea ready")

func set_work_type(type: String) -> void:
	work_type = type
	print("WorkArea type set to: ", work_type)

func _process(delta: float) -> void:
	if minigame_active:
		return

	if player_in_area and Input.is_action_just_pressed("interact") and not is_completed and not is_working:
		if work_type == "dexterity":
			_start_minigame()
		else:
			_start_work()

	if is_working:
		_update_work(delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		if not is_completed:
			label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		label.visible = false

func _start_work() -> void:
	is_working = true
	label.text = "工作中..."
	# 交互即时反馈：闪烁高亮
	if sprite:
		if _sprite_tween and _sprite_tween.is_valid():
			_sprite_tween.kill()
		_sprite_tween = create_tween()
		_sprite_tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.08)
		_sprite_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	print("Work started in area")

func _update_work(delta: float) -> void:
	# 根据任务类型获取对应属性加成
	var attribute_bonus = 0.0
	match work_type:
		"strength":
			attribute_bonus = PlayerData.strength / 100.0
		"agility":
			attribute_bonus = PlayerData.agility / 100.0
		"dexterity":
			attribute_bonus = PlayerData.dexterity / 100.0
	
	# 根据工作类型获取对应工具效率
	var tool_type = "shovel"
	match work_type:
		"strength":
			tool_type = "shovel"
		"agility":
			tool_type = "broom"
		"dexterity":
			tool_type = "level"
	var tool_efficiency = PlayerData.get_tool_efficiency(tool_type)
	
	# 计算工作速度
	# 完成时间 = 基础时间 / (1 + 属性加成) / 工具效率
	# 工作速度 = 1 / 完成时间 = (1 + 属性加成) * 工具效率 / 基础时间
	var work_speed = (1.0 + attribute_bonus) * tool_efficiency / base_work_time
	
	work_progress += work_speed * delta
	progress_bar.value = work_progress * 100
	
	if work_progress >= 1.0:
		_finish_work()

func _finish_work() -> void:
	is_working = false
	is_completed = true
	label.text = "已完成 ✓"

	# 完成动画：先闪绿再变灰
	if sprite:
		if _sprite_tween and _sprite_tween.is_valid():
			_sprite_tween.kill()
		_sprite_tween = create_tween()
		_sprite_tween.tween_property(sprite, "modulate", Color(0.2, 1.0, 0.2), 0.1)
		_sprite_tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5), 0.4).set_ease(Tween.EASE_IN)

	# 相机震动反馈
	if is_instance_valid(CameraEffects):
		CameraEffects.shake(2.0, 0.15)

	work_completed.emit()
	print("WorkArea completed")

# 小游戏相关
func _start_minigame() -> void:
	minigame_active = true
	label.text = "小游戏进行中..."

	# 按需加载小游戏脚本
	_load_minigame_scripts()
	var minigame_scripts = [LevelAlignMinigame, BrickPuzzleMinigame, RhythmHammerMinigame]
	var script = minigame_scripts[randi() % minigame_scripts.size()]

	current_minigame = CanvasLayer.new()
	current_minigame.set_script(script)
	get_tree().root.add_child(current_minigame)
	current_minigame.minigame_completed.connect(_on_minigame_completed)
	# 等待 _ready 完成后启动
	current_minigame.call_deferred("start_minigame")

func _on_minigame_completed(score: float) -> void:
	minigame_active = false
	print("Minigame score: ", score)

	# 根据分数设置进度
	work_progress = score
	progress_bar.value = work_progress * 100

	if current_minigame and is_instance_valid(current_minigame):
		current_minigame.queue_free()
		current_minigame = null

	if score >= 0.5:
		_finish_work()
	else:
		# 分数太低，需要重试
		label.text = "再试一次! (按E)"
		print("Minigame failed, retry needed")
