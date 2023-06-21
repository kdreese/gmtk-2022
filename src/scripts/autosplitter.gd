extends Node


signal timer_updated

var server := TCPServer.new()
var peers: Array[WebSocketPeer] = []

var speedrun_is_running := false
var run_started_time: int
var speedrun_time: float


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func start() -> void:
	if server.is_listening():
		return
	var error := server.listen(Global.autosplitter_port)
	if error:
		push_error("Error starting websocket server, autosplitter will not run!")
		Global.autosplitter_enabled = false
		var dialog := AcceptDialog.new()
		dialog.title = "Error"
		dialog.dialog_text = "Could not create WebSocket server!\nCheck if port %d is open or choose another port." \
				% Global.autosplitter_port
		get_tree().get_root().add_child.call_deferred(dialog)
		dialog.popup_centered.call_deferred()
		return
	Global.autosplitter_enabled = true
	print("Websocket server listening on port %d" % [server.get_local_port()])


func stop() -> void:
	if not server.is_listening():
		return
	server.stop()
	peers = []
	Global.autosplitter_enabled = false
	print("Websocket server stopped")


func send_data(data: String) -> void:
	if not server.is_listening():
		return
	for peer in peers:
		var error := peer.send_text(data)
		if error:
			push_warning("Error sending \"%s\" to %s:%d" % [data, peer.get_connected_host(), peer.get_connected_port()])


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
	if server.is_listening():
		while server.is_connection_available():
			var conn := server.take_connection()
			var peer := WebSocketPeer.new()
			var error := peer.accept_stream(conn)
			if error:
				push_warning("Incoming peer could not accept stream")
			else:
				print("Websocket connected: %s:%d" % [peer.get_connected_host(), peer.get_connected_port()])
				peers.push_back(peer)
		var poll_and_filter = func(peer: WebSocketPeer) -> bool:
			peer.poll()
			if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
				print("Websocket peer disconnected")
				return false
			return true
		peers = peers.filter(poll_and_filter)
