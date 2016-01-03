package be.justcode.bandtracker.clients.bandtracker;

public class BandTrackerBand
{
    // public interface
    public String getMBID() {
        return MBID;
    }

    public void setMBID(String MBID) {
        this.MBID = MBID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public String getBioSource() {
        return bioSource;
    }

    public void setBioSource(String bioSource) {
        this.bioSource = bioSource;
    }

    // member variables
    String  MBID;
    String  name;
    String  genre;
    String  imageUrl;
    String  biography;
    String  bioSource;

}
