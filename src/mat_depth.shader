shader_type spatial;

varying vec4 v_pos;
uniform vec4 u_col : hint_color = vec4(0., 0., 0., 1.);
uniform float u_far = 100.;
uniform float u_dist_correction = 0.05;

void vertex() {
	v_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyzw;
}

void fragment() {
	vec3 pos = v_pos.xyz;//v_pos.xyz / v_pos.w;
	pos.z = -pos.z;
	ALBEDO.rgb = vec3(0.);
	float closeness = 1./(1.+length(pos)*u_dist_correction);
	float correction = 1./(1.+u_far*u_dist_correction);
	closeness = (closeness-correction) / (1.-correction);
	EMISSION.rgb = mix(vec3(1.), u_col.rgb, closeness);
}