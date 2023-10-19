class_name Game
extends Node2D

@export var SPAWN_DELAY = 0.3

const GRID_SIZE = 32
const gnome = preload("res://scenes/mob.tscn")
const tower_1 = preload("res://scenes/tower.tscn")
const Utils = preload("res://scripts/utils.gd")
const States = Utils.States

@onready var path = $Monsters/Path2D
@onready var ui_lives = $UI/Control/HBoxContainer/Control/Lives
@onready var ui_alive = $UI/Control/HBoxContainer/Control3/Alive
@onready var ui_score = $UI/Control/HBoxContainer/Control4/Score
@onready var ui_state = $UI/Control/HBoxContainer/StateControl/State

@onready var viewport_size = get_viewport().size
@onready var min_y:float = GRID_SIZE*2
@onready var min_x:float = GRID_SIZE*2
@onready var max_x:float = viewport_size.x - (GRID_SIZE * 3)
@onready var max_y:float = viewport_size.y - (GRID_SIZE * 3)


var _state: States = States.BUILDING
var monsters = []
var monster_count = 20
var since_spawn = SPAWN_DELAY
var wave = 1
var alive = 0
var lives = 3
var score = 0
var selected_tower:Tower = null


func state() -> States:
	return _state


func can_build() -> bool:
	return state() == States.BUILDING


func _process(delta):
	if _state == States.BUILDING:
		$Monsters/PathPreview.visible = false
		_handle_purchasing()
		_handle_next_wave()

	elif _state == States.SPAWNING:
		$Monsters/PathPreview.visible = true
		_handle_wave_spawning(delta)

	else:  # CLEANUP
		if self.alive == 0:
			_clean_up_board()


func _handle_purchasing():
	if self.selected_tower:
		return  # only buy one at a time
	if Input.is_action_pressed("buy_tower_1"):
		self.selected_tower = tower_1.instantiate()
		
	if self.selected_tower:
		self.selected_tower.selected = true
		self.selected_tower.Picked.connect(_handle_tower_picked_up)
		self.selected_tower.Placed.connect(_handle_tower_placed)
		$Towers.add_child(self.selected_tower)


func _handle_tower_picked_up(tower: Tower):
	self.selected_tower = tower


func _handle_tower_placed(_tower: Tower):
	self.selected_tower = null


func _handle_next_wave():
	if Input.is_action_pressed("next_wave"):
		if selected_tower:
			selected_tower.queue_free()
			selected_tower = null
		_state = States.SPAWNING
		ui_state.text = "WAVE " + str(wave) + " ATTACKING"


func _handle_wave_spawning(delta):
	since_spawn += delta
	if monster_count > 0 and since_spawn >= SPAWN_DELAY:
		var new_mob = gnome.instantiate()
		new_mob.Survived.connect(monster_survived)
		new_mob.Killed.connect(monster_killed)
		path.add_child(new_mob)
		monster_count -= 1
		since_spawn = 0
		alive += 1
		ui_alive.text = str(alive)
	elif monster_count == 0:
		_state = States.CLEANUP
		ui_state.text = "CLEANUP"


func _clean_up_board():
	wave += 1
	alive = 0
	since_spawn = SPAWN_DELAY
	monster_count = 20
	_state = States.BUILDING
	ui_state.text = "BUILDING"


func monster_survived():
	print("Monster surived")
	lives -= 1
	alive -= 1
	ui_lives.text = str(lives)
	if lives <= 0:
		print("GAME OVER")
		get_tree().change_scene_to_file("res://ui/menu.tscn")


func _draw():
	var color = Color(0.8, 0.8, 0.8, 0.5)
	var half = int(float(GRID_SIZE)/2)
	for x in range(min_x - half, max_x + GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(x, min_y - half), Vector2(x, max_y + half), color)
	for y in range(min_y - half, max_y + GRID_SIZE, GRID_SIZE):
		draw_line(Vector2(min_x - half, y), Vector2(max_x + half, y), color)


func monster_killed():
	alive -= 1
	score += 1
	ui_alive.text = str(alive)
	ui_score.text = str(score)
