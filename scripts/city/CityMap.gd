extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var buildings: Node2D = $Buildings

func _ready() -> void:
	print("CityMap loaded")
	print("Active task: ", TaskManager.active_task.get("full_name", "None"))

	# 确保任务已生成
	if TaskManager.available_tasks.is_empty():
		TaskManager.generate_tasks()
		print("Generated initial tasks: ", TaskManager.available_tasks.size())

	_setup_buildings()

func _setup_buildings() -> void:
	# 为所有建筑设置交互
	for building in buildings.get_children():
		if building is Area2D:
			print("Building found: ", building.name)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		# ESC键打开/关闭属性面板
		var attr_panel = get_tree().get_first_node_in_group("attribute_panel")
		if attr_panel:
			if attr_panel.visible:
				attr_panel.hide()
			else:
				attr_panel.show_panel()
