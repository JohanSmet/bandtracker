package be.justcode.bandtracker.clients;

import android.content.Context;
import android.util.Log;

import com.squareup.okhttp.Cache;
import com.squareup.okhttp.OkHttpClient;

import java.security.cert.CertificateException;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

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
            Log.w(LOG_TAG, "getClient", e);
            return null;
        }
    }

    public static OkHttpClient getUnsafeClient(Context context, boolean enableCache)
    {
        try {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[] {
                    new X509TrustManager() {
                        @Override
                        public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException
                        {
                        }

                        @Override
                        public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                        }

                        @Override
                        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                            return null;
                        }
                    }
            };

            // Install the all-trusting trust manager
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

            // Create an ssl socket factory with our all-trusting manager
            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient okHttpClient = new OkHttpClient();
            okHttpClient.setSslSocketFactory(sslSocketFactory);
            okHttpClient.setHostnameVerifier(new HostnameVerifier()
            {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            });

            // cache control
            if (enableCache) {
                int cacheSize = 50 * 1024 * 1024;   // 50 MiB
                Cache cache = new Cache(context.getCacheDir(), cacheSize);
                okHttpClient.setCache(cache);
            }


            return okHttpClient;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
