package be.justcode.bandtracker.utils;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateUtils {

    public static String dateToString(Date date) {
        return dateFormatter.format(date);
    }

    public static String dateToShortString(Date date) {
        return shortDateFormatter.format(date);
    }

    public static String timeToString(Date date) {
        return timeFormatter.format(date);
    }

    public static Date dateFromComponents(int year, int month, int day, int hour, int minute) {
        calendar.set(year, month, day, hour, minute);
        return calendar.getTime();
    }

    public static int dateYear(Date date) {
        calendar.setTime(date);
        return calendar.get(Calendar.YEAR);
    }

    public static int dateMonth(Date date) {
        calendar.setTime(date);
        return calendar.get(Calendar.MONTH);
    }

    public static int dateDay(Date date) {
        calendar.setTime(date);
        return calendar.get(Calendar.DAY_OF_MONTH);
    }

    public static int dateHour(Date date) {
        calendar.setTime(date);
        return calendar.get(Calendar.HOUR_OF_DAY);
    }

    public static int dateMinute(Date date) {
        calendar.setTime(date);
        return calendar.get(Calendar.MINUTE);
    }

    private static Calendar   calendar      = Calendar.getInstance();
    private static DateFormat dateFormatter = DateFormat.getDateInstance(DateFormat.FULL);
    private static DateFormat shortDateFormatter = DateFormat.getDateInstance(DateFormat.MEDIUM);
    private static DateFormat timeFormatter = DateFormat.getTimeInstance(DateFormat.SHORT);
}
