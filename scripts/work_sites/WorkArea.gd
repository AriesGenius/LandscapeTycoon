extends Area2D

signal work_completed

@export var base_work_time: float = 5.0  # 基础工作时间（秒）

var work_type: String = "strength"  # strength, agility, dexterity
var is_working: bool = false
var work_progress: float = 0.0
var player_in_area: bool = false
var is_completed: bool = false

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
	if player_in_area and Input.is_action_just_pressed("interact") and not is_completed and not is_working:
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
	
	# 变灰表示完成
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5)
	
	work_completed.emit()
	print("WorkArea completed")
