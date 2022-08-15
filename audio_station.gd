extends PanelContainer

onready var player = $AudioStreamPlayer
onready var list = $VBoxContainer/ItemList
onready var volume = $VBoxContainer/HBoxContainer/Volume

onready var streams = []
onready var bus = AudioServer.get_bus_index($AudioStreamPlayer.bus)

var current_index = 0
var loop = false

func _ready():
	OS.min_window_size = get_minimum_size()
	for resource_name in $ResourcePreloader.get_resource_list():
		var resource = $ResourcePreloader.get_resource(resource_name)
		streams.append(resource)
		list.add_item(resource.resource_path.get_file())
	get_tree().connect("files_dropped", self, "_on_files_dropped")

func load_ogg(path):
	var file = File.new()
	file.open(path, File.READ)
	var buffer = file.get_buffer(file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = buffer
	
	return stream

func _on_files_dropped(paths, screen):
	for path in paths:
		if path.get_extension() == "ogg":
			_on_FileDialog_files_selected([path])
			
func _on_ItemList_item_activated(index):
	current_index = index
	
	player.stream = streams[index]
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

func _on_Load_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_files_selected(paths):
	for path in paths:
		streams.append(load_ogg(path) )
		list.add_item(path.get_basename().get_file())
		
		

func _on_Loop_toggled(button_pressed):
	loop = button_pressed


func _on_LowPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 1, button_pressed)


func _on_HighPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 2, button_pressed)

func _on_BandPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 3, button_pressed)


func _on_SpectrumAnalyzer_toggled(button_pressed):
	list.visible = not button_pressed
	$VBoxContainer/SpectrumVisualizer.visible = button_pressed
	$VBoxContainer/Filters.visible = button_pressed


#		var length = player.stream.get_length()
#		var minutes = length / 60
#		var seconds = int(length) % 60
#		list.set_item_tooltip(index, "%2d:%02d" % [minutes, seconds])
