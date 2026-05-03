extends Node

var root_path: String
var sound_files: Array[Resource] = []
var song_dict: Dictionary = {}

func index_all_sound_files_in_root_directory() -> void:
	sound_files.clear()
	song_dict.clear()
	_scan_folder(root_path)

func _scan_folder(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("SongScanner: failed to open directory '%s'" % path)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		file_name = file_name.trim_suffix(".remap")
		var full_path: String = path.path_join(file_name)
		if dir.current_is_dir():
			_scan_folder(full_path + "/")
		else:
			if _is_sound_file(file_name):
				var res: Resource = ResourceLoader.load(full_path)
				if res:
					sound_files.append(res)
					if file_name.get_extension().to_lower() == "tres" and res is Song:
						song_dict[file_name] = res
				else:
					push_warning("SongScanner: could not load '%s'" % full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func _is_sound_file(file_name: String) -> bool:
	var ext: String = file_name.get_extension().to_lower()
	return ext in ["wav", "ogg", "mp3", "tres"]

func get_song_by_filename(filename: String) -> Song:
	return song_dict.get(filename, null) as Song
