shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int quality;
uniform float level;
uniform float dark;
uniform float scale;

void fragment() {
    vec4 output = texture(SCREEN_TEXTURE,vec2(0.5,0.5) * abs(scale - 1.0) + SCREEN_UV * scale);
    for (int i=0;i < quality;i++) {
        vec4 output2 = texture(SCREEN_TEXTURE,vec2(sin(float(i) * float(360 / quality)) * (level / 100.0),cos(float(i) * float(360 / quality)) * (level / 100.0)) + vec2(0.5,0.5) * abs(scale - 1.0) + SCREEN_UV * scale);
        output2.a = 1.0 / float(quality);
        output += output2;
    }
    vec4 output1 = texture(TEXTURE,UV);
    COLOR = vec4(output1.r + (output.r * dark),output1.g + (output.g * dark),output1.b + (output.b * dark),output1.a);
}