package be.justcode.bandtracker.model;

import be.justcode.bandtracker.clients.bandtracker.BandTrackerBand;

public class Band
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

    public String getFanartThumbUrl() {
        return fanartThumbUrl;
    }

    public String getFanartLogoUrl() {
        return fanartLogoUrl;
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
    }

    public void setTotalRating(int totalRating) {
        this.totalRating = totalRating;
    }

    public void setFanartThumbUrl(String fanartThumbUrl) {
        this.fanartThumbUrl = fanartThumbUrl;
    }

    public void setFanartLogoUrl(String fanartLogoUrl) {
        this.fanartLogoUrl = fanartLogoUrl;
    }

    // member variables
    private String  MBID;
    private String  name;
    private String  biography;

    private int     numGigs;
    private int     totalRating;

    private String  fanartThumbUrl;
    private String  fanartLogoUrl;
}
