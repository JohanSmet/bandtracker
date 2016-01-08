package be.justcode.bandtracker.utils;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;

import java.util.HashMap;

import be.justcode.bandtracker.model.Country;
import be.justcode.bandtracker.model.DataContext;

public class CountryCache {

    public static CountryDrawable get(Context context, String code) {
        CountryDrawable cd = mCache.get(code);

        if (cd == null) {
            Country country = DataContext.countryFetch(code);
            byte[]  flag = country.getFlagData();
            cd = new CountryDrawable(country, new BitmapDrawable(context.getResources(), BitmapFactory.decodeByteArray(flag, 0, flag.length)));
            mCache.put(code, cd);
        }

        return cd;
    }

    // nested types
    public static class CountryDrawable  {

        public CountryDrawable(Country country, BitmapDrawable drawable) {
            this.mCountry = country;
            this.mDrawable = drawable;
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
    private static HashMap<String, CountryDrawable>    mCache = new HashMap<>();

}
