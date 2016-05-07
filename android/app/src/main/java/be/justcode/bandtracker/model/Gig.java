package be.justcode.bandtracker.model;

import com.raizlabs.android.dbflow.annotation.ForeignKey;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import java.util.Date;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerTourDate;
import be.justcode.bandtracker.utils.CountryCache;

import org.parceler.Parcel;
import org.parceler.Parcel.Serialization;

@Table(database = AppDatabase.class, allFields = true)
@Parcel(Serialization.BEAN)
public class Gig extends BaseModel {

    public Gig() {
        id          = 0;
        band        = null;
        startDate   = new Date();
        country     = null;
        city        = null;
        venue       = null;
        stage       = "";
        supportAct  = false;
        rating      = 0;
        comments    = "";
    }

    public Gig(BandTrackerTourDate tourDate) {
        band        = DataContext.bandFetch(tourDate.getBandId());
        startDate   = tourDate.getStartDate();
        country     = CountryCache.getCountry(tourDate.getCountryCode());
        city        = DataContext.cityByName(tourDate.getCity(), country);
        venue       = DataContext.venueByName(tourDate.getVenue(), city, country);
        stage       = tourDate.getStage();
        supportAct  = tourDate.isSupportAct();
        rating      = 0;
        comments    = "";
    }

    // getters
    public int getId() {
        return id;
    }

    public Band getBand() {
        return band;
    }

    public Date getStartDate() {
        return startDate;
    }

    public Country getCountry() {
        return country;
    }

    public City getCity() {
        return city;
    }

    public Venue getVenue() {
        return venue;
    }

    public String getStage() {
        return stage;
    }

    public boolean getSupportAct() {
        return supportAct;
    }

    public int getRating() {
        return rating;
    }

    public String getComments() {
        return comments;
    }

    public String getCountryName() {
        return (country != null) ? country.getName() : "";
    }

    public String getCityName() {
        return (city != null) ? city.getName() : "";
    }

    public String getVenueName() {
        return (venue != null) ? venue.getName() : "";
    }

    public String formatLocation() {
        String location = "";
        String separator = "";
        boolean venueSet = false;

        if (venue != null) {
            location += separator + venue.getName();
            separator = ",";
            venueSet  = true;
        }

        if (city != null) {
            location += separator + city.getName();
            separator = ",";
        }

        if (!venueSet && country != null) {
            location += separator + country.getName();
        }

        return location;
    }

    // setters
    public void setId(int id) {
        this.id = id;
    }

    public void setBand(Band band) {
        this.band = band;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public void setCountry(Country country) {
        this.country = country;
    }

    public void setCity(City city) {
        this.city = city;
    }

    public void setVenue(Venue venue) {
        this.venue = venue;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public void setSupportAct(boolean supportAct) {
        this.supportAct = supportAct;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    // member variables
    @PrimaryKey(autoincrement = true)
    private int     id;

    @ForeignKey
    private Band    band;

    private Date    startDate;

    @ForeignKey
    private Country country;

    @ForeignKey
    private City    city;

    @ForeignKey
    private Venue   venue;

    private String  stage;
    private boolean supportAct;
    private int     rating;
    private String  comments;
}
