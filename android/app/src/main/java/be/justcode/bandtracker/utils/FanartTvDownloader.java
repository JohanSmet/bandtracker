package be.justcode.bandtracker.utils;

import android.os.AsyncTask;

import be.justcode.bandtracker.clients.fanart.tv.FanartTvClient;
import be.justcode.bandtracker.model.Band;

public class FanartTvDownloader extends AsyncTask<String, Integer, FanartTvClient.FanartTvBandUrls> {

    public static FanartTvDownloader run(Band band) {
        FanartTvDownloader task =  new FanartTvDownloader(band);
        task.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, band.getMBID());
        return task;
    }

    FanartTvDownloader(Band band) {
        mBand    = band;
    }

    protected FanartTvClient.FanartTvBandUrls doInBackground(String... params) {
        return FanartTvClient.getInstance().getBandUrls(params[0]);
    }

    protected void onPostExecute(FanartTvClient.FanartTvBandUrls result) {
        if (result != null && result.bandThumbnailUrl != null) {
            mBand.setFanartThumbUrl(result.bandThumbnailUrl);
        }

        if (result != null && result.bandLogoUrl != null) {
            mBand.setFanartLogoUrl(result.bandLogoUrl);
        }

        mBand.save();
    }

    final Band   mBand;
}
