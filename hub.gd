extends Node2D


var ip_address: String
var host = false


func _ready() -> void:
	for ip in IP.get_local_addresses():
		if ip.count(".") == 3 and ip != "127.0.0.1":
			ip_address = ip
			break
	$your_ip_address.text = "Seu endereço IP local: " + ip_address
	$host_ip_address.text = ip_address.split(".")[0] + "." + ip_address.split(".")[1] + "." + ip_address.split(".")[2] + "."


func disable_visibility(yes_or_no: bool) -> void:
	$host.visible = !yes_or_no
	$join.visible = !yes_or_no
	$avatar_button.visible = !yes_or_no
	$host_ip_address.visible = !yes_or_no
	$your_ip_address.visible = !yes_or_no
	$host_ip_address_label.visible = !yes_or_no


func _on_host_pressed() -> void:
	$multiplayer_menu.visible = true
	host = true
	$multiplayer_menu.host_game(host)
	disable_visibility(true)


func _on_join_pressed() -> void:
	$multiplayer_menu.visible = true
	$multiplayer_menu.host_game(false)
	disable_visibility(true)


func _on_avatar_button_pressed() -> void:
	$avatar.enable_visibility("hub")
	disable_visibility(true)
