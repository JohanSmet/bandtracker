package be.justcode.bandtracker.model;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class SQLDatabase extends SQLiteOpenHelper {

    private static final String DATABASE_NAME       = "BandTracker";
    private static final int    DATABASE_VERSION    = 1;

    public  static final String TABLE_BAND              = "BAND_TBL";
    public  static final String COL_BAND_PK             = "_id";
    public  static final String COL_BAND_MBID           = "MBID";
    public  static final String COL_BAND_NAME           = "Name";
    public  static final String COL_BAND_BIOGRAPHY      = "Biography";
    public  static final String COL_BAND_NUM_GIGS       = "NumGigs";
    public  static final String COL_BAND_TOTAL_RATING   = "TotalRating";
    public  static final String COL_BAND_FANART_THUMB   = "FanartThumb";
    public  static final String COL_BAND_FANART_LOGO    = "FanartLogo";

    public SQLDatabase(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        bandCreate(db);
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
        values.put(COL_BAND_TOTAL_RATING,   band.getTotalRating());
        values.put(COL_BAND_FANART_THUMB,   band.getFanartThumbUrl());
        values.put(COL_BAND_FANART_LOGO,    band.getFanartLogoUrl());

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



}
