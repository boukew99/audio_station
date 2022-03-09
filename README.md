func get_audio_length()
	var length = player.stream.get_length()

	var minutes = length / 60
	var seconds = int(length) % 60

	list.set_item_tooltip(index, "%2d:%02d" % [minutes, seconds])


player.stream.seek(time)