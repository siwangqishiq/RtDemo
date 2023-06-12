#include "shader_demo.hpp"
#include "utils.hpp"
#include "render/common.hpp"
#include "render/render.hpp"
#include "render/render_batch.hpp"
#include "render/sprite.hpp"

void ShaderDemo::init(){
    viewWidth_ = appContext->viewWidth_;
    viewHeight_ = appContext->viewHeight_;
    renderEngine_ = appContext->getRender();
    
    if(isInited){
        return;
    }
    isInited = true;

    customRenderShader = ShaderManager::getInstance()->loadAssetShader(
        "shader_demo","shader/shader_vert.glsl","shader/demo17.glsl");
}

void ShaderDemo::tick(){
    testRenderShader();
}

void ShaderDemo::dispose(){
    
}

void ShaderDemo::onKeyAction(int keyCode , int action, int mods){
    Logi("shaderDemo" , "onkey action code :%d , action : %d , mods:%d",keyCode , action, mods);
    if(keyCode >= 49 && keyCode < 58 && action == 1){
        maxRayRelectTimes_ = keyCode - 49;
    }
}


void ShaderDemo::testRenderShader(){
    Rect viewRect;
    viewRect.left = 0.0f;
    viewRect.top = viewHeight_;
    viewRect.width = viewWidth_;
    viewRect.height = viewHeight_;

    // Paint paint;
    // renderEngine_->getShapeBatch()->begin();
    // renderEngine_->getShapeBatch()->renderRect(viewRect , paint);
    // renderEngine_->getShapeBatch()->end();

    // Logi("ShaderDemo" , "testRenderShader");
    renderEngine_->renderShader(customRenderShader , viewRect, [this](){
        customRenderShader.setUniformInt("uRayMaxReflectTimes", maxRayRelectTimes_);
        customRenderShader.setUniformFloat("uViewWidth",viewWidth_);
        customRenderShader.setUniformFloat("uViewHeight",viewHeight_);
        customRenderShader.setUniformFloat("uTime" , static_cast<float>(appContext->frameCount_));
        
        customRenderShader.setUniformFloat("uFuzz" , 
            static_cast<float>(0.5f * glm::sin(delta) + 0.5f));

        customRenderShader.setUniformFloat("uDeltaY" , 0.3f * glm::sin(delta));
    });

    delta += 0.05f;
}
