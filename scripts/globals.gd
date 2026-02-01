extends RefCounted
class_name GameGlobals

const GROUP_PLAYER := "player"
const GROUP_ASTEROID := "asteroid"
const GROUP_BULLET := "bullet"
const GROUP_PICKUP := "pickup"

const SCORE_ASTEROID_LARGE := 20
const SCORE_ASTEROID_MEDIUM := 35
const SCORE_ASTEROID_SMALL := 50
const SCORE_PICKUP := 10

const TRACTOR_HEAT_MAX := 100.0
const TRACTOR_HEAT_GAIN_PER_SEC := 45.0
const TRACTOR_HEAT_COOL_PER_SEC := 30.0
const TRACTOR_HEAT_COOL_OVERHEATED_PER_SEC := 50.0

const SPAWN_INTERVAL_START := 1.2
const SPAWN_INTERVAL_MIN := 0.35
const SPAWN_INTERVAL_STEP := 0.05
const SCORE_PER_RAMP_STEP := 20

static func wrap_position(p: Vector2, w: float, h: float) -> Vector2:
	var x := p.x
	var y := p.y
	if x < 0.0:
		x = w
	elif x > w:
		x = 0.0
	if y < 0.0:
		y = h
	elif y > h:
		y = 0.0
	return Vector2(x, y)
