extends Control
signal message_received()
const starter_events : Array = ["PlayerMessage"] 
var connected_players : Dictionary = {} # The players directly connected to the websocket server
var event_queue : Array = []
var previous_events : Array = []

func _on_message_received(peer: WebSocketPeer, id: int, message: PackedByteArray, is_string: bool):
	var decode : String = message.get_string_from_utf8()
	var parse = JSON.parse_string(decode)
	parse["sender_id"] = id
	parse.body["sender_id"] = id
	if parse.header["messagePurpose"] != "event":
		parse.body["request_id"] = parse.header["requestId"]
	parse["direction"] = "Incoming"
	event_queue.push_back(parse)
	previous_events.append(parse)
	print(parse)

func _process(_delta):
	var parent = get_parent()
	$main_container.size = get_parent().size
	for event in event_queue:
		match event.header.messagePurpose:
			"commandResponse":
				command_response(event.body)
				event_queue.erase(event)
			"event":
				subscribed_event(event.body)
				event_queue.erase(event)

func command_response(event: Dictionary):
	var keys : Array = event.keys()
	match keys[0]:
		"localplayername": #Player identification
			print("Sender " + str(event["sender_id"]) + " is named: " + event["localplayername"])
			_player_identified(event["sender_id"], event["localplayername"])
		_:
			pass
	
func subscribed_event(event: Dictionary):
	if event.type == "chat":
		new_chat_message(event.sender, event.message, event.sender_id)


func _on_client_connect(peer: WebSocketPeer, id: int, protocol: String) -> void:
	connected_players[id] = {"name": "Unknown", "last_location": Vector3(0, 0, 0)}
	send_command_request("getlocalplayername", id)
	
func _on_client_disconnect(peer: WebSocketPeer, id: int, was_clean_close: bool) -> void:
	var player_name : String = connected_players[id].name
	var message_content : String = player_name + " has disconnected from the chat"
	send_command_request("/tell @s §a" + message_content)
	%chat.text = %chat.text + message_content + "\n"
	connected_players.erase(id)
	update_player_lists()

func _server_chat_send(new_text: String) -> void:
	new_chat_message("Server", new_text, 1)
	%chat_server.text = ""


func send_event_subscribe(event_name: String, peer_id: int) -> void:
	var message = {
			"body": {
				"eventName": event_name
			},
			"header": {
				"requestId": $UUID.generate_new_UUID(),
				"messagePurpose": "subscribe",
				"version": 1,
				"messageType": "commandRequest"
			}
		}
	var parse = JSON.stringify(message)
	send_packet(parse, peer_id)
	
func send_command_request(command: String, peer_id: int=MultiplayerPeer.TARGET_PEER_BROADCAST) -> void:
	var message = {
			"body": {
				"commandLine": command
			},
			"header": {
				"requestId": $UUID.generate_new_UUID(),
				"messagePurpose": "commandRequest",
				"version": 1,
				"messageType": "commandRequest"
			}
		}
	var parse = JSON.stringify(message)
	send_packet(parse, peer_id)
	
func send_packet(message: String, peer_id=MultiplayerPeer.TARGET_PEER_BROADCAST) -> void:
	$WebSocketServer.set_target_peer(peer_id)
	$WebSocketServer.send_text(message)
	var export = JSON.parse_string(message)
	export["direction"] = "Outgoing"
	previous_events.push_back(export)
	
	
func subscribe_nessicary_events(peer_id: int) -> void:
	for event in starter_events:
		send_event_subscribe(event, peer_id)
		
func _player_identified(sender_id: int, sender_name: String) -> void:
	if connected_players.get(sender_id).name != sender_name:
		connected_players[sender_id].name = sender_name
		update_player_lists()
		subscribe_nessicary_events(sender_id)
		var message_content : String = sender_name + " has joined the chat"
		send_command_request("/tell @s §a" + message_content)
		%chat.text = %chat.text + message_content + "\n"
	
func update_player_lists() -> void:
	%playerList_main.text = ""
	for player in connected_players:
		var player_info : Dictionary = connected_players[player]
		if player_info["name"] != "Unknown":
			%playerList_main.text += player_info["name"]
		else:
			%playerList_main.text -= "Unknown player name (ID: %s)" % connected_players.find_key(player)
		%playerList_main.text += "\n"
	
func new_chat_message(sender_name: String, message: String, sender_id=MultiplayerPeer.TARGET_PEER_BROADCAST) -> void:
	sender_id *= -1
	var message_content : String = "<%s> %s" % [sender_name, message]
	send_command_request("/tell @s §b" + message_content, sender_id)
	%chat.text = %chat.text + message_content + "\n"
