shader_type canvas_item;

uniform float speed = 3.5;
uniform float intensity = 2.;

float random(vec2 v) {
	return fract(sin(dot(v.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	float t = floor(TIME * speed);
	VERTEX.y += random(VERTEX + vec2(-t, t)) * intensity;
	//VERTEX.x += sin(TIME * 12. * VERTEX.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
