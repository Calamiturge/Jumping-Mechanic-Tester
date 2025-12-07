shader_type canvas_item;

uniform float world_y;       // world Y of this tilemap's top-left or origin
uniform float world_height;  // total height of the map
uniform vec3 top_color : source_color;
uniform vec3 bottom_color : source_color;

void fragment() {
    float t = clamp((world_y + UV.y * world_height) / world_height, 0.0, 1.0);
    vec3 shade = mix(top_color, bottom_color, t);
    COLOR = texture(TEXTURE, UV) * vec4(shade, 1.0);
}
