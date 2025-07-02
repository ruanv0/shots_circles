extends Node2D


var avatar_pressed = -1
var ip_address: String
var host = false


func _ready():
	$host.position.x = (get_viewport_rect().size.x - 500) / 2
	$host.position.y = ((get_viewport_rect().size.y - 250) * 0.5) / 2
	$join.position.x = (get_viewport_rect().size.x - 500) / 2
	$join.position.y = ((get_viewport_rect().size.y - 250) * 1.5) / 2
	for ip in IP.get_local_addresses():
		if ip.count(".") == 3 and ip != "127.0.0.1":
			ip_address = ip
			break
	$your_ip_address.text = ip_address
	$host_ip_address.text = ip_address.split(".")[0] + "." + ip_address.split(".")[1] + "." + ip_address.split(".")[2] + "."


func _on_host_pressed():
	$multiplayer_menu.visible = true
	host = true
	$multiplayer_menu.host_game(host)
	$host.visible = false
	$join.visible = false
	$avatar.visible = false
	$avatar_label.visible = false
	$host_ip_address.visible = false
	$your_ip_address.visible = false


func _on_join_pressed():
	$multiplayer_menu.visible = true
	$multiplayer_menu.host_game(false)
	$host.visible = false
	$join.visible = false
	$avatar.visible = false
	$avatar_label.visible = false
	$host_ip_address.visible = false
	$your_ip_address.visible = false


func _input(event):
	if event is InputEventScreenTouch and not event.pressed:
		if event.position.x > 30 and event.position.x < 183.6 + 160 and event.position.y > 0 and event.position.y < 183.6:
			call_deferred("add_sibling", load("res://avatar.tscn").instantiate())
			queue_free()
		elif avatar_pressed == event.index:
			avatar_pressed = -1
			$avatar_label.add_theme_color_override("font_color", Color8(255, 255, 255))
			$avatar.texture = load("res://avatar_normal.png")
	elif event is InputEventScreenTouch and event.pressed:
		if event.position.x > 30 and event.position.x < 183.6 + 160 and event.position.y > 0 and event.position.y < 183.6:
			$avatar_label.add_theme_color_override("font_color", Color8(134, 134, 134))
			$avatar.texture = load("res://avatar_pressed.png")
			avatar_pressed = event.index
