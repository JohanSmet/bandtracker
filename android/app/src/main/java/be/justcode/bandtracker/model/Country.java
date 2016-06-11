package be.justcode.bandtracker.model;

import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

import org.parceler.Parcel;
import org.parceler.Parcel.Serialization;

@Table(database = AppDatabase.class, allFields = true)
@Parcel(value = Serialization.BEAN)
public class Country extends BaseModel {

    // construction
    public Country() {
        code    = "";
        name    = "";
    }

    public Country(BandTrackerCountry serverCountry) {
        code        = serverCountry.getCode();
        name        = serverCountry.getName();
    }

    // getters
    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    // setters
    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    // member variables

    @PrimaryKey
    private String  code;
    private String  name;
}
