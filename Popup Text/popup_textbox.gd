extends TextureRect
@onready var PopupBackground : Panel = $Panel
@onready var PopupLabel : Label = $Panel/MarginContainer/Label
@export_multiline var PopupText : String = "Tooltip here"

#This is a fairly basic popup textbox I'm using, feel free to just take this entire thing, theme the panel, and stick it right into your own project if you want

func _ready() -> void:
	PopupLabel.text = PopupText #Set the popup text to the export var
	
	#This block of code simply expands the size of the popup background to fit the text if needed; the label itself automatically expands
	var Label_Lines = PopupLabel.get_line_count()
	var Pixels_Per_Line = PopupLabel.get_line_height(-1)
	PopupBackground.size.y = 15 + Label_Lines*(Pixels_Per_Line+3)
	
	PopupBackground.scale.x = 1/scale.x
	PopupBackground.scale.y = 1/scale.y
	#This essentially does a bit of math to place the popup box to the left or right of the main text, 
	var screen_width : float = get_viewport_rect().size.x
	if global_position.x < screen_width/2:
		PopupBackground.position = Vector2(30,-10)
	else:
		PopupBackground.position = Vector2(-490,-10)
		
		
func _on_mouse_entered() -> void:
	PopupBackground.visible = true

func _on_mouse_exited() -> void:
	PopupBackground.visible = false
