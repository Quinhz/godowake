extends Control

# Variables
var save_path = "user://settings.cfg"
var test_path = "res://def_wallpaper_koala.jpg"

var alarm_hour = -1
var alarm_minute = -1
var active_alarm = false

# Nodes
onready var wallpaper = $Wallpaper
onready var label_clock = $Clock
onready var file_dialog = $FileDialog
onready var alarm_sound = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	set_wallpaper(test_path)
	load_config()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_time()
	label_clock.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	
	if active_alarm:
		var curr_time = OS.get_time()
		if curr_time.hour == alarm_hour and curr_time.minute == alarm_minute:
			play_alarm()


# My functions
func set_wallpaper(path): # I hate Windows
	if "res://" in path:
		var tex = load(path)
		if tex:
			$Wallpaper.texture = tex
			return
	var img = Image.new()
	var error = img.load(path)
	
	if error == OK:
		var tex =ImageTexture.new()
		tex.create_from_image(img)
		$Wallpaper.texture = tex
#		print("External wallpaper loaded.")
	else:
#		pass
		return
#		print("Error loading from PC: ", error)

func play_alarm():
	if active_alarm and not alarm_sound.playing:
		alarm_sound.play()
		$StopAlarm.show()
		$LabelStatus.text = "Ringing"
#		print("HEY DEV!")

func save_config(image_path):
	var config = ConfigFile.new()
	config.set_value("General", "wallpaper_path", image_path)
	config.save(save_path)

func load_config():
	var config = ConfigFile.new()
	var error = config.load(save_path)
	
	if error == OK:
		var saved_path = config.get_value("General", "wallpaper_path", "res://walpaper_placeholder.jpg")
		set_wallpaper(saved_path)

# Connections
func _on_ChangeWallp_pressed():
	file_dialog.popup_centered_clamped(Vector2(600, 400))


func _on_FileDialog_file_selected(path):
	set_wallpaper(path)
	save_config(path)


func _on_SetAlarm_pressed():
	var h = int($HourInput.text)
	var m = int($MinInput.text)
	var curr_time = OS.get_time()
	
	if h >= 0 and h < 24 and m>= 0 and m < 60:
		alarm_hour = h
		alarm_minute = m
		active_alarm = true
		if $StopAlarm.visible and alarm_sound.playing:
			$StopAlarm.hide()
			$LabelStatus.text = ""
			alarm_sound.stop()
			active_alarm = false
		if active_alarm:
			$LabelStatus.text = "Alarm set for: %02d:%02d" % [h, m]
	else:
		alarm_hour = -1
		alarm_minute = -1
		active_alarm = false
		$LabelStatus.text = "Invalid Time!"
	print(active_alarm)


func _on_StopAlarm_pressed():
	$StopAlarm.hide()
	active_alarm = false
	alarm_sound.stop()
	$LabelStatus.text = ""
	
