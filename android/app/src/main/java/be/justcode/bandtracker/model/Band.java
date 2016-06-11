package be.justcode.bandtracker.model;

import com.raizlabs.android.dbflow.annotation.ColumnIgnore;
import com.raizlabs.android.dbflow.annotation.PrimaryKey;
import com.raizlabs.android.dbflow.annotation.Table;
import com.raizlabs.android.dbflow.structure.BaseModel;

import java.util.List;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;

import org.parceler.Parcel;
import org.parceler.Parcel.Serialization;

@Table(database = AppDatabase.class, allFields = true)
@Parcel(Serialization.BEAN)
public class Band extends BaseModel
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
