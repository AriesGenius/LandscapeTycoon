extends Node

var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _original_offset: Vector2 = Vector2.ZERO
var _flash_rect: ColorRect = null
var _cached_camera: Camera2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta
		if _shake_duration <= 0:
			_shake_timer = 0
			return
		var progress = _shake_timer / _shake_duration
		var current_intensity = _shake_intensity * progress
		var camera = _get_camera()
		if camera:
			camera.offset = _original_offset + Vector2(
				randf_range(-current_intensity, current_intensity),
				randf_range(-current_intensity, current_intensity)
			)
		if _shake_timer <= 0:
			if camera:
				camera.offset = _original_offset

func _get_camera() -> Camera2D:
	if _cached_camera and is_instance_valid(_cached_camera):
		return _cached_camera
	var tree = get_tree()
	if not tree:
		return null
	var cameras = tree.get_nodes_in_group("camera")
	if cameras.size() > 0:
		_cached_camera = cameras[0]
		return _cached_camera
	if tree.current_scene:
		_cached_camera = _find_camera(tree.current_scene)
		return _cached_camera
	return null

func _find_camera(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		var found = _find_camera(child)
		if found:
			return found
	return null

func shake(intensity: float = 5.0, duration: float = 0.3) -> void:
	if duration <= 0.0:
		return
	var camera = _get_camera()
	if not camera:
		return
	# Only save original offset on first shake (not during overlapping shakes)
	if _shake_timer <= 0:
		_original_offset = camera.offset
	_shake_intensity = maxf(_shake_intensity, intensity)
	_shake_duration = duration
	_shake_timer = duration

func hitstop(duration: float = 0.05) -> void:
	Engine.time_scale = 0.0
	# Use real time via OS ticks to avoid timer freeze at time_scale=0
	var start_usec = Time.get_ticks_usec()
	var duration_usec = int(duration * 1_000_000)
	while (Time.get_ticks_usec() - start_usec) < duration_usec:
		await get_tree().process_frame
	Engine.time_scale = 1.0

func flash(color: Color = Color(1, 1, 1, 0.3), duration: float = 0.15) -> void:
	if _flash_rect and is_instance_valid(_flash_rect):
		var old_canvas = _flash_rect.get_parent()
		if old_canvas:
			old_canvas.queue_free()
		_flash_rect = null

	var canvas = CanvasLayer.new()
	canvas.layer = 90
	add_child(canvas)

	_flash_rect = ColorRect.new()
	_flash_rect.color = color
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_flash_rect)

	var tween = create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.0, duration)
	tween.tween_callback(func():
		if is_instance_valid(canvas):
			canvas.queue_free()
		_flash_rect = null
	)
