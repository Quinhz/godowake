extends Control

# Variables
var version = "v0.8.1-beta"
var save_path = "user://settings.cfg"
var wllp_path = "res://def_wallpaper_koala.jpg"
var wllps = [
	"res://def_wallpaper_goat.jpg",
	"res://def_wallpaper_idk.jpg",
	"res://def_wallpaper_koala.jpg"
]
var def_wllp
var sound_path = "res://lo-fi-alarm-clock.mp3"

var alarm_hour = -1
var alarm_minute = -1
var active_alarm = false
var snooze_time = 5

var unit_prefix = ""

# Nodes
onready var wallpaper = $Wallpaper
onready var label_clock = $Clock
onready var file_dialog = $FileDialog
onready var audio_dialog = $AudioDialog
onready var alarm_sound = $AudioStreamPlayer
onready var status = $Clock/LabelStatus
onready var tween = get_node("Tween")


# Called when the node enters the scene tree for the first time.
func _ready():
	var plti = OS.get_time() # Placeholder current time
	randomize()
	var index = randi() % wllps.size()
	def_wllp = wllps[index]
	$Version.text = version
	$HourInput.text = str(plti.hour)
	$MinInput.text = str(plti.minute)
	load_config()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_time()
	label_clock.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	
	if active_alarm:
		var curr_time = OS.get_time()
		OS.low_processor_usage_mode = false
		if curr_time.hour == alarm_hour and curr_time.minute == alarm_minute:
			play_alarm()
	if alarm_sound.playing:
#		$AlertOverlay.visible = OS.get_ticks_msec() % 1000 < 500
		$AlertOverlay.visible = true
		if OS.get_ticks_msec() % 1000 < 500:
			$AlertOverlay.color = Color(1, 0.31, 0.31, 0.5)
			tween.interpolate_property($Clock, "modulate",
				Color(1,1,1,1), Color(1,1,1,0.5), 0.5,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()

		else:
			$AlertOverlay.color = Color(0.7, 0.31, 1, 0.44)
			tween.interpolate_property($Clock, "modulate",
				Color(1,1,1,0.5), Color(1,1,1,1), 0.5,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
#		$Wallpaper.rect_position.x += sin(OS.get_ticks_msec() * 0.005)
		
		$Clock.rect_position.y += sin(OS.get_ticks_msec() * 0.001) * 0.1
	elif alarm_sound.playing == false:
		tween.interpolate_property($Clock, "modulate",
				Color(1,1,1,1), Color(1,1,1,1), 0.5,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		$Clock.rect_position.y = 266
		$AlertOverlay.visible = false

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_F11:
			OS.window_fullscreen = !OS.window_fullscreen

# My functions
func set_wallpaper(path): # I hate Windows
	def_wllp = path
	if "res://" in def_wllp:
		var tex = load(path)
		$Wallpaper.texture = tex
		return
	var img = Image.new()
	var error = img.load(path)
	
	if error == OK:
		var tex =ImageTexture.new()
		tex.create_from_image(img)
		$Wallpaper.texture = tex

func set_audio(path):
	var f = File.new()
	f.open(path, File.READ)
	var size = f.get_len()
#	var conv_size = convert_size(size)
#	print(conv_size)
#	print("The file '%s' is in size: '%.2f %s'" % [path, conv_size, unit_prefix])
	var new_sound = AudioStreamMP3.new()
	new_sound.data = f.get_buffer(size)
	$AudioStreamPlayer.stream = new_sound
	f.close()
	
	sound_path = path

func play_alarm():
	if active_alarm and not alarm_sound.playing:
		alarm_sound.play()
		$StopAlarm.show()
		$Snooze.show()
		$SetAlarm.hide()
		status.text = "Ringing"

func save_config():
	var config = ConfigFile.new()
	config.set_value("General", "wallpaper_path", def_wllp)
	config.set_value("General", "audio_path", sound_path)
	config.save(save_path)

func load_config():
	var config = ConfigFile.new()
	var error = config.load(save_path)
	
	if error == OK:
		var img_saved_path = config.get_value("General", "wallpaper_path", def_wllp)
		if img_saved_path == "res://def_wallpaper_koala.jpg":
			img_saved_path = def_wllp
		
		var aud_saved = config.get_value("General", "audio_path", "res://lo-fi-alarm-clock.mp3")
		set_wallpaper(img_saved_path)
		set_audio(aud_saved)
	else:
		set_wallpaper(def_wllp)

func convert_size(size_bytes):
	# Bytes to Kilobytes
	size_bytes = size_bytes/1024.0
	
	if size_bytes >= 1000:
		# Kilobytes to Megabytes
		size_bytes = size_bytes / 1000.0
		
		unit_prefix = "MB"
#		print("salut")
		return size_bytes
	else:
#		print("KB")
		unit_prefix = "KB"
		return size_bytes


# Connections
func _on_ChangeWallp_pressed():
	file_dialog.popup_centered_clamped(Vector2(600, 400))


func _on_FileDialog_file_selected(path):
	set_wallpaper(path)
	save_config()


func _on_SetAlarm_pressed():
	var h = int($HourInput.text)
	var m = int($MinInput.text)
	
	if h >= 0 and h < 24 and m>= 0 and m < 60:
		alarm_hour = h
		alarm_minute = m
		active_alarm = true
		if $StopAlarm.visible and alarm_sound.playing:
			$StopAlarm.hide()
			$Snooze.hide()
			$SetAlarm.show()
			status.text = ""
			alarm_sound.stop()
			active_alarm = false
			OS.low_processor_usage_mode = true
		if active_alarm:
			status.text = "Alarm set for: %02d:%02d" % [h, m]
	else:
		alarm_hour = -1
		alarm_minute = -1
		active_alarm = false
		OS.low_processor_usage_mode = true
		status.text = "Invalid Time!"


func _on_StopAlarm_pressed():
	$StopAlarm.hide()
	$Snooze.hide()
	$SetAlarm.show()
	active_alarm = false
	OS.low_processor_usage_mode = true
	alarm_sound.stop()
	status.text = ""
	


func _on_ChangeAudio_pressed():
	audio_dialog.popup_centered_clamped(Vector2(600, 400))


func _on_AudioDialog_file_selected(path):
	set_audio(path)
	save_config()


func _on_Snooze_pressed():
	alarm_minute += snooze_time
	if alarm_minute >= 60:
		alarm_minute -= 60
		alarm_hour += 1
	if alarm_hour >= 24:
		alarm_hour = 0
	$Snooze.hide()
	alarm_sound.stop()
	status.text = "Snoozed to: %02d:%02d" % [alarm_hour, alarm_minute]
