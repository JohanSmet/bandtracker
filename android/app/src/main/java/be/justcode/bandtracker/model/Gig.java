package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Date;

public class Gig  implements Parcelable {

    public Gig() {
        id          = 0;
        bandId      = "";
        startDate   = new Date();
        countryCode = "";
        city        = "";
        venue       = "";
        stage       = "";
        supportAct  = false;
        rating      = 0;
        comments    = "";
    }

    // getters
    public int getId() {
        return id;
    }

    public String getBandId() {
        return bandId;
    }

    public Date getStartDate() {
        return startDate;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public String getCity() {
        return city;
    }

    public String getVenue() {
        return venue;
    }

    public String getStage() {
        return stage;
    }

    public boolean isSupportAct() {
        return supportAct;
    }

    public int getRating() {
        return rating;
    }

    public String getComments() {
        return comments;
    }


    // setters
    public void setId(int id) {
        this.id = id;
    }

    public void setBandId(String bandId) {
        this.bandId = bandId;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public void setVenue(String venue) {
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
        parcel.writeString(bandId);
        parcel.writeSerializable(startDate);
        parcel.writeString(countryCode);
        parcel.writeString(city);
        parcel.writeString(venue);
        parcel.writeString(stage);
        parcel.writeInt(supportAct ? 1 : 0);
        parcel.writeInt(rating);
        parcel.writeString(comments);
    }

    public Gig(Parcel parcel) {
        id          = parcel.readInt();
        bandId      = parcel.readString();
        startDate   = (Date) parcel.readSerializable();
        countryCode = parcel.readString();
        city        = parcel.readString();
        venue       = parcel.readString();
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
    private int     id;
    private String  bandId;
    private Date    startDate;
    private String  countryCode;
    private String  city;
    private String  venue;
    private String  stage;
    private boolean supportAct;
    private int     rating;
    private String  comments;
}
