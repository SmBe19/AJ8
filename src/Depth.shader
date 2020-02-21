shader_type spatial;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth = depth * 2. - 1.;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	
	ALBEDO.rgb = vec3(0.);
	EMISSION.rgb = vec3(1.-1./depth);
}

	
