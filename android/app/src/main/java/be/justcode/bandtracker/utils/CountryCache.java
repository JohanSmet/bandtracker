package be.justcode.bandtracker.utils;

import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;

import java.util.HashMap;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.CountryFlag;
import be.justcode.bandtracker.model.DataContext;

public class CountryCache {

    public static Country getCountry(String code) {
        CountryData cd = get(code);
        return cd.getCountry();
    }

    public static BitmapDrawable getFlagDrawable(String code) {
        CountryData cd = get(code);
        return cd.getDrawable();
    }

    public static String getCountryName(String code) {
        CountryData cd = get(code);

        if (cd != null && cd.getCountry() != null) {
            return cd.getCountry().getName();
        }

        return "?";
    }

    private static CountryData get(String code) {
        CountryData cd = mCache.get(code);

        if (cd == null) {
            cd = new CountryData(DataContext.countryFetch(code), DataContext.countryFlagFetch(code));
            mCache.put(code, cd);
        }

        return cd;
    }

    // nested types
    private static class CountryData {

        public CountryData(Country country, CountryFlag flag) {
            this.mCountry = country;

            byte[] flagData = flag.getFlagData();
            this.mDrawable = new BitmapDrawable(App.getContext().getResources(), BitmapFactory.decodeByteArray(flagData, 0, flagData.length));
        }

        public Country getCountry() {
            return mCountry;
        }

        public BitmapDrawable getDrawable() {
            return mDrawable;
        }

        private Country         mCountry;
        private BitmapDrawable  mDrawable;
    }

    // member variables
    private static HashMap<String, CountryData>    mCache = new HashMap<>();

}
