package be.justcode.bandtracker.activity;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.BandImageDownloader;
import be.justcode.bandtracker.utils.DateUtils;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RatingBar;
import android.widget.TextView;

public class BandDetailsActivity extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER = "param_band";

    public static void showBand(Context context, Band band) {
        Intent intent = new Intent(context, BandDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_band_details);

        // read params
        Bundle bundle = getIntent().getExtras();
        mBand = bundle.getParcelable(INTENT_BAND_PARAMETER);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        ab.setTitle(mBand.getName());

        // init fields
        txtBiography = (TextView)  findViewById(R.id.txtBiography);
        imgBand      = (ImageView) findViewById(R.id.imgBand);
        displayBand();

        // list view
        final ListView listView = (ListView) findViewById(R.id.listBandGigs);

        mListAdapter = new BandsGigsAdapter(this, DataContext.gigList(mBand.getMBID()));
        listView.setAdapter(mListAdapter);
    }

    private void displayBand() {
        txtBiography.setText(Html.fromHtml(mBand.getBiography()));

        BandImageDownloader.run(mBand.getMBID(), this, imgBand);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // button events
    //

    public void btnGigAdd_clicked(View p_view) {
        GigDetailsActivity.createNew(this, mBand);
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsGigsAdapter extends CursorAdapter {
        public BandsGigsAdapter(Context context, Cursor cursor) {
            super(context, cursor, 0);
        }

        @Override
        public View newView(Context context, Cursor cursor, ViewGroup parent) {
            View view = LayoutInflater.from(context).inflate(R.layout.row_band_gig, parent, false);

            // fields
            ViewHolder holder = new ViewHolder();
            holder.lblLocation = (TextView) view.findViewById(R.id.lblLocation);
            holder.lblDate     = (TextView) view.findViewById(R.id.lblDate);
            holder.ratingBar   = (RatingBar) view.findViewById(R.id.ratingBar);
            view.setTag(holder);

            return view;
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            Gig gig           = DataContext.gigFromCursor(cursor);
            ViewHolder holder = (ViewHolder) view.getTag();

            holder.lblLocation.setText(gig.getCity());
            holder.lblDate.setText(DateUtils.dateToString(gig.getStartDate()));
            holder.ratingBar.setRating(gig.getRating() / 10);
        }

        private class ViewHolder {
            public TextView     lblLocation;
            public TextView     lblDate;
            public RatingBar    ratingBar;
        };
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Band        mBand;

    private TextView    txtBiography;
    private ImageView   imgBand;

    private BandsGigsAdapter mListAdapter;
}
