extends Control


var connected_peer_ids = []
var peer_colors = []
var peer_names = []
var tempo = 300


func _ready():
	pass


func host_game(is_host: bool) -> void:
	if is_host:
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(54822)
		multiplayer.multiplayer_peer = peer
		add_player(1, player_info.cor, player_info.user_name)
		multiplayer.peer_connected.connect(
			func(new_peer_id):
				add_previously_connected_players.rpc_id(new_peer_id, connected_peer_ids, peer_colors, peer_names)
				add_myself.rpc_id(new_peer_id, new_peer_id, tempo)
		)
		$iniciar.visible = true
		$tempo_host.visible = true
		update_information(tempo)
	elif not is_host:
		var peer = ENetMultiplayerPeer.new()
		peer.create_client($"../host_ip_address".text, 54822)
		multiplayer.multiplayer_peer = peer
		update_information(tempo)


func add_player(id: int, color: int, user_name_: String):
	if user_name_ in peer_names:
		for i in range(0, 33):
			if user_name_ + str(i) not in peer_names:
				user_name_ = user_name_ + str(i)
			break
	$names_list.add_item(user_name_)
	connected_peer_ids.append(id)
	peer_colors.append(color)
	peer_names.append(user_name_)
	update_information(tempo)

func players_positions():
	var players_positions_ = []
	for i in get_children():
		if i is CharacterBody2D:
			players_positions_.append(i.global_position)
	return players_positions_


@rpc
func add_myself(id: int, tempo_: int):
	tempo = tempo_
	add_newly_connected_player.rpc(id, player_info.cor, player_info.user_name)


@rpc("call_local", "any_peer")
func add_newly_connected_player(id: int, color: int, user_name_):
	add_player(id, color, user_name_)


@rpc
func add_previously_connected_players(peer_ids_: Array, colors: Array, names_: Array):
	for i in range(0, len(peer_ids_)):
		add_player(peer_ids_[i], colors[i], names_[i])


func _process(_delta):
	if $iniciando.visible:
		$iniciando.text = "Iniciando em " + str(floori($timer.time_left)) + " segundos..."


@rpc("call_local")
func carregar():
	add_sibling(load("res://zero.tscn").instantiate())
	$"../zero/game_timer".start(tempo)
	$iniciando.visible = false
	if $"..".host:
		$cancelar.visible = false
		$iniciar.visible = true
	visible = false


@rpc("call_local")
func iniciar():
	$iniciando.visible = true
	$timer.start()


@rpc("call_local")
func cancelar():
	$iniciando.visible = false
	$timer.stop()


func time_text():
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


func _on_iniciar_pressed():
	time_text()
	iniciar.rpc()
	$iniciar.visible = false
	$cancelar.visible = true


func _on_cancelar_pressed():
	cancelar.rpc()
	$iniciar.visible = true
	$cancelar.visible = false


@rpc("call_remote")
# É importante uma chamada local para que ao clicar
# o botão 'Iniciar' todos os jogadores estejam atualizados
func update_information(time: int):
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


func _on_timer_timeout():
	carregar()


func _on_minutes_edit_text_changed(new_text: String) -> void:
	time_text()


func _on_seconds_edit_text_changed(new_text: String) -> void:
	time_text()
