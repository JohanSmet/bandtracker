package be.justcode.bandtracker;

import android.app.Application;
import android.content.Context;

public class App extends Application {

    public static Application getApplication() {
        return mApplication;
    }

    public static Context getContext() {
        return getApplication().getApplicationContext();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mApplication = this;
    }

    private static Application mApplication;
}
