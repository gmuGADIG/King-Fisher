extends Node
class_name LivewellFish

var fish_file_path : String
var fish_info : livewell_fish_info

func set_fish(path, info):
	self.fish_file_path = path
	self.fish_info = info
