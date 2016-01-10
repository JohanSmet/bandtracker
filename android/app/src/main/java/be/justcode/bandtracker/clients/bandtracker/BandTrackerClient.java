package be.justcode.bandtracker.clients.bandtracker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.util.Collection;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.OkHttpBuilder;
import be.justcode.bandtracker.model.City;
import be.justcode.bandtracker.model.Venue;
import retrofit.RequestInterceptor;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.OkClient;
import retrofit.client.Response;
import retrofit.converter.ConversionException;
import retrofit.converter.GsonConverter;
import retrofit.http.Body;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Path;
import retrofit.http.Query;

public class BandTrackerClient
{
    private static final String LOG_TAG = "BandTrackerClient";

    public static final String HEADER_CACHE_CONTROL         = "Cache-Control";
    public static final String CACHE_CONTROL_SERVER         = "max-age=0";
    public static final String CACHE_CONTROL_PREFER_CACHE   = "max-age=315360000";
    public static final String CACHE_CONTROL_ONLY_CACHE     = "only-if-cached";

    private BandTrackerClient() {

        if (restClient == null) {

            String serverHost    = App.getContext().getString(R.string.bandtracker_host);
            String serverBaseUrl = App.getContext().getString(R.string.bandtracker_proto) + "://" + serverHost + ":" + App.getContext().getString(R.string.bandtracker_port);

            gsonConverter = new GsonConverter(new GsonBuilder()
                    .setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
                    .create()
            );

            restClient = new RestAdapter.Builder()
                .setEndpoint(serverBaseUrl)
                .setConverter(gsonConverter)
                .setClient(new OkClient(OkHttpBuilder.getClient(App.getContext(), true)))
                .setRequestInterceptor(new RequestInterceptor()
                {
                    @Override
                    public void intercept(RequestFacade request)
                    {
                        if (authToken != null) {
                            request.addHeader("x-access-token", authToken);
                        }
                    }
                })
                // .setLogLevel(RestAdapter.LogLevel.FULL)
                .build()
                .create(IBandTracker.class)
            ;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // REST-interface
    //

    private interface IBandTracker {
        @POST("/api/auth/login")
        public Response login(@Body LoginBody body);

        @GET("/api/bands/find-by-name")
        public Collection<BandTrackerBand> findBands(@Query("name") String pattern);

        @GET("/api/bandImage/{bandId}")
        public Response getBandImage(@Path("bandId") String bandId, @retrofit.http.Header(HEADER_CACHE_CONTROL) String cacheControlValue);

        @GET("/api/country/sync")
        public CountrySyncResponse countrySync(@Query("syncId") int syncId);

        @GET("/api/city/find")
        public Collection<City> findCities(@Query("pattern") String name, @Query("country") String country);

        @GET("/api/venue/find")
        public Collection<Venue> findVenues(@Query("pattern") String name, @Query("city") String city, @Query("country") String country);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //

    public void login() {
        try {
            // make the request
            Response response = restClient.login(new LoginBody("ios-development", "test"));

            if (response.getStatus() != 200)
                return;

            // check the body of the response
            try {
                LoginResponse loginInfo = (LoginResponse) gsonConverter.fromBody(response.getBody(), LoginResponse.class);

                if (loginInfo.getSuccess()) {
                    authToken = loginInfo.getToken();
                }

            } catch (ConversionException e) {
                Log.d(LOG_TAG, "login", e);
            }

        } catch (RetrofitError e) {
           Log.d(LOG_TAG, "login", e);
        }
    }

    public Collection<BandTrackerBand> findBands(String p_pattern) {

        try {
            // make sure we're logged in before making the request
            if (authToken == null) {
                login();
            }

            // make the request
            return restClient.findBands(p_pattern);

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "findBands", e);
            return null;
        }
    }

    public Bitmap bandImage(String bandId) {

        try {
            // make sure we're logged in before making the request
            if (authToken == null) {
                login();
            }

            Response response = restClient.getBandImage(bandId, CACHE_CONTROL_PREFER_CACHE);

            if (response == null || response.getStatus() != 200)
                return null;

            return BitmapFactory.decodeStream(response.getBody().in());

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "bandImage", e);
            return null;
        } catch (IOException e) {
            return null;
        }
    }

    public CountrySyncResponse countrySync(int syncId) {

        try {
            // make sure we're logged in before making the request
            if (authToken == null) {
                login();
            }

            return restClient.countrySync(syncId);

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "bandImage", e);
            return null;
        }
    }

    public Collection<City> findCities(String name, String country) {
        try {
            // make sure we're logged in before making the request
            if (authToken == null) {
                login();
            }

            // make the request
            return restClient.findCities(name, country);

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "findCities", e);
            return null;
        }
    }

    public Collection<Venue> findVenues(String name, String city, String country) {
        try {
            // make sure we're logged in before making the request
            if (authToken == null) {
                login();
            }

            // make the request
            return restClient.findVenues(name, (city != null && !city.isEmpty()) ? city : null, country);

        } catch (RetrofitError e) {
            Log.d(LOG_TAG, "findVenues", e);
            return null;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // internal types
    //

    private class LoginBody {

        public LoginBody(String p_name, String p_passwd) {
            name    = p_name;
            passwd  = p_passwd;
        }

        public String   name;
        public String   passwd;
    }

    private class LoginResponse {

        public boolean getSuccess() {
            return success;
        }

        public void getSuccess(boolean success) {
            this.success = success;
        }

        public String getError()
        {
            return error;
        }

        public void setError(String error)
        {
            this.error = error;
        }

        public String getToken()
        {
            return token;
        }

        public void setToken(String token)
        {
            this.token = token;
        }

        private boolean success;
        private String  error;
        private String  token;
    }

    public class CountrySyncResponse {

        public int getSync() {
            return sync;
        }

        public void setSync(int sync) {
            this.sync = sync;
        }

        public Collection<BandTrackerCountry> getCountries() {
            return countries;
        }

        public void setCountries(Collection<BandTrackerCountry> countries) {
            this.countries = countries;
        }

        private int                             sync;
        private Collection<BandTrackerCountry>  countries;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private IBandTracker    restClient;
    private GsonConverter   gsonConverter;

    private String          authToken = null;

    private static BandTrackerClient instance;

    public static BandTrackerClient getInstance() {
        if (instance == null)
            instance = new BandTrackerClient();

        return instance;
    }
}
