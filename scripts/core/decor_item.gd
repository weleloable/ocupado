class_name DecorItem
extends Interactable
## Decoration that only triggers a narrator comment.

var event: String = ""


func setup(p_prompt: String, p_event: String) -> DecorItem:
	prompt_text = p_prompt
	event = p_event
	return self


func interact() -> void:
	GameState.say(event)
