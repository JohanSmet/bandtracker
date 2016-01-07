package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.BandImageDownloader;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // initialize database
        DataContext.initialize(getApplicationContext());

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // list view
        final ListView listView = (ListView) findViewById(R.id.listMainBands);

        mListAdapter = new BandsSeenAdapter(this, DataContext.bandList(""));
        listView.setAdapter(mListAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                BandDetailsActivity.showBand(MainActivity.this, DataContext.bandFromCursor((Cursor) mListAdapter.getItem(position)));
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main_toolbar, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId())
        {
            case R.id.action_band_add:
                Intent intent = new Intent(this, BandSearchActivity.class);
                startActivityForResult(intent, BandSearchActivity.SELECT_BAND_REQUEST);
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == BandSearchActivity.SELECT_BAND_REQUEST && resultCode == RESULT_OK) {
            String bandId = data.getStringExtra("bandId");
            refreshData();
        }
    }

    private void refreshData() {
        mListAdapter.changeCursor(DataContext.bandList(""));
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsSeenAdapter extends CursorAdapter {
        public BandsSeenAdapter(Context context, Cursor cursor) {
            super(context, cursor, 0);
        }

        @Override
        public View newView(Context context, Cursor cursor, ViewGroup parent) {
            View view = LayoutInflater.from(context).inflate(R.layout.row_bands_seen, parent, false);
            return view;
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            TextView bandName = (TextView) view.findViewById(R.id.lblBandName);
            ImageView imgBand = (ImageView) view.findViewById(R.id.imgBand);

            Band band = DataContext.bandFromCursor(cursor);

            if (!bandName.getText().equals(band.getName())) {
                bandName.setText(band.getName());
                BandImageDownloader.run(band.getMBID(), MainActivity.this, imgBand);
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private BandsSeenAdapter mListAdapter;
}

