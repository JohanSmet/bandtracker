package be.justcode.bandtracker.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.google.android.youtube.player.YouTubeInitializationResult;
import com.google.android.youtube.player.YouTubeStandalonePlayer;
import com.google.android.youtube.player.YouTubeThumbnailLoader;
import com.google.android.youtube.player.YouTubeThumbnailView;

import org.parceler.Parcels;

import java.util.ArrayList;
import java.util.List;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.youtube.YoutubeDataClient;
import be.justcode.bandtracker.model.Gig;

public class GigYoutubeActivity extends AppCompatActivity {

    private static String INTENT_GIG = "intent_gig";
    private static String INTENT_SONG = "intent_song";
    private static String INTENT_PARENT = "intent_parent";

    public static void searchYoutube(Context parent, Gig gig, String song) {
        Intent intent = new Intent(parent, GigYoutubeActivity.class);
        intent.putExtra(INTENT_GIG, Parcels.wrap(gig));
        intent.putExtra(INTENT_SONG, song);
        intent.putExtra(INTENT_PARENT, parent.getClass());
        parent.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gig_youtube);

        mApiKey = getString(R.string.youtube_player_key);

        // read params
        Bundle bundle = getIntent().getExtras();
        mGig            = Parcels.unwrap(bundle.getParcelable(INTENT_GIG));
        mSong           = bundle.getString(INTENT_SONG);
        mParentClass    = (Class<Activity>) bundle.getSerializable(INTENT_PARENT);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        if (ab != null) {
            ab.setDisplayHomeAsUpEnabled(true);
        }

        // setup listview
        rvYoutube = (RecyclerView) findViewById(R.id.listYoutube);
        rvYoutube.setLayoutManager(new LinearLayoutManager(this));

        // ask youtube for videos in the background
        new YoutubeSearchTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    @Override
    protected void onStop() {
        super.onStop();

        for (YouTubeThumbnailLoader loader : mLoaders) {
            loader.release();
        }
    }

    @Override
    public Intent getSupportParentActivityIntent() {
        return getParentActivityIntent();
    }

    @Override
    public Intent getParentActivityIntent() {
        Intent intent = new Intent(this, mParentClass);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return intent;
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class YoutubeSearchTask extends AsyncTask<Void, Integer, List<YoutubeDataClient.Video>> {

        @Override
        protected List<YoutubeDataClient.Video> doInBackground(Void... params) {
            return YoutubeDataClient.getInstance().searchVideosForGig(mGig, mSong, 10);
        }

        @Override
        protected void onPostExecute(List<YoutubeDataClient.Video> videos) {
            if (videos != null) {
                YoutubeAdapter listAdapter = new YoutubeAdapter(videos);
                rvYoutube.setAdapter(listAdapter);
            }
        }
    }

    private class YoutubeAdapter extends RecyclerView.Adapter<YoutubeAdapter.ViewHolder>  {

        public YoutubeAdapter(List<YoutubeDataClient.Video> videos) {
            mVideos = videos;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());

            // inflate layout
            View rowView = inflater.inflate(R.layout.row_youtube, parent, false);

            // create holder
            return new ViewHolder(rowView);
        }

        @Override
        public void onBindViewHolder(final ViewHolder holder, int position) {
            final YoutubeDataClient.Video video = mVideos.get(position);

            final YouTubeThumbnailLoader.OnThumbnailLoadedListener thumbnailLoadedListener = new YouTubeThumbnailLoader.OnThumbnailLoadedListener() {
                @Override
                public void onThumbnailLoaded(YouTubeThumbnailView youTubeThumbnailView, String s) {
                    holder.btnYoutube.setVisibility(View.VISIBLE);
                }

                @Override
                public void onThumbnailError(YouTubeThumbnailView youTubeThumbnailView, YouTubeThumbnailLoader.ErrorReason errorReason) {
                }
            };

            holder.btnYoutube.setVisibility(View.INVISIBLE);
            holder.thumbYoutube.initialize(mApiKey, new YouTubeThumbnailView.OnInitializedListener() {
                @Override
                public void onInitializationSuccess(YouTubeThumbnailView youTubeThumbnailView, YouTubeThumbnailLoader youTubeThumbnailLoader) {
                    youTubeThumbnailLoader.setOnThumbnailLoadedListener(thumbnailLoadedListener);
                    youTubeThumbnailLoader.setVideo(video.getId());
                    mLoaders.add(youTubeThumbnailLoader);
                }

                @Override
                public void onInitializationFailure(YouTubeThumbnailView youTubeThumbnailView, YouTubeInitializationResult youTubeInitializationResult) {
                }
            });

            holder.btnYoutube.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = YouTubeStandalonePlayer.createVideoIntent(GigYoutubeActivity.this, mApiKey, video.getId());
                    startActivity(intent);
                }
            });


            holder.lblSongName.setText(video.getTitle());
        }

        @Override
        public int getItemCount() {
            return mVideos.size();
        }

        public class ViewHolder extends RecyclerView.ViewHolder  {

            public ViewHolder(View view) {
                super(view);
                lblSongName  = (TextView) view.findViewById(R.id.lblTitle);
                thumbYoutube = (YouTubeThumbnailView) view.findViewById(R.id.thumbYoutube);
                btnYoutube   =  view.findViewById(R.id.btnYoutube);
            }

            TextView lblSongName;
            View     btnYoutube;
            YouTubeThumbnailView thumbYoutube;
        }

        List<YoutubeDataClient.Video>   mVideos;
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private Gig     mGig;
    private String  mSong;
    private Class   mParentClass;

    private String  mApiKey;
    private List<YouTubeThumbnailLoader>    mLoaders = new ArrayList<>();

    private RecyclerView rvYoutube;

}
