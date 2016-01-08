package be.justcode.bandtracker.clients.bandtracker;

public class BandTrackerCountry {

    // getters
    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getFlag() {
        return flag;
    }

    // setters
    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }

    // member variables
    private String  code;
    private String  name;
    private String  flag;
}
