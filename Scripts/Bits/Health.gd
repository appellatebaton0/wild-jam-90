class_name HealthBit extends Bit
## Provides all the functionality expected of a Bot that would have health.
## Signals on taking damage and health reaching zero, etc.

signal took_damage ## Emitted when the health value decreases.
signal took_regeneration ## Emitted when the health value increases.
signal reached_zero ## Emitted when the health value reaches zero.

@export var max_health := 40.0
@export var health := 40.0

@export_group("Invincibility", "invincibility_")
## Specifies the amount of time, in seconds, for which a bot
## Can't take damage immediately after being hit.
## NOTE: If invincibility_frames is higher, that will be used instead.
@export var invincibility_time := 0.0
var invince_time := 0.0
## Specifies the amount of time, in frames, for which a bot
## Can't take damage immediately after being hit.
## NOTE: If invincibility_time is higher, that will be used instead.
@export var invincibility_frames := 0
var invince_frames := 0
## Whether this HealthBit can currently take damage
var is_invincible := false


## Called by things that want to do damage, namely DamageBits.
func modify_health(amount:float):
	is_invincible = invince_frames > 0 or invince_time > 0.0
	
	if amount == 0:
		return
	elif amount < 0 and not is_invincible: ## If the modification is damage, take the damage
		health = max(0, health + amount)
		took_damage.emit()
		
		invince_frames = invincibility_frames
		invince_time = invincibility_time
	elif amount > 0: ## If the modification is regen, regenerate the health.
		health = min(max_health, health + amount)
		took_regeneration.emit()
	
	if health <= 0:
		reached_zero.emit()

func _process(delta: float) -> void:
	invince_frames = max(0, invince_frames - 1)
	invince_time = move_toward(invince_time, 0, delta)
	
	is_invincible = invince_frames > 0 or invince_time > 0.0
