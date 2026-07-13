/*
	Glitch Effect Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;

float rand(float n){return fract(sin(n) * 43758.5453123);}


uniform vec2 aberration_direction = vec2(1, 1);
// 色の分離率
uniform float aberration_strength : hint_range( 0.0, 1.0 ) = 0.01;
// スクリーン
uniform sampler2D screen_texture : hint_screen_texture;
uniform float noise_freq = 0;
uniform float noise_intensity = 0;
uniform float noise_exp = 4.;

float noise(float p){
	float fl = floor(p);
	float fc = fract(p);
	float ret =  mix(rand(fl), rand(fl + 1.0), fc);
	return pow(ret, noise_exp);
}

void fragment( )
{

	float strength = aberration_strength + (clamp(noise(TIME * noise_freq), 0, 1) * noise_intensity * .001);
	vec2 fixed_uv = SCREEN_UV;

	vec4 pixel_color = textureLod( screen_texture, fixed_uv, 0.0 );
	pixel_color.r = mix(
		pixel_color.r
	,	textureLod( screen_texture, fixed_uv + aberration_direction * strength, 0.0 ).r
	,	1.0
	);
	pixel_color.b = mix(
		pixel_color.b
	,	textureLod( screen_texture, fixed_uv - aberration_direction * strength, 0.0 ).b
	,	1.0
	);
	COLOR = pixel_color;
}