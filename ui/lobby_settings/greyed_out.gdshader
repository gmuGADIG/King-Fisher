shader_type canvas_item;

uniform bool greyed_out = true;
uniform float intensity : hint_range(0, 1) = 1.;

void fragment() {
	if (greyed_out) {
		float greyscale = dot(COLOR.rgb * vec3(0.2, 0.4, 0.05), vec3(1));
		COLOR.rgb = mix(COLOR.rgb, vec3(greyscale), intensity);
	}
}
