/*
	Glitch Effect Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;

// 色の分離率
uniform float aberration_strength : hint_range( 0.0, 1.0 ) = 0.01;
// スクリーン
uniform sampler2D screen_texture : hint_screen_texture;


void fragment( )
{

	vec2 fixed_uv = SCREEN_UV;

	vec4 pixel_color = textureLod( screen_texture, fixed_uv, 0.0 );
	pixel_color.r = mix(
		pixel_color.r
	,	textureLod( screen_texture, fixed_uv + vec2( aberration_strength, aberration_strength ), 0.0 ).r
	,	1.0
	);
	pixel_color.b = mix(
		pixel_color.b
	,	textureLod( screen_texture, fixed_uv + vec2( -aberration_strength, -aberration_strength ), 0.0 ).b
	,	1.0
	);
	COLOR = pixel_color;
}