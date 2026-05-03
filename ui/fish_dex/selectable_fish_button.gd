extends Node

@export var dex : fishdex

func _on_pressed() -> void:
	dex.current_fish.fish = get_parent().fish
	dex.current_fish_name.text = dex.current_fish.fish.fish_name
	dex.current_fish_rarity.text = str(dex.current_fish.fish.grade)
	dex.current_fish_worth.text = str(dex.current_fish.fish.get_score())
	dex.current_fish_description.text = dex.current_fish.fish.description
	dex.current_fish_caught.text = "Caught: " + str(dex.fishdex_entries.get(dex.current_fish.fish.fish_name, 0))
	dex.toggle_fishinfo_visibility(true)
	dex.current_fish.show()
	dex.current_fish.get_node("Fish_Image").texture = dex.current_fish.fish.sprite
	dex.current_fish_index = dex.fishdex_order.find(get_parent().fish.fish_name)
	dex.setup_current_tab()
	pass
