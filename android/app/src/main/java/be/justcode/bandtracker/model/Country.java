package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Base64;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

public class Country implements Parcelable {

    // construction
    public Country() {
        code        = "";
        name        = "";
        flagData = null;
    }

    public Country(BandTrackerCountry serverCountry) {
        code        = serverCountry.getCode();
        name        = serverCountry.getName();
        flagData    = Base64.decode(serverCountry.getFlag(), Base64.DEFAULT);
    }

    // getters
    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public byte[] getFlagData() {
        return flagData;
    }

    // setters
    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setFlagData(byte[] flagData) {
        this.flagData = flagData;
    }

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(code);
        parcel.writeString(name);
        parcel.writeByteArray(flagData);
    }

    public Country(Parcel parcel) {
        code = parcel.readString();
        name = parcel.readString();
        parcel.readByteArray(flagData);
    }

    public static final Parcelable.Creator<Country>  CREATOR = new Parcelable.Creator<Country>() {
        public Country createFromParcel(Parcel in) {
            return new Country(in);
        }

        public Country[] newArray(int size) {
            return new Country[size];
        }
    };

    // member variables
    private String  code;
    private String  name;
    private byte[] flagData;
}
