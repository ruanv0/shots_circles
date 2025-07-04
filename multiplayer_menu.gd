extends Control


var connected_peer_ids = []
var peer_colors = []
var peer_names = []
var peer_ips = []
var tempo = 300


func host_game(is_host: bool) -> void:
	if is_host:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(54822)
		multiplayer.multiplayer_peer = peer
		add_player(1, player_info.cor, player_info.user_name, $"..".ip_address)
		multiplayer.peer_connected.connect(
			func(new_peer_id):
				add_previously_connected_players.rpc_id(new_peer_id, connected_peer_ids, peer_colors, peer_names, peer_ips)
				add_myself.rpc_id(new_peer_id, new_peer_id, tempo)
		)
		multiplayer.peer_disconnected.connect(
			func(peer_id):
				remove_player.rpc(peer_id)
		)
		$iniciar.visible = true
		$tempo_host.visible = true
		update_information(tempo)
	elif not is_host:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client($"../host_ip_address".text, 54822)
		multiplayer.multiplayer_peer = peer
		update_information(tempo)


func add_player(id: int, color: int, user_name_: String, ip: String) -> void:
	$names_list.add_item(user_name_)
	connected_peer_ids.append(id)
	peer_colors.append(color)
	peer_names.append(user_name_)
	peer_ips.append(ip)
	update_information.rpc(tempo)


@rpc("call_local")
func remove_player(id: int):
	peer_colors.pop_at(connected_peer_ids.find(id))
	peer_names.pop_at(connected_peer_ids.find(id))
	$names_list.remove_item(connected_peer_ids.find(id))
	peer_ips.pop_at(connected_peer_ids.find(id))
	connected_peer_ids.erase(id)
	update_information.rpc(tempo)


func players_positions() -> Array:
	var players_positions_ = []
	for child in get_children():
		if child is CharacterBody2D:
			players_positions_.append(child.global_position)
	return players_positions_


@rpc
func add_myself(id: int, tempo_: int) -> void:
	tempo = tempo_
	if player_info.user_name in peer_names:
		for index in range(0, 33):
			if player_info.user_name + str(index) not in peer_names:
				if len(player_info.user_name + str(index)) < $"../avatar/name_text".max_length:
					$"../avatar/name_text".text = player_info.user_name + str(index)
				else:
					if index >= 10:
						$"../avatar/name_text".max_length += 2
					elif index < 10:
						$"../avatar/name_text".max_length += 1
					$"../avatar/name_text".text = player_info.user_name + str(index)
				break
	add_newly_connected_player.rpc(id, player_info.cor, $"../avatar/name_text".text, $"..".ip_address)


@rpc("call_local", "any_peer")
func add_newly_connected_player(id: int, color: int, user_name_, ip: String) -> void:
	add_player(id, color, user_name_, ip)


@rpc
func add_previously_connected_players(peer_ids_: Array, colors: Array, names_: Array, ips: Array) -> void:
	for index in range(0, len(peer_ids_)):
		add_player(peer_ids_[index], colors[index], names_[index], ips[index])


func _process(_delta) -> void:
	if $iniciando.visible:
		$iniciando.text = "Iniciando em " + str(floori($timer.time_left)) + " segundos..."
	#print("3. len(peer_names) -> ", len(peer_names))


@rpc("call_local")
func carregar() -> void:
	add_sibling(load("res://zero.tscn").instantiate())
	$"../zero/game_timer".start(tempo)
	$iniciando.visible = false
	if $"..".host:
		$cancelar.visible = false
		$iniciar.visible = true
	visible = false


@rpc("call_local")
func iniciar() -> void:
	$iniciando.visible = true
	$timer.start()


@rpc("call_local")
func cancelar() -> void:
	$iniciando.visible = false
	$timer.stop()


func time_text() -> void:
	var minutes = $tempo_host/minutes_edit.text
	var seconds = $tempo_host/seconds_edit.text
	for character in minutes:
		if character not in "0123456789":
			minutes = minutes.replace(character, "")
	for character in seconds:
		if character not in "0123456789":
			seconds = seconds.replace(character, "")
	if len(minutes) == 0:
		if len(seconds) == 0:
			tempo = 0
		else:
			tempo = int(seconds)
	else:
		if len(seconds) == 0:
			tempo = int(minutes) * 60
		else:
			tempo = int(minutes) * 60 + int(seconds)
	if $tempo_host/minutes_edit.text != minutes:
		$tempo_host/minutes_edit.text = minutes
	if $tempo_host/seconds_edit.text != seconds:
		$tempo_host/seconds_edit.text = seconds
	update_information.rpc(tempo)


func _on_iniciar_pressed() -> void:
	time_text()
	iniciar.rpc()
	$iniciar.visible = false
	$cancelar.visible = true


func _on_cancelar_pressed() -> void:
	cancelar.rpc()
	$iniciar.visible = true
	$cancelar.visible = false


@rpc("call_local", "any_peer")
func update_player_data(color: int, user_name_: String) -> void:
	$names_list.set_item_text(connected_peer_ids.find(multiplayer.get_remote_sender_id()), user_name_)
	peer_colors[connected_peer_ids.find(multiplayer.get_remote_sender_id())] = color
	peer_names[connected_peer_ids.find(multiplayer.get_remote_sender_id())] = user_name_


# É importante uma chamada local para que ao clicar
# o botão 'Iniciar' todos os jogadores estejam atualizados
@rpc("call_local", "any_peer")
func update_information(time: int) -> void:
	tempo = time
	if floori(tempo / 60.0) >= 10:
		if tempo % 60 >= 10:
			$informacoes.text = "Número de jogadores: " + str(len(peer_names)) + "\nModo: Contra todos\nMapa: zero\nTempo: " + str(floori(tempo / 60.0)) + ":" + str(tempo % 60) + "\nEndereço do hospedeiro:\n" + $"..".ip_address
		elif tempo % 60 < 10:
			$informacoes.text = "Número de jogadores: " + str(len(peer_names)) + "\nModo: Contra todos\nMapa: zero\nTempo: " + str(floori(tempo / 60.0)) + ":0" + str(tempo % 60) + "\nEndereço do hospedeiro:\n" + $"..".ip_address
	elif floori(tempo / 60.0) < 10:
		if tempo % 60 >= 10:
			$informacoes.text = "Número de jogadores: " + str(len(peer_names)) + "\nModo: Contra todos\nMapa: zero\nTempo: 0" + str(floori(tempo / 60.0)) + ":" + str(tempo % 60) + "\nEndereço do hospedeiro:\n" + $"..".ip_address
		elif tempo % 60 < 10:
			$informacoes.text = "Número de jogadores: " + str(len(peer_names)) + "\nModo: Contra todos\nMapa: zero\nTempo: 0" + str(floori(tempo / 60.0)) + ":0" + str(tempo % 60) + "\nEndereço do hospedeiro:\n" + $"..".ip_address


func _on_timer_timeout() -> void:
	carregar()


func _on_minutes_edit_text_changed(new_text: String) -> void:
	time_text()


func _on_seconds_edit_text_changed(new_text: String) -> void:
	time_text()


func _on_sair_pressed() -> void:
	multiplayer.multiplayer_peer = null
	connected_peer_ids = []
	peer_colors = []
	peer_names = []
	$names_list.clear()
	tempo = 300
	visible = false
	$"..".disable_visibility(false)


func _on_avatar_button_pressed() -> void:
	$"../avatar".enable_visibility("multiplayer")
	visible = false
