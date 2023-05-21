extends Node


signal timer_updated

# TODO: Godot 4 remove WebSocketServer, and creating a WebSocket server is different now and not as documented
#var server: WebSocketServer
#var peers := []

var speedrun_is_running := false
var run_started_time: int
var speedrun_time: float


func _ready() -> void:
	#server = WebSocketServer.new()
	#var error := server.connect("client_close_request", Callable(self, "_on_server_client_close_request"))
	#assert(not error)
	#error = server.connect("client_connected", Callable(self, "_on_server_client_connected"))
	#assert(not error)
	#error = server.connect("client_disconnected", Callable(self, "_on_server_client_disconnected"))
	#assert(not error)
	#error = server.connect("data_received", Callable(self, "_on_server_data_received"))
	#assert(not error)
	process_mode = Node.PROCESS_MODE_ALWAYS


func start() -> void:
	pass
	#if server.is_listening():
	#	return
	#var error := server.listen(Global.autosplitter_port)
	#if error:
	#	print("Error starting websocket, autosplitter will not run")
	#	return
	#Global.autosplitter_enabled = true
	#print("Websocket listening on %s:%d" % [server.bind_ip, Global.autosplitter_port])


func stop() -> void:
	pass
	#if not server.is_listening():
	#	return
	#server.stop()
	#peers = []
	#Global.autosplitter_enabled = false
	#print("Server stopped")


func send_data(_data: String) -> void:
	pass
	#if not server.is_listening():
	#	return
	#for id in peers:
	#	var error := server.get_peer(id).put_packet(data.to_ascii_buffer())
	#	if error:
	#		print("Error sending packet")


func run_start() -> void:
	speedrun_is_running = true
	run_started_time = Time.get_ticks_usec()
	speedrun_time = 0.0
	send_data("initgametime")
	send_data("start")
	send_data("setgametime 0.0")


func run_reset() -> void:
	speedrun_is_running = false
	send_data("reset")


func run_split() -> void:
	run_delta()
	send_data("split")


func run_finish() -> void:
	emit_signal("timer_updated", true)
	speedrun_is_running = false


func run_delta() -> void:
	speedrun_time = (Time.get_ticks_usec() - run_started_time) / 1000000.0
	send_data("setgametime %s" % speedrun_time)


func _process(_delta: float) -> void:
	if speedrun_is_running:
		run_delta()
		emit_signal("timer_updated")
	#if server.is_listening():
	#	server.poll()


#func _on_server_client_close_request(id: int, code: int, reason: String) -> void:
#	print("Received client close request: %d %d %s" % [id, code, reason])


#func _on_server_client_connected(id: int, protocol: String) -> void:
#	print("Client connected: %d %s" % [id, protocol])
#	peers.append(id)
#	server.get_peer(id).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


#func _on_server_client_disconnected(id: int, was_clean_close: bool) -> void:
#	print("Client disconnected: %d %s" % [id, was_clean_close])
#	peers.erase(id)


#func _on_server_data_received(id: int) -> void:
#	print("Data received: %d" % id)
