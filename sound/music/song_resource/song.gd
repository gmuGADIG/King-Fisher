extends Resource
class_name Song

@export var song_file: Resource
## Array of named sections in this song. Sections with loop=true will loop.
@export var sections: Array[Section] = []
## Volume adjustment in dB for mastering. 0 = no change, negative = quieter.
@export_range(-20.0, 6.0, 0.1, "suffix:dB") var amplify_db: float = 0.0

## Returns the section with the given name, or null if not found
func get_section(section_name: String) -> Section:
	for section in sections:
		if section.section_name == section_name:
			return section
	return null

## Returns the section start time for the given name, or 0.0 if not found
func get_section_start(section_name: String) -> float:
	var section := get_section(section_name)
	return section.section_start if section else 0.0
