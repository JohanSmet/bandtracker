package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.raizlabs.android.dbflow.annotation.ForeignKey;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

@Table(database = AppDatabase.class, allFields = true)
public class City extends BaseModel implements Parcelable {

    // construction
    public City() {
        name = "";
        country = null;
        longitude = 0;
        latitude = 0;
    }

    public City(String name, Country country) {
        this.name           = name;
        this.country        = country;
        this.longitude      = 0;
        this.latitude       = 0;
    }

    // getters
    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Country getCountry() {
        return country;
    }

    public double getLongitude() {
        return longitude;
    }

    public double getLatitude() {
        return latitude;
    }

    // setters
    public void setId(long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setCountry(Country country) {
        this.country= country;
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
        parcel.writeLong(id);
        parcel.writeString(name);
        parcel.writeParcelable(country, flags);
        parcel.writeDouble(longitude);
        parcel.writeDouble(latitude);
    }

    public City(Parcel parcel) {
        id          = parcel.readLong();
        name        = parcel.readString();
        country     = parcel.readParcelable(Country.class.getClassLoader());
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
    @PrimaryKey(autoincrement=true)
    private long id;

    private String name;

    @ForeignKey
    private Country country;

    private double longitude;
    private double latitude;
}
