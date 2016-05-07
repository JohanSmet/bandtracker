package be.justcode.bandtracker.activity;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerTourDateYear;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.BandImageDownloader;
import be.justcode.bandtracker.utils.CountryCache;
import be.justcode.bandtracker.utils.DateUtils;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.raizlabs.android.dbflow.list.FlowCursorList;

import org.parceler.Parcels;

import java.util.ArrayList;
import java.util.List;

public class BandDetailsActivity extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER = "param_band";
    private static final String STATE_BAND = "state_band";

    public static void showBand(Context context, Band band) {
        Intent intent = new Intent(context, BandDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, Parcels.wrap(band));
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_band_details);

        // read state / params
        if (savedInstanceState != null) {
            mBand = Parcels.unwrap(savedInstanceState.getParcelable(STATE_BAND));
        } else {
            Bundle bundle = getIntent().getExtras();
            mBand = Parcels.unwrap(bundle.getParcelable(INTENT_BAND_PARAMETER));
        }

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        ab.setTitle(mBand.getName());

        // init fields
        txtBiography     = (TextView)  findViewById(R.id.txtBiography);
        txtGigListHeader = (TextView)  findViewById(R.id.txtGigListHeader);
        imgBand          = (ImageView) findViewById(R.id.imgBand);
        bandRating       = (RatingBar) findViewById(R.id.bandRating);
        displayBand();

        // recycler view
        final RecyclerView rvGigs = (RecyclerView) findViewById(R.id.listBandGigs);

        mListAdapter = new BandsGigsAdapter();
        rvGigs.setAdapter(mListAdapter);
        rvGigs.setLayoutManager(new LinearLayoutManager(this));
        rvGigs.setHasFixedSize(true);

        // add gig button
        final FloatingActionButton btnGigAdd = (FloatingActionButton) findViewById(R.id.btnGigAdd);
        btnGigAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mTourDateYears != null && !mTourDateYears.isEmpty()) {
                    GigGuidedCreation.run(BandDetailsActivity.this, mBand, mTourDateYears);
                } else {
                    GigDetailsActivity.createNew(BandDetailsActivity.this, mBand);
                }
            }
        });

        // retrieve the years of the available tourdates
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                List<BandTrackerTourDateYear> dates = BandTrackerClient.getInstance().tourDateYearsCount(mBand.getMBID());

                if (dates != null)
                    mTourDateYears = new ArrayList<>(dates);
                else
                    mTourDateYears = null;
            }
        });
    }

    @Override
    protected void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);

        savedInstanceState.putParcelable(STATE_BAND, Parcels.wrap(mBand));
    }

    private void displayBand() {
        txtBiography.setText(Html.fromHtml(mBand.getBiography()));

        switch (mBand.getNumGigs()) {
            case 0 :
                txtGigListHeader.setText(getString(R.string.band_details_giglist_none));
                break;
            case 1 :
                txtGigListHeader.setText(getString(R.string.band_details_giglist_single));
                break;
            default :
                String title = getString(R.string.band_details_giglist_multiple);
                txtGigListHeader.setText(String.format(title, mBand.getNumGigs()));
        }

        BandImageDownloader.thumbnail(mBand, this, imgBand);
        bandRating.setRating((float) mBand.getAvgRating() / 10.0f);
    }

    @Override
    protected void onResume() {
        super.onResume();

        // refresh band information
        mBand = DataContext.bandFetch(mBand.getMBID());
        displayBand();

        // refresh gig list
        mListAdapter.refresh();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsGigsAdapter  extends RecyclerView.Adapter<BandsGigsAdapter.ViewHolder> {

        public BandsGigsAdapter() {
            mCursor  = DataContext.gigCursor(mBand);
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());
            View rowView = inflater.inflate(R.layout.row_band_gig, parent, false);
            return new ViewHolder(rowView);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            Gig gig = mCursor.getItem(position);

            holder.lblLocation.setText(gig.getCityName());
            holder.lblDate.setText(DateUtils.dateToString(gig.getStartDate()));
            holder.ratingBar.setRating(gig.getRating() / 10);

            if (gig.getCountry() != null)
                holder.imgFlag.setImageDrawable(CountryCache.get(BandDetailsActivity.this, gig.getCountry().getCode()).getDrawable());
            else
                holder.imgFlag.setImageDrawable(null);
        }

        @Override
        public int getItemCount() {
            return mCursor.getCount();
        }

        public void rowClicked(int position) {
            GigDetailsActivity.viewExisting(BandDetailsActivity.this, mBand, mCursor.getItem(position) );
        }

        public void refresh() {
            mCursor  = DataContext.gigCursor(mBand);
            notifyDataSetChanged();
        }

        // view holder
        public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

            public ViewHolder(View view) {
                super(view);
                lblLocation = (TextView)  view.findViewById(R.id.lblLocation);
                lblDate     = (TextView)  view.findViewById(R.id.lblDate);
                ratingBar   = (RatingBar) view.findViewById(R.id.ratingBar);
                imgFlag     = (ImageView) view.findViewById(R.id.imgCountryFlag);
                view.setOnClickListener(this);
            }

            @Override
            public void onClick(View v) {
                rowClicked(getAdapterPosition());
            }

            // member variables
            TextView     lblLocation;
            TextView     lblDate;
            RatingBar    ratingBar;
            ImageView    imgFlag;
        };

        // member variables
        private FlowCursorList<Gig> mCursor;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Band        mBand;

    private TextView    txtBiography;
    private TextView    txtGigListHeader;
    private ImageView   imgBand;
    private RatingBar   bandRating;

    private BandsGigsAdapter mListAdapter;

    private ArrayList<BandTrackerTourDateYear> mTourDateYears;
}
