extends Control


var host
var connected_peer_ids = []
var peer_colors = []
var peer_names = []


func _ready():
  host = $"../hub".host
  $"../hub".visible = false
  if host:
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(54822)
    multiplayer.multiplayer_peer = peer
    add_player(1, player_info.cor, player_info.user_name)
    multiplayer.peer_connected.connect(
      func(new_peer_id):
        add_previously_connected_players.rpc_id(new_peer_id, connected_peer_ids, peer_colors, peer_names)
        add_myself.rpc_id(new_peer_id, new_peer_id)
    )
    $iniciar.visible = 1
  elif not host:
    var peer = ENetMultiplayerPeer.new()
    peer.create_client("127.0.0.1", 54822)
    multiplayer.multiplayer_peer = peer


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
  $numero_jogadores.text = "Número de jogadores: " + str(len(peer_names))


func players_positions():
  var players_positions_ = []
  for i in get_children():
    if i is CharacterBody2D:
      players_positions_.append(i.global_position)
  return players_positions_


@rpc
func add_myself(id: int):
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
    $iniciando.text = "Iniciando em " + str(floor($timer.time_left)) + " segundos..."


@rpc("call_local")
func carregar():
  add_sibling(load("res://zero.tscn").instantiate())


@rpc("call_local")
func iniciar():
  $iniciando.visible = 1
  $timer.start()


@rpc("call_local")
func cancelar():
  $iniciando.visible = 0
  $timer.stop()


func _on_iniciar_pressed():
  iniciar.rpc()
  $iniciar.visible = 0
  $cancelar.visible = 1


func _on_cancelar_pressed():
  cancelar.rpc()
  $iniciar.visible = 1
  $cancelar.visible = 0


func _on_timer_timeout():
  carregar()
