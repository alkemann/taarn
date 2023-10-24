class_name CombatUtils
extends Object

enum ActionType { ATTACK, DEBUFF, BUFF, PASSIVE }
enum TargetType { SINGLE, RADIUS, SQUARE, BEAM, LASER }
enum DamageType { PHYSICAL, FIRE, ELECTRIC }
enum EffectType { DAMAGE, HEAL, SLOW, STUN }


class Target:
	var type: TargetType


class SingleTarget extends Target:
	var mob: Mob
	var location: Vector2  # cell or float?!
	
	func _init(mob: Mob):
		self.mob = mob
		self.location = mob.position
		self.type = TargetType.SINGLE


class RadiusTarget extends Target:
	var location: Vector2
	var radius: float
	
	func _init(location: Vector2, radius: float):
		self.location = location
		self.radius = radius
		self.type = TargetType.RADIUS


class Source:
	pass


class TowerSource extends Source:
	var tower: Tower
	
	func _init(tower: Tower):
		self.tower = tower


class Effect:
	var type: EffectType


class Damage extends Effect:
	var min: float
	var max: float
	var roll: float
	var damage_type: DamageType = DamageType.PHYSICAL
	var crit_chance: float = 0.0
	var crit_multi: float = 0.0
	
	func _init(roll: float):
		self.roll = roll
		self.type = EffectType.DAMAGE


class Package:
	var action: ActionType
	var source: Source
	var target: Target
	var effect: Effect
	
	var area_victims: Array[SingleTarget] = []
	var area_effects: Array[Effect] = []
	
	func _init(
		target: Target,
		source: Source,
		effect: Effect,
		action: ActionType = ActionType.ATTACK
	):
		self.target = target
		self.source = source
		self.effect = effect
		self.action = action


class Result:
	var package: Package
	var survived: bool
	var resisted: bool


class DamageResult extends Result:
	var taken: float
	var reduced: float

	func _init(package: Package, taken: float, reduced: float = 0.0, survived: bool = true) -> void:
		self.package = package
		self.taken = taken
		self.reduced = reduced
		self.resisted = reduced > 0.0
		self.survived = survived


static func create_default_damage_package(dmg: float, mob: Mob, tower: Tower) -> Package:
	var damage: Effect = Damage.new(dmg)
	var target: Target = SingleTarget.new(mob)
	var source: Source = TowerSource.new(tower)
	var package: Package = Package.new(target, source, damage)
	return package


static func create_splash_damage_package(location: Vector2, radius: float, dmg: float, tower: Tower) -> Package:
	var damage: Effect = Damage.new(dmg)
	var target: Target = RadiusTarget.new(location, radius)
	var source: Source = TowerSource.new(tower)
	var package: Package = Package.new(target, source, damage)
	return package
