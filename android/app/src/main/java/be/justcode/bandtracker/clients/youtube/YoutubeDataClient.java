package be.justcode.bandtracker.clients.youtube;

import android.util.Log;

import com.google.gson.GsonBuilder;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.Headers;
import be.justcode.bandtracker.clients.OkHttpBuilder;
import be.justcode.bandtracker.model.Gig;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.OkClient;
import retrofit.converter.GsonConverter;
import retrofit.http.GET;
import retrofit.http.QueryMap;

public class YoutubeDataClient {

    private static final String LOG_TAG = "YoutubeClient";

    private YoutubeDataClient() {
        if (restClient == null) {

            String serverHost    = App.getContext().getString(R.string.youtube_host);
            String serverBaseUrl = App.getContext().getString(R.string.youtube_proto) + "://" + serverHost + ":" + App.getContext().getString(R.string.youtube_port) + App.getContext().getString(R.string.youtube_baseurl);
            youtubeApiKey        = App.getContext().getString(R.string.youtube_data_key);

            GsonConverter gsonConverter = new GsonConverter(new GsonBuilder()
                    .create()
            );

            restClient = new RestAdapter.Builder()
                    .setEndpoint(serverBaseUrl)
                    .setConverter(gsonConverter)
                    //.setClient(new OkClient(OkHttpBuilder.getClient(App.getContext(), true)))
                    .setClient(new OkClient(OkHttpBuilder.getUnsafeClient(App.getContext(), true)))
                    // .setLogLevel(RestAdapter.LogLevel.FULL)
                    .build()
                    .create(IYoutube.class)
            ;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // REST-interface
    //

    private interface IYoutube {
        @GET("/search")
        public YoutubeResponse search(@QueryMap Map<String, String> parameters, @retrofit.http.Header(Headers.HEADER_CACHE_CONTROL) String cacheControlValue);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //

    public List<Video> searchVideosForGig(Gig gig, String song, int maxResults) {

        // build search query
        StringBuilder query = new StringBuilder();
        query.append(gig.getBand().getName());
        query.append(" ").append(youtubeDateFormat.format(gig.getStartDate()));

        if (gig.getCity() != null) {
            query.append(" ").append(gig.getCity().getName());
        }

        if (song != null && !song.isEmpty()) {
            query.append(" ").append(song);
        }

        // build query parameter list
        Map<String, String> params = new HashMap<>();
        params.put("key",             youtubeApiKey);
        params.put("videoEmbeddable", "true");
        params.put("type",            "video");
        params.put("order",           "relevance");
        params.put("part",            "snippet");
        params.put("fields",          "items(id/videoId,snippet/title)");
        params.put("maxResults",      Integer.toString(maxResults));

        params.put("q", query.toString());

        try {
            YoutubeResponse response = restClient.search(params, Headers.CACHE_CONTROL_PREFER_CACHE);

            if (response == null)
                return null;

            List<Video> videos = new ArrayList<>();

            for (YoutubeResource item : response.items) {
                Video video = new Video();
                video.id    = item.id.videoId;
                video.title = item.snippet.title;
                videos.add(video);
            }

            return videos;

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "searchVideosForGig", e);
            return null;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested types
    //

    public class Video {
        public String getId() {
            return id;
        }

        public String getTitle() {
            return title;
        }

        String  id;
        String  title;
    }

    private class YoutubeResponse {
        List<YoutubeResource> items;
    }

    private class YoutubeResource {
        YoutubeId       id;
        YoutubeSnippet  snippet;
    }

    private class YoutubeId {
        String  videoId;
    }

    private class YoutubeSnippet {
        String  title;
        String  description;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private IYoutube restClient;
    private String   youtubeApiKey;
    private DateFormat youtubeDateFormat = new SimpleDateFormat("yyyy MMMM dd");

    private static YoutubeDataClient instance;

    public static YoutubeDataClient getInstance() {
        if (instance == null)
            instance = new YoutubeDataClient();

        return instance;
    }

}
