package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.HashMap;
import java.util.List;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.CountryCache;

public class ListSelectionCountryDelegate implements ListSelectionActivity.Delegate {

    public static final String TYPE = "country";

    ListSelectionCountryDelegate(Context context, HashMap<String, String> params) {
        mContext = context;
    }

    @Override
    public int numberOfSections() {
        return 1;
    }

    @Override
    public String titleForSection(int section) {
        return "";
    }

    @Override
    public int numRowsForSection(int section) {
        synchronized (this) {
            if (mFilteredCountries == null) {
                return 0;
            } else {
                return mFilteredCountries.size();
            }
        }
    }

    @Override
    public int rowLayout() {
        return R.layout.row_selection_country;
    }

    @Override
    public void configureRowView(View view, int section, int row) {
        if (section == 0) {
            Country country = mFilteredCountries.get(row);

            ((TextView) view.findViewById(R.id.lblCountry)).setText(country.getName());
            ((ImageView) view.findViewById(R.id.imgCountry)).setImageDrawable(CountryCache.get(mContext, country.getCode()).getDrawable());
        }
    }

    @Override
    public void  filterUpdate(final BaseAdapter adapter, final String newFilter) {

        if (newFilter.length() < 2) {
            synchronized (this) { mFilteredCountries = null; }
            adapter.notifyDataSetChanged();
            return;
        }

        new AsyncTask<Void, Void, Void>() {

            @Override
            protected Void doInBackground(Void... unused) {
                List<Country> newData = DataContext.countryList(newFilter);
                synchronized (this) { mFilteredCountries = newData; }
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
            return mFilteredCountries.get(row).getCode();
        }

        return null;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Context mContext;
    private List<Country> mFilteredCountries;

}
