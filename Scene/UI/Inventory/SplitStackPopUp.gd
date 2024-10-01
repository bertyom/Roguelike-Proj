extends Popup

var data

@onready var hslider = $Frame/Margin/VBox/SliderBox/HSlider
@onready var label_left = $Frame/Margin/VBox/SliderBox/LabelL
@onready var label_right = $Frame/Margin/VBox/SliderBox/LabelR
@onready var ok_button = $Frame/Margin/VBox/ButtonBox/Ok
@onready var cancel_button = $Frame/Margin/VBox/ButtonBox/Cancel

func _ready():
	$Frame/Margin/VBox/Name.text = data["origin_item_name"]
	
	hslider.min_value = 1
	hslider.max_value = data["origin_stack"] - 1
	hslider.value = data["origin_stack"] / 2
	update_labels()

	popup()

func update_labels():
	label_left.text = str(data["origin_stack"] - hslider.value)
	label_right.text = str(hslider.value)
	label_left.caret_column = len(label_left.text)
	label_right.caret_column = len(label_right.text)

func _on_h_slider_value_changed(value):
	update_labels()

func _on_label_l_text_submitted(new_text):
	update_label_left(new_text)

func _on_label_r_text_submitted(new_text):
	update_label_right(new_text)

func update_label_left(new_text):
	var value = new_text.to_int()
	value = clampi(value, 1, data["origin_stack"] - 1)
	hslider.value = data["origin_stack"] - value
	update_labels()

func update_label_right(new_text):
	var value = new_text.to_int()
	value = clampi(value, 1, data["origin_stack"] - 1)
	hslider.value = value
	update_labels()

func _on_ok_pressed():
	var split_amount = int(hslider.value)
	get_parent()._SplitStack(split_amount, data)
	queue_free()

func _input(event):
	if event.is_action_pressed("CHR_INTERACT"):
		_on_ok_pressed()

func _on_cancel_pressed():
	queue_free()

func _on_label_l_focus_exited():
	update_label_left(label_left.text)

func _on_label_r_focus_exited():
	update_label_right(label_right.text)

func _on_label_l_text_changed(new_text):
	if new_text.is_valid_int():
		update_label_left(new_text)
	else:
		label_left.text = "1"
		label_left.caret_column = 1

func _on_label_r_text_changed(new_text):
	if new_text.is_valid_int():
		update_label_right(new_text)
	else:
		label_right.text = "1"
		label_right.caret_column = 1
