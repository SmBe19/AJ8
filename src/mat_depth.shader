shader_type spatial;

varying vec4 v_pos;
uniform vec4 u_col : hint_color = vec4(0., 0., 0., 1.);
uniform float u_far = 5.;

void vertex() {
	v_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyzw;
}

void fragment() {
	vec3 pos = v_pos.xyz;//v_pos.xyz / v_pos.w;
	pos.z = -pos.z;
	ALBEDO.rgb = vec3(0.);
	float closeness = 1./(1.+length(pos));
	float correction = 1./(1.+u_far);
	closeness = (closeness-correction) / (1.-correction);
	EMISSION.rgb = mix(vec3(1.), u_col.rgb, closeness);
}