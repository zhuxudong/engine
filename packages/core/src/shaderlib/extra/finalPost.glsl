#include <common>

varying vec2 v_uv;
uniform sampler2D renderer_BlitTexture;

void main(){

	mediump vec4 color = texture2D(renderer_BlitTexture, v_uv);

    // We have convert the color to sRGB space in sRGB pass
    // So we need to convert it back to linear space when output to render target.
	#ifndef ENGINE_OUTPUT_SRGB_CORRECT
	 	color = sRGBToLinear(color);
    #endif

    gl_FragColor = color;
}