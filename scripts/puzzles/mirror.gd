class_name MirrorFog
extends Interactable
## Puzzle 3: the mirror only fogs up (revealing "3 _ _ _") when ALL of these hold:
##  - the red hot-water valve is open,
##  - the hot tap is open and has been running for WARMUP seconds (first the pipe runs cold),
##  - the cold tap is closed (hot + cold = lukewarm, and lukewarm does not fog).
## The fog fades slowly once any of that stops.

const WARMUP := 2.5      # seconds of hot water before steam appears
const FOG_UP := 0.2      # ~5 s of steam to reveal everything
const FOG_DOWN := 0.07   # ~14 s to clear

var hot_tap: Tap
var cold_tap: Tap
var fog: float = 0.0
var warm: float = 0.0
var _announced: bool = false
var _fog_mat: StandardMaterial3D
var _text: Label3D


func _ready() -> void:
	prompt_text = "Mirarte al espejo"
	add_mesh_box(Vector3(0.62, 0.72, 0.02), Vector3(0, 0, 0.01), Build.mat(Color(0.3, 0.3, 0.32)))
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.5, 0.6, 0.65)
	glass.metallic = 0.8
	glass.roughness = 0.15
	add_mesh_box(Vector3(0.56, 0.66, 0.01), Vector3(0, 0, 0.025), glass)
	_fog_mat = Build.mat_unique(Color(0.92, 0.94, 0.96, 0.0))
	Build.box(self, Vector3(0.55, 0.65, 0.004), Vector3(0, 0, 0.033), _fog_mat)
	_text = Build.label_fit(self, GameState.digit_pattern(GameState.DIGIT_TRIALS["mirror"]), Vector3(0, 0, 0.04), 0.0, Vector2(0.46, 0.16), Color(0.2, 0.25, 0.3, 0.0))
	_text.alpha_cut = Label3D.ALPHA_CUT_DISABLED
	_text.render_priority = 2
	add_shape(Vector3(0.62, 0.72, 0.06), Vector3(0, 0, 0.03))
	GameState.mirror_revealed.connect(_on_revealed)


func _process(delta: float) -> void:
	var hot_flowing := hot_tap != null and hot_tap.is_open and GameState.valve_open
	warm = warm + delta if hot_flowing else 0.0
	var lukewarm := cold_tap != null and cold_tap.is_open
	if warm >= WARMUP and not _announced:
		_announced = true
		GameState.say("tap_mixed" if lukewarm else "hot_water_arrives")
	if warm == 0.0:
		_announced = false
	if warm >= WARMUP and not lukewarm:
		fog = minf(1.0, fog + FOG_UP * delta)
	else:
		fog = maxf(0.0, fog - FOG_DOWN * delta)
	_fog_mat.albedo_color.a = fog * 0.8
	_text.modulate.a = clampf((fog - 0.35) / 0.6, 0.0, 1.0)
	if fog >= 0.95 and not GameState.mirror_done:
		GameState.solve_mirror()


func interact() -> void:
	if fog > 0.5:
		GameState.say("mirror_fogged")
	elif GameState.mirror_done:
		GameState.say("mirror_after")
	else:
		GameState.say("mirror_look")


func _on_revealed() -> void:
	fog = 1.0
