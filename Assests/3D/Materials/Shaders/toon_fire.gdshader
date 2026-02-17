shader_type spatial;
render_mode cull_back, unshaded, world_vertex_coords;

uniform float burn_depth = 0.15;
uniform float warble_strength = 0.125;
uniform float warble_speed = 1.0;

uniform vec3 vertex_fire_direction = vec3(0.0, 1.0, 0.0);
uniform float vertex_fire_strength = 1.0;

uniform float energy = 2.0;

uniform vec3 fire_color_a : source_color = vec3(0.7, 0.3, 0.0);
uniform vec3 fire_color_b : source_color = vec3(1.0, 0.8, 0.0);

uniform sampler2D fire_noise : hint_default_black;

uniform float triplanar_scale = 1.0;
uniform vec2 texture_scale = vec2(1.0, 1.0);

uniform bool inverted_normals = false;

uniform sampler2D depth_texture: hint_depth_texture;
global uniform vec3 wind_direction;

varying float heat_coefficient;
varying vec3 model_normal;
varying vec3 model_pos;

float posterize(float value, float steps) {
	return floor(value * steps) / steps;
}

vec3 sample_triplanar(sampler2D sample_texture, vec3 pos, vec3 normal, float tiling_scale) {
	vec3 blend_weights = abs(normal);
	blend_weights = normalize(max(blend_weights, 0.00001));
	
	vec2 uv_x = pos.yz * tiling_scale;
	vec2 uv_y = pos.xz * tiling_scale;
	vec2 uv_z = pos.xy * tiling_scale;
	
	vec3 sample_x = texture(sample_texture, uv_x * texture_scale).rgb;
	vec3 sample_y = texture(sample_texture, uv_y * texture_scale).rgb;
	vec3 sample_z = texture(sample_texture, uv_z * texture_scale).rgb;
	
	return (sample_x * blend_weights.x)
		+ (sample_y * blend_weights.y)
		+ (sample_z * blend_weights.z);
}

float get_depth(sampler2D depth_tex, vec2 uv, mat4 inv_projection_matrix) {
    float depth_raw = texture(depth_tex, uv).x;
    vec3 ndc = vec3(uv * 2.0 - 1.0, depth_raw);
    vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
    view.xyz /= view.w;
    float depth_linear = -view.z;
    return depth_linear;
}

void vertex() {
	vec3 normal = NORMAL;
	if (inverted_normals) {
		normal = -NORMAL;
	}
	
	model_normal = normal;
	model_pos = VERTEX;
	
	vec3 offset_pos = model_pos + vec3(0.0, -TIME * 2.0, 0.0);
	float noise_a = sample_triplanar(fire_noise, offset_pos, model_normal, 0.5).r;
	
	offset_pos = model_pos + vec3(0.5, 1.0 -TIME * 1.0, 0.5);
	float noise_b = sample_triplanar(fire_noise, offset_pos, model_normal, 1.0).r;
	
	vec3 wind_binormal = vec3(wind_direction.z, wind_direction.x, wind_direction.y);
	
	vec3 modified_wind_direction = wind_direction + wind_binormal * (sin(TIME * warble_speed) * warble_strength);

	heat_coefficient = max(0.0, dot(normal, normalize(modified_wind_direction)));
	
	float v_fire_strength = vertex_fire_strength + (warble_strength * sin(TIME * warble_speed));
	
	VERTEX += normalize(modified_wind_direction + (normal * 0.1)) * noise_a * noise_b * v_fire_strength * (heat_coefficient + 0.1);
	
}

void fragment() {
	
	vec3 offset_pos = model_pos + vec3(0.0, -TIME * 2.0, 0.0);
	float noise_a = sample_triplanar(fire_noise, offset_pos, model_normal, 0.5).r;
	
	offset_pos = model_pos + vec3(0.5, 1.0 -TIME * 1.0, 0.5);
	float noise_b = sample_triplanar(fire_noise, offset_pos, model_normal, 1.0).r;
	
	float fresnel = dot(VIEW, NORMAL);
	fresnel = (1.0 - fresnel) * (1.0 - heat_coefficient);
	fresnel += noise_a * noise_b * 0.35;
	fresnel = pow(fresnel, 2.0);
	//fresnel = posterize(fresnel, 5.0);
	
	float depth_linear = get_depth(depth_texture, SCREEN_UV, INV_PROJECTION_MATRIX);
	float color_depth_mix = smoothstep(0.0, burn_depth, depth_linear + VERTEX.z);
	color_depth_mix = posterize(color_depth_mix, 1.0);
	fresnel = mix(0.0, fresnel, color_depth_mix);
	
	ALBEDO = mix(fire_color_a, fire_color_b, abs(fresnel)) * energy;
}
