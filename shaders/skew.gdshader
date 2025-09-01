shader_type canvas_item;

uniform vec2 top_position;

void vertex(){
	if( UV.x >= 0.0 && UV.y <= 0.0) {
		VERTEX += top_position;
	}
}