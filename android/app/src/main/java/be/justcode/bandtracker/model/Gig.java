package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.raizlabs.android.dbflow.annotation.ForeignKey;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import java.util.Date;

@Table(database = AppDatabase.class, allFields = true)
public class Gig extends BaseModel implements Parcelable {

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

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeInt(id);
        parcel.writeParcelable(band, flags);
        parcel.writeSerializable(startDate);
        parcel.writeParcelable(country, flags);
        parcel.writeParcelable(city, flags);
        parcel.writeParcelable(venue, flags);
        parcel.writeString(stage);
        parcel.writeInt(supportAct ? 1 : 0);
        parcel.writeInt(rating);
        parcel.writeString(comments);
    }

    public Gig(Parcel parcel) {
        id          = parcel.readInt();
        band        = parcel.readParcelable(Band.class.getClassLoader());
        startDate   = (Date) parcel.readSerializable();
        country     = parcel.readParcelable(Country.class.getClassLoader());
        city        = parcel.readParcelable(City.class.getClassLoader());
        venue       = parcel.readParcelable(Venue.class.getClassLoader());
        stage       = parcel.readString();
        supportAct  = parcel.readInt() == 1;
        rating      = parcel.readInt();
        comments    = parcel.readString();
    }

    public static final Parcelable.Creator<Gig> CREATOR = new Parcelable.Creator<Gig>() {
        public Gig createFromParcel(Parcel in) {
            return new Gig(in);
        }

        public Gig[] newArray(int size) {
            return new Gig[size];
        }
    };

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
