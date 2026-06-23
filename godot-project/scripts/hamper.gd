extends RigidBody2D

enum State { EMPTY, CLEAN, DIRTY, WET }

signal drag_start(hamper: RigidBody2D)
signal drag_end(hamper: RigidBody2D)

@onready var anim : AnimationPlayer = $AnimationPlayer

@export var drag_force : float = 200.0
@export var drag_damping : float = 20.0

var is_dragging : bool = false
var grab_click_offset : Vector2 = Vector2.ZERO

var state : State = State.DIRTY:
	set(value):
		state = value
		if is_inside_tree(): _update_animation()

func _ready() -> void:
	_update_animation()

func _physics_process(_delta: float) -> void:
	if is_dragging:
		var current_grab_point := global_position + grab_click_offset.rotated(global_rotation)
		
		var to_mouse := get_global_mouse_position() - current_grab_point
		
		var point_velocity := linear_velocity + BiasedVelocityOffset(grab_click_offset.rotated(global_rotation))
		var force := to_mouse * drag_force - point_velocity * drag_damping
		
		apply_force(force, current_grab_point - global_position)

func BiasedVelocityOffset(offset: Vector2) -> Vector2:
	return Vector2(-offset.y, offset.x) * angular_velocity

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_dragging = true
		
		grab_click_offset = (get_global_mouse_position() - global_position).rotated(-global_rotation)
		
		drag_start.emit(self)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		drag_end.emit(self)

func _update_animation() -> void:
	anim.play(State.keys()[state].to_lower())
