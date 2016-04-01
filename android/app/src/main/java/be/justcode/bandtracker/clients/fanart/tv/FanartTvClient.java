package be.justcode.bandtracker.clients.fanart.tv;

import android.util.Log;

import com.google.gson.GsonBuilder;

import java.util.List;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.OkHttpBuilder;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.OkClient;
import retrofit.converter.GsonConverter;
import retrofit.http.GET;
import retrofit.http.Path;
import retrofit.http.Query;

public class FanartTvClient {

    private static final String LOG_TAG = "FanartTvClient";

    public static final String HEADER_CACHE_CONTROL         = "Cache-Control";
    public static final String CACHE_CONTROL_SERVER         = "max-age=0";
    public static final String CACHE_CONTROL_PREFER_CACHE   = "max-age=315360000";
    public static final String CACHE_CONTROL_ONLY_CACHE     = "only-if-cached";

    private FanartTvClient() {
        if (restClient == null) {

            String serverHost    = App.getContext().getString(R.string.fanarttv_host);
            String serverBaseUrl = App.getContext().getString(R.string.fanarttv_proto) + "://" + serverHost + ":" + App.getContext().getString(R.string.fanarttv_port);
            fanartApiKey         = App.getContext().getString(R.string.fanarttv_key);

            gsonConverter = new GsonConverter(new GsonBuilder()
                    .setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
                    .create()
            );

            restClient = new RestAdapter.Builder()
                    .setEndpoint(serverBaseUrl)
                    .setConverter(gsonConverter)
                    .setClient(new OkClient(OkHttpBuilder.getClient(App.getContext(), true)))
                    // .setLogLevel(RestAdapter.LogLevel.FULL)
                    .build()
                    .create(IFanartTv.class)
            ;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // REST-interface
    //

    private interface IFanartTv {
        @GET("/v3/music/{bandId}")
        public FanartTvArtist getArtist(@Path("bandId") String bandId, @Query("api_key") String api_key, @retrofit.http.Header(HEADER_CACHE_CONTROL) String cacheControlValue);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //

    public FanartTvBandUrls getBandUrls(String bandId) {

        try {
            FanartTvArtist response = restClient.getArtist(bandId, fanartApiKey, CACHE_CONTROL_PREFER_CACHE );

            if (response == null)
                return null;

            FanartTvBandUrls urls = new FanartTvBandUrls();

            if (response.artistthumb != null && !response.artistthumb.isEmpty()) {
                urls.bandThumbnailUrl = response.artistthumb.get(0).url;
            }

            if (response.hdmusiclogo != null && !response.hdmusiclogo.isEmpty()) {
                urls.bandLogoUrl = response.hdmusiclogo.get(0).url;
            }

            return urls;

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "bandImage", e);
            return null;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // internal types
    //

    private class FanartTvUrl {
        String id;
        String url;
        String likes;
    }

    private class FanartTvArtist {
        String name;
        String mbid_id;
        List<FanartTvUrl> artistbackground;
        List<FanartTvUrl> artistthumb;
        List<FanartTvUrl> musiclogo;
        List<FanartTvUrl> hdmusiclogo;
        List<FanartTvUrl> musicbanner;
    }

    public class FanartTvBandUrls {
        public String bandThumbnailUrl;
        public String bandLogoUrl;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private IFanartTv     restClient;
    private String        fanartApiKey;
    private GsonConverter gsonConverter;

    private static FanartTvClient instance;

    public static FanartTvClient getInstance() {
        if (instance == null)
            instance = new FanartTvClient();

        return instance;
    }
}
