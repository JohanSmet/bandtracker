package be.justcode.bandtracker.clients.bandtracker;

import java.util.Date;

import be.justcode.bandtracker.utils.CountryCache;

public class BandTrackerTourDate {

    // public interface
    public String getBandId() {
        return bandId;
    }

    public void setBandId(String bandId) {
        this.bandId = bandId;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public String getVenue() {
        return venue;
    }

    public String formatLocation() {
        String location = "";
        String separator = "";
        boolean venueSet = false;

        if (venue != null && !venue.isEmpty()) {
            location += separator + venue;
            separator = ",";
            venueSet  = true;
        }

        if (city != null && !city.isEmpty()) {
            location += separator + city;
            separator = ",";
        }

        if (!venueSet && countryCode != null && !countryCode.isEmpty()) {
            location += separator + CountryCache.getCountry(countryCode).getName();
        }

        return location;
    }

    public void setVenue(String venue) {
        this.venue = venue;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public boolean isSupportAct() {
        return supportAct;
    }

    public void setSupportAct(boolean supportAct) {
        this.supportAct = supportAct;
    }



    // member variables
    private String  bandId;
    private Date    startDate;
    private Date    endDate;
    private String  stage;
    private String  venue;
    private String  city;
    private String  countryCode;
    private boolean supportAct;
}
