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

float rnd(float min , float max){
    return min + (max - min) * random();
}

void main(){
    // vec2 uv = vec2(gl_FragCoord.xy); 
    // vec3 color = vec3(random() , random() , random());
    // FragColor = vec4(color.rgb , 1.0);

    // vec3 color = vec3(0.0 , 1.0 , 0.0);
    // for(int i = 0 ; i < 10000 ;i++){
    //     float value = rnd(100.0 , 110.0f);
    //     if(value < 100.0 || value > 110.0){
    //         color = vec3(1.0 , 0.0 , 0.0);
    //     }
    // }//end for i

    
    float value = rnd(0.0 , 0.9f);
    vec3 color = vec3(value , 0.0 , 0.0);
    
    FragColor = vec4(color.rgb , 1.0);
}