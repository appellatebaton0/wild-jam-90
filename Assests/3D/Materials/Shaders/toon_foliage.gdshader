shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float alpha_scissor_threshold = 0.5;

global uniform vec3 player_position;

global uniform sampler2D wind_noise;
global uniform vec3 wind_direction;
global uniform float wind_speed;

float posterize(float value, float steps) {
	return floor(value * steps) / steps;
}

void vertex() {
	
	float wind_force = length(wind_direction);
	float wind_strength = texture(wind_noise, vec2(VERTEX.x + TIME * wind_speed, VERTEX.z + TIME * wind_speed)).r;
	float offset_wind_strength = texture(wind_noise, vec2(0.15, 0.15) + vec2(VERTEX.x + TIME * wind_speed, VERTEX.z + TIME * wind_speed)).r;
	
	vec3 wind = (normalize(wind_direction) * min(wind_force, 1.0) * (wind_strength * offset_wind_strength));
	VERTEX += wind;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * tint_color; // * COLOR.rgb
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	ALPHA = albedo.a;
}
void light() {
	float light_product = dot(NORMAL, LIGHT);
	float surface = step(0, abs(light_product));
	
	//float fresnel = (1.0 - dot(NORMAL, VIEW));
	//DIFFUSE_LIGHT += fresnel * ATTENUATION * LIGHT_COLOR * 0.15;
	
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * (1.0 / PI); //* surface;
}