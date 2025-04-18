extends Node2D

signal hovered
signal hovered_off

func _ready() -> void:
	get_parent().connect_card_signal(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
