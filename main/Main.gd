extends Control


var test_path = "res://wallpaper_placeholder.jpg"

onready var wallpaper = $Wallpaper
onready var label_clock = $Clock


# Called when the node enters the scene tree for the first time.
func _ready():
	set_wallpaper(test_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_time()
	label_clock.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

func set_wallpaper(path):
	var img = Image.new()
	var error = img.load(path)
	
	if error == OK:
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		wallpaper.texture = tex
		print ("Wallpaper loaded!")
	else:
		print("Error loading image.")
