package be.justcode.bandtracker.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
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
import be.justcode.bandtracker.model.Band_Table;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.utils.BandImageDownloader;

public class MainBandsFragment extends Fragment {

    private static final int REQUEST_BAND   = 4;

    public static MainBandsFragment newInstance() {
        MainBandsFragment fragment = new MainBandsFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main_bands, container, false);

        // setup recycler view
        final RecyclerView rvBands = (RecyclerView) view.findViewById(R.id.listMainBands);

        mListAdapter = new BandsSeenAdapter("");
        rvBands.setAdapter(mListAdapter);
        rvBands.setLayoutManager(new LinearLayoutManager(getActivity()));
        rvBands.setHasFixedSize(true);

        // add band button
        final FloatingActionButton btnBandAdd = (FloatingActionButton) view.findViewById(R.id.btnBandAdd);
        btnBandAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ListSelectionActivity.create(getActivity(), MainBandsFragment.this, ListSelectionBandDelegate.TYPE, REQUEST_BAND, null);
            }
        });


        return view;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_BAND && resultCode == Activity.RESULT_OK) {
            mListAdapter.refresh();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class BandsSeenAdapter extends RecyclerView.Adapter<BandsSeenAdapter.ViewHolder> {

        public BandsSeenAdapter(String pattern) {
            mCursor = DataContext.bandCursor(pattern);
        }

        @Override
        public BandsSeenAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());

            // inflate layout
            View rowView = inflater.inflate(R.layout.row_bands_seen, parent, false);

            // create holder
            return new ViewHolder(rowView);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            Band band = mCursor.getItem(position);

            if (!holder.lblBandName.getText().equals(band.getName())) {
                holder.lblBandName.setText(band.getName());
                BandImageDownloader.thumbnail(band, App.getContext(), holder.imgBand);
                BandImageDownloader.logo(band, App.getContext() , holder.imgLogo);
            }

            holder.ratingBar.setRating((float) band.getAvgRating() / 10.0f);

            int textId = (band.getNumGigs() == 0) ? R.string.band_list_numgigs_none : (band.getNumGigs() == 1 ) ? R.string.band_list_numgigs_single : R.string.band_list_numgigs_multiple;
            holder.lblNumGigs.setText(String.format(getString(textId), band.getNumGigs()));
        }

        @Override
        public int getItemCount() {
            return mCursor.getCount();
        }

        public void refresh() {
            mCursor = DataContext.bandCursor("");
            notifyDataSetChanged();
        }

        public void rowClicked(int position) {
            BandDetailsActivity.showBand(getActivity(), mCursor.getItem(position));
        }

        // view holder
        public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

            public ViewHolder(View view) {
                super(view);

                lblBandName = (TextView) view.findViewById(R.id.lblBandName);
                lblNumGigs  = (TextView) view.findViewById(R.id.lblNumGigs);
                imgBand     = (ImageView) view.findViewById(R.id.imgBand);
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
            TextView    lblNumGigs;
            RatingBar   ratingBar;
            ImageView   imgBand;
            ImageView   imgLogo;
        }

        // member variables
        private FlowCursorList<Band> mCursor;

    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private BandsSeenAdapter mListAdapter;



}
