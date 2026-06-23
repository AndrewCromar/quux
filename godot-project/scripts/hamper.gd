extends RigidBody2D

enum drag { NONE, DRAGGING }
enum State { EMPTY, CLEAN, DIRTY, WET }

signal drag_start(hamper: RigidBody2D)
signal drag_end(hamper: RigidBody2D)

@export var graphic_empty : Texture2D
@export var graphic_full_dry_clean : Texture2D
@export var graphic_full_dry_dirty : Texture2D
@export var graphic_full_wet : Texture2D

@export var drag_force : float = 500.0
@export var drag_damping : float = 50.0

@onready var graphic : Sprite2D = $Sprite2D

var dragging : drag = drag.NONE
var state : State = State.DIRTY

func _physics_process(_delta: float) -> void:
	match state:
		State.EMPTY:
			graphic.texture = graphic_empty
		State.WET:
			graphic.texture = graphic_full_wet
		State.CLEAN:
			graphic.texture = graphic_full_dry_clean
		State.DIRTY:
			graphic.texture = graphic_full_dry_dirty

	if dragging:
		var to_mouse := get_global_mouse_position() - global_position
		apply_central_force(to_mouse * drag_force - linear_velocity * drag_damping)

func _start_dragging() -> void:
	dragging = drag.DRAGGING
	get_viewport().set_input_as_handled()
	drag_start.emit(self)

func _stop_dragging() -> void:
	dragging = drag.NONE
	drag_end.emit(self)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_dragging()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and dragging:
		_stop_dragging()
