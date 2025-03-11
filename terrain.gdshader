shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D rock_texture;
uniform sampler2D snow_texture;

uniform float max_rockgrass_height = 30.0;
uniform float min_snow_height = 25.0;
uniform float min_rock_slope : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float max_grass_slope : hint_range(0.0, 1.0, 0.1) = 0.9;

uniform float blue_level_height : hint_range(0.0, 100.0) = 15.0;

varying float normal_y;
varying float vertex_y;

void vertex() {
    // Pass vertex height and normal Y to fragment shader
    normal_y = NORMAL.y;
    vertex_y = VERTEX.y;
	
	if (vertex_y <= blue_level_height + sin(TIME * 0.5) * 0.3) {
		VERTEX.y = blue_level_height;
		VERTEX.y += sin(TIME * 0.5 + VERTEX.x * 10.0) * 0.3;
	}
}

void fragment() {
    // Sample textures
    vec3 grass_albedo = texture(grass_texture, UV * 4.0).xyz;
    vec3 rock_albedo = texture(rock_texture, UV * 4.0).xyz;
    vec3 snow_albedo = texture(snow_texture, UV * 4.0).xyz;

    // Calculate rock/grass weight based on slope
    float rock_grass_weight = smoothstep(min_rock_slope, max_grass_slope, normal_y);

    // Calculate snow/rockgrass weight based on height
    float snow_rockgrass_weight = smoothstep(min_snow_height, max_rockgrass_height, vertex_y);

    // Blend rock and grass based on slope
    vec3 rockgrass_albedo = mix(rock_albedo, grass_albedo, rock_grass_weight);

    // Blend snow with rock/grass based on height
	vec3 final_albedo = mix(rockgrass_albedo, snow_albedo, snow_rockgrass_weight);
	
	if (vertex_y <= blue_level_height + sin(TIME * 0.5) * 0.3){
		final_albedo = vec3(0, 0, 1);
	}
    ALBEDO = final_albedo;
}