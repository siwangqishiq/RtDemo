#pragma once

#include "application.hpp"

class RenderEngine;

class ShaderDemo{
public:
    ShaderDemo(Application *app){
        appContext = app;
    }

    void init();

    void tick();

    void dispose();

    void onKeyAction(int keyCode , int action, int mods);

    bool isInited = false;
private:
    Application *appContext;

    int viewWidth_;
    int viewHeight_;
    int maxRayRelectTimes_ = 2;

    std::shared_ptr<RenderEngine> renderEngine_;

    float delta = 0.0f;
    
    Shader customRenderShader;
    void testRenderShader();
};