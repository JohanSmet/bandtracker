package be.justcode.bandtracker.model;

import android.util.Base64;

import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.data.Blob;
import com.raizlabs.android.dbflow.structure.BaseModel;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerCountry;

@Table(database = AppDatabase.class, allFields = true)
public class CountryFlag extends BaseModel {

    // construction
    public CountryFlag() {
        code = "";
        flag = null;
    }

    public CountryFlag(BandTrackerCountry serverCountry) {
        code    = serverCountry.getCode();
        flag    = new Blob(Base64.decode(serverCountry.getFlag(), Base64.DEFAULT));
    }

    // getters
    public String getCode() {
        return code;
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

    public void setFlagData(byte[] flagData) {
        this.flag = new Blob(flagData);
    }

    public void setFlag(Blob flag) {
        this.flag = flag;
    }

    // member variables
    @PrimaryKey
    private String  code;
    private Blob    flag;
}
