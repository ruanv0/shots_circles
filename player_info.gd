extends Node


var cor
var language
var user_name
var save_path = "user://save.json"
var my_multiplayer_id = -1


func save() -> void:
	var save_dict = {
		"language": language,
		"user_name": user_name,
		"cor": cor
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	file.store_line(json_string)


func load_data() -> void:
	var file = FileAccess.open(save_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var json = JSON.new()
		json.parse(json_string)
		var node_data = json.get_data()
		language = node_data["language"]
		cor = int(node_data["cor"])
		user_name = node_data["user_name"]


func _ready() -> void:
	if not FileAccess.file_exists(save_path):
		var random = RandomNumberGenerator.new().randi_range(0, 9999)
		language = OS.get_locale_language()
		cor = 0
		user_name = OS.get_name() + str(random)
		save()
	else:
		load_data()
