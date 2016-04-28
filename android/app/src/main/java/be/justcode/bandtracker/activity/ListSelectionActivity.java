package be.justcode.bandtracker.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Parcelable;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.HashMap;

import be.justcode.bandtracker.R;

public class ListSelectionActivity extends AppCompatActivity {

    private static final String INTENT_DELEGATE_TYPE = "intent_delegate_type";
    private static final String INTENT_PARAMS        = "intent_params";
    private static final String INTENT_PARENT        = "intent_parent";
    private static final String PREF_SEARCH_STRING   = "search_pattern";

    public interface Delegate {
        public int          numberOfSections();
        public String       titleForSection(int section);
        public int          numRowsForSection(int section);
        public int          rowLayout();
        public void         configureRowView(View view, int section, int row);
        public void         filterUpdate(BaseAdapter adapter, String newFilter);
        public Parcelable   selectedRow(int section, int row);
        public String persistenceKey();
    }

    public static void create(Activity parent, String delegateType, int requestCode, HashMap<String, String> params) {
        Intent intent = new Intent(parent, ListSelectionActivity.class);
        intent.putExtra(INTENT_DELEGATE_TYPE, delegateType);
        intent.putExtra(INTENT_PARAMS, params);
        intent.putExtra(INTENT_PARENT, parent.getClass());
        parent.startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_selection);

        // read params
        Bundle bundle = getIntent().getExtras();
        mDelegate       = delegateFactory(bundle.getString(INTENT_DELEGATE_TYPE),(HashMap<String, String>) bundle.getSerializable(INTENT_PARAMS));
        mParentClass    = (Class<Activity>) bundle.getSerializable(INTENT_PARENT);

        // toolbar
        Toolbar toolBar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolBar);

        // actionbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);

        // listview
        mListAdapter = new SelectionListAdapter(this);
        ListView listView = (ListView) findViewById(R.id.listSelection);
        listView.setAdapter(mListAdapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                int[] sectionRow = mListAdapter.positionToSectionRow(position);
                if (mDelegate != null && sectionRow[1] >= 0) {
                    Intent intent = new Intent();
                    intent.putExtra("result", mDelegate.selectedRow(sectionRow[0], sectionRow[1]));
                    setResult(RESULT_OK, intent);
                    finish();
                }
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        final SearchView searchView = new SearchView(getSupportActionBar().getThemedContext());
        final String     defPattern = loadFilterPattern();

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {

            @Override
            public boolean onQueryTextSubmit(String query) {
                return true;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                if (mDelegate != null) {
                    mDelegate.filterUpdate(mListAdapter, newText);
                    saveFilterPattern(newText);
                }
                return true;
            }
        });

        MenuItem item = menu.add("Search")
                .setIcon(R.drawable.ic_search)
                .setActionView(searchView);
        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM | MenuItem.SHOW_AS_ACTION_COLLAPSE_ACTION_VIEW);
        item.expandActionView();
        MenuItemCompat.setOnActionExpandListener(item, new MenuItemCompat.OnActionExpandListener() {
            @Override
            public boolean onMenuItemActionExpand(MenuItem item) {
                return true;
            }

            @Override
            public boolean onMenuItemActionCollapse(MenuItem item) {
                finish();
                return true;
            }
        });

        searchView.setQuery(defPattern, true);

        return super.onCreateOptionsMenu(menu);
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

    private Delegate delegateFactory(String type, HashMap<String, String> params) {
        if (type.equals(ListSelectionCountryDelegate.TYPE))
            return new ListSelectionCountryDelegate(this, params);
        else if (type.equals(ListSelectionCityDelegate.TYPE))
            return new ListSelectionCityDelegate(this, params);
        else if (type.equals(ListSelectionVenueDelegate.TYPE))
            return new ListSelectionVenueDelegate(this, params);
        else
            return null;
    }

    private String loadFilterPattern() {

        if (mDelegate == null || mDelegate.persistenceKey().isEmpty())
            return "";

        SharedPreferences sharedPref = getSharedPreferences(mDelegate.persistenceKey(), Context.MODE_PRIVATE);
        return sharedPref.getString(PREF_SEARCH_STRING, "");
    }

    private void saveFilterPattern(String pattern) {

        if (mDelegate == null || mDelegate.persistenceKey().isEmpty())
            return;

        SharedPreferences sharedPref = getSharedPreferences(mDelegate.persistenceKey(), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(PREF_SEARCH_STRING, pattern);
        editor.commit();
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class SelectionListAdapter extends BaseAdapter {

        SelectionListAdapter(Context context) {
            mContext = context;
        }

        @Override
        public int getCount() {
            int result = 0;

            for (int idx=0; idx < mDelegate.numberOfSections(); ++idx) {
                result += sectionNumRows(idx);
            }

            return result;
        }

        @Override
        public int getViewTypeCount() {
            return 2;
        }

        @Override
        public int getItemViewType(int position) {
            int[] sectionRow = positionToSectionRow(position);

            return (sectionRow[1] >= 0) ? 0 : 1;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public Object getItem(int i) {
            return null;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // inflate the desired layout
            View rowView = convertView;

            if (rowView == null) {
                LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                rowView = inflater.inflate(getItemViewType(position) == 0 ? mDelegate.rowLayout() : R.layout.row_selection_header, parent, false);
            }

            // fill in view
            int[] sectionRow = positionToSectionRow(position);

            if (sectionRow[1] >= 0)
                mDelegate.configureRowView(rowView, sectionRow[0], sectionRow[1]);
            else
                setHeader(rowView, mDelegate.titleForSection(sectionRow[0]));

            return rowView;
        }

        private boolean sectionHasHeader(int section) {
            return !mDelegate.titleForSection(section).isEmpty();
        }
        private int sectionNumRows(int section) {
            int result = mDelegate.numRowsForSection(section);
            if (result > 0 && sectionHasHeader(section))
                ++result;

            return result;
        }

        public int[] positionToSectionRow(int position) {
            int[] result = {0, 0};

            int startPos = 0;
            int nextPos  = sectionNumRows(result[0]);

            while (position >= nextPos && result[0] < mDelegate.numberOfSections()) {
                result[0]++;
                startPos = nextPos;
                nextPos += sectionNumRows(result[0]);
            }

            result[1] = position - startPos - (sectionHasHeader(result[0]) ? 1 : 0);

            return result;
        }

        private void setHeader(View view, String title) {
            ((TextView) view.findViewById(R.id.selectionHeader)).setText(title);
        }



        private final Context mContext;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //

    private SelectionListAdapter    mListAdapter;
    private Delegate                mDelegate;
    private Class                   mParentClass;

}
