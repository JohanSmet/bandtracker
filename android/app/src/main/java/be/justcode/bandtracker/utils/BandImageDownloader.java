package be.justcode.bandtracker.utils;

import android.content.Context;
import android.os.AsyncTask;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.Band;

public class BandImageDownloader {

    public static void thumbnail(final Band band, final Context context, final ImageView forView) {
        ImageDownloadTask task = new ImageDownloadTask(context, forView);
        task.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, band);
    }

    public static void logo(final Band band, final Context context, final ImageView forView) {

        String url = band.getFanartLogoUrl();

        if (url == null || url.isEmpty()) {
            forView.setImageDrawable(null);
            return;
        }

        Picasso.with(context).load(url)
                .fit()
                .centerInside()
                .into(forView);
    }

    private static class ImageDownloadTask extends AsyncTask<Band, Integer, String> {

        ImageDownloadTask(Context context, ImageView forView) {
            mContext = context;
            mImgView = forView;
        }

        protected String doInBackground(Band... params) {
            final Band band = params[0];

            String url = band.getFanartThumbUrl();

            if (url == null || url.isEmpty())
                url = BandTrackerClient.getInstance().bandImageUrl(band.getMBID());

            return url;
        }

        protected void onPostExecute(String result) {
            Picasso.with(mContext).load(result)
                    .into(mImgView);
        }

        Context mContext;
        ImageView mImgView;
    }
}
