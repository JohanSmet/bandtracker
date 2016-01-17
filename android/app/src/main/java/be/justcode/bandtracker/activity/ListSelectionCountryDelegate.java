package be.justcode.bandtracker.activity;

import android.content.Context;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.CountryCache;

public class ListSelectionCountryDelegate implements ListSelectionActivity.Delegate {

    public static final String TYPE = "country";

    ListSelectionCountryDelegate(Context context) {
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
    public void  filterUpdate(BaseAdapter adapter, String newFilter) {

        List<Country> newData = null;

        if (!newFilter.isEmpty()) {
            newData = DataContext.countryList(newFilter);
        }

        synchronized (this) {
            mFilteredCountries = newData;
            adapter.notifyDataSetChanged();
        }
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
