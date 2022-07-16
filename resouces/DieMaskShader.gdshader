shader_type canvas_item;

const vec4 PALETTE_COLORS[] = {
	vec4(1.0, 0.0, 0.0, 1.0),
	vec4(1.0, 85.0/255.0, 0.0, 1.0),
	vec4(1.0, 170.0/255.0, 0.0, 1.0),
	vec4(170.0/255.0, 1.0, 0.0, 1.0),
	vec4(85.0/255.0, 1.0, 0.0, 1.0),
	vec4(0.0, 1.0, 1.0, 1.0)
};

uniform sampler2D palette;

void fragment() {
	vec4 sample = texture(TEXTURE, UV);
	for (int i = 0; i < PALETTE_COLORS.length(); i++) {
		if (sample == PALETTE_COLORS[i]) {
			sample = texture(palette, vec2(float(i) / float(PALETTE_COLORS.length()), 0.0));
			break;
		}
	}
	COLOR = sample;
}
