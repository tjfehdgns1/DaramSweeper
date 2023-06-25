extends Node2D


signal game_over
signal game_start
signal game_win


@onready var cover := $Cover
@onready var check_flag := $CheckFlag
@onready var mine := $DaramHead
@onready var label := $Label
@onready var click_sound := $ClickSound
@onready var flag_sound := $FlagSound


var is_cover := true
var is_flag := false
var is_mine := false


func  set_mine():
	is_mine = true
	mine.show()
	label.hide()


func uncover():
	emit_signal("game_start")
	if !is_flag:
		if is_mine:
			emit_signal("game_over")
			cover.hide()
		else:
			cover.hide()
			is_cover = false
			var count_surround := 0
			var flag_surround := 0
			for tile in get_surrounding():
				if tile.is_mine:
					count_surround += 1
				if tile.is_flag:
					flag_surround += 1
			if count_surround > 0:
				label.text =str(count_surround)
				if count_surround == flag_surround:
					for tile in get_surrounding():
						if tile.is_cover and !tile.is_flag:
							tile.uncover()
			else:
				for tile in get_surrounding():
					if tile.is_cover:
						tile.uncover()


func check_game_win():
	var mine_count := 0
	for tile in get_parent().tile_child:
		if tile.is_mine and tile.is_flag:
			mine_count += 1
			
	if mine_count == 10:
		emit_signal("game_win")


func get_surrounding():
	var surrounds := []
	var offsets := [
		(Vector2.UP + Vector2.LEFT) * 32,
		Vector2.UP * 32,
		(Vector2.UP + Vector2.RIGHT) * 32,
		Vector2.LEFT * 32,
		Vector2.RIGHT * 32,
		(Vector2.DOWN + Vector2.LEFT) * 32,
		Vector2.DOWN * 32,
		(Vector2.DOWN + Vector2.RIGHT) * 32,
		]
	for offset in offsets:
		for tile in get_parent().tile_child:
			if tile.position == position + offset:
				surrounds.append(tile)
	return surrounds


func flag():
	if is_cover:
		if is_flag:
			is_flag = false
			check_flag.hide()
		else:
			is_flag = true
			check_flag.show()


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		check_game_win()
		if event.is_action_pressed("left_click"):
			uncover()
			click_sound.play()
		if event.is_action_pressed("right_click"):
			flag()
			flag_sound.play()
