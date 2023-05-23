precision highp float;

uniform float uViewWidth;
uniform float uViewHeight;

out vec4 FragColor;

void main(){
    vec2 pos = gl_FragCoord.xy;
    float r = pos.x / uViewWidth;
    float g = pos.y / uViewHeight;
    float b = 0.25; 
    FragColor = vec4(r, g , b ,1.0);
}