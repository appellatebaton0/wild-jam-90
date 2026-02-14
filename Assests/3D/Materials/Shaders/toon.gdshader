shader_type spatial;

uniform sampler2D albedo_texture: hint_default_white, source_color;
uniform sampler2D emission_texture: hint_default_black, source_color;
uniform float emission_strength = 1.0;

float posterize(float value, float steps) {
	return floor(value * steps) / steps;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb;
	EMISSION = texture(emission_texture, UV).rgb * emission_strength;
}

void light() {
    float surface = max(0.0, dot(NORMAL, LIGHT));
	
    DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * surface * (1.0 / PI);
}