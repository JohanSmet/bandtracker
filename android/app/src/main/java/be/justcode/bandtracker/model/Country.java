package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Base64;

import com.raizlabs.android.dbflow.annotation.Column;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.data.Blob;
import com.raizlabs.android.dbflow.structure.BaseModel;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

@Table(database = AppDatabase.class, allFields = true)
public class Country extends BaseModel implements Parcelable {

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

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(code);
        parcel.writeString(name);
        parcel.writeInt(flag.getBlob().length);
        parcel.writeByteArray(flag.getBlob());
    }

    public Country(Parcel parcel) {
        code = parcel.readString();
        name = parcel.readString();
        byte[] flagData = new byte[parcel.readInt()];
        parcel.readByteArray(flagData);
        flag = new Blob(flagData);
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
    @PrimaryKey
    private String  code;

    private String  name;
    private Blob    flag;
}
