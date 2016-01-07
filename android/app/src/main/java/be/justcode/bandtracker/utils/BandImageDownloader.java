package be.justcode.bandtracker.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.widget.ImageView;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;

public class BandImageDownloader extends AsyncTask<String, Integer, Drawable> {

    public static BandImageDownloader run(String bandId, Context context, ImageView forView) {
        BandImageDownloader task =  new BandImageDownloader(context, forView);
        task.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, bandId);
        return task;
    }

    BandImageDownloader(Context context, ImageView forView) {
        mContext = context;
        mImgView = forView;
    }

    protected Drawable doInBackground(String... params) {
        Bitmap bitmap = BandTrackerClient.getInstance().bandImage(params[0]);

        return new BitmapDrawable(mContext.getResources(), bitmap);
    }

    protected void onPostExecute(Drawable result) {
        mImgView.setImageDrawable(result);
    }

    Context     mContext;
    ImageView   mImgView;

}
