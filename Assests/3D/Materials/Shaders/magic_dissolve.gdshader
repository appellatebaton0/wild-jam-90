shader_type spatial;
//render_mode cull_disabled;

uniform float dissolve : hint_range(0.0, 1.0, 0.05) = 0.0;

uniform float map_threshold : hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.05) = 0.5;

uniform vec3 dissolve_color : source_color = vec3(0.0, 0.3, 0.6);
uniform float dissolve_brightness = 1.0;
uniform sampler2D dissolve_map : hint_default_black;

uniform sampler2D object_albedo : source_color, hint_default_white;

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
}

void fragment() {
	ALBEDO = texture(object_albedo, UV).rgb;
	
	float dissolve_base = sample_triplanar(dissolve_map, model_pos, model_normal, 1.0).r;
	dissolve_base = smoothstep(-map_threshold, 1.0 + map_threshold, dissolve_base);
	dissolve_base = smoothstep(1.0 - dissolve, 1.0, dissolve_base);
	dissolve_base += pow(dissolve, 10.0);
	dissolve_base = clamp(dissolve_base, 0.0, 1.0);
	
	EMISSION = dissolve_color * dissolve_base * dissolve_brightness;
	
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	
	ALPHA = (1.0 - dissolve_base);
}
