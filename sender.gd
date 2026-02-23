extends Node
class_name NtfySender


@export var ntfy_server: String = "https://ntfy.sh"
@export var topic: String = "your-topic-name"
@export var default_title: String = "Godot Notification"
@export var default_priority: int = 3  # 1=min, 2=low, 3=default, 4=high, 5=max

func send_notification(
	message: String,
	title: String = default_title,
	priority: int = default_priority,
	tags: Array = [],
	click_url: String = ""
) -> void:
	var url = "%s/%s" % [ntfy_server, topic]
	
	var headers = [
		"Content-Type: text/plain",
		"Title: %s" % title,
		"Priority: %d" % priority,
	]
	
	if tags.size() > 0:
		headers.append("Tags: %s" % ",".join(tags))
	
	if click_url != "":
		headers.append("Click: %s" % click_url)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(http_request))
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, message)
	if error != OK:
		push_error("ntfy: Failed to send request, error code: %d" % error)
		http_request.queue_free()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("ntfy: HTTP request failed with result: %d" % result)
	elif response_code == 200:
		print("ntfy: Notification sent successfully!")
	else:
		push_error("ntfy: Server returned code %d — %s" % [response_code, body.get_string_from_utf8()])
	
	http_request.queue_free()
	
##EXAMPLE USAGE BELOW - Add your own ntfy server to the ntfy_server variable, and call send_notification() to use

func _ready():
	send_notification("Player reached level 9999!")

	#Message showing all options
	send_notification(
		"Build finished successfully", # note
		"Game Complete",           # title
		4,                 # priority 
		["white_check_mark", "godot"],  # emoji tags
		"https://example.com"           # click URL
	)
