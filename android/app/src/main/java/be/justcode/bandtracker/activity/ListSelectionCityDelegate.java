package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.City;
import be.justcode.bandtracker.model.DataContext;

public class ListSelectionCityDelegate implements ListSelectionActivity.Delegate  {

    public static final String TYPE = "city";

    ListSelectionCityDelegate(Context context) {
        mContext = context;
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

        // ask server
        new AsyncTask<Void, Void, Void> () {

            @Override
            protected Void doInBackground(Void... unused) {
                List<String> cities = BandTrackerClient.getInstance().findCities(newFilter, "");
                synchronized (this) { mNewCities = cities; }
                return null;
            }

            @Override
            protected void onPostExecute(Void unused) {
                adapter.notifyDataSetChanged();
            }

        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

        // local database
        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... unused) {
                List<City> newData = DataContext.cityList(newFilter, "");
                synchronized (this) { mOldCities = newData; }
                return null;
            }

            @Override
            protected void onPostExecute(Void unused) {
                adapter.notifyDataSetChanged();
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    @Override
    public String selectedRow(int section, int row) {
        if (section == 0) {
            return mManualInput;
        } else if (section == 1) {
            return mOldCities.get(row).getName();
        } else if (section == 2) {
            return mNewCities.get(row);
        }

        return null;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Context         mContext;
    private String          mManualInput = "";
    private List<City>      mOldCities;
    private List<String>    mNewCities;

}
