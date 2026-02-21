extends Control


var test_path = "res://wallpaper_placeholder.jpg"

onready var wallpaper = $Wallpaper
onready var label_clock = $Clock
onready var file_dialog = $FileDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	set_wallpaper(test_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_time()
	label_clock.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

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
		print("External wallpaper loaded.")
	else:
		print("Error loading from PC: ", error)


func _on_ChangeWallp_pressed():
	file_dialog.popup_centered_clamped(Vector2(600, 400))


func _on_FileDialog_file_selected(path):
	set_wallpaper(path)
