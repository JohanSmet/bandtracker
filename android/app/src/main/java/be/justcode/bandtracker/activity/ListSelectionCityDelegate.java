package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Parcelable;
import android.util.Log;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.TextView;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.Predicate;
import org.parceler.Parcels;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.City;
import be.justcode.bandtracker.model.DataContext;

public class ListSelectionCityDelegate implements ListSelectionActivity.Delegate  {

    public static final String TYPE             = "city";
    public static final String PARAM_COUNTRY    = "param_country";
    private static final String SHARED_PREFERENCES_KEY = "be.justcode.bandtracker.ListSelectionCityDelegate";
    private static final String LOG_TAG                 = "ListSelectionCity";

    ListSelectionCityDelegate(Context context, HashMap<String, String> params) {

        if (params != null && params.containsKey(PARAM_COUNTRY))
            mParamCountry = params.get(PARAM_COUNTRY);
    }

    @Override
    public int numberOfSections() {
        return 3;
    }

    @Override
    public String titleForSection(int section) {
        if (section == 1)
            return "Previously used";
        else if (section == 2)
            return "New";
        else
            return "";
    }

    @Override
    public int numRowsForSection(int section) {
        synchronized (this) {
            switch (section) {
                case 0 :
                    return mManualInput.isEmpty() ? 0 : 1;
                case 1 :
                    return mOldCities != null ? mOldCities.size() : 0;
                default :
                    return mNewCities != null ? mNewCities.size() : 0;
            }
        }
    }

    @Override
    public int rowLayout() {
        return android.R.layout.simple_list_item_1;
    }

    @Override
    public void configureRowView(View view, int section, int row) {
        TextView text = (TextView) view.findViewById(android.R.id.text1);

        if (section == 0) {
            text.setText(mManualInput);
        } else if (section == 1) {
            City city = mOldCities.get(row);
            text.setText(city.getName());
        } else if (section == 2) {
            text.setText(mNewCities.get(row));
        }
    }

    @Override
    public void  filterUpdate(final BaseAdapter adapter, final String newFilter) {

        mManualInput = newFilter;

        if (newFilter.length() < 3) {
            synchronized (this) {
                mOldCities = null;
                mNewCities = null;
            }
            adapter.notifyDataSetChanged();
            return;
        }

        final CountDownLatch latchTask = new CountDownLatch(2);

        // ask server
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                mNewCities = BandTrackerClient.getInstance().findCities(newFilter, mParamCountry);
                latchTask.countDown();
            }
        });

        // local database
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                mOldCities = DataContext.cityList(newFilter, DataContext.countryFetch(mParamCountry));
                latchTask.countDown();
            }
        });

        // post-process lists
        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... unused) {
                try {
                    latchTask.await();

                    // remove old cities from the new cities
                    CollectionUtils.filter(mNewCities, new Predicate<String>() {
                        @Override
                        public boolean evaluate(final String newCity) {
                            return CollectionUtils.find(mOldCities, new Predicate<City>() {
                                @Override
                                public boolean evaluate(City oldCity) {
                                    return oldCity.getName().equals(newCity);
                                }
                            }) == null;
                        }
                    });

                } catch (InterruptedException e) {
                    Log.d(LOG_TAG, "post-process", e);
                }

                return null;
            }

            @Override
            protected void onPostExecute(Void unused) {
                adapter.notifyDataSetChanged();
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    @Override
    public Parcelable selectedRow(int section, int row) {
        if (section == 0) {
            return Parcels.wrap(DataContext.cityCreate(mManualInput, DataContext.countryFetch(mParamCountry)));
        } else if (section == 1) {
            return Parcels.wrap(mOldCities.get(row));
        } else if (section == 2) {
            return Parcels.wrap(DataContext.cityCreate(mNewCities.get(row), DataContext.countryFetch(mParamCountry)));
        }

        return null;
    }

    @Override
    public String persistenceKey() {
        return SHARED_PREFERENCES_KEY;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private String          mParamCountry = "";
    private String          mManualInput = "";
    private List<City>      mOldCities;
    private List<String>    mNewCities;

}
