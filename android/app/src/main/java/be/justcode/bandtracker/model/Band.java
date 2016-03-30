package be.justcode.bandtracker.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.raizlabs.android.dbflow.annotation.Column;
import com.raizlabs.android.dbflow.annotation.ColumnIgnore;
import com.raizlabs.android.dbflow.annotation.OneToMany;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import java.util.List;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;

@Table(database = AppDatabase.class, allFields = true)
public class Band extends BaseModel implements Parcelable
{
    // construction
    Band() {
        MBID            = "";
        name            = "";
        biography       = "";
        numGigs         = 0;
        totalRating     = 0;
        fanartThumbUrl  = "";
        fanartLogoUrl   = "";
    }

    Band(BandTrackerBand serverBand) {
        MBID            = serverBand.getMBID();
        name            = serverBand.getName();
        biography       = serverBand.getBiography();
        numGigs         = 0;
        totalRating     = 0;
        fanartThumbUrl  = "";
        fanartLogoUrl   = "";
    }

    @Override
    public void save() {
        computeTotals();
        super.save();
    }

    // getters
    public String getMBID() {
        return MBID;
    }

    public String getName() {
        return name;
    }

    public String getBiography() {
        return biography;
    }

    public int getNumGigs() {
        return numGigs;
    }

    public int getTotalRating() {
        return totalRating;
    }

    public double getAvgRating() {
        return avgRating;
    }

    public String getFanartThumbUrl() {
        return fanartThumbUrl;
    }

    public String getFanartLogoUrl() {
        return fanartLogoUrl;
    }

    public List<Gig> getGigs() {

        if (gigs == null || gigs.isEmpty()) {
            gigs = DataContext.gigList(this);
        }

        return gigs;
    }

    // setters
    public void setMBID(String MBID) {
        this.MBID = MBID;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public void setNumGigs(int numGigs) {
        this.numGigs = numGigs;
        computeAverageRating();
    }

    public void setTotalRating(int totalRating) {
        this.totalRating = totalRating;
        computeAverageRating();
    }

    public void setAvgRating(double avgRating) {
        this.avgRating = avgRating;
    }

    public void setFanartThumbUrl(String fanartThumbUrl) {
        this.fanartThumbUrl = fanartThumbUrl;
    }

    public void setFanartLogoUrl(String fanartLogoUrl) {
        this.fanartLogoUrl = fanartLogoUrl;
    }

    // parcelable interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeString(MBID);
        parcel.writeString(name);
        parcel.writeString(biography);
        parcel.writeInt(numGigs);
        parcel.writeInt(totalRating);
        parcel.writeDouble(avgRating);
        parcel.writeString(fanartThumbUrl);
        parcel.writeString(fanartLogoUrl);
    }

    public Band(Parcel parcel ) {
        MBID            = parcel.readString();
        name            = parcel.readString();
        biography       = parcel.readString();
        numGigs         = parcel.readInt();
        totalRating     = parcel.readInt();
        avgRating       = parcel.readDouble();
        fanartThumbUrl  = parcel.readString();
        fanartLogoUrl   = parcel.readString();
    }

    public static final Parcelable.Creator<Band> CREATOR = new Parcelable.Creator<Band>() {
        public Band createFromParcel(Parcel in) {
            return new Band(in);
        }

        public Band[] newArray(int size) {
            return new Band[size];
        }
    };

    // helper functions
    private void computeAverageRating() {
        if (numGigs != 0)
            avgRating = totalRating / numGigs;
        else
            avgRating = 0;
    }

    private void computeTotals() {
        numGigs = getGigs().size();
        totalRating = 0;

        for (Gig gig : getGigs()) {
            totalRating += gig.getRating();
        }

        computeAverageRating();
    }

    // member variables
    @PrimaryKey
    private String  MBID;

    private String  name;
    private String  biography;
    private int     numGigs;
    private int     totalRating;
    private double  avgRating;
    private String  fanartThumbUrl;
    private String  fanartLogoUrl;

    @ColumnIgnore
    private List<Gig> gigs;
}
