shader_type canvas_item;
uniform vec4 shadow : source_color;
uniform vec4 base : source_color;
uniform vec4 highlight : source_color;
// This shader remaps a texture with pixel of 0.0, 0.5, 1.0 to other colors

varying vec4 vertex_color;
void vertex() {
	// Called for every vertex the material is visible on.

	// get the modulate color
	vertex_color = COLOR;
}

void fragment() {
	vec4 out_color = highlight;
	float tex_color = texture(TEXTURE, UV).r;
	if (tex_color==1.0){
		out_color = highlight;
	}
	else{
		out_color = base;
	}
	if (tex_color == 0.0){
		out_color = shadow;
	}

	out_color.a = texture(TEXTURE, UV).a;
	COLOR = out_color;

	// Use the modulate alpha ontop of the clouds
	COLOR.a = COLOR.a * vertex_color.a;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
