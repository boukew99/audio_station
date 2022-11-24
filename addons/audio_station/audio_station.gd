extends PanelContainer

onready var player = $AudioStreamPlayer
onready var list = $VBoxContainer/ItemList
onready var volume = $VBoxContainer/HFlowContainer/Volume/VolumeSlider
onready var advance_shuffle = $VBoxContainer/HFlowContainer/Advance/AdvanceShuffle

onready var streams = []

var current_index = 0
var advance = 1
var rng = RandomNumberGenerator.new()
var loop = false

func _ready():
	get_tree().connect("files_dropped", self, "_on_FileDialog_files_selected")
	for resource_name in $ResourcePreloader.get_resource_list():
		var resource = $ResourcePreloader.get_resource(resource_name)
		streams.append(resource)
		list.add_item(resource.resource_path.get_file())
	
	advance_shuffle.max_value = max(1, streams.size() - 2)
	
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
	player.stop()
	
func _on_AudioStreamPlayer_finished():
	if advance_shuffle.value == 0: #loop
		_on_ItemList_item_activated(current_index)
		return
		
	list.unselect(current_index) 
	var selected = list.get_selected_items()
	if selected:
		current_index = selected[0]
	else:
		current_index = wrapi(current_index + rng.randi_range(1, advance), 0, streams.size())
		list.select(current_index) 
		
	_on_ItemList_item_activated(current_index)
	
	# could be cleaner with list.focus(current_index)

func _on_Load_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_files_selected(paths, screen = 0):
	for path in paths:
		streams.append(load_ogg(path) )
		list.add_item(path.get_basename().get_file())
	
	advance_shuffle.max_value = streams.size() - 2

func _on_AdvanceShuffle_value_changed(value):
	advance = value

#		var length = player.stream.get_length()
#		var minutes = length / 60
#		var seconds = int(length) % 60
#		list.set_item_tooltip(index, "%2d:%02d" % [minutes, seconds])




func _on_Volume_toggled(button_pressed):
	player.stream_paused = not button_pressed
