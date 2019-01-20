package be.justcode.bandtracker.model;

import android.support.annotation.NonNull;

import com.raizlabs.android.dbflow.annotation.Migration;
import com.raizlabs.android.dbflow.sql.migration.BaseMigration;
import com.raizlabs.android.dbflow.structure.database.DatabaseWrapper;

import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;

import be.justcode.bandtracker.App;
import be.justcode.bandtracker.R;

@Migration(version = 0, database = AppDatabase.class)
public class DemoDataCreator extends BaseMigration {

    @Override
    public void migrate(DatabaseWrapper database) {

        // only do something of demo mode is activated
        if (!App.getContext().getResources().getBoolean(R.bool.demo_mode)) {
            return;
        }

        createCountries(database);
        createBands(database);
        createGigs(database);
    }

    private void createCountries(DatabaseWrapper database) {
        countryCreate(database, "NL", "Netherlands");
        countryCreate(database, "BE", "Belgium");
    }

    private void createBands(DatabaseWrapper database) {
        bandCreate(database, "5182c1d9-c7d2-4dad-afa0-ccfeada921a8", "Black Sabbath",
            "<b>Black Sabbath</b> are an English rock band, formed in Birmingham in 1968, by guitarist and main songwriter Tony Iommi, " +
            "bassist and main lyricist Geezer Butler, singer Ozzy Osbourne, and drummer Bill Ward. The band have since experienced " +
            "multiple line-up changes, with guitarist Iommi being the only constant presence in the band through the years. " +
            "Originally formed in 1968 as a blues rock band, the group soon adopted the Black Sabbath moniker and began incorporating " +
            "occult themes with horror-inspired lyrics and tuned-down guitars. Despite an association with these two themes, " +
            "Black Sabbath also composed songs dealing with social instability, political corruption, the dangers of drug abuse " +
            "and apocalyptic prophecies of the horrors of war."
        );

        bandCreate(database, "ca891d65-d9b0-4258-89f7-e6ba29d83767", "Iron Maiden",
            "<b>Iron Maiden</b> are an English heavy metal band formed in Leyton, east London, in 1975 by bassist and primary " +
            "songwriter Steve Harris. The band&apos;s discography has grown to thirty-eight albums, including sixteen studio albums, " +
            "eleven live albums, four EPs, and seven compilations."
        );

        bandCreate(database, "41f4d85a-0bd7-4602-a3e3-8c47f36efb0a", "Accept",
            "Accept is a German heavy metal band from the town of Solingen, originally assembled by former vocalist Udo Dirkschneider, " +
            "guitarist Wolf Hoffmann and bassist Peter Baltes. Their beginnings can be traced back to the late 1960s. " +
            "The band played an important role in the development of speed and thrash metal, being part of the German heavy metal scene, " +
            "which emerged in the early to mid-1980s. Accept achieved commercial success with their fifth studio album Balls to the Wall (1983), " +
            "which remains the band's only album to be certified gold in the United States and Canada, and spawned their well-known hit " +
            "Balls to the Wall. Following their disbandment in 1997 and short-lived reunion in 2005, Accept reunited again in 2009 with " +
            "former T.T. Quick frontman Mark Tornillo[5] replacing Dirkschneider and released their three highest charting albums to date, " +
            "Blood of the Nations (2010), Stalingrad (2012) and Blind Rage (2014), the latter of which was Accept's first album to reach " +
            "number one on the charts in their home country. Accept is currently preparing to work on a new album."
        );

        bandCreate(database, "8aa5b65a-5b3c-4029-92bf-47a544356934", "Ozzy Osbourne",
            "<b>John Michael</b> &quot;<b>Ozzy</b>&quot; <b>Osbourne</b> (born 3 December 1948) is an English singer, songwriter and " +
            "television personality. He rose to prominence in the early 1970s as the lead vocalist of the band Black Sabbath, " +
            "widely considered to be the first heavy metal band. Osbourne was fired from Black Sabbath in 1979 and has since " +
            "had a successful solo career, releasing 11 studio albums, the first seven of which were all awarded multi-platinum " +
            "certifications in the U.S., although he has reunited with Black Sabbath on several occasions, recording the " +
            "album <i>13</i> in 2013. Osbourne&apos;s longevity and success have earned him the informal title of &quot;Godfather of Heavy Metal&quot;."
        );

        bandCreate(database, "a8e935c6-3fcc-414c-900c-77e8170e7e7c", "Black Label Society",
            "<b>Black Label Society</b> is an American heavy metal band from Los Angeles, California formed in 1998 by Zakk Wylde. The band has, " +
            "thus far, released nine studio albums, two live albums, two compilation albums, one EP, and three video albums."
        );

        bandCreate(database, "a9044915-8be3-4c7e-b11f-9e2d2ea0a91e", "Megadeth",
            "<b>Megadeth</b> is an American thrash metal band from Los Angeles, California. The group was formed in 1983 by guitarist Dave Mustaine " +
            "and bassist David Ellefson, shortly after Mustaine&apos;s dismissal from Metallica. A pioneer of the American thrash metal scene, " +
            "the band is credited as one of the genre&apos;s &quot;big four&quot; with Anthrax, Metallica and Slayer, responsible for thrash " +
            "metal&apos;s development and popularization. Megadeth plays in a technical style, featuring fast rhythm sections and complex arrangements; " +
            "themes of death, war, politics and religion are prominent in the group&apos;s lyrics."
        );

        bandCreate(database, "bbd80354-597e-4d53-94e4-92b3a7cb8f2c", "Saxon",
            "<b>Saxon</b> are an English heavy metal band formed in 1976, in South Yorkshire. As one of the leaders of the New Wave of British Heavy Metal, " +
            "they had eight UK Top 40 albums in the 1980s including four UK Top 10 albums and two Top 5 albums. The band also had numerous singles " +
            "in the UK Singles Chart and chart success all over Europe and Japan, as well as success in the US. During the 1980s Saxon established " +
            "themselves as one of Europe&apos;s biggest metal acts. The band tours regularly and have sold more than 15 million albums worldwide. " +
            "They are considered one of the classic metal acts and have influenced many bands such as Metallica, M&#xF6;tley Cr&#xFC;e, Pantera, Sodom, Skid Row, and Megadeth."
        );

        bandCreate(database, "08003348-b873-4b22-91af-c1592cdf2f08", "Channel Zero",
            "Channel Zero is a Belgian heavy metal band, formed in Brussels, Belgium, in 1990. They are one of the best known heavy metal " +
            "bands from Belgium. They disbanded at the height of their career in 1997, however in 2009, the band announced a series " +
            "of reunion gigs starting in January 2010."
        );
    }

    private void createGigs(DatabaseWrapper database) {
        {
            Band band = bands.get("Black Sabbath");
            gigCreate(database, band, d(2013, 11, 28), "NL", "Amsterdam", "Ziggo Dome", false, 50);
            gigCreate(database, band, d(2014, 6, 29), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
        }
        {
            Band band = bands.get("Iron Maiden");
            gigCreate(database, band, d(1999, 9, 10), "NL", "Rotterdam", "Ahoy' Rotterdam", false, 40);
            gigCreate(database, band, d(2000, 6, 24), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
            gigCreate(database, band, d(2003, 7, 5), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
            gigCreate(database, band, d(2003, 11, 20), "BE", "Leuven", "Brabenthal", false, 40);
            gigCreate(database, band, d(2005, 6, 26), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
            gigCreate(database, band, d(2005, 7, 3), "NL", "Weert", "Bospop", false, 40);
            gigCreate(database, band, d(2006, 11, 27), "NL", "Den Bosch", "Brabanthal", false, 30);
            gigCreate(database, band, d(2007, 6, 23), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
            gigCreate(database, band, d(2008, 6, 29), "BE", "Dessel", "Graspop Metal Meeting", false, 40);
            gigCreate(database, band, d(2013, 6, 30), "BE", "Dessel", "Boeretang Festival park", false, 40);
        }
        {
            Band band = bands.get("Accept");
            gigCreate (database, band, d(2005, 6, 25), "BE", "Dessel", "Boeretang", false, 50);
            gigCreate (database, band, d(2011, 1, 16), "BE", "Antwerp", "Hof Ter Lo", false, 40);
            gigCreate (database, band, d(2014, 10, 7), "BE", "Antwerp", "Muziekcentrum TRIX", false, 40);
        }
        {
            Band band = bands.get("Ozzy Osbourne");
            gigCreate(database, band, d(2012, 6, 22), "BE", "Dessel", "Boeretang", false, 40);
            gigCreate(database, band, d(2007, 6, 24), "BE", "Dessel", "Boeretang", false, 40);
            gigCreate(database, band, d(2011, 6, 13), "DE", "Oberhausen", "König-Pilsener-Arena", false, 40);
            gigCreate(database, band, d(2012, 6, 4), "DE", "Dortmund", "Westfalenhalle", false, 40);
        }
        {
            Band band = bands.get("Black Label Society");
            gigCreate(database, band, d(2015, 8, 2), "BE", "Lokeren", "Grote Kaai", false, 30);
            gigCreate(database, band, d(2007, 6, 24), "BE", "Dessel", "Boeretang", false, 30);
            gigCreate(database, band, d(2011, 6, 25), "BE", "Dessel", "Boeretang", false, 40);
            gigCreate(database, band, d(2011, 6, 13), "DE", "Oberhausen", "König-Pilsener-Arena", true, 30);
            gigCreate(database, band, d(2012, 6, 4), "DE", "Dortmund", "Westfalenhalle", true, 20);
            gigCreate(database, band, d(2012, 6, 22), "BE", "Dessel", "Boeretang", false, 30);
            gigCreate(database, band, d(2014, 6, 29), "BE", "Dessel", "Boeretang", false, 30);
        }
        {
            Band band = bands.get("Megadeth");
            gigCreate(database, band, d(2015, 11, 15), "NL", "Rotterdam", "Ahoy' Rotterdam", true, 20);
        }
        {
            Band band = bands.get("Saxon");
            gigCreate(database, band, d(2000, 6, 24), "BE", "Dessel", "Boeretang", false, 30);
            gigCreate(database, band, d(2005, 5, 21), "BE", "Roeselare", "Expohallen Schievelde", false, 40);
            gigCreate(database, band, d(2006, 6, 25), "BE", "Dessel", "Boeretang", false, 40);
            gigCreate(database, band, d(2006, 11, 18), "BE", "Poperinge", "Maeke Blyde", false, 50);
            gigCreate(database, band, d(2007, 3, 10), "BE", "Antwerp", "Hof Ter Lo", false, 40);
            gigCreate(database, band, d(2008, 7, 25), "NL", "Lichtenvoorde", "De Schans", false, 40);
            gigCreate(database, band, d(2009, 2, 2), "BE", "Brussels", "Ancienne Belgique", false, 40);
            gigCreate(database, band, d(2009, 8, 8), "BE", "Deinze", "Brielpoort", false, 40);
            gigCreate(database, band, d(2011, 5, 17), "BE", "Antwerp", "Muziekcentrum TRIX", false, 40);
            gigCreate(database, band, d(2013, 5, 10), "NL", "Uden", "De Pul", false, 40);
            gigCreate(database, band, d(2013, 6, 29), "BE", "Dessel", "Boeretang", false, 40);
            gigCreate(database, band, d(2012, 5, 23), "BE", "Antwerp", "Lotto Arena", false, 40);
            gigCreate(database, band, d(2014, 11, 5), "BE", "Antwerp", "Muziekcentrum TRIX", false, 40);
        }
        {
            Band band = bands.get("Channel Zero");
            gigCreate(database, band, d(2015, 8, 2), "BE", "Lokeren", "Grote Kaai", false, 40);
            gigCreate(database, band, d(2011, 6, 25), "BE", "Dessel", "Boeretang", false, 30);
            gigCreate(database, band, d(2010, 6, 26), "BE", "Dessel", "Boeretang", false, 30);
        }
    }

    private static Date d(int y, int m, int d) {
        return new GregorianCalendar(y, m, d).getTime();
    }

    private Country countryCreate(@NonNull DatabaseWrapper database, String code, String name) {
        Country country = new Country();
        country.setCode(code);
        country.setName(name);

        countries.put(code, country);
        return country;
    }

    private City cityCreate(@NonNull DatabaseWrapper database, String name, Country country) {

        City city = cities.get(name);

        if (city == null) {
            city = new City(name, country);
            city.save(database);
            cities.put(name, city);
        }

        return city;
    }

    private Venue venueCreate(@NonNull DatabaseWrapper database, String name, City city, Country country) {

        Venue venue = venues.get(name);

        if (venue == null) {
            venue = new Venue(name, city, country);
            venue.save(database);
            venues.put(name, venue);
        }
        return venue;
    }

    private Band bandCreate(@NonNull DatabaseWrapper database, String MBID, String name, String biography) {
        Band band = new Band();
        band.setMBID(MBID);
        band.setName(name);
        band.setBiography(biography);
        band.save(database);
        bands.put(name, band);
        return band;
    }


    private Gig gigCreate(@NonNull DatabaseWrapper database, Band band, Date date, String country, String city, String venue, Boolean support, int rating) {

        Gig gig = new Gig();
        gig.setBand(band);
        gig.setStartDate(date);
        gig.setCountry(countries.get(country));
        gig.setCity(cityCreate(database, city, gig.getCountry()));
        gig.setVenue(venueCreate(database, venue, gig.getCity(), gig.getCountry()));
        gig.setSupportAct(support);
        gig.setRating(rating);
        gig.save(database);

        band.setNumGigs(band.getNumGigs() + 1);
        band.setTotalRating(band.getTotalRating() + rating);
        band.save(database);

        return gig;
    }

    private Map<String, Country> countries = new HashMap<>();
    private Map<String, Band> bands = new HashMap<>();
    private Map<String, City> cities = new HashMap<>();
    private Map<String, Venue> venues = new HashMap<>();
}
