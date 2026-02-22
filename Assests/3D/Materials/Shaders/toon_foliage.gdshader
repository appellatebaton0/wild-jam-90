shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float alpha_scissor_threshold = 0.5;

uniform float cull_range = 3.0;

uniform float displacement_amount = 0.25;
uniform float displacement_height = 1.0;
uniform float displacement_range = 2.0;

global uniform vec3 player_position;
global uniform vec3 player_movement;

global uniform sampler2D wind_noise;
global uniform vec3 wind_direction;
global uniform float wind_speed;

float posterize(float value, float steps) {
	return floor(value * steps) / steps;
}

vec3 get_offset_position() {
	return vec3(1.0);
}

void vertex() {
	vec3 world_pos = VERTEX;//(MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 local_pos = (inverse(MODEL_MATRIX) * vec4(VERTEX, 1.0)).xyz;
	
	float wind_force = length(wind_direction);
	float wind_strength = texture(wind_noise, vec2(world_pos.x + TIME * wind_speed, world_pos.z + TIME * wind_speed)).r;
	float offset_wind_strength = texture(wind_noise, vec2(0.15, 0.15) + vec2(world_pos.x + TIME * wind_speed, world_pos.z + TIME * wind_speed)).r;
	
	vec3 player_direction = world_pos - player_position;
	vec3 flat_player_direction = (player_direction * vec3(1.0, 0.0, 1.0));
	float player_proximity = smoothstep(0.0, 1.0, 1.0 - length(player_direction) / displacement_range);
	VERTEX += smoothstep(0.0, 1.0, local_pos.y / displacement_height) * displacement_amount * (flat_player_direction + player_movement) * player_proximity;
	
	//wind_direction = inverse(MODEL_MATRIX, )
	vec3 wind = (normalize(wind_direction) * min(wind_force, 1.0) * (wind_strength * offset_wind_strength));
	VERTEX += wind;
	// Called for every vertex the material is visible on.
}

void fragment() {
	//float cam = length(VERTEX.z);
	
	float v_x = (abs(VERTEX.x) / cull_range);
	float v_z = (1.0 - VERTEX.z) / cull_range;
	float cull = step(1.0, max(v_z, v_x));
	
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * tint_color; // * COLOR.rgb
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	ALPHA = albedo.a * cull;
}

void light() {
	float light_product = dot(NORMAL, LIGHT);
	float surface = step(0, abs(light_product));
	
	//float fresnel = (1.0 - dot(NORMAL, VIEW));
	//DIFFUSE_LIGHT += fresnel * ATTENUATION * LIGHT_COLOR * 0.15;
	
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * (1.0 / PI); //* surface;
}