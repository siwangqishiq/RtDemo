precision highp float;

uniform float uViewWidth;
uniform float uViewHeight;

out vec4 FragColor;

const vec3 WHITE_COLOR = vec3(1.0 , 1.0 , 1.0);
const vec3 SKYBLUE_COLOR = vec3(0.5, 0.7, 1.0);
const vec3 RED_COLOR = vec3(1.0 , 0.0 , 0.0);

const int WORLD_MAX_OBJECT_COUNT = 10;//包含最大物体数量

struct Ray{
    vec3 origin;
    vec3 dir;
};

struct Sphere{
    vec3 center;
    float radius;
};

struct World{
    Sphere objList[WORLD_MAX_OBJECT_COUNT];
    int count;
};

struct HitResult{
    bool isHit;
    float timeValue;
};

bool worldAddSphere(inout World world , Sphere sphere){
    if(world.count + 1 > WORLD_MAX_OBJECT_COUNT){
        return false;
    }
    
    world.objList[world.count] = sphere;
    world.count = world.count + 1;
    return true;
}

// 创建场景
void buildScene(inout World world){
    world.count = 0;
    
    worldAddSphere(world , Sphere(vec3(0.0, 0.0, -1.0) , 0.4));
    worldAddSphere(world , Sphere(vec3(0.0, -100.5, -1.0) , 100.0));
}

//检测射线是否与球体相交
void raySphereHit(Ray ray ,Sphere sphere , inout HitResult result){
    vec3 oc = ray.origin - sphere.center;
    float A = dot(ray.dir , ray.dir);
    float B = 2.0 * dot(oc , ray.dir);
    float C = dot(oc , oc) - sphere.radius * sphere.radius;

    float delta = B * B - 4.0 * A * C;
    if(delta <= 0.0){
        result.isHit = false;
        return;
    }

    float t1 = (-B - sqrt(delta)) / (2.0 * A);
    float t2 = (-B + sqrt(delta)) / (2.0 * A);
    if(t1 < 0.0 && t2 < 0.0){
        result.isHit = false;
        return;
    }
    
    result.isHit = true;
    result.timeValue = t1;
}

//光线追踪着色
vec3 rayColor(inout World world, Ray ray){
    for(int i = 0 ; i < world.count ;i++){
        Sphere sphere = world.objList[i];

        HitResult hitResult = HitResult(false , -1.0);
        raySphereHit(ray , sphere , hitResult);
        
        if(hitResult.isHit){
            vec3 hitPos = ray.origin + ray.dir * hitResult.timeValue;
            vec3 N = normalize(hitPos - sphere.center);
            vec3 normalColor = (N + vec3(1.0 , 1.0 , 1.0)) * 0.5;
            return normalColor.rgb;
        }
    }//end for i

    // background
    vec3 dirNormal = normalize(ray.dir);
    float t = 0.5 * (dirNormal.y + 1.0);
    return WHITE_COLOR* (1.0 - t) + SKYBLUE_COLOR * (t);
}

void main(){
    World world;
    buildScene(world); //构造场景物体

    float aspect = uViewWidth / uViewHeight;
    const float viewPortWidth = 2.0f;
    float viewPortHeight = viewPortWidth / aspect;
    float focal = 1.0;//焦距
    
    vec3 origin = vec3(0.0 , 0.0 , 0.0); //射线起始点
    vec3 translateX = vec3(viewPortWidth , 0.0 , 0.0);
    vec3 translateY = vec3(0.0 , viewPortHeight , 0.0);
    vec3 translateZ = vec3(0.0 , 0.0 , focal);
    vec3 bottomLeftPos = origin - (translateX / 2.0f + translateY / 2.0f + translateZ);

    vec2 uv = vec2(gl_FragCoord.xy); 
    vec2 uvCoord = vec2(uv.x /(uViewWidth - 1.0)  , uv.y / (uViewHeight - 1.0));
    vec3 position = bottomLeftPos + uvCoord.x * translateX + uvCoord.y * translateY;
    
    Ray ray;
    ray.origin = origin;
    ray.dir = position - origin;

    vec3 color;
    color = rayColor(world, ray);

    FragColor = vec4(color.xyz , 1.0);
}