class_name MirrorFog
extends Interactable
## Puzzle 3: the hot tap fogs the mirror and reveals "3 3 _ _". Fog fades when the tap is closed.

const FOG_UP := 0.25     # ~4 s with the hot tap open
const FOG_DOWN := 0.07   # ~14 s to clear

var hot_tap: Tap
var fog: float = 0.0
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
	_text = Build.label(self, "3 3 _ _", Vector3(0, 0, 0.04), 0.0, 40, Color(0.2, 0.25, 0.3, 0.0), 0.004)
	_text.alpha_cut = Label3D.ALPHA_CUT_DISABLED
	_text.render_priority = 2
	add_shape(Vector3(0.62, 0.72, 0.06), Vector3(0, 0, 0.03))
	GameState.mirror_revealed.connect(_on_revealed)


func _process(delta: float) -> void:
	if hot_tap != null and hot_tap.is_open:
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
