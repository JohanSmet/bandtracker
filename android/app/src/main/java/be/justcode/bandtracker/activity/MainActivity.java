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
import android.widget.BaseAdapter;
import android.widget.CursorAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.raizlabs.android.dbflow.list.FlowCursorList;
import com.raizlabs.android.dbflow.structure.Model;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.DataLoader;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.BandImageDownloader;
import be.justcode.bandtracker.utils.FlowCursorAdapter;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // initialize database
        DataContext.initialize(getApplicationContext());

        // data sync
        DataLoader.downloadDataAsync(getApplicationContext());

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // list view
        final ListView listView = (ListView) findViewById(R.id.listMainBands);

        mListAdapter = new BandsSeenAdapter(this, "");
        listView.setAdapter(mListAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                BandDetailsActivity.showBand(MainActivity.this, mListAdapter.getItem(position));
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
        mListAdapter.changePattern("");
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsSeenAdapter extends FlowCursorAdapter<Band> {
        public BandsSeenAdapter(Context context, String pattern) {
            mContext = context;
            changeCursor(DataContext.bandCursor(pattern));
        }

        public void changePattern(String pattern) {
            changeCursor(DataContext.bandCursor(pattern));
        }

        public View newView(ViewGroup parent) {
            View view = LayoutInflater.from(mContext).inflate(R.layout.row_bands_seen, parent, false);

            ViewHolder holder = new ViewHolder();
            holder.bandName = (TextView) view.findViewById(R.id.lblBandName);
            holder.imgBand  = (ImageView) view.findViewById(R.id.imgBand);
            view.setTag(holder);

            return view;
        }

        public void bindView(View view, int position) {

            Band band = getItem(position);
            ViewHolder holder = (ViewHolder) view.getTag();

            if (!holder.bandName.getText().equals(band.getName())) {
                holder.bandName.setText(band.getName());
                BandImageDownloader.run(band.getMBID(), MainActivity.this, holder.imgBand);
            }
        }

        private class ViewHolder {
            TextView    bandName;
            ImageView   imgBand;
        }

        private Context              mContext;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private BandsSeenAdapter mListAdapter;
}

