package be.justcode.bandtracker.clients.setlist.fm;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.annotations.SerializedName;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.Headers;
import be.justcode.bandtracker.clients.OkHttpBuilder;
import be.justcode.bandtracker.model.Gig;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.RequestInterceptor;
import retrofit.converter.GsonConverter;
import retrofit.http.GET;
import retrofit.http.Query;

public class SetlistFmClient {

    private static final String LOG_TAG = "SetlistFmClient";

    private SetlistFmClient() {
        if (restClient == null) {

            String serverHost    = App.getContext().getString(R.string.setlistfm_host);
            String serverBaseUrl = App.getContext().getString(R.string.setlistfm_proto) + "://" + serverHost + ":" + App.getContext().getString(R.string.setlistfm_port);
            final String apiKey = App.getContext().getString(R.string.setlistfm_key);

            Gson gson = new GsonBuilder().create();

            restClient = new RestAdapter.Builder()
                    .setEndpoint(serverBaseUrl)
                    .setConverter(new GsonConverter(gson))
                    .setClient(OkHttpBuilder.getClient(App.getContext(), true))
                    .setRequestInterceptor(new RequestInterceptor() {
                        @Override
                        public void intercept(RequestFacade request) {
                            request.addHeader("x-api-key", apiKey);
                            request.addHeader("Accept-Language", "en");
                            request.addHeader("Accept", "application/json");
                        }

                    })
                    //.setLogLevel(RestAdapter.LogLevel.FULL)
                    .build()
                    .create(ISetlistFm.class)
            ;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // REST-interface
    //

    private interface ISetlistFm {
        @GET("/rest/1.0/search/setlists")
        public SetlistFmResponse getSetList(@Query("artistMbid") String artistMbid, @Query("date") String date, @retrofit.http.Header(Headers.HEADER_CACHE_CONTROL) String cacheControlValue);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //

    public Setlist searchSetlist(Gig gig) {

        try {
            SetlistFmResponse response = restClient.getSetList(gig.getBand().getMBID(), setlistFmDate.format(gig.getStartDate()), Headers.CACHE_CONTROL_PREFER_CACHE);

            if (response == null)
                return null;

            SetlistFmSetlist remoteSetlist = response.setlist.get(0);

            if (remoteSetlist == null)
                return null;

            Setlist setlist = new Setlist();
            setlist.url = remoteSetlist.sets.url;

            for (SetlistFmSet remoteSet : remoteSetlist.sets.set) {
                SetlistPart part = new SetlistPart();

                if (remoteSet.name != null) {
                    part.name = remoteSet.name;
                } else if (remoteSet.encore == 1) {
                    part.name = "Encore";
                } else {
                    part.name = "";
                }

                for (SetlistFmSong song : remoteSet.songs) {
                    part.songs.add(song.name);
                }

                setlist.setlistParts.add(part);
            }

            return setlist;

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "searchSetlist", e);
            return null;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // internal types
    //

    public class Setlist {
        public String getUrl() {
            return url;
        }

        public List<SetlistPart> getSetlistParts() {
            return setlistParts;
        }

        String              url;
        List<SetlistPart>   setlistParts = new ArrayList<>();
    }

    public class SetlistPart {
        public String getName() {
            return name;
        }

        public List<String> getSongs() {
            return songs;
        }

        String          name;
        List<String>    songs = new ArrayList<>();
    }

    // Setlist.fm serialization
    private class SetlistFmResponse {
        String                  type;
        int                     itemsPerPage;
        int                     page;
        int                     total;
        List<SetlistFmSetlist>  setlist;
    }

    private class SetlistFmSetlist {
        String                  id;
        String                  versionId;
        SetlistFmSets           sets;
    }

    private class SetlistFmSets {
        List<SetlistFmSet>      set;
        String                  url;
    }

    private class SetlistFmSet {
        int                     encore = 0;
        String                  name;

        @SerializedName("song")
        List<SetlistFmSong>     songs;
    }

    private class SetlistFmSong {
        String                  name;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private ISetlistFm    restClient;
    private DateFormat    setlistFmDate = new SimpleDateFormat("dd-MM-yyyy");

    private static SetlistFmClient instance;

    public static SetlistFmClient getInstance() {
        if (instance == null)
            instance = new SetlistFmClient();

        return instance;
    }
}
