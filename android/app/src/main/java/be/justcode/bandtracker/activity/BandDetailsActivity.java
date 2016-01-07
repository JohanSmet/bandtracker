package be.justcode.bandtracker.activity;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.utils.BandImageDownloader;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.widget.ImageView;
import android.widget.TextView;

public class BandDetailsActivity extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER = "param_band";

    public static void showBand(Context context, Band band) {
        Intent intent = new Intent(context, BandDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_band_details);

        // read params
        Bundle bundle = getIntent().getExtras();
        mBand = bundle.getParcelable(INTENT_BAND_PARAMETER);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        ab.setTitle(mBand.getName());

        // init fields
        txtBiography = (TextView)  findViewById(R.id.txtBiography);
        imgBand      = (ImageView) findViewById(R.id.imgBand);
        displayBand();

    }

    private void displayBand() {
        txtBiography.setText(Html.fromHtml(mBand.getBiography()));

        BandImageDownloader.run(mBand.getMBID(), this, imgBand);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    Band        mBand;

    TextView    txtBiography;
    ImageView   imgBand;
}
