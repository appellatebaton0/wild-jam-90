shader_type spatial;
render_mode unshaded;

uniform vec3 tint_color : source_color = vec3(1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;

uniform float warp_scale = 0.1;
uniform float warp_strength = 0.05;
uniform sampler2D warp_noise : hint_default_black;

uniform float energy_multiplier = 1.0;
uniform float base_energy = 0.1;
uniform float rim_energy = 2.0;
uniform float rim_power = 2.0;

void fragment() {
	
	float fresnel = dot(NORMAL, VIEW);
	fresnel = max(0.0, (pow(1.0 - fresnel, rim_power) * rim_energy));
	
	float warp = texture(warp_noise, warp_scale * vec2(VERTEX.x, VERTEX.y) / VIEW.z).r;
	warp *= warp_strength;
	
	vec3 albedo = texture(albedo_texture, UV + (UV * warp)).rgb;
	vec3 emission = texture(albedo_texture, UV).rgb;
	emission *= fresnel * energy_multiplier;
	
	ALBEDO = ((albedo * base_energy) + emission) * tint_color;
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
