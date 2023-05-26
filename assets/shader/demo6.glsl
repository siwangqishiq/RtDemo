precision highp float;

uniform float uViewWidth;
uniform float uViewHeight;
uniform float uTime;

out vec4 FragColor;

float rndDelta = 0.2;

float random(){
    // 二维特殊处理方式
    rndDelta += uTime / 1000.0f + 0.031415926f;
    vec2 uv = gl_FragCoord.xy;
    return fract(sin(dot(uv, vec2(12.9898 + rndDelta,78.233))) * 43758.5453123);
}

void main(){
    vec2 uv = vec2(gl_FragCoord.xy); 
    vec3 color = vec3(random() , random() , random());
    FragColor = vec4(color.rgb , 1.0);
}