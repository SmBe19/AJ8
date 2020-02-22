shader_type spatial;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 pos = INV_PROJECTION_MATRIX * vec4(2.*SCREEN_UV-1., texture(DEPTH_TEXTURE,SCREEN_UV).r*2.-1., 1.0);
	pos.z = 1.0;
	pos.xyz /= pos.w;
	
	ALBEDO.rgb = vec3(0.);
	//float dist = pos.z;
	float dist = length(pos);
	EMISSION.rgb = vec3(1.-1./(1.+dist));
	//EMISSION.rgb = 1.-col.rgb;
}

	
