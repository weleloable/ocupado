class_name Coaster
extends Interactable
## Beer mat stuck to the wall with chewing gum. Reading it tells where a friend sits; the four of
## them solve the seating riddle on the board. Local space: +Z points into the room.

const COLORS := [Color(0.85, 0.65, 0.2), Color(0.25, 0.55, 0.45), Color(0.75, 0.25, 0.2), Color(0.3, 0.4, 0.75)]

var index: int = 0


func _ready() -> void:
	prompt_text = "Leer el posavasos"
	var rim := Build.mat(Color(0.93, 0.9, 0.8))
	add_mesh_cylinder(0.1, 0.012, Vector3(0, 0, 0.006), rim, Vector3(PI / 2.0, 0, 0))
	add_mesh_cylinder(0.075, 0.014, Vector3(0, 0, 0.007), Build.mat(COLORS[index % COLORS.size()]), Vector3(PI / 2.0, 0, 0))
	# Gum.
	add_mesh_box(Vector3(0.03, 0.03, 0.01), Vector3(0.09, 0.08, 0.005), Build.mat(Color(0.9, 0.5, 0.7)))
	add_shape(Vector3(0.24, 0.24, 0.1), Vector3(0, 0, 0.04))


func interact() -> void:
	GameState.read_coaster(index)
	Sfx.play("click", -6.0, 1.3)
	GameState.say_text("Posavasos: «%s»" % SeatingPuzzle.STATEMENTS[index])
