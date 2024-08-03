shader_type canvas_item;

uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;

uniform bool active = false;

void fragment() {
    vec4 previous_color = texture(TEXTURE, UV);
    vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
    vec4 new_color = mix(previous_color, blink_color, blink_intensity * previous_color.a);
    //if (active == true)
    //{
    //    new_color = white_color;
    //}
    COLOR = new_color;
}
