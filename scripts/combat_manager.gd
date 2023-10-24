class_name CombatManager
extends Node

const Utils = preload("res://scripts/utils.gd")
const Combat = preload("res://scripts/combat.gd")

signal Attack(cb: Combat.Package)
signal Hit(cb: Combat.Package)  # different object, combat results?

@onready var game: Game = $".."

func _ready() -> void:
	game.NewTower.connect(_on_new_tower)

func _on_new_tower(_tower: Tower) -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_attack(cb: Combat.Package) -> void:
	if cb.action == Combat.ActionType.ATTACK:
		self._handle_attack(cb)
	else:
		printerr("Unhandled action type")
		assert(cb.action == Combat.ActionType.ATTACK, "Unhandled action type")

func _handle_attack(cp: Combat.Package) -> void:
	if cp.target is Combat.SingleTarget:
		if cp.effect is Combat.Damage:
			var mob:Mob = cp.target.mob
			mob.resolve_damage(cp)
		else:
			printerr("Unhandled effect type")
	else:
		printerr("Unhandled target type")
