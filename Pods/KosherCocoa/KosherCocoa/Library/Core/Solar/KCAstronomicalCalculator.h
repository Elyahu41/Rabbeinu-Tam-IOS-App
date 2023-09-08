/**
 *  AstronomicalCalculator.h
 *  KosherCocoa 3
 *
 *  Created by Moshe Berman on 7/22/11.
 *  Updated by Moshe Berman on 8/25/13.
 *
 *  Use of KosherCocoa 3 is governed by the LGPL 2.1 License.
 */

@import Foundation;

/**
 *  A protocol defining methods to return sunrise and sunset times.
 */
NS_SWIFT_NAME(AstronomicalCalculator)
@interface KCAstronomicalCalculator : NSObject

- (id _Nullable)init;

// MARK: - Calculating Sunrise

/**
 *  Get sunset as a double.
 *
 *  @param date The date we're using to calculate sunrise.
 *
 *  @param zenith The zenith we use.
 *
 *  @param adjustForElevation Determines if we calculate at a the given elevation or at
 *  sea level.
 *
 *  @return The sunset time as a double. (TODO: Check the units.)
 */

- (double)UTCSunsetForDate:(nonnull NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;

/**
 *  Get sunrise as a double.
 *
 *  @param date The date we're using to calculate sunrise.
 *
 *  @param zenith The zenith we use.
 *
 *  @param adjustForElevation Determines if we calculate at a the given elevation or at
 *  sea level.
 *
 *  @return The sunrise time as a double. (TODO: Check the units.)
 */

-  (double)UTCSunriseForDate:(nonnull NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;

/**
 *    Method to return the adjustment to the zenith required to account for the
 *    elevation. Since a person at a higher elevation can see farther below the
 *    horizon, the calculation for sunrise / sunset is calculated below the
 *    horizon used at sea level. This is only used for sunrise and sunset and
 *    not times above or below it such as nautical twilight since those calculations
 *  are based on the level of available light at the
 *    given dip below the horizon, something that is not affected by elevation,
 *    the adjustment should only made if the zenith == 90&deg;
 *    {@link #adjustZenith adjusted} for refraction and solar radius.<br />
 *    The algorithm used is:
 *
 *    <pre>
 *    elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters
 *            / (earthRadiusInMeters + elevationMeters)));
 *    </pre>
 *
 *    The source of this algorthitm is
 *    "http: *www.calendarists.com"Calendrical Calculations by
 *    Edward M. Reingold and Nachum Dershowitz. An alternate algorithm that
 *    produces an almost identical (but not accurate) result found in Ma'aglay
 *    Tzedek by Moishe Kosower and other sources is:
 *
 *    <pre>
 *    elevationAdjustment = 0.0347 * Math.sqrt(elevationMeters);
 *    </pre>
 *
 *    @param elevation elevation in Meters.
 *    @return the adjusted zenith
 */

- (double)elevationAdjustmentForElevation:(double)elevation;

/**
 *    Adjusts the zenith to account for solar refraction, solar radius and
 *    elevation. The value for Sun's zenith and true rise/set Zenith (used in
 *    this class and subclasses) is the angle that the center of the Sun makes
 *    to a line perpendicular to the Earth's surface. If the Sun were a point
 *    and the Earth were without an atmosphere, true sunset and sunrise would
 *    correspond to a 90&deg; zenith. Because the Sun is not a point, and
 *    because the atmosphere refracts light, this 90&deg; zenith does not, in
 *    fact, correspond to true sunset or sunrise, instead the centre of the
 *    Sun's disk must lie just below the horizon for the upper edge to be
 *    obscured. This means that a zenith of just above 90&deg; must be used.
 *    The Sun subtends an angle of 16 minutes of arc (this can be changed via
 *    the {@link #setSolarRadius(double)} method , and atmospheric refraction
 *    accounts for 34 minutes or so, giving a total of 50 arcminutes.
 *    The total value for ZENITH is 90+(5/6) or 90.8333333&deg; for true
 *    sunrise/sunset. Since a person at an elevation can see blow the horizon
 *    of a person at sea level, this will also adjust the zenith to account for
 *    elevation if available.
 *
 *  @param zenith The zenith to use with the calculation.
 *
 *  @param elevation The elevation to use for the calculation.
 *
 *    @return The zenith adjusted to include the sun's radius, refraction, and
 *  elevation adjustment.
 */

- (double)adjustZenith:(double)zenith forElevation:(double)elevation;

@end
