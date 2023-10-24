class_name Mob
extends PathFollow2D

const Combat = preload("res://scripts/combat.gd")

signal Killed(mob: Mob)
signal Survived

@export var SPEED = 50
@export var HP = 50.0

var health = HP
var dead = false
var has_entered = false
@onready var path = get_node("..")


func _ready():
	self.v_offset = randf_range(-6, 6)


func _process(delta):
	if not has_entered:
		has_entered = self.progress > path.offset_to_start
	if dead:
		queue_free()
	else:
		progress_ratio += delta * SPEED / 1000
		if progress_ratio >= 1.0:
			Survived.emit()
			queue_free()


func resolve_damage(cp: Combat.Package) -> Combat.DamageResult:
	assert(not dead, "Already dead")
	assert(has_entered, "Hasn't entered map")
	var reduction = 0.0
	var taken = cp.effect.roll  # reduced by armor
	self.health -= taken
	self.dead = health <= 0
	if dead:
		Killed.emit(self)
	else:
		$Health.scale.y = health / HP
	return Combat.DamageResult.new(cp, taken, reduction, not dead)
