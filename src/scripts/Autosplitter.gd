extends Node


const PORT := 5678

var server: WebSocketServer
var peers := []


func _ready() -> void:
	server = WebSocketServer.new()
	var error := server.listen(PORT)
	if error:
		print("Error starting websocket, autosplitter will not run")
		return
	print("Websocket listening on %s:%d" % [server.bind_ip, PORT])
	error = server.connect("client_close_request", self, "_on_server_client_close_request")
	assert(not error)
	error = server.connect("client_connected", self, "_on_server_client_connected")
	assert(not error)
	error = server.connect("client_disconnected", self, "_on_server_client_disconnected")
	assert(not error)
	error = server.connect("data_received", self, "_on_server_data_received")
	assert(not error)
	pause_mode = Node.PAUSE_MODE_PROCESS


func send_data(data: String) -> void:
	if not server.is_listening():
		return
	for id in peers:
		print("Sending data to peer %d: %s" % [id, data])
		var error := server.get_peer(id).put_packet(data.to_ascii())
		if error:
			print("Error sending packet")


func _process(_delta: float) -> void:
	if server.is_listening():
		server.poll()


func _on_server_client_close_request(id: int, code: int, reason: String) -> void:
	print("Received client close request: %d %d %s" % [id, code, reason])


func _on_server_client_connected(id: int, protocol: String) -> void:
	print("Client connected: %d %s" % [id, protocol])
	peers.append(id)
	server.get_peer(id).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


func _on_server_client_disconnected(id: int, was_clean_close: bool) -> void:
	print("Client disconnected: %d %s" % [id, was_clean_close])
	peers.erase(id)


func _on_server_data_received(id: int) -> void:
	print("Data received: %d" % id)
