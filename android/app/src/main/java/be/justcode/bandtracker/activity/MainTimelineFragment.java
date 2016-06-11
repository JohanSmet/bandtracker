package be.justcode.bandtracker.activity;


import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.raizlabs.android.dbflow.list.FlowCursorList;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.utils.BandImageDownloader;
import be.justcode.bandtracker.utils.BasicHeaderDecoration;
import be.justcode.bandtracker.utils.CountryCache;
import be.justcode.bandtracker.utils.DateUtils;

public class MainTimelineFragment extends Fragment {

    public static MainTimelineFragment newInstance() {
        MainTimelineFragment fragment = new MainTimelineFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_main_timeline, container, false);

        // setup recycler view
        final RecyclerView rvTimeline = (RecyclerView) view.findViewById(R.id.listMainTimeline);

        mListAdapter = new TimelineAdapter();
        rvTimeline.setAdapter(mListAdapter);
        rvTimeline.setLayoutManager(new LinearLayoutManager(getActivity()));
        rvTimeline.addItemDecoration(new HeaderDecoration(mListAdapter));


        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        mListAdapter.refresh();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class TimelineAdapter extends RecyclerView.Adapter<TimelineAdapter.ViewHolder> {

        public TimelineAdapter() {
            mCursor = DataContext.gigTimelineCursor();
        }

        @Override
        public TimelineAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());

            // inflate layout
            View rowView = inflater.inflate(R.layout.row_timeline, parent, false);

            // create holder
            return new ViewHolder(rowView);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            Gig gig     = mCursor.getItem(position);
            Band band   = gig.getBand();

            if (!holder.lblBandName.getText().equals(band.getName())) {
                holder.lblBandName.setText(band.getName());
                BandImageDownloader.logo(band, App.getContext() , holder.imgLogo);
            }

            holder.ratingBar.setRating((float) gig.getRating() / 10.0f);
            holder.lblLocation.setText(gig.formatLocation());
            holder.lblDate.setText(DateUtils.dateToShortString(gig.getStartDate()));

            if (gig.getCountry() != null)
                holder.imgCountry.setImageDrawable(CountryCache.getFlagDrawable(gig.getCountry().getCode()));
            else
                holder.imgCountry.setImageDrawable(null);
        }

        @Override
        public int getItemCount() {
            return mCursor.getCount();
        }

        public Gig getItem(int position) {
            return mCursor.getItem(position);
        }

        public void refresh() {
            mCursor.refresh();
        }

        public void rowClicked(int position) {
            Gig gig     = mCursor.getItem(position);
            Band band   = gig.getBand();
            GigDetailsActivity.viewExisting(getActivity(), band, gig);
        }

        // view holder
        public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

            public ViewHolder(View view) {
                super(view);

                lblBandName = (TextView) view.findViewById(R.id.lblBandName);
                lblLocation = (TextView) view.findViewById(R.id.lblLocation);
                lblDate     = (TextView) view.findViewById(R.id.lblDate);
                imgCountry  = (ImageView) view.findViewById(R.id.imgCountry);
                imgLogo     = (ImageView) view.findViewById(R.id.imgLogo);
                ratingBar   = (RatingBar) view.findViewById(R.id.ratingBar);

                view.setOnClickListener(this);
            }

            @Override
            public void onClick(View v) {
                rowClicked(getAdapterPosition());
            }

            // member variables
            TextView    lblBandName;
            TextView    lblLocation;
            TextView    lblDate;
            RatingBar   ratingBar;
            ImageView   imgCountry;
            ImageView   imgLogo;
        }

        // member variables
        private FlowCursorList<Gig> mCursor;
    }

    public class HeaderDecoration extends BasicHeaderDecoration {

        public HeaderDecoration(TimelineAdapter adapter) {
            mTimelineAdapter = adapter;
        }

        @Override
        protected View createHeaderView() {
            View headerView = getLayoutInflater(getArguments()).inflate(R.layout.row_timeline_header, null);
            lblYear = (TextView) headerView.findViewById(R.id.lblYear);
            return headerView;
        }

        @Override
        protected void fillHeaderView(View headerView, int position) {
            int year = DateUtils.dateYear(mTimelineAdapter.getItem(position).getStartDate());
            lblYear.setText(Integer.toString(year));
        }

        @Override
        protected boolean needsHeader(int position) {
            if (position == 0) {
                return true;
            }

            Gig prevGig = mTimelineAdapter.getItem(position - 1);
            Gig gig = mTimelineAdapter.getItem(position);

            return DateUtils.dateYear(prevGig.getStartDate()) != DateUtils.dateYear(gig.getStartDate());
        }

        private final TimelineAdapter mTimelineAdapter;

        private TextView        lblYear;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private TimelineAdapter mListAdapter;

}
