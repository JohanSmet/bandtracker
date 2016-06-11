package be.justcode.bandtracker.activity;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Parcelable;
import android.util.Log;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.TextView;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.collections4.Predicate;
import org.parceler.Parcels;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerClient;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.DataContext;

public class ListSelectionBandDelegate implements ListSelectionActivity.Delegate  {

    public static final String TYPE                     = "band";
    private static final String SHARED_PREFERENCES_KEY  = "be.justcode.bandtracker.ListSelectionBandDelegate";
    private static final String LOG_TAG                 = "ListSelectionBand";

    ListSelectionBandDelegate(Context context, HashMap<String, String> params) {
    }

    @Override
    public int numberOfSections() {
        return 2;
    }

    @Override
    public String titleForSection(int section) {
        if (section == 1)
            return "Previously used";
        else
            return "New";
    }

    @Override
    public int numRowsForSection(int section) {
        synchronized (this) {
            switch (section) {
                case 0 :
                    return mNewBands != null ? mNewBands.size() : 0;
                default :
                    return mOldBands != null ? mOldBands.size() : 0;
            }
        }
    }

    @Override
    public int rowLayout() {
        return android.R.layout.simple_list_item_1;
    }

    @Override
    public void configureRowView(View view, int section, int row) {
        TextView text = (TextView) view.findViewById(android.R.id.text1);

        if (section == 0) {
            text.setText(mNewBands.get(row).getName());
        } else if (section == 1) {
            text.setText(mOldBands.get(row).getName());
        }
    }

    @Override
    public void  filterUpdate(final BaseAdapter adapter, final String newFilter) {

        if (newFilter.length() < 3) {
            synchronized (this) {
                mOldBands = null;
                mNewBands = null;
            }
            adapter.notifyDataSetChanged();
            return;
        }

        final CountDownLatch latchTask = new CountDownLatch(2);

        // local database
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                mOldBands = DataContext.bandList(newFilter);
                latchTask.countDown();
            }
        });

        // ask server
        AsyncTask.THREAD_POOL_EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                mNewBands = BandTrackerClient.getInstance().findBands(newFilter);
                latchTask.countDown();
            }
        });

        // post-process the results
        new AsyncTask<Void, Void, Void>() {

            @Override
            protected Void doInBackground(Void... unused) {

                try {
                    // wait for fetch tasks to finish
                    latchTask.await();

                    CollectionUtils.filter(mNewBands, new Predicate<BandTrackerBand>() {
                        @Override
                        public boolean evaluate(final BandTrackerBand newBand) {
                            return CollectionUtils.find(mOldBands, new Predicate<Band>() {
                                @Override
                                public boolean evaluate(Band oldBand) {
                                    return oldBand.getMBID().equals(newBand.getMBID());
                                }
                            }) == null;
                        }
                    });

                } catch (InterruptedException e) {
                    Log.d(LOG_TAG, "post-process", e);
                }

                return null;
            }

            @Override
            protected void onPostExecute(Void unused) {
                adapter.notifyDataSetChanged();
            }

        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);


    }

    @Override
    public Parcelable selectedRow(int section, int row) {
        if (section == 0) {
            return Parcels.wrap(DataContext.bandCreate(mNewBands.get(row)));
        } else if (section == 1) {
            return Parcels.wrap(mOldBands.get(row));
        }

        return null;
    }

    @Override
    public String persistenceKey() {
        return SHARED_PREFERENCES_KEY;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private List<Band>              mOldBands;
    private List<BandTrackerBand>   mNewBands;

}
