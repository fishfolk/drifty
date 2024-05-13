shader_type spatial;

uniform float scale = 0.03f;
uniform sampler2D color_ramp;
varying vec3 world_position;


//https://godotshaders.com/snippet/voronoi/
vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}
float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

//https://www.youtube.com/watch?v=mnpNePu0bv0
void vertex() {
	//world_position = (VERTEX).xyz;
	world_position = NODE_POSITION_WORLD + VERTEX;
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec4 texture_color = texture(texture(), UV);
	// Called for every pixel the material is visible on.
	float worley1 = worley(world_position.xz * scale * TIME * 0.25f, 3.0f, 3.0f);
	float color1 = texture(color_ramp, vec2(worley1)).r;
	float worley2 = worley(world_position.xz * scale * TIME * 0.5f, 1.0f, 1.0f);
	float color2 = texture(color_ramp, vec2(worley2)).r;
	float color = (color2 + color1) /2.0;
	//filter
	color = min(0.999, color);
	color = log(0.999) / log(color);
	color *= 300.0f;
	
	color = min(color, 1.0);
	
	//EMISSION = vec3(color);
	ALPHA = color * 0.8;
	ALBEDO = vec3(color);
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
