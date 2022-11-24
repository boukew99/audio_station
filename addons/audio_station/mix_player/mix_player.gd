extends Panel

export(Array, AudioStream) var mix = []
onready var slider = $"%VSlider"
onready var names = $"%Names"
onready var audio_player = $AudioStreamPlayer

func _ready():
	var group = ButtonGroup.new()
	slider.max_value = mix.size() -1
	slider.tick_count = mix.size() 
	var cumulative_time = 0
	for song in mix:
		var button = Button.new()
		button.flat = true
		var hour = cumulative_time / 60
		var minute = int(cumulative_time) % 60
		var time = "%02d:%02d - " % [hour, minute]
		cumulative_time += song.get_length()
		button.text = time + song.resource_path.get_file()
		button.align = Button.ALIGN_LEFT
		button.group = group
		button.toggle_mode = true
		names.add_child(button)
		
	if mix:
		$AudioStreamPlayer.play()
	group.connect("pressed", self, "on_Button_pressed")
	
func on_Button_pressed(button):
	slider.value = button.get_index() #reverse

func _on_VSlider_value_changed(value):
	audio_player.stream = mix[value]
	audio_player.play()
	

func _on_AudioStreamPlayer_finished():
	slider.value = wrapi(slider.value + slider.step, 0, slider.max_value)


func _on_VSlider_changed():
	pass # Replace with function body.


func _on_Step_value_changed(value):
	slider.step = [1, 3, 5, 7, 9][value]


func _on_Finish_pressed():
	audio_player.stop()


func _on_Mute_toggled(button_pressed):
	audio_player.stream_paused = button_pressed
	


func _on_Volume_value_changed(value):
	audio_player.volume_db = linear2db(value)
