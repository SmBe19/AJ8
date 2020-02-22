shader_type spatial;

render_mode cull_disabled;


varying vec4 v_pos;
uniform vec4 u_col : hint_color = vec4(0., 0., 0., 1.);
uniform float u_far = 10.;
uniform float u_dist_correction = 1.;
uniform sampler2D u_cutout;

void vertex() {
	v_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyzw;
}

void fragment() {
	vec3 pos = v_pos.xyz;//v_pos.xyz / v_pos.w;
	pos.z = -pos.z;
	ALBEDO.rgb = vec3(0.);
	float dist = clamp(length(pos), 0., u_far);
	float closeness = 1./(1.+dist*u_dist_correction);
	float far_closeness = 1./(1.+u_far*u_dist_correction);
	closeness = (closeness - far_closeness)/(1.-far_closeness);
	EMISSION.rgb = mix(vec3(1.), u_col.rgb, closeness);
	float alpha = texture(u_cutout, UV).a;
	ALPHA = alpha;
	ALPHA_SCISSOR = 0.5;

}
