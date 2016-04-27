package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.PersistableBundle;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Collection;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.FanartTvDownloader;

public class BandSearchActivity extends AppCompatActivity {

    public static final int SELECT_BAND_REQUEST = 100;

    private static final String SHARED_PREFERENCES_KEY = "be.justcode.bandtracker.BandSearchActivity";
    private static final String PREF_SEARCH_STRING = "search_string";

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_band_search);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        ab.setTitle(getText(R.string.band_search_title));

        // listview
        mListAdapter      = new BandsArrayAdapter(this);
        ListView listView = (ListView) findViewById(R.id.listView);

        listView.setAdapter(mListAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                handleSelection(mListAdapter.getItem(position));
            }
        });

        // load the last used search string
        SharedPreferences sharedPref = getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        mSearchString = sharedPref.getString(PREF_SEARCH_STRING, "");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        getMenuInflater().inflate(R.menu.menu_bandsearch_toolbar, menu);

        // configure searchview
        MenuItem searchItem = menu.findItem(R.id.action_band_search);
        searchItem.expandActionView();

        SearchView searchView = (SearchView) MenuItemCompat.getActionView(searchItem);

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return true;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                mSearchString = newText;
                refreshData(newText);
                return true;
            }
        });
        searchView.setQuery(mSearchString, true);

        return super.onCreateOptionsMenu(menu);
    }

    private void saveSearchString() {
        SharedPreferences sharedPref = getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(PREF_SEARCH_STRING, mSearchString);
        editor.commit();
    }

    private void refreshData(String query) {
        if (query.length() >= 2) {
            new BandsRetrieveTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, query);
            saveSearchString();
        }
    }

    private void handleSelection(BandTrackerBand band) {

        // save the band to the database
        DataContext.bandCreate(band);

        // send word to the activity that called us
        Intent intent = new Intent();
        intent.putExtra("bandId", band.getMBID());
        setResult(RESULT_OK, intent);
        finish();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsRetrieveTask extends AsyncTask<String, Integer, Collection<BandTrackerBand>> {

        protected Collection<BandTrackerBand> doInBackground(String... params) {
            return BandTrackerClient.getInstance().findBands(params[0]);
        }

        protected void onPostExecute(Collection<BandTrackerBand> results) {
            mListAdapter.clear();
            mListAdapter.addAll(results);
        }
    }

    private class BandsArrayAdapter extends ArrayAdapter<BandTrackerBand> {

        public BandsArrayAdapter(Context context) {
            super(context, android.R.layout.simple_list_item_1, new ArrayList<BandTrackerBand>());
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // inflate the desired layout
            View rowView = convertView;

            if (rowView == null) {
                LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                rowView = inflater.inflate(android.R.layout.simple_list_item_1, parent, false);
            }

            // fill in values
            BandTrackerBand band = getItem(position);
            ((TextView) rowView.findViewById(android.R.id.text1)).setText(band.getName());

            return rowView;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    BandsArrayAdapter   mListAdapter;
    String              mSearchString;
}
