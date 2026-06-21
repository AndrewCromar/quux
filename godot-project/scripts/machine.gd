extends Area2D

@export var graphic_empty_closed : Texture2D
@export var graphic_empty_open : Texture2D
@export var graphic_full_closed_wet : Texture2D
@export var graphic_full_closed_dry_clean : Texture2D
@export var graphic_full_closed_dry_dirty : Texture2D
@export var graphic_full_open_wet : Texture2D
@export var graphic_full_open_dry_clean : Texture2D
@export var graphic_full_open_dry_dirty : Texture2D

# Washer wets the laundry, dryer dries it. Flip this on the dryer scene.
@export var is_dryer : bool = false

@onready var graphic : Sprite2D = $Sprite2D
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
	if not full:
		graphic.texture = graphic_empty_open if open else graphic_empty_closed
	elif wet:
		graphic.texture = graphic_full_open_wet if open else graphic_full_closed_wet
	elif clean:
		graphic.texture = graphic_full_open_dry_clean if open else graphic_full_closed_dry_clean
	else:
		graphic.texture = graphic_full_open_dry_dirty if open else graphic_full_closed_dry_dirty

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("hamper"):
		# Start listening for this hamper's drop while it's over us.
		body.dropped.connect(_on_hamper_dropped)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("hamper"):
		# It left the machine before being dropped — stop listening.
		if body.dropped.is_connected(_on_hamper_dropped):
			body.dropped.disconnect(_on_hamper_dropped)

func _on_hamper_dropped(hamper: RigidBody2D) -> void:
	# Fired when the user releases a hamper that is currently over this machine.
	if not open:
		return
	if not full and hamper.full and _accepts(hamper.wet, hamper.clean):
		# Dump the full hamper into the empty, open machine. A washer only
		# accepts dirty+dry laundry, a dryer only accepts wet (just-washed).
		full = true
		wet = hamper.wet
		clean = hamper.clean
		hamper.full = false
	elif full and not hamper.full:
		# Pull the processed laundry back into an empty hamper.
		hamper.full = true
		hamper.wet = wet
		hamper.clean = clean
		full = false

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if running:
			return  # locked shut while a cycle is running
		if open:
			open = false
			# A cycle can only begin from closed with unprocessed contents: a
			# washer runs dirty+dry laundry, a dryer runs wet (just-washed).
			# Once it's done the contents change state, so it can't be re-run.
			if full and _accepts(wet, clean):
				_start_cycle()
		else:
			open = true

# What this machine will take in / run on, given laundry that is p_wet/p_clean.
func _accepts(p_wet: bool, p_clean: bool) -> bool:
	if is_dryer:
		return p_wet                      # dryer takes just-washed (wet) laundry
	return not p_wet and not p_clean      # washer takes dirty, dry laundry

func _start_cycle() -> void:
	running = true
	timer.start()  # uses the Timer node's wait_time, tweak it in the editor

func _on_cycle_finished() -> void:
	running = false
	if is_dryer:
		wet = false   # dryer: leaves it clean + dry (finished)
		clean = true
	else:
		wet = true    # washer: leaves it clean + wet
		clean = true
