shader_type spatial;

uniform sampler2D noise_texture;
uniform sampler2D color;
uniform float smoothness: hint_range(0.0,1.0,0.01) = 0.05;
uniform float fresnel_amount: hint_range(0.0,1.0,0.01) = 0.05;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float height = texture(noise_texture, VERTEX.xz * smoothness + vec2(TIME * 0.3) + world_position.xy*0.1).r;
	VERTEX += NORMAL * height * 0.3;
}

float fresnel(vec3 normal, mat4 camera_matrix) {
	vec3 view_direction_world = (camera_matrix*vec4(0.0,0.0,1.0,0.0)).xyz;
	vec3 normal_world = (camera_matrix*vec4(normal, 0.0)).xyz;
	
	float fresnel = dot(view_direction_world, normal_world);
	fresnel = clamp(abs(fresnel), 0.0, 1.0);
	return 1.0 - fresnel;
}

float fresnel2(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	//float fresnel = fresnel(NORMAL, VIEW_MATRIX);
	float fresnelTint = (fresnel2(fresnel_amount, NORMAL, VIEW));
	ALBEDO = texture(color, world_position.xy + vec2(TIME*0.2)).rgb;
	ROUGHNESS = 0.0;
	ALPHA = fresnelTint;
	//ALPHA = fresnel;
}



