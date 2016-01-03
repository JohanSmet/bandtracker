package be.justcode.bandtracker.clients;

import android.content.Context;
import android.util.Log;

import com.squareup.okhttp.Cache;
import com.squareup.okhttp.OkHttpClient;

public class OkHttpBuilder
{
    private static final String LOG_TAG = "OkHttpBuilder";

    public static OkHttpClient getClient(Context context, boolean enableCache) {
        try {
            // create client
            OkHttpClient client = new OkHttpClient();

            // cache control
            if (enableCache) {
                int cacheSize = 50 * 1024 * 1024;   // 50 MiB
                Cache cache = new Cache(context.getCacheDir(), cacheSize);
                client.setCache(cache);
            }

            return client;
        } catch (Exception e) {
            Log.w(LOG_TAG, "loadSelfSignedKeyStore", e);
            return null;
        }
    }
}
