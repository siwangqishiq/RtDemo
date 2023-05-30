precision highp float;

uniform float uViewWidth;
uniform float uViewHeight;
uniform float uTime;

out vec4 FragColor;

const vec3 WHITE_COLOR = vec3(1.0 , 1.0 , 1.0);
const vec3 SKYBLUE_COLOR = vec3(0.5, 0.7, 1.0);
const vec3 RED_COLOR = vec3(1.0 , 0.0 , 0.0);
const vec3 BLACK_COLOR = vec3(0.0, 0.0 ,0.0);

const int WORLD_MAX_OBJECT_COUNT = 10;//包含最大物体数量

const int SAMPLE_TIMES = 100; //像素点采样次数

const int MAX_DEPTH_SIZE = 50;//光线的最大弹射次数

float rndDelta = 0.2;

float random(){
    // 二维特殊处理方式
    float seed = 10.0f;
    // seed = uTime;
    rndDelta += seed / 1000.0f + 0.031415926f;
    vec2 uv = gl_FragCoord.xy;
    return fract(sin(dot(uv, vec2(12.9898 + rndDelta,78.233))) * 43758.5453123);
}

float rnd(float min , float max){
    return min + (max - min) * random();
}

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

struct Camera{
    vec3 origin;
    float viewWidth;
    float viewHeight;
    float focal;
    vec3 bottomLeftPos;
};

struct HitResult{
    bool isHit;
    float timeValue;
    bool frontFace;
    vec3 normal;
};

void initCamera(inout Camera camera){
    camera.origin = vec3(0.0 , 0.0 , 0.0); //射线起始点
    camera.viewWidth = 2.0f;
    camera.focal = 1.0f;

    float aspect = uViewWidth / uViewHeight;
    camera.viewHeight = camera.viewWidth / aspect;

    vec3 translateX = vec3(camera.viewWidth , 0.0 , 0.0);
    vec3 translateY = vec3(0.0 , camera.viewHeight , 0.0);
    vec3 translateZ = vec3(0.0 , 0.0 , camera.focal);
    camera.bottomLeftPos = camera.origin - 
        (translateX / 2.0f + translateY / 2.0f + translateZ);
}

Ray getRayFromCamera(inout Camera camera , vec2 offset){
    vec2 uv = vec2(gl_FragCoord.xy); 
    vec2 uvCoord = vec2((uv.x) / (uViewWidth - 1.0)  
                    , (uv.y) / (uViewHeight - 1.0));

    vec3 translateX = vec3(camera.viewWidth , 0.0 , 0.0);
    vec3 translateY = vec3(0.0 , camera.viewHeight , 0.0);
    vec3 position = camera.bottomLeftPos + 
            (uvCoord.x + offset.x) * translateX + (uvCoord.y + offset.y) * translateY;

    Ray ray;
    ray.origin = camera.origin;
    ray.dir = normalize(position - camera.origin);
    return ray;
}

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
    result.timeValue = t1 < t2?t1:t2;
    
    //计算碰撞点的法向量
    vec3 hitPos = ray.origin + ray.dir * result.timeValue;
    vec3 outNormal = normalize(hitPos - sphere.center);
    if(dot(ray.dir , outNormal) > 0.0){
        result.frontFace = false;
        result.normal = -outNormal;
    }else{
        result.frontFace = true;
        result.normal = outNormal;
    }
}

//光线追踪着色
vec3 rayColor(inout World world, Ray ray , int depth){
    if(depth <= 0){
        return BLACK_COLOR;
    }

    for(int i = 0 ; i < world.count ;i++){
        Sphere sphere = world.objList[i];

        HitResult hitResult = HitResult(false , -1.0 , false , vec3(0.0 , 0.0 , 0.0));
        raySphereHit(ray , sphere , hitResult);
        if(hitResult.isHit){
            vec3 N = hitResult.normal;
            vec3 normalColor = (N + vec3(1.0 , 1.0 , 1.0)) * 0.5;
            return normalColor;
        }
    }//end for i

    // background
    vec3 dirNormal = (ray.dir);
    float t = 0.5 * (dirNormal.y + 1.0);
    return WHITE_COLOR* (1.0 - t) + SKYBLUE_COLOR * (t);
}

// vec3 rayColorIter(inout World world, RayList rayList){
//     return BLACK_COLOR;
// }

void main(){
    World world;
    buildScene(world); //构造场景物体

    Camera camera;  //创建摄像机
    initCamera(camera);

    vec3 resultColor;
    float scale = 1.0 / float(SAMPLE_TIMES);

    float offsetHor = 1.0f / (2.0 * uViewWidth);
    float offsetVer = 1.0f / (2.0 * uViewHeight);

    for(int i = 0 ; i < SAMPLE_TIMES ;i++){
        vec2 offset = vec2(rnd(-offsetHor , offsetHor) , rnd(-offsetVer , offsetVer));
        Ray ray = getRayFromCamera(camera , offset); //从摄像机生成与当前像素对应的射线

        vec3 color = rayColor(world, ray , MAX_DEPTH_SIZE);
        resultColor = resultColor + scale * color; 
    }//end for i
    FragColor = vec4(clamp(resultColor.r , 0.0 , 1.0) ,
                     clamp(resultColor.g , 0.0 , 1.0) ,
                     clamp(resultColor.b , 0.0 , 1.0) ,  
                     1.0);
}
