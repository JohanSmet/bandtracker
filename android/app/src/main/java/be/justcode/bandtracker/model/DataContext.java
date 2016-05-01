package be.justcode.bandtracker.model;

import android.content.Context;

import com.raizlabs.android.dbflow.list.FlowCursorList;
import com.raizlabs.android.dbflow.sql.language.Delete;
import com.raizlabs.android.dbflow.sql.language.SQLCondition;
import com.raizlabs.android.dbflow.sql.language.SQLite;
import com.raizlabs.android.dbflow.sql.language.Select;
import com.raizlabs.android.dbflow.sql.language.property.PropertyFactory;

import java.util.ArrayList;
import java.util.List;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;
import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;
import be.justcode.bandtracker.utils.FanartTvDownloader;

import static com.raizlabs.android.dbflow.sql.language.Method.count;

public class DataContext
{
    // class interface
    public static void initialize(Context context) {
    }

    // bands
    public static Band bandCreate(BandTrackerBand serverBand) {

        // create band
        Band band = new Band(serverBand);
        band.save();

        // download extra information about the band
        FanartTvDownloader.run(band);

        return band;
    }

    public static void bandDelete(Band band) {
        band.delete();
    }

    public static FlowCursorList<Band> bandCursor(String name) {
        if (!name.isEmpty()) {
            return new FlowCursorList<Band>(true, SQLite.select().from(Band.class).where(Band_Table.name.like("%" + name + "%")).orderBy(Band_Table.avgRating, false));
        } else {
            return new FlowCursorList<Band>(true, SQLite.select().from(Band.class).orderBy(Band_Table.avgRating, false));
        }
    }

    public static List<Band> bandList(String name) {

        return SQLite.select().from(Band.class)
                .where(Band_Table.name.like("%" + name + "%"))
                .orderBy(Band_Table.name, false)
                .queryList();
    }

    public static Band bandFetch(String mbid) {
        return SQLite.select().from(Band.class).where(Band_Table.MBID.eq(mbid)).querySingle();
    }

    // countries
    public static void countryDeleteAll() {
        Delete.table(Country.class);
    }

    public static Country countryCreate(BandTrackerCountry serverCountry) {
        Country country = new Country(serverCountry);
        country.save();
        return country;
    }

    public static Country countryFetch(String code) {
        return new Select().from(Country.class)
                           .where(Country_Table.code.is(code))
                           .querySingle();
    }

    public static List<Country> countryList(String pattern) {
        return new Select().from(Country.class)
                .where(Country_Table.name.like("%" + pattern + "%"))
                .orderBy(Country_Table.name, true)
                .queryList();
    }

    // city
    public static City cityCreate(String name, Country country) {
        City city = new City(name, country);
        city.save();
        return city;
    }

    public static City cityById(long id) {
        return new Select().from(City.class)
                    .where(City_Table.id.is(id))
                    .querySingle();
    }

    public static City cityByName(String name, Country country) {

        // try to fetch an existing city
        City city = new Select().from(City.class)
                .where(City_Table.name.is(name))
                    .and(City_Table.country_code.is(country.getCode()))
                .querySingle();

        // or create a new record
        if (city == null) {
            city = cityCreate(name, country);
        }

        return city;
    }

    public static List<City> cityList(String name, Country country) {

        List<SQLCondition> conds = new ArrayList<SQLCondition>();

        if (!name.isEmpty()) {
            conds.add(City_Table.name.like("%" + name + "%"));
        }

        if (country != null) {
            conds.add(City_Table.country_code.is(country.getCode()));
        }

        return new Select().from(City.class)
                .where().andAll(conds)
                .orderBy(City_Table.name, true)
                .queryList();
    }

    // venue
    public static Venue venueCreate(String name, City city, Country country) {
        Venue venue = new Venue(name, city, country);
        venue.save();
        return venue;
    }

    public static Venue venueById(long id) {
        return new Select().from(Venue.class)
                    .where(Venue_Table.id.is(id))
                    .querySingle();
    }

    public static Venue venueByName(String name, City city, Country country) {

        // try to fetch an existing city
        Venue venue = new Select().from(Venue.class)
                .where(Venue_Table.name.is(name))
                    .and(Venue_Table.city_id.is(city.getId()))
                    .and(Venue_Table.country_code.is(country.getCode()))
                .querySingle();

        // or create a new record
        if (venue == null) {
            venue = venueCreate(name, city, country);
        }

        return venue;
    }

    public static List<Venue> venueList(String name, City city, Country country) {

        List<SQLCondition> conds = new ArrayList<SQLCondition>();

        if (!name.isEmpty()) {
            conds.add(Venue_Table.name.is(name));
        }

        if (city != null) {
            conds.add(Venue_Table.city_id.is(city.getId()));
        }

        if (country != null) {
            conds.add(Venue_Table.country_code.is(country.getCode()));
        }

        return new Select().from(Venue.class)
                .where().andAll(conds)
                .orderBy(Venue_Table.name, true)
                .queryList();
    }

    // gig
    public static FlowCursorList<Gig> gigCursor(Band band) {

        return new FlowCursorList<Gig>(true, SQLite.select().from(Gig.class)
                                                .where(Gig_Table.band_MBID.is(band.getMBID()))
                                                .orderBy(Gig_Table.startDate, false)
                                      );
    }

    public static FlowCursorList<Gig> gigTimelineCursor() {
        return new FlowCursorList<Gig>(true, SQLite.select().from(Gig.class)
                                                .orderBy(Gig_Table.startDate, false)
                                      );
    }

    public static List<Gig> gigList(Band band) {
        return SQLite.select().from(Gig.class)
                    .where(Gig_Table.band_MBID.is(band.getMBID()))
                    .orderBy(Gig_Table.startDate, false)
                    .queryList();
    }

    public static List<Country> gigTop5Countries()
    {
        List<Gig> gigCountries = SQLite.select(Gig_Table.country_code, count(Gig_Table.id).as("total"))
                .from(Gig.class)
                .groupBy(Gig_Table.country_code)
                .orderBy(PropertyFactory.from("total"), false)
                .queryList();

        List<Country> result = new ArrayList<Country>();

        for (Gig gig : gigCountries) {
            result.add(gig.getCountry());

            if (result.size() >= 5)
                break;
        }

        return result;
    }

}

