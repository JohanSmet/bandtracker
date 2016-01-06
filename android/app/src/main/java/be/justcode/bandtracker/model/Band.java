package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;

public class Band implements Parcelable
{
    // construction
    Band() {
        MBID            = "";
        name            = "";
        biography       = "";
        numGigs         = 0;
        totalRating     = 0;
        fanartThumbUrl  = "";
        fanartLogoUrl   = "";
    }

    Band(BandTrackerBand serverBand) {
        MBID            = serverBand.getMBID();
        name            = serverBand.getName();
        biography       = serverBand.getBiography();
        numGigs         = 0;
        totalRating     = 0;
        fanartThumbUrl  = "";
        fanartLogoUrl   = "";
    }

    // getters
    public String getMBID() {
        return MBID;
    }

    public String getName() {
        return name;
    }

    public String getBiography() {
        return biography;
    }

    public int getNumGigs() {
        return numGigs;
    }

    public int getTotalRating() {
        return totalRating;
    }

    public String getFanartThumbUrl() {
        return fanartThumbUrl;
    }

    public String getFanartLogoUrl() {
        return fanartLogoUrl;
    }

    // setters
    public void setMBID(String MBID) {
        this.MBID = MBID;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public void setNumGigs(int numGigs) {
        this.numGigs = numGigs;
    }

    public void setTotalRating(int totalRating) {
        this.totalRating = totalRating;
    }

    public void setFanartThumbUrl(String fanartThumbUrl) {
        this.fanartThumbUrl = fanartThumbUrl;
    }

    public void setFanartLogoUrl(String fanartLogoUrl) {
        this.fanartLogoUrl = fanartLogoUrl;
    }

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(MBID);
        parcel.writeString(name);
        parcel.writeString(biography);
        parcel.writeInt(numGigs);
        parcel.writeInt(totalRating);
        parcel.writeString(fanartThumbUrl);
        parcel.writeString(fanartLogoUrl);
    }

    public Band(Parcel parcel ) {
        MBID            = parcel.readString();
        name            = parcel.readString();
        biography       = parcel.readString();
        numGigs         = parcel.readInt();
        totalRating     = parcel.readInt();
        fanartThumbUrl  = parcel.readString();
        fanartLogoUrl   = parcel.readString();
    }

    public static final Parcelable.Creator<Band> CREATOR = new Parcelable.Creator<Band>() {
        public Band createFromParcel(Parcel in) {
            return new Band(in);
        }

        public Band[] newArray(int size) {
            return new Band[size];
        }
    };

    // member variables
    private String  MBID;
    private String  name;
    private String  biography;

    private int     numGigs;
    private int     totalRating;

    private String  fanartThumbUrl;
    private String  fanartLogoUrl;
}
