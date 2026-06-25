local shader_code_1 = [[
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);

    float av = pixel.r*255 + pixel.g*255 + pixel.b*255 + pixel.a*255;
    float value = clamp(av,0,1);

    float opacity = pixel.a;

    return vec4(value, value, value, opacity);

}

]]

local shader_code_2 = [[

uniform vec3 targetColour;
    
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);
    
    vec4 newPixel = pixel;

    if (pixel.g < 0.4)
    { 

        float luminocity = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        luminocity = luminocity;
        
        vec3 newColour = targetColour / 255;

        newPixel = vec4(clamp(newColour * luminocity * 2.5, 0.0, 1.0), pixel.a);
    
    } 
    
    return vec4(newPixel.r, newPixel.g, newPixel.b, newPixel.a);

}

]]

local shader_code_3 = [[

uniform vec3 targetColour;
    
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);
    
    vec4 newPixel = pixel;

    if (pixel.a > 0)
    { 

        float luminocity = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        luminocity = luminocity;

        vec3 newColour = targetColour / 255;

        newPixel = vec4(clamp(newColour * luminocity * 2.5, 0.0, 1.0), pixel.a);
    
    } 
    
    return vec4(newPixel.r, newPixel.g, newPixel.b, newPixel.a);

}

]]

local shader_code_4 = [[

uniform vec2 gameSize;
uniform vec2 windowSize;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);
    float ppp =  windowSize.y / gameSize.y;

    if (mod(screen_coords.y, ppp)  >  (ppp * 0.5))
    { 
    return pixel * color;
    }

    return vec4(pixel.r, pixel.g, pixel.b, pixel.a - 0.5);

}

]]




flashShader = love.graphics.newShader(shader_code_1)
tintPlayerShader = love.graphics.newShader(shader_code_2)
tintShader = love.graphics.newShader(shader_code_3)
crtShader = love.graphics.newShader(shader_code_4)