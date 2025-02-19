@tool
class_name WeightEditor
extends Control


signal weight_selected(weight: int)
signal closed()


const ARROW_HEIGHT := 5
const MARGIN := 10


@export var bbox: Rect2

var button_group : ButtonGroup = null

@onready var panel: PanelContainer = %Panel
@onready var arrow: TextureRect = %Arrow


func _ready() -> void:
	var button := %ButtonGrid.get_child(0) as Button
	button_group = button.button_group
	button_group.pressed.connect(on_button_pressed)


func set_selected(weight: int) -> void:
	if weight == 0:
		for button in %ButtonGrid.get_children() as Array[Button]:
			button.set_pressed_no_signal(false)
	else:
		# The 0th button has weight 1
		var button := %ButtonGrid.get_child(weight - 1) as Button
		button.set_pressed_no_signal(true)


func on_button_pressed(button: BaseButton) -> void:
	var index = button_group.get_buttons().find(button)
	if button.button_pressed:
		# The 0th button has weight 1
		weight_selected.emit(index + 1)
	else:
		# This was an unselect, set the weight to 0.
		weight_selected.emit(0)


func on_back_button_pressed() -> void:
	hide()
	closed.emit()


func enable_back_button() -> void:
	%BackButton.disabled = false


## Set the bounding box of this tooltip. The box is given in local coordinates where (0, 0)
## indicates the position of the object spawning the tooltip.
func set_bounding_box(bounding_box: Rect2) -> void:
	if bounding_box.size.x < panel.size.x:
		push_error("Bounding box too small to fit tooltip.")
		return

	var tooltip_height := ARROW_HEIGHT + panel.size.y

	var upside_down : bool
	if bounding_box.has_point(tooltip_height * Vector2.DOWN):
		upside_down = false
	elif bounding_box.has_point(tooltip_height * Vector2.UP):
		upside_down = true
	else:
		push_error("Bounding box too small to fit tooltip.")
		return

	# Set the arrow direction.
	if upside_down:
		arrow.scale.y = -1
		panel.position.y = -tooltip_height
	else:
		arrow.scale.y = 1
		panel.position.y = ARROW_HEIGHT

	var bounding_box_min_x := bounding_box.position.x
	var bounding_box_max_x := bounding_box.position.x + bounding_box.size.x

	var panel_min_x_pos = max(bounding_box_min_x + MARGIN, -panel.size.x / 2.0)
	var panel_max_x_pos = min(bounding_box_max_x - panel.size.x - MARGIN, -panel.size.x / 2.0)

	panel.position.x = clampf(-panel.size.x / 2.0, panel_min_x_pos, panel_max_x_pos)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_bounding_box(bbox)
