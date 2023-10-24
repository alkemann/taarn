class_name CombatUtils
extends Object

enum ActionType { ATTACK, DEBUFF, BUFF, PASSIVE }
enum TargetType { SINGLE, RADIUS, SQUARE, BEAM, LASER }
enum EffectType { PHYSICAL, FIRE, ELECTRIC }


class Target:
	var _type: TargetType
	
	func type() -> TargetType:
		return self._type


class SingleTarget extends Target:
	var _mob: Mob
	var _location: Vector2  # cell or float?!
	
	func _init(mob: Mob):
		self._mob = mob
		self._location = mob.position
		self._type = TargetType.SINGLE


class RadiusTarget extends Target:
	var _location: Vector2
	var _radius: float
	
	func _init(location: Vector2, radius: float):
		self._location = location
		self._radius = radius
		self._type = TargetType.RADIUS


class Source:
	pass


class TowerSource extends Source:
	
	var _tower: Tower
	
	func _init(tower: Tower):
		self._tower


class Effect:
	pass


class Damage extends Effect:
	var _min: float
	var _max: float
	var _roll: float
	var _type: EffectType = EffectType.PHYSICAL
	var _crit_chance: float = 0.0
	var _crit_multi: float = 0.0
	
	func _init(roll: float):
		self._roll = roll


class Package:

	var _action: ActionType
	var _source: Source
	var _target: Target
	var _effect: Effect
	
	var _area_victims: Array[SingleTarget] = []
	var _area_effects: Array[Effect] = []
	
	func _init(
		target: Target,
		source: Source,
		effect: Effect,
		action: ActionType = ActionType.ATTACK
	):
		self._target = target
		self._source = source
		self._effect = effect
		self._action = action


func create_default_damage_package(dmg: float, mob: Mob, tower: Tower) -> Package:
	var damage: Effect = Damage.new(dmg)
	var target: Target = SingleTarget.new(mob)
	var source: Source = TowerSource.new(tower)
	var package: Package = Package.new(target, source, damage)
	return package


func create_splash_damage_package(location: Vector2, radius: float, dmg: float, tower: Tower) -> Package:
	var damage: Effect = Damage.new(dmg)
	var target: Target = RadiusTarget.new(location, radius)
	var source: Source = TowerSource.new(tower)
	var package: Package = Package.new(target, source, damage)
	return package
