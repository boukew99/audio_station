extends Control

onready var player = $AudioStreamPlayer
onready var list = $PanelContainer/VBoxContainer/ItemList
onready var volume = $PanelContainer/VBoxContainer/HBoxContainer/Volume
onready var menu = $PanelContainer/VBoxContainer/HBoxContainer/MenuButton.get_popup()

onready var streams = $ResourcePreloader.get_resource_list() as Array
onready var bus = AudioServer.get_bus_index($AudioStreamPlayer.bus)

var current_index = 0

func _ready():
	OS.min_window_size = OS.window_size
	
	streams.shuffle()
	set_stream_items()
	
	menu.add_check_item("Band Pass")
	menu.add_check_item("High Pass Filter")
	menu.add_check_item("Low Pass Filter")
	menu.add_item("Toggle spectrum visualizer")
	menu.add_item("Sort")
	menu.add_item("Shuffle")
	menu.connect("index_pressed", self, "_on_menu_item_checked")

func set_stream_items():
	list.clear()
	for stream in streams:
		list.add_item(stream)
		
func _on_menu_item_checked(index):
	match index:
		0, 1, 2:
			menu.toggle_item_checked(index)
			AudioServer.set_bus_effect_enabled(bus, index + 1, menu.is_item_checked(index))
		3:
			$SpectrumVisualizer.visible = not $SpectrumVisualizer.visible
		4: 
			streams.sort()
			set_stream_items()
		5: 
			streams.shuffle()
			set_stream_items()

		
func _on_ItemList_item_activated(index):
	current_index = index
	player.stream = $ResourcePreloader.get_resource(streams[index])
	player.play()
		

func _on_Pause_toggled(button_pressed): 
	player.stream_paused = button_pressed
	

func _on_FastForward_toggled(button_pressed):
	player.pitch_scale = 2 if button_pressed else 1

func _on_Volume_value_changed(value): 
	var db = linear2db(value)
	volume.hint_tooltip = "%.1f DB volume" % db
	player.volume_db = db

func _on_Skip_pressed():
	$AudioStreamPlayer.stop()
	
func _on_AudioStreamPlayer_finished():
	list.unselect(current_index) 
	var selected = list.get_selected_items()
	if selected:
		current_index = selected[0]
	else:
		current_index = wrapi(current_index + 1, 0, streams.size())
		list.select(current_index) 
		
	_on_ItemList_item_activated(current_index)
	
	# could be cleaner with list.focus(current_index)

