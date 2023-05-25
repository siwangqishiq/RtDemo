precision highp float;

uniform float uViewWidth;
uniform float uViewHeight;

out vec4 FragColor;

const vec3 WHITE_COLOR = vec3(1.0 , 1.0 , 1.0);
const vec3 SKYBLUE_COLOR = vec3(0.5, 0.7, 1.0);
const vec3 RED_COLOR = vec3(1.0 , 0.0 , 0.0);

struct Ray{
    vec3 origin;
    vec3 dir;
};

struct Sphere{
    vec3 center;
    float radius;
};

//检测射线是否与球体相交
bool checkRaySphereHit(inout Ray ray ,inout Sphere sphere){
    float A = 1.0f;
    float B = 2 * dot(ray.origin , ray.dir) + 2 * dot(sphere.center , ray.dir);
    float C = dot(sphere.center, sphere.center) + dot(ray.origin , ray.origin) - 
        sphere.radius * sphere.radius - 2 * dot(ray.origin , sphere.center);
    
    float delta = B * B - 4 * A * C;
    return delta > 0;
}

//光线追踪着色
vec3 rayColor(Ray ray){
    Sphere sphere = Sphere(vec3(0.0, 0.0 ,2.0) , 0.5);
    if(checkRaySphereHit(ray , sphere)){
        return RED_COLOR;
    }

    // background
    float t = 0.5 * (ray.dir.y + 1.0);
    return WHITE_COLOR* (1.0 - t) + SKYBLUE_COLOR * (t);
}


void main(){
    float aspect = uViewWidth / uViewHeight;
    const float viewPortWidth = 2.0f;
    float viewPortHeight = viewPortWidth / aspect;
    float focal = 1.0;//焦距

    const vec3 origin = vec3(0.0 , 0.0 , 0.0); //射线起始点

    vec3 translateX = vec3(viewPortWidth , 0.0 , 0.0);
    vec3 translateY = vec3(0.0 , viewPortHeight , 0.0);
    vec3 translateZ = vec3(0.0 , 0.0 , focal);
    
    vec3 bottomLeftPos = origin - translateX / 2.0f - translateY / 2.0f - translateZ;

    vec2 uvCoord = vec2(gl_FragCoord.x / uViewWidth , (gl_FragCoord.y / uViewHeight)); 
    vec3 position = bottomLeftPos + uvCoord.x * translateX + uvCoord.y * translateY - origin;

    Ray ray;
    ray.origin = origin;
    ray.dir = normalize(position - origin);
    
    vec3 color;
    color = rayColor(ray);

    FragColor = vec4(color.xyz ,1.0);
}