package be.justcode.bandtracker.utils;

import java.text.DateFormat;
import java.util.Date;

public class DateUtils {

    public static String dateToString(Date date) {
        return dateFormatter.format(date);
    }

    private static DateFormat dateFormatter = DateFormat.getDateInstance(DateFormat.FULL);
}
