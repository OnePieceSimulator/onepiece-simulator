extends Node2D

const COLLISION_MASK_CARD = 1
const GRID_SIZE = 100  # Adjust grid size as needed

var screen_size
var card_being_dragged
var card_offset = Vector2.ZERO

@onready var arena = get_node_or_create("Arena")

func _ready() -> void:
	screen_size = get_viewport_rect().size
	get_tree().get_root().connect("size_changed", _on_screen_resized)
	adjust_arena_size()
	adjust_card_sizes()

func get_node_or_create(node_name: String):
	if has_node(node_name):
		return get_node(node_name)
	else:
		var new_arena = Node2D.new()
		new_arena.name = node_name
		add_child(new_arena)
		return new_arena

func _on_screen_resized():
	screen_size = get_viewport_rect().size
	adjust_arena_size()
	adjust_card_sizes()

func adjust_arena_size():
	arena.scale = Vector2(screen_size.x / 1920.0, screen_size.y / 1080.0)  # Adjust based on reference resolution
	create_grid()

func adjust_card_sizes():
	for card in get_tree().get_nodes_in_group("cards"):  # Ensure all cards are in a "cards" group
		card.scale = Vector2(screen_size.x / 1920.0, screen_size.y / 1080.0) * 0.3  # Scale relative to window

func create_grid():
	var grid_width = int(screen_size.x / GRID_SIZE)
	var grid_height = int(screen_size.y / GRID_SIZE)
	for x in range(grid_width):
		for y in range(grid_height):
			var grid_point = Vector2(x * GRID_SIZE, y * GRID_SIZE)
			# You can visualize the grid with debug drawing if needed

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x - card_offset.x, 0, screen_size.x),
			clamp(mouse_pos.y - card_offset.y, 0, screen_size.y)
		)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				card_being_dragged = card
				card_offset = get_global_mouse_position() - card.position
		else:
			if card_being_dragged:
				card_being_dragged.position = snap_to_grid(card_being_dragged.position)
				card_being_dragged = null

func snap_to_grid(position: Vector2) -> Vector2:
	return Vector2(
		round(position.x / GRID_SIZE) * GRID_SIZE,
		round(position.y / GRID_SIZE) * GRID_SIZE
	)

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0 and result[0].collider:
		return result[0].collider.get_parent()
	return null

func connect_card_signal(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	highlight_card(card, true)

func on_hovered_off_card(card):
	highlight_card(card, false)

func highlight_card(card, hovered):
	var tween = get_tree().create_tween()
	var scale_factor = Vector2(screen_size.x / 1920.0, screen_size.y / 1080.0) * 0.3
	if hovered:
		tween.tween_property(card, "scale", scale_factor * 1.1, 0.1)  # Slightly larger on hover
		card.z_index = 2
	else:
		tween.tween_property(card, "scale", scale_factor, 0.1)
		card.z_index = 1
