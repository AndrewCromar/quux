extends Area2D

@export var graphic_empty_closed : Texture2D
@export var graphic_empty_open : Texture2D
@export var graphic_full_closed : Texture2D
@export var graphic_full_open : Texture2D

@onready var graphic : Sprite2D = $Sprite2D

var open : bool = false
var full : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	graphic.texture = (graphic_full_open if open else graphic_full_closed) if full else (graphic_empty_open if open else graphic_empty_closed)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("hamper"):
		if open:
			if body.dragging:
				# wait until not dragging, if still in empty basket and fill machine
				pass

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			open = !open
