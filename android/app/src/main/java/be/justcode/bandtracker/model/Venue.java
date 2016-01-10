package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

public class Venue implements Parcelable {

    // construction
    public Venue() {
        name = "";
        city = "";
        countryCode = "";
        longitude = 0;
        latitude = 0;
    }

    public Venue(String name, String city, String countryCode) {
        this.name           = name;
        this.city           = city;
        this.countryCode    = countryCode;
        this.longitude      = 0;
        this.latitude       = 0;
    }

    // getters
    public String getName() {
        return name;
    }

    public String getCity() {
        return city;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public double getLongitude() {
        return longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    // setters
    public void setName(String name) {
        this.name = name;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(name);
        parcel.writeString(city);
        parcel.writeString(countryCode);
        parcel.writeDouble(longitude);
        parcel.writeDouble(latitude);
    }

    public Venue(Parcel parcel) {
        name        = parcel.readString();
        city        = parcel.readString();
        countryCode = parcel.readString();
        longitude   = parcel.readDouble();
        latitude    = parcel.readDouble();
    }

    public static final Parcelable.Creator<Venue> CREATOR = new Parcelable.Creator<Venue>() {
        public Venue createFromParcel(Parcel in) {
            return new Venue(in);
        }

        @Override
        public Venue[] newArray(int size) { return new Venue[size]; }
    };

    // member variables
    private String name;
    private String city;
    private String countryCode;
    private double longitude;
    private double latitude;
}
