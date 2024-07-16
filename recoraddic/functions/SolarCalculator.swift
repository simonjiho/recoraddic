//
//  SunriseSunset.swift
//  recoraddic
//
//  Created by 김지호 on 7/17/24.
// will be used later.

import Foundation

struct SolarCalculator {
    let latitude: Double
    let longitude: Double
    let timeZone: TimeZone
    
    func calculateSunriseSunset(for date: Date) -> (sunrise: Date?, sunset: Date?) {
        let calendar = Calendar(identifier: .gregorian)
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let fractionalYear = calculateFractionalYear(year: year, month: month, day: day, date: date)
        let equationOfTime = calculateEquationOfTime(fractionalYear: fractionalYear)
        let solarDeclination = calculateSolarDeclination(fractionalYear: fractionalYear)
        
        let hourAngle = calculateHourAngle(latitude: latitude, solarDeclination: solarDeclination)
        
        guard let sunrise = calculateSunriseTime(hourAngle: hourAngle, equationOfTime: equationOfTime),
              let sunset = calculateSunsetTime(hourAngle: hourAngle, equationOfTime: equationOfTime) else {
            return (nil, nil)
        }
        
        let sunriseDate = calendar.date(bySettingHour: Int(sunrise), minute: Int((sunrise.truncatingRemainder(dividingBy: 1) * 60).rounded()), second: 0, of: date)
        let sunsetDate = calendar.date(bySettingHour: Int(sunset), minute: Int((sunset.truncatingRemainder(dividingBy: 1) * 60).rounded()), second: 0, of: date)
        
        // startofday < (sunrise, sunset, now) -> so the results can differ by region -> only use hour and minute components.

        return (sunriseDate?.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT())), sunsetDate?.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT())))
    }

    
    private func calculateFractionalYear(year: Int, month: Int, day: Int, date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let daysInYear = isLeapYear(year) ? 366.0 : 365.0
        let dayOfYear = Double(dayOfYearFromDate(year: year, month: month, day: day))
        let hour = Double(calendar.component(.hour, from: date))
        let minute = Double(calendar.component(.minute, from: date))
        let fractionalHour = hour + minute / 60.0
        return 2 * .pi / daysInYear * (dayOfYear - 1 + (fractionalHour - 12) / 24)
    }
    
    private func calculateEquationOfTime(fractionalYear: Double) -> Double {
        let epsilon = 23.4393 - 0.0000004 * fractionalYear
        let epsilonRad = epsilon * .pi / 180
        
        let l0 = 280.46646 + 36000.76983 * fractionalYear + 0.0003032 * pow(fractionalYear, 2)
        let l0Rad = (l0.truncatingRemainder(dividingBy: 360)) * .pi / 180
        
        let e = 0.016708634 - 0.000042037 * fractionalYear - 0.0000001267 * pow(fractionalYear, 2)
        
        let m = 357.52911 + 35999.05029 * fractionalYear - 0.0001537 * pow(fractionalYear, 2)
        let mRad = m * .pi / 180
        
        let y = pow(tan(epsilonRad / 2), 2)
        
        let eot = y * sin(2 * l0Rad) - 2 * e * sin(mRad) + 4 * e * y * sin(mRad) * cos(2 * l0Rad) - 0.5 * y * y * sin(4 * l0Rad) - 1.25 * e * e * sin(2 * mRad)
        
        return eot * 4 * 180 / .pi  // Convert from radians to minutes
    }
    
    private func calculateSolarDeclination(fractionalYear: Double) -> Double {
        let y = fractionalYear
        return 0.006918 - 0.399912 * cos(y) + 0.070257 * sin(y) - 0.006758 * cos(2 * y) + 0.000907 * sin(2 * y) - 0.002697 * cos(3 * y) + 0.00148 * sin(3 * y)
    }
    
    private func calculateHourAngle(latitude: Double, solarDeclination: Double) -> Double { // prevents nan (acos range: -1~1) -> Handles cases where the sun never rises (polar night) or never sets (midnight sun).
        let latRad = latitude * .pi / 180
        let cosZenith = cos(90.833 * .pi / 180)
        let cosLatitude = cos(latRad)
        let sinLatitude = sin(latRad)
        let cosDeclination = cos(solarDeclination)
        let sinDeclination = sin(solarDeclination)
        
        let cosHourAngle = (cosZenith - sinLatitude * sinDeclination) / (cosLatitude * cosDeclination)
        
        if cosHourAngle > 1 {
            // Sun never rises
            return 0
        } else if cosHourAngle < -1 {
            // Sun never sets
            return .pi
        } else {
            return acos(cosHourAngle)
        }
    }

    
    private func calculateSunriseTime(hourAngle: Double, equationOfTime: Double) -> Double? {
        let localTime = 720 - 4 * (longitude + hourAngle * 180 / .pi) - equationOfTime
        return (localTime / 60 + 24).truncatingRemainder(dividingBy: 24)
    }
    
    private func calculateSunsetTime(hourAngle: Double, equationOfTime: Double) -> Double? {
        let localTime = 720 - 4 * (longitude - hourAngle * 180 / .pi) - equationOfTime
        return (localTime / 60 + 24).truncatingRemainder(dividingBy: 24)
    }
    
    private func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
    
    private func dayOfYearFromDate(year: Int, month: Int, day: Int) -> Int {
        let daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        var dayOfYear = day
        
        for i in 0..<(month - 1) {
            dayOfYear += daysInMonth[i]
        }
        
        if month > 2 && isLeapYear(year) {
            dayOfYear += 1
        }
        
        return dayOfYear
    }
}




