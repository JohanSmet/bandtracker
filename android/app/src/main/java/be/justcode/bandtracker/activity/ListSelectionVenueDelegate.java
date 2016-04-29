package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Parcelable;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.TextView;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.Predicate;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.City;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Venue;

public class ListSelectionVenueDelegate implements ListSelectionActivity.Delegate {

    public static final String TYPE = "venue";

    public static final String PARAM_COUNTRY    = "param_country";
    public static final String PARAM_CITY       = "param_city";

    private static final String SHARED_PREFERENCES_KEY = "be.justcode.bandtracker.ListSelectionVenueDelegate";

    ListSelectionVenueDelegate(Context context, HashMap<String, String> params) {
        mContext = context;

        if (params != null && params.containsKey(PARAM_COUNTRY))
            mParamCountry = params.get(PARAM_COUNTRY);
        if (params != null && params.containsKey(PARAM_CITY))
            mParamCity = params.get(PARAM_CITY);
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
                    return mOldVenues != null ? mOldVenues.size() : 0;
                default :
                    return mNewVenues != null ? mNewVenues.size() : 0;
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
            Venue venue = mOldVenues.get(row);
            text.setText(venue.getName());
        } else if (section == 2) {
            text.setText(mNewVenues.get(row));
        }
    }

    @Override
    public void  filterUpdate(final BaseAdapter adapter, final String newFilter) {

        mManualInput = newFilter;

        if (newFilter.length() < 3) {
            synchronized (this) {
                mOldVenues = null;
                mNewVenues = null;
            }
            adapter.notifyDataSetChanged();
            return;
        }

        final CountDownLatch latchTask = new CountDownLatch(2);

        // ask server
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                mNewVenues = BandTrackerClient.getInstance().findVenues(newFilter, mParamCity, mParamCountry);
                latchTask.countDown();
            }
        });

        // local database
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                Country country = (!mParamCountry.isEmpty()) ? DataContext.countryFetch(mParamCountry) : null;
                City    city    = (!mParamCity.isEmpty()) ? DataContext.cityById(Long.parseLong(mParamCity)) : null;

                mOldVenues = DataContext.venueList(newFilter, city, country);
                latchTask.countDown();
            }
        });

        // post-process lists
        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... unused) {
                try {
                    latchTask.await();

                    // remove old venues from the new venues
                    CollectionUtils.filter(mNewVenues, new Predicate<String>() {
                        @Override
                        public boolean evaluate(final String newVenue) {
                            return CollectionUtils.find(mOldVenues, new Predicate<Venue>() {
                                @Override
                                public boolean evaluate(Venue oldVenue) {
                                    return oldVenue.getName().equals(newVenue);
                                }
                            }) == null;
                        }
                    });

                } catch (InterruptedException e) {
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
        Country country = (!mParamCountry.isEmpty()) ? DataContext.countryFetch(mParamCountry) : null;
        City    city    = (!mParamCity.isEmpty()) ? DataContext.cityById(Long.parseLong(mParamCity)) : null;

        if (section == 0) {
            return DataContext.venueCreate(mManualInput, city, country);
        } else if (section == 1) {
            return mOldVenues.get(row);
        } else if (section == 2) {
            return DataContext.venueCreate(mNewVenues.get(row), city, country);
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

    private Context         mContext;
    private String          mParamCountry= "";
    private String          mParamCity   = "";
    private String          mManualInput = "";
    private List<Venue>     mOldVenues;
    private List<String>    mNewVenues;

}
