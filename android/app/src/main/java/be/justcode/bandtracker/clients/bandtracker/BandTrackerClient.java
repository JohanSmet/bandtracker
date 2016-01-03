package be.justcode.bandtracker.clients.bandtracker;

import android.util.Log;

import com.google.gson.GsonBuilder;

import java.util.Collection;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.OkHttpBuilder;
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
import retrofit.http.Query;

public class BandTrackerClient
{
    private static final String LOG_TAG = "BandTrackerClient";

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
