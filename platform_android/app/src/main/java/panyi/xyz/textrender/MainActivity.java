package panyi.xyz.textrender;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.Gravity;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import java.util.Timer;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class MainActivity extends AppCompatActivity {
    private MainView mMainView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        NativeBridge.setAndroidAssetManager(getAssets());
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);

        FrameLayout containerView = findViewById(R.id.root_view);
        mMainView = new MainView(this);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(NativeBridge.getViewWidth() , NativeBridge.getViewHeight());
        params.gravity = Gravity.CENTER;
        containerView.addView(mMainView , params);
    }

    @Override
    protected void onDestroy() {
        if(mMainView != null){
            mMainView.postRunnableRenderThread(()->{
                NativeBridge.free();
            });
        }
        super.onDestroy();
    }

    private class MainView extends GLSurfaceView implements GLSurfaceView.Renderer {
        public MainView(Context context) {
            super(context);
            initView(context);
        }

        private void initView(Context context){
            setEGLContextClientVersion(3);
            setEGLConfigChooser(8, 8, 8, 8, 16, 8);
            setRenderer(this);
            setRenderMode(RENDERMODE_CONTINUOUSLY);
        }

        @Override
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            NativeBridge.init();
        }

        @Override
        public void onSurfaceChanged(GL10 gl, int width, int height) {
            NativeBridge.resize(width , height);
        }

        public void postRunnableRenderThread(Runnable runnable){
            queueEvent(runnable);
        }

        @Override
        public void onDrawFrame(GL10 gl) {
            NativeBridge.trick();
        }
    }//end inner class
}//end class