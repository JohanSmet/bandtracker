package be.justcode.bandtracker.activity;


import android.graphics.Canvas;
import android.graphics.Rect;
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
        rvTimeline.addItemDecoration(new HeaderDecoration(mListAdapter, inflater));


        return view;
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
                holder.imgCountry.setImageDrawable(CountryCache.get(getActivity(), gig.getCountry().getCode()).getDrawable());
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

    public class HeaderDecoration extends RecyclerView.ItemDecoration {

        public HeaderDecoration(TimelineAdapter adapter, LayoutInflater inflater) {
            mTimelineAdapter = adapter;
            mHeaderView = inflater.inflate(R.layout.row_timeline_header, null);
            lblYear = (TextView) mHeaderView.findViewById(R.id.lblYear);
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {

            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) view.getLayoutParams();
            final int position = params.getViewAdapterPosition();

            if (needsHeader(position)) {
                if (mHeaderView.getMeasuredHeight() <= 0) {
                    mHeaderView.measure(View.MeasureSpec.makeMeasureSpec(parent.getMeasuredWidth(), View.MeasureSpec.AT_MOST),
                            View.MeasureSpec.makeMeasureSpec(parent.getMeasuredHeight(), View.MeasureSpec.AT_MOST));
                }
                outRect.set(0, mHeaderView.getMeasuredHeight(), 0, 0);
            }
        }

        @Override
        public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
            super.onDraw(c, parent, state);

            mHeaderView.layout(parent.getLeft(), 0, parent.getRight(), mHeaderView.getMeasuredHeight());

            for (int i = 0; i < parent.getChildCount(); i++) {
                final View rowView = parent.getChildAt(i);
                final int adapterIndex = ((RecyclerView.LayoutParams) rowView.getLayoutParams()).getViewAdapterPosition();

                if (needsHeader(adapterIndex)) {
                    // fill the header
                    int year = DateUtils.dateYear(mTimelineAdapter.getItem(adapterIndex).getStartDate());
                    lblYear.setText(Integer.toString(year));

                    // draw the header in the reserved space above the row
                    c.save();
                    c.clipRect(parent.getLeft(), parent.getTop(), parent.getRight(), rowView.getTop());
                    final float top = rowView.getTop() - mHeaderView.getMeasuredHeight();
                    c.translate(0, top);
                    mHeaderView.draw(c);
                    c.restore();
                }
            }
        }

        private boolean needsHeader(int position) {
            if (position == 0) {
                return true;
            }

            Gig prevGig = mTimelineAdapter.getItem(position - 1);
            Gig gig = mTimelineAdapter.getItem(position);

            return DateUtils.dateYear(prevGig.getStartDate()) != DateUtils.dateYear(gig.getStartDate());
        }

        private final TimelineAdapter mTimelineAdapter;

        private final View            mHeaderView;
        private final TextView        lblYear;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private TimelineAdapter mListAdapter;

}
