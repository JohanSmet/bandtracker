package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Parcelable;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import org.parceler.Parcels;

import java.util.HashMap;
import java.util.List;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.CountryCache;

public class ListSelectionCountryDelegate implements ListSelectionActivity.Delegate {

    public static final String TYPE = "country";
    private static final String SHARED_PREFERENCES_KEY = "be.justcode.bandtracker.ListSelectionCountryDelegate";

    ListSelectionCountryDelegate(Context context, HashMap<String, String> params) {
        mContext = context;
    }

    @Override
    public int numberOfSections() {
        return 2;
    }

    @Override
    public String titleForSection(int section) {
        if (section == 0) {
            return mContext.getText(R.string.country_search_popular).toString();
        } else {
            return "New";
        }
    }

    @Override
    public int numRowsForSection(int section) {
        synchronized (this) {
            switch (section) {
                case 0 :
                    return mPopularCountries != null ? mPopularCountries.size() : 0;
                default :
                    return mFilteredCountries != null ? mFilteredCountries.size() : 0;
            }
        }
    }

    @Override
    public int rowLayout() {
        return R.layout.row_selection_country;
    }

    @Override
    public void configureRowView(View view, int section, int row) {

        Country country = (section == 1) ? mFilteredCountries.get(row) :  mPopularCountries.get(row);

        if (country != null) {
            ((TextView) view.findViewById(R.id.lblCountry)).setText(country.getName());
            ((ImageView) view.findViewById(R.id.imgCountry)).setImageDrawable(CountryCache.get(mContext, country.getCode()).getDrawable());
        }
    }

    @Override
    public void  filterUpdate(final BaseAdapter adapter, final String newFilter) {

        if (mPopularCountries == null) {

            new AsyncTask<Void, Void, Void>() {

                @Override
                protected Void doInBackground(Void... unused) {
                    List<Country> newData = DataContext.gigTop5Countries();
                    synchronized (this) { mPopularCountries = newData; }
                    return null;
                }

                @Override
                protected void onPostExecute(Void unused) {
                    adapter.notifyDataSetChanged();
                }
            }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        }

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
    public Parcelable selectedRow(int section, int row) {

        if (section == 0) {
            return Parcels.wrap(mPopularCountries.get(row));
        } else if (section == 1) {
            return Parcels.wrap(mFilteredCountries.get(row));
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

    private Context mContext;
    private List<Country> mPopularCountries;
    private List<Country> mFilteredCountries;

}
