package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import org.parceler.Parcels;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.setlist.fm.SetlistFmClient;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.BandImageDownloader;
import be.justcode.bandtracker.utils.BasicHeaderDecoration;
import be.justcode.bandtracker.utils.DateUtils;

public class GigSetlistActivity extends AppCompatActivity {

    private static String INTENT_GIG_PARAMETER = "param_gig";
    private static String STATE_GIG = "state_gig";

    public static void viewSetlist(Context context, Gig gig) {
        Intent intent = new Intent(context, GigSetlistActivity.class);
        intent.putExtra(INTENT_GIG_PARAMETER, Parcels.wrap(gig));
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gig_setlist);

        // read params / state
        if (savedInstanceState != null) {
            mGig = Parcels.unwrap(savedInstanceState.getParcelable(STATE_GIG));
        } else {
            Bundle bundle = getIntent().getExtras();
            mGig = Parcels.unwrap(bundle.getParcelable(INTENT_GIG_PARAMETER));
        }

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        ab.setTitle(getString(R.string.setlist_title));

        // fields
        lblLocation = (TextView) findViewById(R.id.lblLocation);
        lblDate     = (TextView) findViewById(R.id.lblDate);
        lblNotFound = (TextView) findViewById(R.id.lblSetlistNotFound);
        imgLogo     = (ImageView) findViewById(R.id.imgLogo);

        lblLocation.setText(mGig.formatLocation());
        lblDate.setText(DateUtils.dateToString(mGig.getStartDate()));
        BandImageDownloader.logo(mGig.getBand(), App.getContext(), imgLogo);

        // setup listview
        rvSetlist = (RecyclerView) findViewById(R.id.listSetlist);
        rvSetlist.setLayoutManager(new LinearLayoutManager(this));

        // fetch the setlist
        new SetlistFmDownloader().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, mGig);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putParcelable(STATE_GIG, Parcels.wrap(mGig));
    }

    public void pnlFooter_clicked(View view) {
        if (mUrl != null && !mUrl.isEmpty()) {
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(mUrl));
            startActivity(browserIntent);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class SetlistFmDownloader extends AsyncTask<Gig, Integer, SetlistFmClient.Setlist> {

        @Override
        protected SetlistFmClient.Setlist doInBackground(Gig... params) {
            final Gig gig = params[0];
            return SetlistFmClient.getInstance().searchSetlist(gig);
        }

        @Override
        protected void onPostExecute(SetlistFmClient.Setlist setlist) {
            if (setlist != null) {
                SetlistAdapter listAdapter = new SetlistAdapter(setlist);
                rvSetlist.setAdapter(listAdapter);
                rvSetlist.addItemDecoration(new SetlistHeaderDecoration(listAdapter));
                mUrl = setlist.getUrl();
            } else {
                rvSetlist.setVisibility(View.INVISIBLE);
                lblNotFound.setVisibility(View.VISIBLE);
            }
        }
    }

    private class SetlistAdapter extends RecyclerView.Adapter<SetlistAdapter.ViewHolder> {

        public SetlistAdapter(SetlistFmClient.Setlist setlist) {
            mSetlist = setlist;
        }

        @Override
        public SetlistAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());

            // inflate layout
            View rowView = inflater.inflate(android.R.layout.simple_list_item_1, parent, false);

            // create holder
            return new ViewHolder(rowView);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            holder.lblSongName.setText(String.format("%d.  %s", position + 1, getItem(position)));
        }

        @Override
        public int getItemCount() {
            int totalCount = 0;

            for (SetlistFmClient.SetlistPart part : mSetlist.getSetlistParts()) {
                totalCount += part.getSongs().size();
            }

            return totalCount;
        }

        public String getItem(int position) {
            int runningCount = 0;

            for (SetlistFmClient.SetlistPart part : mSetlist.getSetlistParts()) {
                if (position < runningCount + part.getSongs().size()) {
                    return part.getSongs().get(position - runningCount);
                }

                runningCount += part.getSongs().size();
            }

            return null;
        }

        public class SongIndex {
            SetlistFmClient.SetlistPart setlistPart;
            int                         partPosition;
        }

        public SongIndex indexFromPosition(int position) {

            int runningCount = 0;

            for (SetlistFmClient.SetlistPart part : mSetlist.getSetlistParts()) {
                if (position < runningCount + part.getSongs().size()) {
                    SongIndex index = new SongIndex();
                    index.setlistPart  = part;
                    index.partPosition = position - runningCount;
                    return index;
                }

                runningCount += part.getSongs().size();
            }

            return null;
        }

        public void rowClicked(int position) {
            String song = getItem(position);
            GigYoutubeActivity.searchYoutube(GigSetlistActivity.this, mGig, song);
        }

        // view holder
        public class ViewHolder extends RecyclerView.ViewHolder {

            public ViewHolder(View view) {
                super(view);
                lblSongName = (TextView) view.findViewById(android.R.id.text1);

                view.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        rowClicked(getAdapterPosition());
                    }
                });
            }

            // member variables
            TextView lblSongName;
        }

        // member variables
        SetlistFmClient.Setlist     mSetlist;
    }

    public class SetlistHeaderDecoration extends BasicHeaderDecoration {

        SetlistHeaderDecoration(SetlistAdapter adapter) {
            mAdapter = adapter;
        }

        @Override
        protected boolean needsHeader(int position) {
            SetlistAdapter.SongIndex index = mAdapter.indexFromPosition(position);
            return index != null && index.partPosition == 0 && index.setlistPart.getName() != null && !index.setlistPart.getName().isEmpty();
        }

        @Override
        protected View createHeaderView() {
            View header = getLayoutInflater().inflate(R.layout.row_setlist_header, null);
            lblName = (TextView) header.findViewById(R.id.lblName);
            return header;
        }

        @Override
        protected void fillHeaderView(View headerView, int position) {
            SetlistAdapter.SongIndex index = mAdapter.indexFromPosition(position);
            lblName.setText(index.setlistPart.getName());
        }

        TextView        lblName;
        SetlistAdapter  mAdapter;
    }



    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Gig mGig;
    String      mUrl = "";

    private RecyclerView rvSetlist;
    private TextView     lblLocation;
    private TextView     lblDate;
    private TextView     lblNotFound;
    private ImageView    imgLogo;
}
