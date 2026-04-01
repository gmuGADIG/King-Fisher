## Interacts with the DonorDrive API to get _donations from Extra Life
##
## This object will send a request to the DonorDrive API every 15 seconds to get the most recent _donations.
## Donations can be polled with the [method get_donation] and must be "freed" with the [method Donation.erase].
## That API was decided to minimize the potential of missing the delivery of a donation reward.

extends Node

const _team_id := 69736 # gadig team id
# const _team_id := 68999 # random team id

const _filter := "?where=createdDateUTC > '%s'"
const _api_url := "https://extra-life.org/api/teams/%s/donations"
#const _api_url := "http://localhost:8088/%s" # phony-drive

const _datetime_key := "createdDateUTC"
const _donor_name_key := "displayName"
const _dollar_amount_key := "amount"

var _most_recent_timestamp: int
var _donations: Dictionary[Donation, Object]
var _http_request: HTTPRequest

var active := false

class Donation:
	var dollar_amount: float
	var unix_timestamp: int
	var donor_name: String
	
	func _init(
		new_donor_name: String, 
		new_dollar_amount: float, 
		new_unix_timestamp: int
	) -> void:
		self.dollar_amount = new_dollar_amount
		self.unix_timestamp = new_unix_timestamp
		self.donor_name = new_donor_name
	
	func erase() -> void:
		DonorDrive._donations.erase(self)

## Gets the oldest donation. Returns [code]null[/code] if no _donations exist.
func get_donation() -> Donation:
	if _donations.is_empty():
		return null
	return _donations.keys()[0]

func _poll_iteration() -> void:
	# send request
	var url := _api_url % _team_id
	url += _filter % Time.get_datetime_string_from_unix_time(_most_recent_timestamp)
	var error := _http_request.request(url)

	if error != OK:
		push_error("[donor_drive] error getting new _donations")
		return

	var x: Array = await _http_request.request_completed
	var res_result: int = x[0]
	var status_code: int = x[1]
	var _res_headers: PackedStringArray = x[2]
	var raw_response: PackedByteArray = x[3]
	
	if res_result != OK or status_code != 200:
		push_error("[donor_drive] error getting new _donations")
		return

	# parse response
	var response: Array = JSON.parse_string(raw_response.get_string_from_utf8())
	if response.is_empty(): return

	for raw_donation: Dictionary in response:
		var donation := Donation.new(
			raw_donation[_donor_name_key],
			raw_donation[_dollar_amount_key],
			Time.get_unix_time_from_datetime_string(raw_donation[_datetime_key]),
		)

		# filter out old donations
		if donation.unix_timestamp <= _most_recent_timestamp:
			continue 

		_donations[donation] = null
	
	if _donations.is_empty(): return
	# reset most recent timestamp
	var timestamps: Array = _donations.keys().map(func(d: Donation) -> int: return d.unix_timestamp)
	assert(typeof(timestamps[0]) == TYPE_INT)
	timestamps.sort()
	_most_recent_timestamp = timestamps[-1]

func _ready() -> void:
	# connect to API
	
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	
	var error := _http_request.request(_api_url % _team_id)
	if error != OK:
		push_error("[donor_drive] error making first contact with donor drive api.")
		return
	
	var x: Array = await _http_request.request_completed
	
	var res_result: int = x[0]
	var status_code: int = x[1]
	var _res_headers: PackedStringArray = x[2]
	var raw_response: PackedByteArray = x[3]
	
	if res_result != OK or status_code != 200:
		push_error("[donor_drive] error making first contact with donor drive api.")
		return
	
	var response: Array = JSON.parse_string(raw_response.get_string_from_utf8())
	if response.is_empty():
		_most_recent_timestamp = 0
	else:
		_most_recent_timestamp = Time.get_unix_time_from_datetime_string(response[0][_datetime_key])

	active = true
	
	while true:
		await get_tree().create_timer(15.).timeout
		await _poll_iteration()
