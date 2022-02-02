//
//  ViewController.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 1/22/22.
//

import UIKit
import KosherCocoa

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 30.0
    var currentZman: Int = 0
    var zmanShown: Bool = false
    var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
    
    @IBOutlet weak var selectOpinion: UITextField!
    @IBOutlet weak var opinions: UIPickerView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var locationNLabel: UILabel!
    @IBAction func elevationSwitch(_ sender: UISwitch) {
        if sender.isOn {
                    GlobalStruct.useElevation = true
                } else {
                    GlobalStruct.useElevation = false
                    
                }
        showZman(row: currentZman)
    }
    @IBOutlet weak var elevationSwitch: UISwitch!
    @IBOutlet weak var currentElevationLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dateChanged(_ sender: Any) {//picker date selected
        zmanimCalendar.workingDate = datePicker.date
        showZman(row: currentZman)
    }
    @IBOutlet weak var changeDateButton: UIButton!
    @IBAction func changeDate(_ sender: Any) {
        selectOpinion.isHidden = !selectOpinion.isHidden
        locationNLabel.isHidden = !locationNLabel.isHidden
        if zmanShown {
            time.isHidden = !time.isHidden
            date.isHidden = !date.isHidden
        }
        if !opinions.isHidden && datePicker.isHidden {
            opinions.isHidden = true
        }
        datePicker.isHidden = !datePicker.isHidden
        if !datePicker.isHidden {
            changeDateButton.setTitle("OK", for: .normal)
        } else {
            changeDateButton.setTitle("Change Date", for: .normal)
        }
    }
    
    var list = ["72 Zmaniyot Minutes", "90 Zmaniyot Minutes", "96 Zmaniyot Minutes", "120 Zmaniyot Minutes", "50 Regular Minutes (NY Only)", "60 Regular Minutes", "72 Regular Minutes", "90 Regular Minutes", "96 Regular Minutes", "120 Regular Minutes", "16.1 degrees", "18 degrees", "19.8 degrees", "26 degrees"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.getUserLocation {
            location in DispatchQueue.main.async {
                self.lat = location.coordinate.latitude
                self.long = location.coordinate.longitude
                let geoLocation = KosherCocoa.GeoLocation.init(latitude: self.lat, andLongitude: self.long, elevation: self.elevation, andTimeZone: TimeZone.current)
                self.zmanimCalendar = ComplexZmanimCalendar(location: geoLocation)
                
                //let yesterday: Date = calendar.internalCalendar().date(byAdding: .day, value: -1, to: calendar.workingDate)!
                //calendar.workingDate = yesterday

                //let formatter = DateFormatter()
                //formatter.dateFormat = "HH:mm:ss E, d MMM y"
                LocationManager.shared.resolveLocationName(with: location) { locationName in
                    self.locationNLabel.text = locationName!
                }
            }
        }
        if lat == 0 && long == 0 {
            self.locationNLabel.text = "Error: No location info"
        }
        GlobalStruct.useElevation = elevationSwitch.isOn
        currentElevationLabel.text = "Current: " + String(format: "%.1f", elevation)
        if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectOpinion.text = self.list[row]
        time.isHidden = false
        date.isHidden = false
        currentZman = row
        showZman(row: currentZman)
        zmanShown = true
        self.opinions.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.selectOpinion {
            self.opinions.isHidden = false
            //if you don't want the users to see the keyboard type:
            textField.endEditing(true)
        }
    }
    
    func showZman(row: Int) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm:ss aa"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM y"
        if list[row] == "72 Zmaniyot Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait72Zmanit()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait72Zmanit()!)
        }
        if list[row] == "90 Zmaniyot Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait90Zmanit()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait90Zmanit()!)
        }
        if list[row] == "96 Zmaniyot Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait96Zmanit()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait96Zmanit()!)
        }
        if list[row] == "120 Zmaniyot Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait120Zmanit()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait120Zmanit()!)
        }
        if list[row] == "50 Regular Minutes (NY Only)" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait50()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait50()!)
        }
        if list[row] == "60 Regular Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait60()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait60()!)
        }
        if list[row] == "72 Regular Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait72()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait72()!)
        }
        if list[row] == "90 Regular Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait90()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait90()!)
        }
        if list[row] == "96 Regular Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait96()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait96()!)
        }
        if list[row] == "120 Regular Minutes" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzait120()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzait120()!)
        }
        if list[row] == "16.1 degrees" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzais16Point1Degrees()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzais16Point1Degrees()!)
        }
        if list[row] == "18 degrees" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzais18Degrees()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzais18Degrees()!)
        }
        if list[row] == "19.8 degrees" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzais19Point8Degrees()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzais19Point8Degrees()!)
        }
        if list[row] == "26 degrees" {
            self.time.text = timeFormatter.string(from: zmanimCalendar.tzais26Degrees()!)
            self.date.text = dateFormatter.string(from: zmanimCalendar.tzais26Degrees()!)
        }
    }
}

struct GlobalStruct {
    static var useElevation = false
}

public extension ComplexZmanimCalendar {
    
    func tzait120() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 120, to: sunset())
        }
        return date(byAddingMinutes: 120, to: seaLevelSunset())
    }
    
    func tzait96() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 96, to: sunset())
        }
        return date(byAddingMinutes: 96, to: seaLevelSunset())
    }
    
    func tzait90() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 90, to: sunset())
        }
        return date(byAddingMinutes: 90, to: seaLevelSunset())
    }
    
    func tzait72() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 72, to: sunset())
        }
        return date(byAddingMinutes: 72, to: seaLevelSunset())
    }
    
    func tzait60() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 60, to: sunset())
        }
        return date(byAddingMinutes: 60, to: seaLevelSunset())
    }
    
    func tzait50() -> Date? {
        if GlobalStruct.useElevation {
            return date(byAddingMinutes: 50, to: sunset())
        }
        return date(byAddingMinutes: 50, to: seaLevelSunset())
    }
    
    func tzait120Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        if GlobalStruct.useElevation {
            return sunset()?.addingTimeInterval(shaahZmanit*2.0);
        }
        return seaLevelSunset()?.addingTimeInterval(shaahZmanit*2.0);
    }
    
    func tzait96Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        if GlobalStruct.useElevation {
            return sunset()?.addingTimeInterval(shaahZmanit*1.6);
        }
        return seaLevelSunset()?.addingTimeInterval(shaahZmanit*1.6);
    }
    
    func tzait90Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        if GlobalStruct.useElevation {
            return sunset()?.addingTimeInterval(shaahZmanit*1.5);
        }
        return seaLevelSunset()?.addingTimeInterval(shaahZmanit*1.5);
    }
    
    func tzait72Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        if GlobalStruct.useElevation {
            return sunset()?.addingTimeInterval(shaahZmanit*1.2);
        }
        return seaLevelSunset()?.addingTimeInterval(shaahZmanit*1.2);
    }
    
    override func shaahZmanisGra() -> Double {
        if GlobalStruct.useElevation {
            return temporalHour(fromSunrise: sunrise()!, toSunset: sunset()!)
        }
        return temporalHour(fromSunrise: seaLevelSunrise()!, toSunset: seaLevelSunset()!)
    }
}
