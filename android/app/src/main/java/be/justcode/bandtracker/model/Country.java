package be.justcode.bandtracker.model;

import android.util.Base64;

import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.data.Blob;
import com.raizlabs.android.dbflow.structure.BaseModel;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

import org.parceler.Parcel;
import org.parceler.Parcel.Serialization;
import org.parceler.ParcelConverter;

@Table(database = AppDatabase.class, allFields = true)
@Parcel(value = Serialization.BEAN, converter = Country.CountryParcelConverter.class)
public class Country extends BaseModel {

    // construction
    public Country() {
        code    = "";
        name    = "";
        flag    = null;
    }

    public Country(BandTrackerCountry serverCountry) {
        code        = serverCountry.getCode();
        name        = serverCountry.getName();
        flag        = new Blob(Base64.decode(serverCountry.getFlag(), Base64.DEFAULT));
    }

    // getters
    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public Blob getFlag() {
        return flag;
    }

    public byte[] getFlagData() {
        return flag.getBlob();
    }

    // setters
    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setFlagData(byte[] flagData) {
        this.flag = new Blob(flagData);
    }

    public void setFlag(Blob flag) {
        this.flag = flag;
    }

    // nested types
    public static class CountryParcelConverter implements ParcelConverter<Country> {
        @Override
        public void toParcel(Country input, android.os.Parcel parcel) {
            parcel.writeString(input.code);
            parcel.writeString(input.name);
            parcel.writeInt(input.flag.getBlob().length);
            parcel.writeByteArray(input.flag.getBlob());
        }

        @Override
        public Country fromParcel(android.os.Parcel parcel) {
            Country country = new Country();
            country.code = parcel.readString();
            country.name = parcel.readString();
            byte[] flagData = new byte[parcel.readInt()];
            parcel.readByteArray(flagData);
            country.flag = new Blob(flagData);

            return country;
        }
    }

    // member variables
    @PrimaryKey
    private String  code;

    private String  name;
    private Blob    flag;
}
