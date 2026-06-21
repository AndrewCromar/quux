extends RigidBody2D

signal dropped(hamper: RigidBody2D)

@export var graphic_empty : Texture2D
@export var graphic_full_dry : Texture2D
@export var graphic_full_wet : Texture2D

@export var drag_force : float = 500.0
@export var drag_damping : float = 50.0

@onready var graphic : Sprite2D = $Sprite2D

var dragging : bool

var full : bool = true
var wet : bool = false

func _physics_process(_delta: float) -> void:
	graphic.texture = (graphic_full_wet if wet else graphic_full_dry) if full else graphic_empty

	if dragging:
		var to_mouse := get_global_mouse_position() - global_position
		apply_central_force(to_mouse * drag_force - linear_velocity * drag_damping)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if dragging:
				dragging = false
				dropped.emit(self)
