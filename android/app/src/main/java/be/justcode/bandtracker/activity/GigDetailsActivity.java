package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.View;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;

public class GigDetailsActivity extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER = "param_band";

    private static final int PICKER_DATE = 0;
    private static final int PICKER_TIME = 1;

    public static void createNew(Context context, Band band) {
        Intent intent = new Intent(context, GigDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gig_details);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);

        // fields
        mPickerRows[PICKER_DATE] = findViewById(R.id.rowStartDatePicker);
        mPickerRows[PICKER_TIME] = findViewById(R.id.rowStartTimePicker);

        // initial view setup
        pickerViewsHideAll();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // events
    //

    public void rowStartDatePicker_clicked(View view) {
        pickerViewsToggle(PICKER_DATE);
    }

    public void rowStartTimePicker_clicked(View view) {
        pickerViewsToggle(PICKER_TIME);
    }

    public void editText_clicked(View view) {
        pickerViewsHideAll();
        ListSelectionActivity.create(this, ListSelectionCountryDelegate.TYPE);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //

    private void pickerViewsHideAll() {
        for (int idx=0; idx < mPickerRows.length; ++idx) {
            mPickerRows[idx].setVisibility(View.GONE);
            mPickerEditing[idx] = false;
        }
    }

    private void pickerViewsToggle(int idx) {
        if (!mPickerEditing[idx]) {
            pickerViewsHideAll();
            mPickerEditing[idx] = true;
            mPickerRows[idx].setVisibility(View.VISIBLE);
        } else {
            pickerViewsHideAll();
        }
    }

    // member variables
    private View[]      mPickerRows = new View[2];
    private boolean[]   mPickerEditing = new boolean[2];
}
