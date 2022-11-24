extends Control

const FREQ_MAX = 11050.0 / 4
const MIN_DB = 60

var bus = 0#AudioServer.get_bus_index($AudioStreamPlayer.bus)
var spectrum = AudioServer.get_bus_effect_instance(1, 0)

onready var vus = $VBoxContainer/VUs

func _process(_delta):
	var prev_hz = 0
	var vu_count = vus.get_child_count()
	for i in range(1, vu_count +1):
		var hz = i * FREQ_MAX / vu_count;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length() # max and avg
		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		
		vus.get_child(i - 1).value = energy + 0.02 # baseline

		prev_hz = hz


func _on_SpectrumVisualizer_visibility_changed():
	AudioServer.set_bus_effect_enabled(1, 0, visible)

func _on_LowPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 1, button_pressed)


func _on_HighPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 2, button_pressed)

func _on_BandPass_toggled(button_pressed):
	AudioServer.set_bus_effect_enabled(bus, 3, button_pressed)
