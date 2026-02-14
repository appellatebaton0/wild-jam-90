shader_type spatial;

uniform sampler2D albedo_texture: hint_default_white, source_color;
uniform sampler2D emission_texture: hint_default_black, source_color;
uniform sampler2D emission_noise: hint_default_black;
uniform sampler2D vertex_fire_mask: hint_default_white;

uniform float emission_strength = 1.0;

uniform vec3 vertex_fire_direction = vec3(0.0, 1.0, 0.0);
uniform float vertex_fire_strength = 1.0;

uniform vec3 fire_color: source_color = vec3(0.75, 0.5, 0.0);
uniform float fire_strength = 3.0;
uniform float fire_center = 0.5;
uniform float fire_height = 3.0;

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
	
	vec3 sample_x = texture(sample_texture, uv_x).rgb;
	vec3 sample_y = texture(sample_texture, uv_y).rgb;
	vec3 sample_z = texture(sample_texture, uv_z).rgb;
	
	return (sample_x * blend_weights.x)
		+ (sample_y * blend_weights.y)
		+ (sample_z * blend_weights.z);
}

void vertex() {
	model_normal = NORMAL;
	model_pos = VERTEX;
	
	vec3 offset_pos = model_pos + vec3(0.0, -TIME * 2.0, 0.0);
	float noise_a = sample_triplanar(emission_noise, offset_pos, model_normal, 0.5).r;
	
	offset_pos = model_pos + vec3(0.5, 1.0 -TIME * 1.0, 0.5);
	float noise_b = sample_triplanar(emission_noise, offset_pos, model_normal, 1.0).r;
	
	float pointing_up = max(0.0, dot(NORMAL, normalize(vertex_fire_direction)));
	
	float fire_mask = texture(vertex_fire_mask, UV).r;
	VERTEX += normalize(vertex_fire_direction + (NORMAL * 0.25)) * noise_a * noise_b * vertex_fire_strength * fire_mask * pointing_up;
	
}

void fragment() {
	vec3 albedo = texture(albedo_texture, UV).rgb;
	
	vec3 offset_pos = model_pos + vec3(0.0, -TIME * 2.0, 0.0);
	float noise_a = sample_triplanar(emission_noise, offset_pos, model_normal, 0.5).r;
	
	offset_pos = model_pos + vec3(0.5, 1.0 -TIME * 1.0, 0.5);
	float noise_b = sample_triplanar(emission_noise, offset_pos, model_normal, 1.0).r;
	
	vec4 emission = texture(emission_texture, UV);
	vec3 fire = vec3(noise_a * noise_b * clamp(smoothstep(fire_height, 0.0, model_pos.y - fire_center), 0.0, 1.0));
	float fresnel = (1.0 - max(0, dot(NORMAL, VIEW)));
	fresnel = pow(fresnel, 2.5) * 0.5;
	
	ALBEDO = albedo;
	EMISSION = mix(emission.rgb * emission_strength, fire_color * fire_strength, max(fire.r, fresnel)) * emission.a;
}

void light() {
    float surface = max(0.0, dot(NORMAL, LIGHT));
	
    DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * surface * (1.0 / PI);
}