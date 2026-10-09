extends Node
## Procedural sound effects: every sound is synthesized at startup into AudioStreamWAV.

const RATE := 22050

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _loops: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.seed = 1234
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	_build_all()


func play(sound_id: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var stream: AudioStreamWAV = _streams.get(sound_id, null)
	if stream == null:
		push_warning("Unknown sound: %s" % sound_id)
		return
	var player: AudioStreamPlayer = _pool[0]
	for p in _pool:
		if not p.playing:
			player = p
			break
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()


func start_loop(loop_id: String, sound_id: String, volume_db: float = 0.0) -> void:
	if _loops.has(loop_id) or not _streams.has(sound_id):
		return
	var p := AudioStreamPlayer.new()
	p.stream = _streams[sound_id]
	p.volume_db = volume_db
	add_child(p)
	p.play()
	_loops[loop_id] = p


func stop_loop(loop_id: String) -> void:
	if not _loops.has(loop_id):
		return
	var p: AudioStreamPlayer = _loops[loop_id]
	p.stop()
	p.queue_free()
	_loops.erase(loop_id)


func stop_all_loops() -> void:
	for loop_id: String in _loops.keys():
		stop_loop(loop_id)


# --- Synthesis ---

func _build_all() -> void:
	_streams["beep"] = _make(_tone(1200.0, 0.06, "square", 0.22))
	_streams["type"] = _make(_tone(1800.0, 0.012, "square", 0.12, 0.001, 0.006))
	_streams["error"] = _make(_join([_tone(220.0, 0.12, "square", 0.3), _tone(150.0, 0.28, "square", 0.3)]))
	_streams["success"] = _make(_join([
		_tone(660.0, 0.08, "square", 0.22), _tone(880.0, 0.08, "square", 0.22), _tone(1320.0, 0.18, "square", 0.22)]))
	_streams["tick"] = _make(_tone(990.0, 0.22, "sine", 0.4, 0.002, 0.2))
	_streams["click"] = _make(_mix(_noise(0.03, 0.6, 0.5), _tone(2400.0, 0.012, "square", 0.2, 0.001, 0.005)))
	_streams["phone"] = _make(_join([_tone(1400.0, 0.07, "sine", 0.35), _silence(0.04), _tone(1800.0, 0.1, "sine", 0.35)]))
	_streams["clunk"] = _make(_mix(_sweep(320.0, 70.0, 0.22, "square", 0.3), _noise(0.15, 0.5, 0.2)))
	_streams["rattle"] = _make(_rattle())
	_streams["flush"] = _make(_flush())
	_streams["dryer"] = _make(_dryer())
	_streams["tap"] = _make(_noise(1.0, 0.35, 0.55, false), true)
	_streams["door"] = _make(_mix(_sweep(110.0, 210.0, 0.7, "square", 0.12), _noise(0.7, 0.15, 0.1)))
	_streams["hum"] = _make(_hum(), true)
	_streams["fanfare"] = _make(_fanfare())


func _make(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = data
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = samples.size()
	return s


func _wave(kind: String, phase: float) -> float:
	match kind:
		"square":
			return 1.0 if fposmod(phase, TAU) < PI else -1.0
		"triangle":
			return 2.0 * absf(2.0 * (phase / TAU - floorf(phase / TAU + 0.5))) - 1.0
		_:
			return sin(phase)


func _envelope(i: int, n: int, attack: float, release: float) -> float:
	var t := float(i) / RATE
	var remaining := float(n - i) / RATE
	var e := 1.0
	if attack > 0.0 and t < attack:
		e = t / attack
	if release > 0.0 and remaining < release:
		e = minf(e, remaining / release)
	return e


func _tone(freq: float, dur: float, kind: String = "square", vol: float = 0.3,
		attack: float = 0.004, release: float = 0.03) -> PackedFloat32Array:
	return _sweep(freq, freq, dur, kind, vol, attack, release)


func _sweep(f0: float, f1: float, dur: float, kind: String = "square", vol: float = 0.3,
		attack: float = 0.004, release: float = 0.03) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var f := lerpf(f0, f1, float(i) / maxf(1.0, float(n)))
		phase += TAU * f / RATE
		out[i] = _wave(kind, phase) * vol * _envelope(i, n, attack, release)
	return out


## Low-passed white noise. smoothing: 1 = raw noise, small = darker.
func _noise(dur: float, vol: float, smoothing: float, with_env: bool = true) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var y := 0.0
	for i in n:
		y += smoothing * (_rng.randf_range(-1.0, 1.0) - y)
		var e := _envelope(i, n, 0.005, 0.05) if with_env else 1.0
		out[i] = y * vol * e
	return out


func _silence(dur: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(dur * RATE))
	return out


func _join(parts: Array[PackedFloat32Array]) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for p in parts:
		out.append_array(p)
	return out


func _mix(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var out := a.duplicate() if a.size() >= b.size() else b.duplicate()
	var other := b if a.size() >= b.size() else a
	for i in other.size():
		out[i] += other[i]
	return out


func _flush() -> PackedFloat32Array:
	var dur := 2.4
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var y := 0.0
	for i in n:
		var t := float(i) / RATE
		var env := minf(1.0, t / 0.08) * clampf(1.0 - (t - 0.3) / (dur - 0.3), 0.0, 1.0)
		var gurgle := 0.7 + 0.3 * sin(TAU * 7.0 * t + sin(TAU * 1.3 * t) * 3.0)
		y += 0.25 * (_rng.randf_range(-1.0, 1.0) - y)
		out[i] = y * 0.9 * env * gurgle
	return out


func _dryer() -> PackedFloat32Array:
	var dur := 2.4
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var y := 0.0
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		var env := minf(1.0, t / 0.2) * clampf((dur - t) / 0.4, 0.0, 1.0)
		y += 0.4 * (_rng.randf_range(-1.0, 1.0) - y)
		phase += TAU * 115.0 / RATE
		out[i] = (y * 0.5 + _wave("square", phase) * 0.06) * env
	return out


func _rattle() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for _k in 3:
		out.append_array(_mix(_noise(0.05, 0.6, 0.3), _tone(90.0, 0.05, "square", 0.25)))
		out.append_array(_silence(0.05))
	return out


func _hum() -> PackedFloat32Array:
	var n := RATE  # exactly 1 s so 100 Hz and 200 Hz loop seamlessly
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		out[i] = (sin(TAU * 100.0 * t) * 0.6 + sin(TAU * 200.0 * t) * 0.3 + sin(TAU * 300.0 * t) * 0.1) * 0.12
	return out


func _fanfare() -> PackedFloat32Array:
	var notes := [[523.25, 0.12], [659.25, 0.12], [783.99, 0.12], [1046.5, 0.3], [783.99, 0.1], [1046.5, 0.5]]
	var out := PackedFloat32Array()
	for note: Array in notes:
		var f: float = note[0]
		var d: float = note[1]
		out.append_array(_mix(_tone(f, d, "square", 0.2), _tone(f * 0.5, d, "triangle", 0.25)))
	return out
