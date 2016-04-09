package be.justcode.bandtracker.activity;

import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import be.justcode.bandtracker.R;
import be.justcode.bandtracker.clients.DataLoader;
import be.justcode.bandtracker.model.DataContext;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // initialize database
        DataContext.initialize(getApplicationContext());

        // data sync
        DataLoader.downloadDataAsync(getApplicationContext());

        // viewpager
        ViewPager viewPager = (ViewPager) findViewById(R.id.viewPager);
        viewPager.setAdapter(new MainFragmentPagerAdapter(getSupportFragmentManager()));

        // tablayout
        TabLayout tabLayout = (TabLayout) findViewById(R.id.tabContainer);
        tabLayout.setupWithViewPager(viewPager);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // nested classes
    //

    private class MainFragmentPagerAdapter extends FragmentPagerAdapter {

        public MainFragmentPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public int getCount() {
            return pageNames.length;
        }

        @Override
        public Fragment getItem(int position) {
            return pages[position];
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return pageNames[position];
        }

        private Fragment[]      pages = {MainBandsFragment.newInstance()};
        private CharSequence[]  pageNames = {getText(R.string.page_bands)};
    }


}

