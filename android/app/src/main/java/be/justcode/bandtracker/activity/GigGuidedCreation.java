package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RatingBar;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerTourDate;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.CountryCache;
import be.justcode.bandtracker.utils.DateUtils;

public class GigGuidedCreation extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER  = "param_band";
    private static final String INTENT_YEARS_PARAMETER = "param_years";

    private static final int REQUEST_COUNTRY = 1;


    public static void run(Context context, Band band, ArrayList<Integer> years) {
        Intent intent = new Intent(context, GigGuidedCreation.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        intent.putIntegerArrayListExtra(INTENT_YEARS_PARAMETER, years);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gig_guided_creation);

        // toolbar
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolbar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);

        // read params
        Bundle bundle = getIntent().getExtras();
        mBand  = bundle.getParcelable(INTENT_BAND_PARAMETER);
        mYears = bundle.getIntegerArrayList(INTENT_YEARS_PARAMETER);

        setTitle(mBand.getName());

        // fields
        pickYear = (Spinner) findViewById(R.id.pickYear);
        editCountry = (EditText) findViewById(R.id.editCountry);
        imgCountry  = (ImageView) findViewById(R.id.imgCountry);

        // initialize year picker
        pickYear.setAdapter(new ArrayAdapter<Integer>(this, android.R.layout.simple_spinner_item, mYears));
        pickYear.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                mFilterYear = (Integer) parent.getItemAtPosition(position);
                updateFilter();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        // initialize tourdates list
        mListAdapter = new FilterResultsAdapter(this, new ArrayList<BandTrackerTourDate>());
        final ListView listView = (ListView) findViewById(R.id.listTourDates);
        listView.setAdapter(mListAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                createGig(mListAdapter.getItem(position));
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode != RESULT_OK)
            return;

        if (requestCode == REQUEST_COUNTRY) {
            mFilterCountry = data.getParcelableExtra("result");
            editCountry.setText(mFilterCountry.getName());
            imgCountry.setImageDrawable(CountryCache.get(this, mFilterCountry.getCode()).getDrawable());
            updateFilter();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // events
    //

    public void editText_clicked(View view) {
        if (view == editCountry) {
            ListSelectionActivity.create(this, ListSelectionCountryDelegate.TYPE, REQUEST_COUNTRY, null);
        }
    }

    public void btnManualCreate_clicked(View view) {
        finish();
        GigDetailsActivity.createNew(this, mBand);
    }

    public void createGig(BandTrackerTourDate tourDate) {
        finish();

        Gig gig = new Gig(tourDate);
        GigDetailsActivity.editExisting(this, mBand, gig);
    }

    public void updateFilter() {

        new AsyncTask<Void, Integer, List<BandTrackerTourDate>>() {

            @Override
            protected List<BandTrackerTourDate> doInBackground(Void... params) {
                return BandTrackerClient.getInstance().tourDateFind(mBand.getMBID(),
                                                                    DateUtils.dateFromComponents(mFilterYear, 1, 1, 0, 0),
                                                                    DateUtils.dateFromComponents(mFilterYear, 12, 31, 0, 0),
                                                                    (mFilterCountry != null) ? mFilterCountry.getCode() : null,
                                                                    null);
            }

            @Override
            protected void onPostExecute(List<BandTrackerTourDate> bandTrackerTourDates) {
                mListAdapter.clear();
                mListAdapter.addAll(bandTrackerTourDates);
            }

        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class FilterResultsAdapter extends ArrayAdapter<BandTrackerTourDate> {
        public FilterResultsAdapter(Context context, List<BandTrackerTourDate> tourDates) {
            super(context, 0, tourDates);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            BandTrackerTourDate tourDate = getItem(position);

            if (convertView == null) {
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.row_band_gig, parent, false);
                ViewHolder holder = new ViewHolder();
                holder.lblLocation = (TextView) convertView.findViewById(R.id.lblLocation);
                holder.lblDate     = (TextView) convertView.findViewById(R.id.lblDate);
                holder.ratingBar   = (RatingBar) convertView.findViewById(R.id.ratingBar);
                holder.imgFlag     = (ImageView) convertView.findViewById(R.id.imgCountryFlag);
                convertView.setTag(holder);
            }

            ViewHolder holder = (ViewHolder) convertView.getTag();

            holder.lblLocation.setText(tourDate.formatLocation());
            holder.lblDate.setText(DateUtils.dateToString(tourDate.getStartDate()));
            holder.imgFlag.setImageDrawable(CountryCache.get(GigGuidedCreation.this, tourDate.getCountryCode()).getDrawable());
            holder.ratingBar.setVisibility(View.GONE);


            return convertView;
        }

        private class ViewHolder {
            public TextView     lblLocation;
            public TextView     lblDate;
            public RatingBar    ratingBar;
            public ImageView    imgFlag;
        };
    }

    // member variables
    private Band                mBand;
    private ArrayList<Integer>  mYears;

    private Country             mFilterCountry = null;
    private Integer             mFilterYear    = 0;

    private FilterResultsAdapter        mListAdapter;

    private Spinner             pickYear;
    private EditText            editCountry;
    private ImageView           imgCountry;

}