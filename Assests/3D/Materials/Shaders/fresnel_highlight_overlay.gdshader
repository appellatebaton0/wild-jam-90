shader_type spatial;
render_mode unshaded;

uniform vec3 highlight_color : source_color = vec3(1.0);
uniform float highlight_strength = 1.0;
uniform float fresnel_power = 3.0;

uniform float pulse_frequency = 0.0;
uniform float pulse_hold = 0.0;

float convert_range(float x, float from_min, float from_max, float to_min, float to_max) {
	float from_percent = abs((x - from_min) / (from_max - from_min));
	return to_min + (from_percent * (to_max - to_min));
}

void fragment() {
	float fresnel = abs(dot(NORMAL, VIEW));
	fresnel = pow(fresnel, fresnel_power);
	float highlight = 1.0 - clamp(fresnel, 0.0, 1.0);
	
	if (pulse_frequency > 0.0) {
		float pulse = sin(TIME * pulse_frequency);
		pulse = convert_range(pulse, -1.0, 1.0, -(1.0 + pulse_hold), 1.0);
		highlight *= max(0.0, pulse);
	}
	
	ALPHA = highlight;
	ALBEDO = highlight_color * highlight * highlight_strength;
}
