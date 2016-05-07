package be.justcode.bandtracker.model;

import com.raizlabs.android.dbflow.annotation.ForeignKey;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import org.parceler.Parcel;
import org.parceler.Parcel.Serialization;

@Table(database = AppDatabase.class, allFields = true)
@Parcel(Serialization.BEAN)
public class City extends BaseModel {

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

    // member variables
    @PrimaryKey(autoincrement=true)
    private long id;

    private String name;

    @ForeignKey
    private Country country;

    private double longitude;
    private double latitude;
}
