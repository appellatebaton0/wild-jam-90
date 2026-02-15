shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float alpha_scissor_threshold = 0.5;

uniform float banding_steps = 2.0;

float posterize(float value, float steps) {
	return floor(value * steps) / steps;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * tint_color;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	ALPHA = albedo.a;
}

void light() {
	float surface = step(0, abs(dot(NORMAL, LIGHT)));
	//surface = posterize(surface, banding_steps);
	
	float attenuation = ATTENUATION;//posterize(ATTENUATION, banding_steps);
	DIFFUSE_LIGHT += LIGHT_COLOR * attenuation * surface * (1.0 / PI);
}