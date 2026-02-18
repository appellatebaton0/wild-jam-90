shader_type spatial;
//render_mode cull_disabled;

uniform float dissolve : hint_range(0.0, 1.0, 0.05) = 0.0;

uniform float map_threshold : hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.05) = 0.5;

uniform vec3 dissolve_color : source_color = vec3(0.0, 0.3, 0.6);
uniform float dissolve_brightness = 1.0;
uniform sampler2D dissolve_map : hint_default_black, filter_linear_mipmap, repeat_enable;

uniform sampler2D object_albedo : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 albedo_tint : source_color = vec3(1.0, 1.0, 1.0);

uniform float roughness_multiplier : hint_range(0.0, 1.0, 0.05) = 1.0;
uniform sampler2D object_roughness : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);

uniform float metallic_multiplier : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform sampler2D object_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);

uniform sampler2D object_normal_map : hint_normal, filter_linear_mipmap, repeat_enable;

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

float sample_texture_channel(sampler2D sampler, vec2 uv, vec4 channel) {
	return dot(texture(sampler, uv), channel);
}

void vertex() {
	model_normal = NORMAL;
	model_pos = VERTEX;
}

void fragment() {
	ROUGHNESS = sample_texture_channel(object_roughness, UV, roughness_texture_channel) * roughness_multiplier;
	METALLIC = sample_texture_channel(object_metallic, UV, metallic_texture_channel) * metallic_multiplier;
	NORMAL_MAP = texture(object_normal_map, UV).xyz;
	
	float dissolve_base = sample_triplanar(dissolve_map, model_pos, model_normal, 1.0).r;	
	dissolve_base = smoothstep(-map_threshold, 1.0 + map_threshold, dissolve_base);
	
	float dissolve_burn = clamp(smoothstep(0.0, 1.0, pow(dissolve_base, 1.0 / dissolve)) * (dissolve * 4.0), 0.0, 1.0);
	dissolve_base = smoothstep(1.0 - dissolve, 1.0, dissolve_base);
	
	dissolve_base += pow(dissolve, 10.0);
	dissolve_base = clamp(dissolve_base, 0.0, 1.0);
	
	ALBEDO = texture(object_albedo, UV).rgb * albedo_tint * (1.0 - dissolve_burn);
	
	EMISSION = dissolve_color * dissolve_base * dissolve_brightness;
	
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	
	ALPHA = (1.0 - dissolve_base);
}
