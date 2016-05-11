package be.justcode.bandtracker.clients.setlist.fm;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonParseException;
import com.google.gson.TypeAdapter;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

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
import retrofit.http.Query;

public class SetlistFmClient {

    private static final String LOG_TAG = "SetlistFmClient";

    private SetlistFmClient() {
        if (restClient == null) {

            String serverHost    = App.getContext().getString(R.string.setlistfm_host);
            String serverBaseUrl = App.getContext().getString(R.string.setlistfm_proto) + "://" + serverHost + ":" + App.getContext().getString(R.string.setlistfm_port);
            apiKey               = App.getContext().getString(R.string.setlistfm_key);

            Gson gson = new GsonBuilder()
                                .create();

            restClient = new RestAdapter.Builder()
                    .setEndpoint(serverBaseUrl)
                    .setConverter(new GsonConverter(gson))
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
        @GET("/rest/0.1/search/setlists.json")
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

            SetlistFmSetlist remoteSetlist = response.setlists.setlists.get(0);

            if (remoteSetlist == null)
                return null;

            Setlist setlist = new Setlist();
            setlist.url = remoteSetlist.url;

            for (SetlistFmSet remoteSet : remoteSetlist.sets.sets) {
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
    // gson type adapters
    //

    public class SetlistFmSetlistsTypeAdapter extends TypeAdapter<SetlistFmSetlists> {

        @Override
        public void write(JsonWriter out, SetlistFmSetlists value) throws IOException {
            new Gson().toJson(value, SetlistFmSetlists.class, out);
        }

        @Override
        public SetlistFmSetlists read(JsonReader reader) throws IOException {

            reader.beginObject();

            int itemsPerPage = 0;
            int page = 0;
            int total = 0;
            SetlistFmSetlists result = null;

            while (reader.hasNext()) {

                String name = reader.nextName();

                if (name.equals("@itemsPerPage")) {
                    itemsPerPage = Integer.parseInt(reader.nextString());
                } else if (name.equals("@page")) {
                    page = Integer.parseInt(reader.nextString());
                } else if (name.equals("@total")) {
                    total = Integer.parseInt(reader.nextString());
                } else if (name.equals("setlist")) {
                    if (reader.peek() == JsonToken.BEGIN_ARRAY) {
                        result = new SetlistFmSetlists(itemsPerPage, page, total, (SetlistFmSetlist[]) new Gson().fromJson(reader, SetlistFmSetlist[].class));
                    } else if(reader.peek() == JsonToken.BEGIN_OBJECT) {
                        result = new SetlistFmSetlists(itemsPerPage, page, total, (SetlistFmSetlist) new Gson().fromJson(reader, SetlistFmSetlist.class));
                    } else {
                        throw new JsonParseException("Unexpected token " + reader.peek());
                    }
                }
            }

            reader.endObject();

            return result;
        }
    }

    public class SetlistFmSetsTypeAdapter extends TypeAdapter<SetlistFmSets> {

        @Override
        public void write(JsonWriter out, SetlistFmSets value) throws IOException {
            new Gson().toJson(value, SetlistFmSets.class, out);
        }

        @Override
        public SetlistFmSets read(JsonReader reader) throws IOException {

            SetlistFmSets result = null;

            reader.beginObject();
            reader.nextName();

            if (reader.peek() == JsonToken.BEGIN_ARRAY) {
                result = new SetlistFmSets((SetlistFmSet[]) new Gson().fromJson(reader, SetlistFmSet[].class));
            } else if (reader.peek() == JsonToken.BEGIN_OBJECT) {
                result = new SetlistFmSets((SetlistFmSet) new Gson().fromJson(reader, SetlistFmSet.class));
            } else {
                throw new JsonParseException("Unexpected token " + reader.peek());
            }

            reader.endObject();
            return result;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // internal types
    //

    public class Setlist {
        String              url;
        List<SetlistPart>   setlistParts = new ArrayList<>();
    }

    public class SetlistPart {
        String          name;
        List<String>    songs = new ArrayList<>();
    }

    private class SetlistFmResponse {
        SetlistFmSetlists setlists;
    }

    @JsonAdapter(SetlistFmSetlistsTypeAdapter.class)
    private class SetlistFmSetlists {

        SetlistFmSetlists(int itemsPerPage, int page, int total, SetlistFmSetlist... setlists) {
            this.itemsPerPage = itemsPerPage;
            this.page         = page;
            this.total        = total;
            this.setlists     = Arrays.asList(setlists);
        }

        int itemsPerPage;
        int page;
        int total;

        List<SetlistFmSetlist> setlists;
    }

    private class SetlistFmSetlist {
        @SerializedName("@id")
        String  id ;
        @SerializedName("@versionId")
        String  versionId;
        @SerializedName("@tour")
        String  tour;
        @SerializedName("@info")
        String  info;
        String  url;

        SetlistFmArtist artist;
        SetlistFmSets   sets;
    }

    private class SetlistFmArtist {

        @SerializedName("@disambiguation")
        String disambiguation;
        @SerializedName("@mbid")
        String mbid;
        @SerializedName("@name")
        String name;
        @SerializedName("@sortName")
        String sortName;
    }

    @JsonAdapter(SetlistFmSetsTypeAdapter.class)
    private class SetlistFmSets {

        SetlistFmSets(SetlistFmSet... sets) {
            this.sets = Arrays.asList(sets);
        }

        List<SetlistFmSet>  sets;
    }

    private class SetlistFmSet {
        @SerializedName("@encore")
        int encore = 0;

        @SerializedName("song")
        List<SetlistFmSong> songs;

        @SerializedName("name")
        String name;
    }

    private class SetlistFmSong {
        @SerializedName("@name")
        String  name;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private IFanartTv     restClient;
    private String        apiKey;
    private DateFormat    setlistFmDate = new SimpleDateFormat("dd-MM-yyyy");

    private static SetlistFmClient instance;

    public static SetlistFmClient getInstance() {
        if (instance == null)
            instance = new SetlistFmClient();

        return instance;
    }
}
