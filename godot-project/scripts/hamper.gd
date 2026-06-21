extends RigidBody2D

@export var drag_force : float = 500.0
@export var drag_damping : float = 50.0

var dragging : bool

func _ready() -> void:
	input_event.connect(_input_event)

func _physics_process(_delta: float) -> void:
	if dragging:
		var to_mouse := get_global_mouse_position() - global_position
		apply_central_force(to_mouse * drag_force - linear_velocity * drag_damping)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			dragging = false
