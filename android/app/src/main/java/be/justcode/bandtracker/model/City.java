package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

public class City implements Parcelable {

    // construction
    public City() {
        name = "";
        countryCode = "";
        longitude = 0;
        latitude = 0;
    }

    public City(String name, String countryCode) {
        this.name           = name;
        this.countryCode    = countryCode;
        this.longitude      = 0;
        this.latitude       = 0;
    }

    // getters
    public String getName() {
        return name;
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
        parcel.writeString(countryCode);
        parcel.writeDouble(longitude);
        parcel.writeDouble(latitude);
    }

    public City(Parcel parcel) {
        name        = parcel.readString();
        countryCode = parcel.readString();
        longitude   = parcel.readDouble();
        latitude    = parcel.readDouble();
    }

    public static final Parcelable.Creator<City> CREATOR = new Parcelable.Creator<City>() {
        public City createFromParcel(Parcel in) {
            return new City(in);
        }

        @Override
        public City[] newArray(int size) { return new City[size]; }
    };

    // member variables
    private String name;
    private String countryCode;
    private double longitude;
    private double latitude;
}
