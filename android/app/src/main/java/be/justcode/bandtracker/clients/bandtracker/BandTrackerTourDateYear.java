package be.justcode.bandtracker.clients.bandtracker;

import org.parceler.Parcel;

@Parcel
public class BandTrackerTourDateYear {

    // public interface
    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    // member variables
    int year;
    int count;
}
