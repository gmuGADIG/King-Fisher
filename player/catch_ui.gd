extends Control

const DEFAULT_CATCH_BLURB := "hmmm..... somethign smells fishy here, but i can't quite put my finger on it."

@onready var catch_blurb : Label = %CatchBlurb
@onready var fish_title : Label = %FishTitle
@onready var fish_texture_rect : TextureRect = %FishTextureRect
@onready var anim : AnimationPlayer = %CatchUIAnimator

func present(fish: Fish) -> void:
	fish_texture_rect.texture = fish.sprite
	fish_title.text = fish.fish_name
	catch_blurb.text = fish.catch_blurb
	if catch_blurb.text.is_empty():
		Debug.log_err("Catch blurb does not exist for fish '%s'!" % fish.fish_name)
		catch_blurb.text = DEFAULT_CATCH_BLURB
	
	anim.play("anim")
