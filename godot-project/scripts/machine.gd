extends Area2D

enum State { EMPTY_CLOSED, EMPTY_OPEN, DIRTY, WET, DRY_CLOSED, DRY_OPEN }

@onready var anim : AnimationPlayer = $AnimationPlayer

var state : State = State.EMPTY_CLOSED

func _process(_delta: float) -> void:
	_update_animation()

func _update_animation() -> void:
	anim.play(State.keys()[state].to_lower())

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		match state:
			State.EMPTY_CLOSED:
				state = State.EMPTY_OPEN
			State.EMPTY_OPEN:
				state = State.EMPTY_CLOSED
