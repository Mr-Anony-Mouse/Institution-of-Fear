shader_type canvas_item;

uniform bool outline_enabled = true;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.0;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);

    vec2 pixel = TEXTURE_PIXEL_SIZE * outline_size;

    float outline_alpha = 0.0;

    // Only compute outline if enabled AND current pixel is transparent
    if (outline_enabled && base_color.a == 0.0) {
        outline_alpha += texture(TEXTURE, UV + vec2(pixel.x, 0.0)).a;
        outline_alpha += texture(TEXTURE, UV + vec2(-pixel.x, 0.0)).a;
        outline_alpha += texture(TEXTURE, UV + vec2(0.0, pixel.y)).a;
        outline_alpha += texture(TEXTURE, UV + vec2(0.0, -pixel.y)).a;
    }

    // If outline should be drawn
    if (outline_alpha > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = base_color;
    }
}
