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

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.Predicate;
import org.parceler.Parcels;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerTourDate;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerTourDateYear;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.CountryCache;
import be.justcode.bandtracker.utils.DateUtils;

public class GigGuidedCreation extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER  = "param_band";
    private static final String INTENT_YEARS_PARAMETER = "param_years";

    private static final int REQUEST_COUNTRY = 1;


    public static void run(Context context, Band band, ArrayList<BandTrackerTourDateYear> years) {
        Intent intent = new Intent(context, GigGuidedCreation.class);
        intent.putExtra(INTENT_BAND_PARAMETER,  Parcels.wrap(band));
        intent.putExtra(INTENT_YEARS_PARAMETER, Parcels.wrap(years));
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
        mBand  = Parcels.unwrap(bundle.getParcelable(INTENT_BAND_PARAMETER));
        mYears = Parcels.unwrap(bundle.getParcelable(INTENT_YEARS_PARAMETER));

        setTitle(mBand.getName());

        // fields
        pickYear = (Spinner) findViewById(R.id.pickYear);
        editCountry = (EditText) findViewById(R.id.editCountry);
        imgCountry  = (ImageView) findViewById(R.id.imgCountry);

        // initialize year picker
        pickYear.setAdapter(new TourDateYearsAdapter(this, mYears));
        pickYear.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                mFilterYear = ((BandTrackerTourDateYear) parent.getItemAtPosition(position)).getYear();
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
            mFilterCountry = Parcels.unwrap(data.getParcelableExtra("result"));
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
            ListSelectionActivity.create(this, ListSelectionCountryDelegate.TYPE, REQUEST_COUNTRY, editCountry.getText().toString(), null);
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

        final List<BandTrackerTourDate> newTourDates = new ArrayList<>();
        final List<Gig>                 existingGigs = new ArrayList<>();
        final CountDownLatch            latchTask = new CountDownLatch(2);

        // retrieve all known gigs for a year from the server
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                newTourDates.addAll(BandTrackerClient.getInstance().tourDateFind(
                                        mBand.getMBID(),
                                        DateUtils.dateFromComponents(mFilterYear, Calendar.JANUARY, 1, 0, 0),
                                        DateUtils.dateFromComponents(mFilterYear, Calendar.DECEMBER, 31, 0, 0),
                                        (mFilterCountry != null) ? mFilterCountry.getCode() : null,
                                        null));
                latchTask.countDown();
            }
        });

        // retrieve the gigs that were already added to the database
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                existingGigs.addAll(DataContext.gigListDateInterval(mBand,
                                    DateUtils.dateFromComponents(mFilterYear, Calendar.JANUARY, 1, 0, 0),
                                    DateUtils.dateFromComponents(mFilterYear, Calendar.DECEMBER, 31, 0, 0)));
                latchTask.countDown();
            }
        });

        // compute the difference between the two lists and display those
        new AsyncTask<Void, Integer, List<BandTrackerTourDate>>() {

            @Override
            protected List<BandTrackerTourDate> doInBackground(Void... params) {
                try {
                    latchTask.await();

                    CollectionUtils.filter(newTourDates, new Predicate<BandTrackerTourDate>() {
                        @Override
                        public boolean evaluate(final BandTrackerTourDate newTourDate) {
                            return CollectionUtils.find(existingGigs, new Predicate<Gig>() {
                                @Override
                                public boolean evaluate(Gig existingGig) {
                                    return newTourDate.getStartDate().equals(existingGig.getStartDate());
                                }
                            }) == null;
                        }
                    });

                    return newTourDates;

                } catch (InterruptedException e) {
                    return null;
                }
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

    private class TourDateYearsAdapter extends ArrayAdapter<BandTrackerTourDateYear> {

        public TourDateYearsAdapter(Context context, List<BandTrackerTourDateYear> years) {
            super(context, 0, years);
        }

        @Override
        public View getDropDownView(int position, View convertView, ViewGroup parent) {
            BandTrackerTourDateYear year = getItem(position);

            if (convertView == null) {
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.spinner_item_year, parent, false);
                convertView.setTag(new ViewHolder(convertView));
            }

            ViewHolder holder = (ViewHolder) convertView.getTag();

            holder.lblYear.setText(Integer.toString(year.getYear()));
            holder.lblCount.setText(String.format(getContext().getString(R.string.spinner_year_count), year.getCount()));

            return convertView;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            BandTrackerTourDateYear year = getItem(position);

            if (convertView == null) {
                convertView = LayoutInflater.from(getContext()).inflate(android.R.layout.simple_spinner_item, parent, false);
            }

            TextView label = (TextView) convertView.findViewById(android.R.id.text1);
            label.setText(Integer.toString(year.getYear()));

            return convertView;

        }

        private class ViewHolder {

            public ViewHolder(View view) {
                lblYear  = (TextView) view.findViewById(R.id.lblYear);
                lblCount = (TextView) view.findViewById(R.id.lblCount);
            }

            public TextView lblYear;
            public TextView lblCount;
        }
    }

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
    private ArrayList<BandTrackerTourDateYear>  mYears;

    private Country             mFilterCountry = null;
    private Integer             mFilterYear    = 0;

    private FilterResultsAdapter        mListAdapter;

    private Spinner             pickYear;
    private EditText            editCountry;
    private ImageView           imgCountry;

}
