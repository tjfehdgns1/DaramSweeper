extends Node2D


@export var tiles = preload("res://tile.tscn") 
@onready var lose := $"../HUD/VBoxContainer"
@onready var win_screen := $"../HUD/WinScreen"
@onready var time := $"../Time"
@onready var main := $".."
@onready var start_button := $"../HUD/Control"
@onready var explosion_sound := $"../ExplosionSound"
@onready var win_sound := $"../WinSound"
@onready var lose_sound := $"../LoseSound"
@onready var count_down := $"../CountDown"


var row := 10
var col := 10
var mine_num = 10
var tile_child
var starting_time := 0
var elapsed_time := 0
var game_over := false


func _ready() -> void:
	set_process(false)
	randomize()
	generate_tiles()
	set_mines()
	

func _process(delta: float) -> void:
	time.text = time_start()
	
func time_start():
		var now := Time.get_ticks_msec()
		var elapsed_time := now - starting_time
		var min = int(elapsed_time  / 60000.0)
		var sec = int(fmod(elapsed_time , 60000.0) / 1000.0)
		var msec = elapsed_time % 1000
		return ("%02d:%02d.%03d" % [min, sec, msec])


func generate_tiles():
	for i in row:
		for j in col:
			var tile = tiles.instantiate()
			tile.position = Vector2(i, j) * 32
			add_child(tile)
	tile_child = get_children()


func set_mines():
	var num = 0
	while  num < mine_num:
		var tile = tile_child[randi() % len(tile_child)]
		if !tile.is_mine:
			tile.set_mine()
			num += 1
		tile.game_over.connect(_on_game_over)
		tile.game_start.connect(time_start)
		tile.game_win.connect(_on_game_win)


func _on_game_over() -> void:
	count_down.stop()
	explosion_sound.play()
	lose_sound.play()
	game_over = true
	for tile in tile_child:
		if tile.is_mine:
			tile.cover.hide()
	lose.show()
	set_process(false)
	

func _on_game_win() -> void:
	for tile in tile_child:
		if tile.is_mine:
			tile.cover.hide()
	count_down.stop()
	win_screen.show()
	print("WIN!")
	win_sound.play()
	set_process(false)


func reset_game() -> void:
	randomize()
	lose.hide()
	win_screen.hide()
	set_process(true)
	for tile in tile_child:
		queue_free()
	game_over = false
	get_tree().change_scene_to_file("res://main.tscn")
	
	
func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		starting_time = Time.get_ticks_msec()
		set_process(true)
		start_button.hide()
		count_down.play()

func _on_re_pressed() -> void:
	reset_game()
	
