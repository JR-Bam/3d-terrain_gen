shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D noise : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);
uniform float distortion_stength : hint_range(-1, 1) = 0.2;
uniform vec4 tone_color : source_color;
uniform vec4 top_color : source_color;
uniform float light_start : hint_range(-1, 1) = 0.275;
uniform float light_end : hint_range(-1, 1) = 0.4;

void vertex() {
	VERTEX.y += sin(TIME * 0.5 + VERTEX.x * 0.5) * 0.5;
}

void fragment() {
	float depth = texture(noise, UV + scroll * TIME).r
		* texture(noise2, UV + scroll2 * TIME).r;

	vec4 screen_color = texture(SCREEN_TEXTURE,
		SCREEN_UV + distortion_stength * vec2(depth));

	vec4 top_light = smoothstep(light_start, light_start, depth) * top_color;

	ALBEDO = screen_color.xyz * tone_color.xyz + top_light.xyz;
}
