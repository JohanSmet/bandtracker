package be.justcode.bandtracker.model;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class SQLDatabase extends SQLiteOpenHelper {

    private static final String DATABASE_NAME       = "BandTracker";
    private static final int    DATABASE_VERSION    = 1;

    public static final String TABLE_BAND              = "BAND_TBL";
    public static final String COL_BAND_PK             = "_id";
    public static final String COL_BAND_MBID           = "MBID";
    public static final String COL_BAND_NAME           = "Name";
    public static final String COL_BAND_BIOGRAPHY      = "Biography";
    public static final String COL_BAND_NUM_GIGS       = "NumGigs";
    public static final String COL_BAND_TOTAL_RATING   = "TotalRating";
    public static final String COL_BAND_FANART_THUMB   = "FanartThumb";
    public static final String COL_BAND_FANART_LOGO    = "FanartLogo";

    public static final String TABLE_COUNTRY           = "COUNTRY_TBL";
    public static final String COL_COUNTRY_PK          = "_id";
    public static final String COL_COUNTRY_CODE        = "code";
    public static final String COL_COUNTRY_NAME        = "name";
    public static final String COL_COUNTRY_FLAG        = "flag";

    public static final String TABLE_CITY              = "CITY_TBL";
    public static final String COL_CITY_PK             = "_id";
    public static final String COL_CITY_NAME           = "name";
    public static final String COL_CITY_COUNTRY_CODE   = "countryCode";
    public static final String COL_CITY_LONGITUDE      = "longitude";
    public static final String COL_CITY_LATITUDE       = "latitude";

    public static final String TABLE_VENUE             = "VENUE_TBL";
    public static final String COL_VENUE_PK            = "_id";
    public static final String COL_VENUE_NAME          = "name";
    public static final String COL_VENUE_CITY          = "city";
    public static final String COL_VENUE_COUNTRY_CODE  = "countryCode";
    public static final String COL_VENUE_LONGITUDE     = "longitude";
    public static final String COL_VENUE_LATITUDE      = "latitude";

    public SQLDatabase(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        bandCreate(db);
        countryCreate(db);
        cityCreate(db);
        venueCreate(db);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // bands
    //

    private void bandCreate(SQLiteDatabase db) {
        // create table
        db.execSQL("create table " + TABLE_BAND + "(" +
                        COL_BAND_PK + " integer primary key, " +
                        COL_BAND_MBID + " nchar(36), " +
                        COL_BAND_NAME + " text, " +
                        COL_BAND_BIOGRAPHY + " text, " +
                        COL_BAND_NUM_GIGS + " integer, " +
                        COL_BAND_TOTAL_RATING + " integer, " +
                        COL_BAND_FANART_THUMB + " text, " +
                        COL_BAND_FANART_LOGO + " text " +
                    ")");

        // unique index on MBID
        db.execSQL("create unique index BANDS_IX1 on " + TABLE_BAND + "(" + COL_BAND_MBID + ")");
    }

    public ContentValues bandToContentValues(Band band) {
        ContentValues values = new ContentValues();

        values.put(COL_BAND_MBID,           band.getMBID());
        values.put(COL_BAND_NAME,           band.getName());
        values.put(COL_BAND_BIOGRAPHY,      band.getBiography());
        values.put(COL_BAND_NUM_GIGS,       band.getNumGigs());
        values.put(COL_BAND_TOTAL_RATING, band.getTotalRating());
        values.put(COL_BAND_FANART_THUMB, band.getFanartThumbUrl());
        values.put(COL_BAND_FANART_LOGO, band.getFanartLogoUrl());

        return values;
    }

    public Band bandFromCursor(Cursor c) {
        Band band = new Band();

        band.setMBID(c.getString(c.getColumnIndex(COL_BAND_MBID)));
        band.setName(c.getString(c.getColumnIndex(COL_BAND_NAME)));
        band.setBiography(c.getString(c.getColumnIndex(COL_BAND_BIOGRAPHY)));
        band.setNumGigs(c.getInt(c.getColumnIndex(COL_BAND_NUM_GIGS)));
        band.setTotalRating(c.getInt(c.getColumnIndex(COL_BAND_TOTAL_RATING)));
        band.setFanartThumbUrl(c.getString(c.getColumnIndex(COL_BAND_FANART_THUMB)));
        band.setFanartLogoUrl(c.getString(c.getColumnIndex(COL_BAND_FANART_LOGO)));

        return band;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // country
    //

    private void countryCreate(SQLiteDatabase db) {
        // create table
        db.execSQL("create table " + TABLE_COUNTRY + "(" +
                        COL_COUNTRY_PK + " integer primary key, " +
                        COL_COUNTRY_CODE + " nchar(4), " +
                        COL_COUNTRY_NAME + " text, " +
                        COL_COUNTRY_FLAG + " blob " +
                   ")");

        // unique index on code
        db.execSQL("create unique index COUNTRY_IX1 on " + TABLE_COUNTRY + "(" + COL_COUNTRY_CODE + ")");
    }

    public ContentValues countryToContentValues(Country country) {
        ContentValues values = new ContentValues();

        values.put(COL_COUNTRY_CODE, country.getCode());
        values.put(COL_COUNTRY_NAME, country.getName());
        values.put(COL_COUNTRY_FLAG, country.getFlagData());

        return values;
    }

    public Country countryFromCursor(Cursor c) {
        Country country = new Country();

        country.setCode(c.getString(c.getColumnIndex(COL_COUNTRY_CODE)));
        country.setName(c.getString(c.getColumnIndex(COL_COUNTRY_NAME)));
        country.setFlagData(c.getBlob(c.getColumnIndex(COL_COUNTRY_FLAG)));

        return country;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // city
    //

    private void cityCreate(SQLiteDatabase db) {
        // create table
        db.execSQL("create table " + TABLE_CITY + "(" +
                        COL_CITY_PK + " integer primary key, " +
                        COL_CITY_NAME + " text, " +
                        COL_CITY_COUNTRY_CODE + " text, " +
                        COL_CITY_LONGITUDE + " real, " +
                        COL_CITY_LATITUDE + " real " +
                   ")");
    }

    public ContentValues cityToContentValues(City city) {
        ContentValues values = new ContentValues();

        values.put(COL_CITY_NAME,           city.getName());
        values.put(COL_CITY_COUNTRY_CODE,   city.getCountryCode());
        values.put(COL_CITY_LONGITUDE,      city.getLongitude());
        values.put(COL_CITY_LATITUDE, city.getLatitude());

        return values;
    }

    public City cityFromCursor(Cursor c) {
        City city = new City();

        city.setName(c.getString(c.getColumnIndex(COL_CITY_NAME)));
        city.setCountryCode(c.getString(c.getColumnIndex(COL_CITY_COUNTRY_CODE)));
        city.setLongitude(c.getDouble(c.getColumnIndex(COL_CITY_LONGITUDE)));
        city.setLatitude(c.getDouble(c.getColumnIndex(COL_CITY_LATITUDE)));

        return city;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // venue
    //

    private void venueCreate(SQLiteDatabase db) {
        // create table
        db.execSQL("create table " + TABLE_VENUE + "(" +
                COL_VENUE_PK + " integer primary key, " +
                COL_VENUE_NAME + " text, " +
                COL_VENUE_CITY + " text, " +
                COL_VENUE_COUNTRY_CODE + " text, " +
                COL_VENUE_LONGITUDE + " real, " +
                COL_VENUE_LATITUDE + " real " +
                ")");
    }

    public ContentValues venueToContentValues(Venue venue) {
        ContentValues values = new ContentValues();

        values.put(COL_VENUE_NAME,          venue.getName());
        values.put(COL_VENUE_CITY,          venue.getCity());
        values.put(COL_VENUE_COUNTRY_CODE,  venue.getCountryCode());
        values.put(COL_VENUE_LONGITUDE,     venue.getLongitude());
        values.put(COL_VENUE_LATITUDE,      venue.getLatitude());

        return values;
    }

    public Venue venueFromCursor(Cursor c) {
        Venue venue = new Venue();

        venue.setName(c.getString(c.getColumnIndex(COL_VENUE_NAME)));
        venue.setCity(c.getString(c.getColumnIndex(COL_VENUE_CITY)));
        venue.setCountryCode(c.getString(c.getColumnIndex(COL_VENUE_COUNTRY_CODE)));
        venue.setLongitude(c.getDouble(c.getColumnIndex(COL_VENUE_LONGITUDE)));
        venue.setLatitude(c.getDouble(c.getColumnIndex(COL_VENUE_LATITUDE)));

        return venue;
    }
}
