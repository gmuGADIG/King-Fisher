extends Control

@export var tutorial_pages: Array[Page]
var current_page: int = 0

@onready var page1: Control = $Background/Page
@onready var page2: Control = $Background/Page2

func _ready() -> void:
	hide()
	display_pages()

func open() -> void:
	show()
	UIState.ui_state = UIState.State.TUTORIAL

func close() -> void:
	hide()
	UIState.ui_state = UIState.State.NONE

func _on_right_arrow_pressed() -> void:
	current_page = clampi(current_page + 2, 0, tutorial_pages.size() - 1)
	display_pages()

func _on_left_arrow_pressed() -> void:
	current_page = clampi(current_page - 2, 0, tutorial_pages.size() - 1)
	display_pages()

func display_pages():
	$Background/Page/Text.get_v_scroll_bar().value = 0
	$Background/Page2/Text.get_v_scroll_bar().value = 0
	page1.get_child(0).text = tutorial_pages[current_page].title
	page1.get_child(1).text = tutorial_pages[current_page].description
	page1.get_child(2).texture = tutorial_pages[current_page].image

	if (current_page + 1 < tutorial_pages.size()):
		page2.get_child(0).text = tutorial_pages[current_page + 1].title
		page2.get_child(1).text = tutorial_pages[current_page + 1].description
		page2.get_child(2).texture = tutorial_pages[current_page + 1].image
	else:
		page2.get_child(0).text = ""
		page2.get_child(1).text = ""
		page2.get_child(2).texture = null

func _on_back_button_pressed() -> void:
	close()
