class_name Mob
extends PathFollow2D

signal Hit(damage: int)
signal Killed
signal Survived

@export var SPEED = 50
@export var HP = 50.0

var health = HP
var dead = false


func _ready():
	self.v_offset = randf_range(-6, 6)


func _process(delta):
	if dead:
		queue_free()
	else:
		progress_ratio += delta * SPEED / 1000
		if progress_ratio >= 1.0:
			Survived.emit()
			queue_free()


func _on_hit(damage):
	if dead:
		return
	health -= damage
	$Health.scale.y = health / HP
	if health <= 0:
		Killed.emit()
		dead = true
