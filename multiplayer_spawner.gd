extends MultiplayerSpawner


var host
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene


func add_player(id=1):
  var player = player_scene.instantiate()
  player.name = str(id)
  call_deferred("add_sibling", player)


func _ready():
  host = $"../../hub".host
  $"../../hub".queue_free()
  if host:
    #print("host", host)
    peer.create_server(54822)
    multiplayer.multiplayer_peer = peer
    add_player()
    multiplayer.peer_connected.connect(add_player)
  elif not host:
    #print("host", host)
    peer.create_client("127.0.0.1", 54822)
    multiplayer.multiplayer_peer = peer


