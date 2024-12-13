extends Control


signal found_server
signal server_removed

var broadcast_timer : Timer
var room_info = {"name": "", "player_count": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@export var broadcast_port : int = 54823
@export var broadcast_address : String = "192.168.100.255"
@export var listen_port : int = 54822

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#broadcast_timer = $broadcast_timer
	#setup()
	pass


"""func _process(delta: float) -> void:
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_utf8()
		room_info = JSON.parse_string(data)
		print("serverip -> ", serverip)
		print("serverport -> ", serverport)
		print("room_info -> ", room_info)"""


func setup() -> void:
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listen_port)
	if ok == OK:
		print("Bound to listen port " + str(listen_port) + " successful.")
	else:
		print("Failed to bind to listen port " + str(listen_port) + ".")


func setup_broadcast():
	room_info.name = player_info.user_name
	room_info.player_count = len($"../multiplayer_menu".connected_peer_ids)
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcast_address, broadcast_port)
	var ok = broadcaster.bind(broadcast_port)
	if ok == OK:
		print("Bound to broadcast port " + str(broadcast_port) + " successful.")
		$Label.text = "Bound to listen port: true"
	else:
		print("Failed to bind to broadcast port " + str(broadcast_port) + ".")
		$Label.text = "Bound to listen port: false"
	$broadcast_timer.start()


func _on_broadcast_timer_timeout() -> void:
	pass
	"""print("Broadcasting game!")
	room_info.player_count = len($"../multiplayer_menu".connected_peer_ids)
	var data = JSON.stringify(room_info)
	var packet = data.to_utf8_buffer()
	broadcaster.put_packet(packet)"""


func clean_up() -> void:
	listener.close()
	$broadcast_timer.stop()
	if broadcaster != null:
		broadcaster.close()


func _exit_tree() -> void:
	clean_up()
