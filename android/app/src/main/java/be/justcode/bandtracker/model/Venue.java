package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.raizlabs.android.dbflow.annotation.ForeignKey;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

@Table(database = AppDatabase.class, allFields = true)
public class Venue extends BaseModel implements Parcelable {

    // construction
    public Venue() {
        id = 0;
        name = "";
        city = null;
        country = null;
        longitude = 0;
        latitude = 0;
    }

    public Venue(String name, City city, Country country) {
        this.name           = name;
        this.city           = city;
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

    public City getCity() {
        return city;
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

    public void setCity(City city) {
        this.city = city;
    }

    public void setCountry(Country country) {
        this.country = country;
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
        parcel.writeParcelable(city, flags);
        parcel.writeParcelable(country, flags);
        parcel.writeDouble(longitude);
        parcel.writeDouble(latitude);
    }

    public Venue(Parcel parcel) {
        id          = parcel.readLong();
        name        = parcel.readString();
        city        = parcel.readParcelable(City.class.getClassLoader());
        country     = parcel.readParcelable(Country.class.getClassLoader());
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
    @PrimaryKey(autoincrement = true)
    private long id;

    private String  name;

    @ForeignKey
    private City    city;

    @ForeignKey
    private Country country;

    private double  longitude;
    private double  latitude;
}
