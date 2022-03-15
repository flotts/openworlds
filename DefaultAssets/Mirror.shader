shader_type spatial;
render_mode unshaded;

uniform sampler2D mirror_texture;
uniform bool is_arvr;

void fragment(){
	vec2 tex_uv = SCREEN_UV;

	tex_uv.x = -tex_uv.x + 1.0;
	ALBEDO = texture(mirror_texture, tex_uv).xyz;
}