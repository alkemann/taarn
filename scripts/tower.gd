class_name Tower
extends Node2D

signal Picked(tower:Tower)
signal Placed(tower:Tower)

@export var DAMAGE : float = 25.0
@export var DELAY = 0.5
@export var GRID_SIZE = 32

const Utils = preload("res://scripts/utils.gd")
const States = Utils.States
const PROHIBITED : Array[Vector2i] = [Vector2i(0, 3), Vector2i(20, 12)]

@onready var game: Game = get_node("/root/Game")
@onready var min_y = game.min_y
@onready var min_x = game.min_x
@onready var max_y = game.max_y
@onready var max_x = game.max_x

var enemies = []
var current_enemy : Mob
var selected = false
var mouse_over = false
var since_lost_shot = DELAY


func _process(delta):
	if selected:
		follow_mouse()
	since_lost_shot += delta
	if not current_enemy and enemies.size():
		enemies.sort_custom(sort_enemies)
		current_enemy = enemies[0]

	if since_lost_shot >= DELAY and enemies.size():
		enemies.sort_custom(sort_enemies)
		current_enemy = enemies[0]
		if current_enemy.has_entered:
			current_enemy.Hit.emit(DAMAGE)
			since_lost_shot = 0.0

	if current_enemy:
		$Aim.visible = true
		$Aim.look_at(current_enemy.global_position)
	else:
		$Aim.visible = false
	$Reload.scale.y = min(1.0, since_lost_shot / DELAY)
	
	if self.selected \
			and Input.is_action_just_pressed("Place") \
			and game.state() == States.BUILDING \
			and not is_placement_prohibited():
		self.Placed.emit(self)
		self.selected = false

	if not self.selected and self.mouse_over \
			and Input.is_action_just_pressed("Pickup") \
			and game.state() == States.BUILDING:
		self.Picked.emit(self)
		self.selected = true


func sort_enemies(a: Mob, b: Mob):
	return a.progress_ratio > b.progress_ratio


func follow_mouse():
	var gp = get_global_mouse_position()
	var x = round(gp.x / GRID_SIZE) * GRID_SIZE
	var y = round(gp.y / GRID_SIZE) * GRID_SIZE
	x = clamp(x, min_x, max_x)
	y = clamp(y, min_y, max_y)
	position = Vector2(x, y)


func _on_mob_entered(area2d: Area2D):
	var mob = area2d.get_parent()
	if mob is Mob:
		enemies.append(mob)
		enemies.sort_custom(sort_enemies)
		mob.Killed.connect(_on_mob_killed)



func _on_mob_killed(_mob: Mob):
	print("Mob killed")
	pass


func _on_mob_exited(area2d: Area2D):
	var mob = area2d.get_parent()
	enemies.erase(mob)
	enemies.sort_custom(sort_enemies)
	if current_enemy == mob:
		current_enemy = null


func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if not event is InputEventMouseMotion:
		print(str(event))
	# Move with right mouse (Testing purposes)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not self.selected:
			self.Picked.emit(self)
			self.selected = true



func is_placement_prohibited() -> bool:
	# assert(not self.selected, "Only useable when selected")
	var gridpos = game.viewport_to_grid(self.position)
	var prohibted = PROHIBITED.has(gridpos)
	if prohibted:
		print("PROBITED " + str(gridpos))
	return prohibted


func _on_select_mouse_entered():
	self.mouse_over = true


func _on_select_mouse_exited():
	self.mouse_over = false
