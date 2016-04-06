package be.justcode.bandtracker.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.DatePicker;
import android.widget.RatingBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.TimePicker;

import java.util.Date;
import java.util.HashMap;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.model.Band;
import be.justcode.bandtracker.model.City;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;
import be.justcode.bandtracker.model.Gig;
import be.justcode.bandtracker.model.Venue;
import be.justcode.bandtracker.utils.DateUtils;

public class GigDetailsActivity extends AppCompatActivity {

    private static final String INTENT_BAND_PARAMETER = "param_band";
    private static final String INTENT_MODE_PARAMETER = "param_mode";
    private static final String INTENT_GIG_PARAMETER  = "param_gig";

    private static final int PICKER_DATE = 0;
    private static final int PICKER_TIME = 1;

    private static final int REQUEST_COUNTRY = 1;
    private static final int REQUEST_CITY    = 2;
    private static final int REQUEST_VENUE   = 3;

    private static final int MODE_VIEW      = 1;
    private static final int MODE_CREATE    = 2;
    private static final int MODE_EDIT      = 3;

    public static void createNew(Context context, Band band) {
        Intent intent = new Intent(context, GigDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        intent.putExtra(INTENT_MODE_PARAMETER, MODE_CREATE);
        context.startActivity(intent);
    }

    public static void viewExisting(Context context, Band band, Gig gig) {
        Intent intent = new Intent(context, GigDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        intent.putExtra(INTENT_GIG_PARAMETER, gig);
        intent.putExtra(INTENT_MODE_PARAMETER, MODE_VIEW);
        context.startActivity(intent);
    }

    public static void editExisting(Context context, Band band, Gig gig) {
        Intent intent = new Intent(context, GigDetailsActivity.class);
        intent.putExtra(INTENT_BAND_PARAMETER, band);
        intent.putExtra(INTENT_GIG_PARAMETER, gig);
        intent.putExtra(INTENT_MODE_PARAMETER, MODE_EDIT);
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

        // read params
        Bundle bundle = getIntent().getExtras();
        mMode = bundle.getInt(INTENT_MODE_PARAMETER);
        mBand = bundle.getParcelable(INTENT_BAND_PARAMETER);

        // init gig to be shown / edited
        if (mMode == MODE_CREATE) {
            initNewGig();
        } else {
            mGig = bundle.getParcelable(INTENT_GIG_PARAMETER);
        }

        // fields
        mPickerRows[PICKER_DATE] = findViewById(R.id.rowStartDatePicker);
        mPickerRows[PICKER_TIME] = findViewById(R.id.rowStartTimePicker);
        lblStartDate             = (TextView) findViewById(R.id.lblStartDate);
        lblStartTime             = (TextView) findViewById(R.id.lblStartTime);
        pickStartDate            = (DatePicker) findViewById(R.id.pickStartDate);
        pickStartTime            = (TimePicker) findViewById(R.id.pickStartTime);
        editCountry              = (TextView) findViewById(R.id.editCountry);
        editCity                 = (TextView) findViewById(R.id.editCity);
        editVenue                = (TextView) findViewById(R.id.editVenue);
        editStage                = (TextView) findViewById(R.id.editStage);
        toggleSupport            = (Switch) findViewById(R.id.toggleSupport);
        ratingBar                = (RatingBar) findViewById(R.id.ratingBar);
        editComments             = (TextView) findViewById(R.id.editComments);

        initDatePicker(pickStartDate, lblStartDate, mGig.getStartDate());
        initTimePicker(pickStartTime, lblStartTime, mGig.getStartDate());
        uiFieldsSetMode(mMode != MODE_VIEW);

        // initial view setup
        pickerViewsHideAll();
        gigToFields();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_gigdetails_toolbar, menu);
        menuGigEdit = menu.findItem(R.id.action_gig_edit);
        menuGigDelete = menu.findItem(R.id.action_gig_delete);
        menuGigSave = menu.findItem(R.id.action_gig_save);
        uiMenuSetMode(mMode != MODE_VIEW);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case R.id.action_gig_edit:
                changeToEditMode();
                break;

            case R.id.action_gig_delete:
                deleteFromDatabase();
                finish();
                break;

            case R.id.action_gig_save:
                saveToDatabase();
                finish();
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode != RESULT_OK)
            return;

        if (requestCode == REQUEST_COUNTRY) {
            mGig.setCountry((Country) data.getParcelableExtra("result"));
            editCountry.setText(mGig.getCountryName());
        } else if (requestCode == REQUEST_CITY) {
            mGig.setCity((City) data.getParcelableExtra("result"));
            editCity.setText(mGig.getCityName());
        } else if (requestCode == REQUEST_VENUE) {
            mGig.setVenue((Venue) data.getParcelableExtra("result"));
            editVenue.setText(mGig.getVenueName());
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // events
    //

    public void rowStartDatePicker_clicked(View view) {
        if (mMode != MODE_VIEW) {
            pickerViewsToggle(PICKER_DATE);
        }
    }

    public void rowStartTimePicker_clicked(View view) {
        if (mMode != MODE_VIEW) {
            pickerViewsToggle(PICKER_TIME);
        }
    }

    public void editText_clicked(View view) {
        pickerViewsHideAll();

        if (mMode != MODE_VIEW) {
            if (view == editCountry) {
                ListSelectionActivity.create(this, ListSelectionCountryDelegate.TYPE, REQUEST_COUNTRY, null);
            } else if (view == editCity) {
                ListSelectionActivity.create(this, ListSelectionCityDelegate.TYPE, REQUEST_CITY, new HashMap<String, String>() {{
                    put(ListSelectionCityDelegate.PARAM_COUNTRY, (mGig.getCountry() != null) ? mGig.getCountry().getCode() : "");
                }});
            } else if (view == editVenue) {
                ListSelectionActivity.create(this, ListSelectionVenueDelegate.TYPE, REQUEST_VENUE, new HashMap<String, String>() {{
                    put(ListSelectionVenueDelegate.PARAM_COUNTRY, (mGig.getCountry() != null) ? mGig.getCountry().getCode() : "");
                    put(ListSelectionVenueDelegate.PARAM_CITY, (mGig.getCity() != null) ? Long.toString(mGig.getCity().getId()) : "");
                }});
            }
        }
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

    private void changeToEditMode() {
        mMode = MODE_EDIT;
        uiFieldsSetMode(true);
        uiMenuSetMode(true);
    }

    private void uiMenuSetMode(boolean editMode) {
        menuGigEdit.setVisible(!editMode);
        menuGigDelete.setVisible(!editMode);
        menuGigSave.setVisible(editMode);
    }

    private void uiFieldsSetMode(boolean editMode) {
        editStage.setEnabled(editMode);
        editComments.setEnabled(editMode);
        toggleSupport.setEnabled(editMode);
        ratingBar.setEnabled(editMode);
    }

    private void initNewGig() {
        mGig = new Gig();
        mGig.setBand(mBand);
        mGig.setStartDate(new Date());
    }

    private void saveToDatabase() {
        fieldsToGig();
        mGig.save();
        mBand.save();
    }

    private void deleteFromDatabase() {
        mGig.delete();
        mBand.save();
    }

    private void gigToFields() {
        editCountry.setText(mGig.getCountryName());
        editCity.setText(mGig.getCityName());
        editVenue.setText(mGig.getVenueName());
        editStage.setText(mGig.getStage());
        toggleSupport.setChecked(mGig.getSupportAct());
        ratingBar.setRating(mGig.getRating() / 10.0f);
        editComments.setText(mGig.getComments());
    }

    private void fieldsToGig() {
        mGig.setStartDate(DateUtils.dateFromComponents(pickStartDate.getYear(), pickStartDate.getMonth(), pickStartDate.getDayOfMonth(), pickStartTime.getCurrentHour(), pickStartTime.getCurrentMinute()));
        mGig.setStage(editStage.getText().toString());
        mGig.setSupportAct(toggleSupport.isChecked());
        mGig.setRating(Math.round(ratingBar.getRating() * 10.0f));
        mGig.setComments(editComments.getText().toString());
    }

    private void initDatePicker(DatePicker pickStartDate, final TextView lblStartDate, Date date) {

        lblStartDate.setText(DateUtils.dateToString(date));

        pickStartDate.init(DateUtils.dateYear(date), DateUtils.dateMonth(date), DateUtils.dateDay(date), new DatePicker.OnDateChangedListener() {
            @Override
            public void onDateChanged(DatePicker datePicker, int year, int month, int day) {
                lblStartDate.setText(DateUtils.dateToString(DateUtils.dateFromComponents(year, month, day, 0, 0)));
            }
        });
    }

    private void initTimePicker(TimePicker pickStartTime, final TextView lblStartTime, Date date) {

        lblStartTime.setText(DateUtils.timeToString(date));

        pickStartTime.setCurrentHour(DateUtils.dateHour(date));
        pickStartTime.setCurrentMinute(DateUtils.dateMinute(date));
        pickStartTime.setOnTimeChangedListener(new TimePicker.OnTimeChangedListener() {
            @Override
            public void onTimeChanged(TimePicker timePicker, int hour, int minute) {
                lblStartTime.setText(DateUtils.timeToString(DateUtils.dateFromComponents(0, 0, 0, hour, minute)));
            }
        });
    }



    // member variables
    int                 mMode;
    Band                mBand;
    Gig                 mGig;

    private View[]      mPickerRows = new View[2];
    private boolean[]   mPickerEditing = new boolean[2];
    private TextView    lblStartDate;
    private TextView    lblStartTime;
    private DatePicker  pickStartDate;
    private TimePicker  pickStartTime;
    private TextView    editCountry;
    private TextView    editCity;
    private TextView    editVenue;
    private TextView    editStage;
    private Switch      toggleSupport;
    private RatingBar   ratingBar;
    private TextView    editComments;

    private MenuItem    menuGigSave;
    private MenuItem    menuGigEdit;
    private MenuItem    menuGigDelete;
}
