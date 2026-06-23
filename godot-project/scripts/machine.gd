extends Area2D

@export var is_dryer : bool = false

enum State { EMPTY_CLOSED, EMPTY_OPEN, DIRTY, WET, DRY_CLOSED, DRY_OPEN }


@export_group("Washer Graphics")
@export var graphic_washer_empty_closed : Texture2D
@export var graphic_washer_empty_open : Texture2D
@export var graphic_washer_full_closed_wet : Texture2D
@export var graphic_washer_full_closed_dry_clean : Texture2D
@export var graphic_washer_full_closed_dry_dirty : Texture2D
@export var graphic_washer_full_open_wet : Texture2D
@export var graphic_washer_full_open_dry_clean : Texture2D
@export var graphic_washer_full_open_dry_dirty : Texture2D
@export var graphic_washer_spinner_wet : Texture2D
@export var graphic_washer_spinner_dirty : Texture2D

@export_group("Dryer Graphics")
@export var graphic_dryer_empty_closed : Texture2D
@export var graphic_dryer_empty_open : Texture2D
@export var graphic_dryer_full_closed_wet : Texture2D
@export var graphic_dryer_full_closed_dry_clean : Texture2D
@export var graphic_dryer_full_closed_dry_dirty : Texture2D
@export var graphic_dryer_full_open_wet : Texture2D
@export var graphic_dryer_full_open_dry_clean : Texture2D
@export var graphic_dryer_full_open_dry_dirty : Texture2D
@export var graphic_dryer_spinner_wet : Texture2D
@export var graphic_dryer_spinner_dirty : Texture2D

@onready var graphic : Sprite2D = $Sprite2D
@onready var spinner : Sprite2D = $Spinner
@onready var timer : Timer = $Timer

var open : bool = false
var full : bool = false
var wet : bool = false
var clean : bool = false
var running : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_cycle_finished)

func _process(_delta: float) -> void:
	var kind := "dryer" if is_dryer else "washer"
	graphic.texture = get("graphic_%s_%s" % [kind, _state_suffix()])
	spinner.visible = running
	if running:
		spinner.texture = get("graphic_%s_spinner_%s" % [kind, "wet" if wet else "dirty"])

func _state_suffix() -> String:
	var pose := "open" if open else "closed"
	if not full:
		return "empty_" + pose
	if wet:
		return "full_%s_wet" % pose
	if clean:
		return "full_%s_dry_clean" % pose
	return "full_%s_dry_dirty" % pose

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("hamper"):
		body.dropped.connect(_on_hamper_dropped)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("hamper") and body.dropped.is_connected(_on_hamper_dropped):
		body.dropped.disconnect(_on_hamper_dropped)

func _on_hamper_dropped(hamper: RigidBody2D) -> void:
	if not open:
		return
	if not full and hamper.full and _accepts(hamper.wet, hamper.clean):
		full = true
		wet = hamper.wet
		clean = hamper.clean
		hamper.full = false
	elif full and not hamper.full:
		hamper.full = true
		hamper.wet = wet
		hamper.clean = clean
		full = false

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if running:
		return
	if not open:
		open = true
		return
	open = false
	if full and _accepts(wet, clean):
		_start_cycle()

func _accepts(p_wet: bool, p_clean: bool) -> bool:
	if is_dryer:
		return p_wet
	return not p_wet and not p_clean

func _start_cycle() -> void:
	running = true
	timer.start()

func _on_cycle_finished() -> void:
	running = false
	wet = not is_dryer
	clean = true
