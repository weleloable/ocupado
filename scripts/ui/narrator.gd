class_name Narrator
extends Control
## Sarcastic narrator: bottom-of-screen text with typewriter effect and a message queue.

const CHARS_PER_SECOND := 45.0
const MAX_QUEUE := 3

var _queue: Array[String] = []
var _label: Label
var _current: String = ""
var _chars: float = 0.0
var _hold: float = 0.0
var _blip_counter: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2(40, 292)
	size = Vector2(560, 60)
	UiUtil.rect(self, Color(0, 0, 0, 0.65), Vector2.ZERO, size)
	_label = UiUtil.label(self, "", Vector2(10, 4), Vector2(540, 52), 13, Color(0.95, 0.95, 0.9))
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	visible = false
	GameState.narration_requested.connect(push)


func push(text: String) -> void:
	if text.is_empty() or text == _current or _queue.has(text):
		return
	if _queue.size() >= MAX_QUEUE:
		_queue.pop_front()
	_queue.append(text)


func _process(delta: float) -> void:
	if _current.is_empty():
		if _queue.is_empty():
			visible = false
			return
		_current = _queue.pop_front()
		_label.text = _current
		_label.visible_characters = 0
		_chars = 0.0
		_hold = 2.0 + _current.length() * 0.035
		visible = true
		return
	var total := _current.length()
	if _chars < total:
		var before := int(_chars)
		_chars = minf(float(total), _chars + CHARS_PER_SECOND * delta)
		var now := int(_chars)
		if now != before:
			_label.visible_characters = now
			_blip_counter += now - before
			if _blip_counter >= 3:
				_blip_counter = 0
				Sfx.play("type", -16.0)
	else:
		# Move on faster when more messages are waiting.
		_hold -= delta * (2.5 if not _queue.is_empty() else 1.0)
		if _hold <= 0.0:
			_current = ""
