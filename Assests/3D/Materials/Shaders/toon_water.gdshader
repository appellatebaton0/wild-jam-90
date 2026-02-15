shader_type spatial;

uniform float surface_alpha = 0.5;

uniform float edge_depth = 0.5;
uniform float darkest_depth = 5.0;
uniform float underwater_caustic_warp = 0.05;

uniform float water_scroll_speed = 0.25;
uniform float triplanar_scale = 1.0;
uniform vec2 texture_scale = vec2(1.0, 1.0);

uniform vec3 shallow_color : source_color = vec3(0.15, 0.35, 0.6);
uniform vec3 deep_color : source_color = vec3(0.0, 0.15, 0.3);
uniform vec3 highlight_color : source_color = vec3(0.7, 0.8, 1.0);

uniform sampler2D caustic_noise_texture : hint_default_black;

uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D depth_texture: hint_depth_texture;

varying vec3 model_normal;
varying vec3 model_pos;

varying float bump;

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
	model_normal = NORMAL;
	model_pos = VERTEX;
}

void fragment() {
	
	vec3 offset_model_pos = model_pos + (vec3(1.0, 0.0, 1.0) * TIME * water_scroll_speed * 0.5);
	vec3 offset_model_pos_b = model_pos + (vec3(1.0, 0.0, 1.0) * TIME * water_scroll_speed);
	float caustic_value = sample_triplanar(caustic_noise_texture, offset_model_pos, model_normal, triplanar_scale).r;
	float caustic_value_b = sample_triplanar(caustic_noise_texture, offset_model_pos_b, model_normal, triplanar_scale).r;
	
	vec2 underwater_uv = SCREEN_UV;
	underwater_uv += vec2(caustic_value) * underwater_caustic_warp;
	
	float depth_linear = get_depth(depth_texture, underwater_uv, INV_PROJECTION_MATRIX);
	float depth_linear_unwarped = get_depth(depth_texture, SCREEN_UV, INV_PROJECTION_MATRIX);
	
	vec3 screen = texture(screen_texture, underwater_uv).rgb;
	
	// stitch fix for warp scanning things above water - leaves ugly edges
	if (depth_linear + VERTEX.z < 0.0) {
		screen = texture(screen_texture, SCREEN_UV).rgb;
		depth_linear = depth_linear_unwarped;
	}
	
	float color_depth_mix = smoothstep(0.0, darkest_depth, depth_linear + VERTEX.z);
	float water_edge = 1.0 - smoothstep(0.0, edge_depth, depth_linear + VERTEX.z);
	
	vec3 adjusted_shallow_color = mix(shallow_color, screen, surface_alpha);
	vec3 color_by_depth = mix(adjusted_shallow_color, deep_color, color_depth_mix);
	
	vec3 albedo = mix(color_by_depth, highlight_color, water_edge);
	ALBEDO = albedo;
	
	caustic_value = smoothstep(0.0, 1.0, (caustic_value + (caustic_value * caustic_value_b * 2.0)));
	bump = caustic_value + water_edge;
	
	EMISSION = highlight_color * (pow(dot(NORMAL, VIEW), 1.0) * caustic_value) * 0.125;
	
}

void light() {
	float surface = 1.0;//max(0.0, abs(dot(NORMAL, LIGHT)));
	float attenuation = pow(ATTENUATION, 2.5) * 5.0;
	
	vec3 caustic_highlight = mix(vec3(0.0), (LIGHT_COLOR + normalize(highlight_color) * 2.0) * smoothstep(0.0, 1.0, length(LIGHT_COLOR)), bump * surface * attenuation);
	
	DIFFUSE_LIGHT += caustic_highlight + LIGHT_COLOR * surface * attenuation * 0.125;
	
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
