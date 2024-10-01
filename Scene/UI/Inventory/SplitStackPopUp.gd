extends Popup

var data

@onready var hslider = $Frame/Margin/VBox/SliderBox/HSlider
@onready var label_left = $Frame/Margin/VBox/SliderBox/LabelL
@onready var label_right = $Frame/Margin/VBox/SliderBox/LabelR
@onready var ok_button = $Frame/Margin/VBox/ButtonBox/Ok
@onready var cancel_button = $Frame/Margin/VBox/ButtonBox/Cancel


func _ready():
	get_node("Frame/Margin/VBox/Name").set_text(data["origin_item_name"])
	
	hslider.min_value = 1
	hslider.max_value = data["origin_stack"]-1
	hslider.value = data["origin_stack"]/2
	update_labels()

	popup()

#Function to update labels based on slider value
func update_labels():
	label_left.text = str(data["origin_stack"] - hslider.value)
	label_right.text = str(hslider.value)
	label_right.set_cursor_position(len(label_right.text))
	label_left.set_cursor_position(len(label_left.text))


func _on_HSlider_value_changed(value):
	update_labels()

func _on_LabelL_text_changed(new_text):
	label_left.max_length = len(str(data["origin_stack"] - 1))
	if new_text == "":
		new_text = "1"
	var value = new_text.to_int()
	if value >= 1 and value < data["origin_stack"]:
		hslider.value = data["origin_stack"] - value
		label_right.text = str(hslider.value)
	else:
		value = data["origin_stack"] - 1
		new_text = str(value)
		hslider.value = data["origin_stack"] - value
		label_right.text = str(hslider.value)
	label_left.text = new_text
	label_left.set_cursor_position(len(label_left.text))

func _on_LabelR_text_changed(new_text):
	label_right.max_length = len(str(data["origin_stack"] - 1))
	if new_text == "":
		new_text = "1"
	var value = new_text.to_int()
	if value >= 1 and value < data["origin_stack"]:
		hslider.value = value
		label_left.text = str(data["origin_stack"] - value)
	else:
		value = data["origin_stack"] - 1
		new_text = str(value)
		hslider.value = value
		label_left.text = str(data["origin_stack"] - value)
	label_right.text = new_text
	label_right.set_cursor_position(len(label_right.text))

func _on_Ok_pressed():
	var split_amount = hslider.value
	get_parent()._SplitStack(int(split_amount), data)
	self.queue_free()

func _input(event):
	if event.is_action_pressed("CHR_INTERACT"):
		_on_Ok_pressed()

func _on_Cancel_pressed():
	self.queue_free()
