#include "application.hpp"
#include "log.hpp"

//window surface header
#include "glheader.hpp"
#include "render/render.hpp"
#include "resource/asset_manager.hpp"
#include "render/texture.hpp"
#include "render/common.hpp"
#include "widget/timer.hpp"
#include "render/render_batch.hpp"
#include "utils.hpp"
#include "game/test_demo.hpp"
#include "game/shader_demo.hpp"

void Application::onFree(){
    Logi(TAG , "app onFree");
    if(testDemo_ != nullptr){
        testDemo_->dispose();
    }

    if(shaderDemo_ != nullptr){
        shaderDemo_->dispose();
    }

    if(timer_ != nullptr){
        timer_->clear();
    }
    // triangleDemo_->free();
    if(renderEngine_ != nullptr){
        renderEngine_->free();
    }
    
    GLuint querys[1];
    querys[0] = query;
    glDeleteQueries(1, querys);
}   

void Application::init(){
    onInit();
}


void Application::update(){
    onTick();
}

void Application::free(){
    onFree();
}

void Application::onKeyAction(int keyCode , int action, int mods){
    if(shaderDemo_ != nullptr){
        shaderDemo_->onKeyAction(keyCode , action , mods);
    }
}

Application::~Application(){
    Logi(TAG , "~app Application");
}

void Application::onResize(int w , int h){
    Logi(TAG , "app onresize %d , %d" , w , h);
    screenWidth_ = w;
    screenHeight_ = h;

    viewWidth_ = w;
    viewHeight_ = h;
    
    if(renderEngine_ != nullptr){
        renderEngine_->onScreenResize();
    }

    if(testDemo_ != nullptr){
        testDemo_->init();
    }
}

std::shared_ptr<Timer> Application::getTimer(){
    if(timer_ == nullptr){
        timer_ = std::make_shared<Timer>();
    }

    return timer_;
}

void Application::onInit(){
    Logi(TAG , "app onInit");

    // renderEngine_ = std::shared_ptr<RenderEngine>(new RenderEngine(std::shared_ptr<Application>(this)));

    renderEngine_ = std::make_shared<RenderEngine>(this);
    renderEngine_->init();
    
    renderEngine_->onScreenResize();

    triangleDemo_ = std::make_shared<Triangle>();
    triangleDemo_->init();

    showNumber = true;

    // TextPaint paint;
    // renderEngine_->renderText(std::to_wstring(mIndex_++) , 0 , 0 , paint);
    
    // auto fileContent = AssetManager::getInstance()->readTextFile("test.txt");
    // Logi("asset" , "test.txt szie: %d \n content: %s" , 
    //         fileContent.size() , fileContent.c_str());

    // TextureFileConfig config;
    // AssetManager::getInstance()->readTextureFile("lan.jpg", config);
    // Logi("asset" , "image info width : %d , height %d , channel : %d , datasize : %d",
    //      config.width , config.height , config.channel , config.dataSize);
    
    // auto info1 = TextureManager::getInstance()->acquireTexture("text/font_texture_0.png");
    // auto info2 = TextureManager::getInstance()->acquireTexture("text/font_texture_1.png");

    timeStamp_ = currentTimeMicro();
    glGenQueries(1 , &query);

    onCreate();
}

void Application::onCreate(){
    getTimer()->scheduleAtFixedRate([this](Application *app){
        Logi("application" , "timer fps : %d" , frameCount_);
        showFps = frameCount_;
        frameCount_ = 0;
    } , 1000L);

    testDemo_ = std::make_shared<TestDemo>(this);
    startTime_ = static_cast<long>(currentTimeMillis());

    testDemo_->init();

    shaderDemo_ = std::make_shared<ShaderDemo>(this);
    shaderDemo_->init();
}

void Application::onTick(){
    // Log(TAG , "app trick");
    // Logi(TAG , "getLastFrameDeltaTimeMirco = %lld" , getLastFrameDeltaTime());

    #ifdef _WIN32
    glBeginQuery(GL_TIME_ELAPSED , query);
    #elif _WIN64
    glBeginQuery(GL_TIME_ELAPSED , query);
    #elif __CYGWIN__
    glBeginQuery(GL_TIME_ELAPSED , query);
    #elif __ANDROID__
    glBeginQuery(GL_TIME_ELAPSED_EXT , query);
    #elif __linux__
    glBeginQuery(GL_TIME_ELAPSED , query);
    #elif _UNIX
    glBeginQuery(GL_TIME_ELAPSED , query);
    #elif __APPLE__
    glBeginQuery(GL_TIME_ELAPSED , query);
    #endif


    

    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    long long timeStart = currentTimeMillis();
    if(renderEngine_ == nullptr){
        return;
    }

    //user logic and draw
    updateSence();
    
    //定时器triker
    if(timer_ != nullptr){
        timer_->trick(this);
    }

    //gl commands run
    renderEngine_->render();

    // for test
    // triangleDemo_->trick(renderEngine_->normalMatrix_);

    timeStamp_ = currentTimeMicro();
    long timeEnd = currentTimeMillis();
    auto deltaTime = timeEnd - timeStart;
    frameCount_++;

    // glQueryCounter(query , GL_TIME_ELAPSED);

    
    #ifdef _WIN32
    glEndQuery(GL_TIME_ELAPSED);
    #elif _WIN64
    glEndQuery(GL_TIME_ELAPSED);
    #elif __CYGWIN__
    glEndQuery(GL_TIME_ELAPSED);
    #elif __ANDROID__
    glEndQuery(GL_TIME_ELAPSED_EXT);
    #elif __linux__
    glEndQuery(GL_TIME_ELAPSED);
    #elif _UNIX
    glEndQuery(GL_TIME_ELAPSED);
    #elif __APPLE__
    glEndQuery(GL_TIME_ELAPSED);
    #endif

    GLuint gpuRenderCostTime; //GPU渲染花费时间 (单位 纳秒nano)
    glGetQueryObjectuiv(query , GL_QUERY_RESULT, &gpuRenderCostTime);
    
    // Logi(TAG , "frame cost time : %d" , gpuRenderCostTime);
}

void Application::updateSence(){
    testDemo_->tick();
    shaderDemo_->tick();

    if(showNumber){
        TextPaint p4;
        p4.textColor = showFps >=50
            ? glm::vec4(0.0f ,1.0f , 0.0f , 1.0f)
            : glm::vec4(1.0f , 0.0f , 0.0f , 1.0f);
        // p4.setTextSize(10.0f);

        std::wstring name = L"帧率:";
        renderEngine_->renderText(name + std::to_wstring(showFps) , screenWidth_ - 220.0f, 
            screenHeight_ - 80.0f, p4);
    }
}


long long Application::getLastFrameDeltaTime(){
    // if(timeStamp_ <= 0 ){
    //     return 0L;
    // }
    return currentTimeMicro() - timeStamp_;
}






