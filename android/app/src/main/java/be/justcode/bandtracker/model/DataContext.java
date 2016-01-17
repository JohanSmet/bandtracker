package be.justcode.bandtracker.model;

import android.content.Context;
import android.database.Cursor;

import java.util.ArrayList;
import java.util.List;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

public class DataContext
{
    // class interface
    public static void initialize(Context context) {
        mDb = new SQLDatabase(context);
    }

    // bands
    public static Band bandCreate(BandTrackerBand serverBand) {

        // create in memory
        Band band = new Band(serverBand);

        // create in database
        mDb.getWritableDatabase().insert(mDb.TABLE_BAND, null, mDb.bandToContentValues(band));

        return band;
    }

    public static void bandDelete(Band band) {
        mDb.getWritableDatabase().delete(mDb.TABLE_BAND, mDb.COL_BAND_MBID + " = ?", new String[]{band.getMBID()});
    }

    public static Cursor bandList(String name) {

        // build SQL query
        String query = "select * from " + mDb.TABLE_BAND;

        if (!name.isEmpty()) {
            query = query + " where instr(lower(" + mDb.COL_BAND_NAME + ")," + name.toLowerCase() + ") <> 0";
        }

        query = query + " order by " + mDb.COL_BAND_TOTAL_RATING + " / nullif(" + mDb.COL_BAND_NUM_GIGS + ",0), " + mDb.COL_BAND_NAME;

        // execute
        return mDb.getReadableDatabase().rawQuery(query, null);
    }

    public static Band bandFromCursor(Cursor c) {
        return mDb.bandFromCursor(c);
    }

    // countries
    public static void countryDeleteAll() {
        mDb.getWritableDatabase().delete(mDb.TABLE_COUNTRY, null, null);
    }

    public static Country countryCreate(BandTrackerCountry serverCountry) {
        Country country = new Country(serverCountry);
        mDb.getWritableDatabase().insert(mDb.TABLE_COUNTRY, null, mDb.countryToContentValues(country));
        return country;
    }

    public static Country countryFetch(String code) {
        // build SQL query
        String query = "select * from " + mDb.TABLE_COUNTRY + " where " +
                            mDb.COL_COUNTRY_CODE + " = ?" ;

        // execute
        Cursor c = mDb.getReadableDatabase().rawQuery(query, new String[] {code});

        // convert
        if (c != null) {
            c.moveToFirst();
            return mDb.countryFromCursor(c);
        }
        else
            return null;
    }

    public static List<Country> countryList(String pattern) {
        // build SQL query
        String query = "select * from " + mDb.TABLE_COUNTRY + " where " +
                            " instr(lower(" + mDb.COL_COUNTRY_NAME + "), \"" + pattern.toLowerCase() + "\") <> 0 " +
                       "order by " + mDb.COL_COUNTRY_NAME;

        // execute
        ArrayList<Country> results = new ArrayList<>();

        Cursor c = mDb.getReadableDatabase().rawQuery(query, null);
        c.moveToFirst();

        while (!c.isAfterLast()) {
            results.add(mDb.countryFromCursor(c));
            c.moveToNext();
        }

        c.close();

        return results;
    }

    // city
    public static City cityCreate(City city) {
        mDb.getWritableDatabase().insert(mDb.TABLE_CITY, null, mDb.cityToContentValues(city));
        return city;
    }

    public static List<City> cityList(String name, String countryCode) {
        // build SQL query
        String query = "select * from " + mDb.TABLE_CITY;
        String sepa  = " where";

        if (!name.isEmpty()) {
            query = query + sepa +  " instr(lower(" + mDb.COL_CITY_NAME + "),\"" + name.toLowerCase() + "\") <> 0";
            sepa  = " and";
        }
        if (!countryCode.isEmpty()) {
            query = query + sepa + " " + mDb.COL_CITY_COUNTRY_CODE + " = \"" + countryCode + "\"";
            sepa  = " and";
        }

        query = query + " order by " + mDb.COL_CITY_NAME;

        // execute
        ArrayList<City> results = new ArrayList<>();

        Cursor c = mDb.getReadableDatabase().rawQuery(query, null);
        c.moveToFirst();

        while (!c.isAfterLast()) {
            results.add(mDb.cityFromCursor(c));
            c.moveToNext();
        }

        c.close();

        return results;
    }

    // venue
    public static Venue venueCreate(Venue venue) {
        mDb.getWritableDatabase().insert(mDb.TABLE_VENUE, null, mDb.venueToContentValues(venue));
        return venue;
    }

    public static List<Venue> venueList(String name, String city, String countryCode) {
        // build SQL query
        String query = "select * from " + mDb.TABLE_VENUE;
        String sepa  = " where ";

        if (!name.isEmpty()) {
            query = query + sepa +  "instr(lower(" + mDb.COL_VENUE_NAME + "),\"" + name.toLowerCase() + "\") <> 0";
            sepa  = " and ";
        }

        if (!city.isEmpty()) {
            query = query + sepa + mDb.COL_VENUE_CITY + " = \"" + city+ "\"";
            sepa  = " and ";
        }

        if (!countryCode.isEmpty()) {
            query = query + sepa + mDb.COL_VENUE_COUNTRY_CODE + " = \"" + countryCode + "\"";
            sepa  = " and ";
        }

        query = query + " order by " + mDb.COL_VENUE_NAME;

        // execute
        ArrayList<Venue> results = new ArrayList<>();

        Cursor c = mDb.getReadableDatabase().rawQuery(query, null);
        c.moveToFirst();

        while (!c.isAfterLast()) {
            results.add(mDb.venueFromCursor(c));
            c.moveToNext();
        }

        c.close();

        return results;
    }

    // gig
    public static Gig createGig(Gig gig) {
        mDb.getWritableDatabase().insert(mDb.TABLE_GIG, null, mDb.gigToContentValues(gig));
        return gig;
    }

    // member variables
    private static SQLDatabase  mDb;
}

