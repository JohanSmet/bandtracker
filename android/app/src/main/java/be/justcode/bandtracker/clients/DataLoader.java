package be.justcode.bandtracker.clients;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;
import be.justcode.bandtracker.model.DataContext;

public class DataLoader {

    private static final String SHARED_PREFERENCES_KEY = "be.justcode.bandtracker.DataLoader";


    public static void downloadDataAsync(final Context context) {

        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                loadCountries(context);
            }
        });
    }


    private static void loadCountries(Context context) {

        // load information about last synchronization
        SharedPreferences sharedPref = context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        int syncId = sharedPref.getInt("countrySyncId", 0);

        // start country sync
        BandTrackerClient.CountrySyncResponse response = BandTrackerClient.getInstance().countrySync(syncId);

        if (response == null || response.getSync() == syncId) {
            return;
        }

        // process countries
        DataContext.countryDeleteAll();

        for (BandTrackerCountry country : response.getCountries()) {
            DataContext.countryCreate(country);
        }

        // save syncId
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putInt("countrySyncId", syncId);
        editor.commit();
    }

}
