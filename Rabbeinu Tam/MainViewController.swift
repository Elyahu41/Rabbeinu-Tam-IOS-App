//
//  ViewController.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 1/22/22.
//

import UIKit
import KosherCocoa
import CoreLocation

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 0.0
    var timezone: TimeZone = TimeZone.current
    var currentZman: Int = 0
    var zmanShown: Bool = false
    var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
    let defaults = UserDefaults.standard
    
    @IBAction func enterZipcode(_ sender: Any) {
        showZipcodeAlert()
    }
    @IBAction func setupElevetion(_ sender: Any) {
        self.performSegue(withIdentifier: "elevationSegue", sender: self)
    }
    @IBOutlet weak var sunset: UILabel!
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
        defaults.set(sender.isOn, forKey: "useElevation")
        showZman(row: currentZman)
        setSunsetTime()
    }
    @IBAction func roundUpSwitch(_ sender: UISwitch) {
        if sender.isOn {
                    GlobalStruct.roundUp = true
                } else {
                    GlobalStruct.roundUp = false
                }
        defaults.set(sender.isOn, forKey: "roundUp")
        showZman(row: currentZman)
        setSunsetTime()
    }
    @IBOutlet weak var roundUpSwitch: UISwitch!
    @IBOutlet weak var elevationSwitch: UISwitch!
    @IBOutlet weak var currentElevationLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dateChanged(_ sender: Any) {//picker date selected
        zmanimCalendar.workingDate = datePicker.date
        showZman(row: currentZman)
        setSunsetTime()
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
        elevationSwitch.isOn = defaults.bool(forKey: "useElevation")
        roundUpSwitch.isOn = defaults.bool(forKey: "roundUp")
        GlobalStruct.useElevation = elevationSwitch.isOn
        GlobalStruct.roundUp = roundUpSwitch.isOn
        elevation = defaults.double(forKey: "elevation")
        currentElevationLabel.text = "Current: " + String(format: "%.1f", elevation)
        if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: NSNotification.Name("text"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationNLabel.text = defaults.string(forKey: "locationName") ?? "Greenwich, England"
        if !defaults.bool(forKey: "hasRunBefore") {
            showZipcodeAlert()
        } else {
            if defaults.bool(forKey: "useZipcode") {
                lat = defaults.double(forKey: "lat")
                long = defaults.double(forKey: "long")
                timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
                recreateZmanimCalendar()
                showZman(row: defaults.integer(forKey: "currentZman"))
                if defaults.bool(forKey: "zmanWasPicked") {
                    selectOpinion.text = list[defaults.integer(forKey: "currentZman")]
                    showZman(row: defaults.integer(forKey: "currentZman"))
                    time.isHidden = false
                    date.isHidden = false
                    zmanShown = true
                }
                setSunsetTime()
            } else {
                getUserLocation()
            }
        }
    }
    
    func getUserLocation() {
        LocationManager.shared.getUserLocation {
            location in DispatchQueue.main.async { [self] in
                self.lat = location.coordinate.latitude
                self.long = location.coordinate.longitude
                self.timezone = TimeZone.current
                self.recreateZmanimCalendar()
                setSunsetTime()
                self.showZman(row: self.defaults.integer(forKey: "currentZman"))
                if self.defaults.bool(forKey: "zmanWasPicked") {
                    self.selectOpinion.text = self.list[self.defaults.integer(forKey: "currentZman")]
                    self.showZman(row: self.defaults.integer(forKey: "currentZman"))
                    self.time.isHidden = false
                    self.date.isHidden = false
                    self.zmanShown = true
                }
                self.defaults.set(true, forKey: "hasRunBefore")
                self.defaults.set(false, forKey: "useZipcode")
                self.defaults.set(timezone.identifier, forKey: "timezone")
                //let yesterday: Date = calendar.internalCalendar().date(byAdding: .day, value: -1, to: calendar.workingDate)!
                //calendar.workingDate = yesterday

                //let formatter = DateFormatter()
                //formatter.dateFormat = "HH:mm:ss E, d MMM y"
                LocationManager.shared.resolveLocationName(with: location) { locationName in
                    self.locationNLabel.text = locationName!
                }
            }
        }
    }
    
    func showZipcodeAlert() {
        let alert = UIAlertController(title: "Location or Zipcode?", message: "If you do not want the app to know your location, you can enter a zipcode below. Otherwise, it is recommended to use your devices location as this provides more accurate results.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Zipcode"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print(textField!.text!)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((textField?.text)!, completionHandler: { i, j in
                var name = ""
                if let locality = i?.first?.locality {
                    name += locality
                }
                if let adminRegion = i?.first?.administrativeArea {
                    name += ", \(adminRegion)"
                }
                if name.isEmpty {
                    name = "No location name info"
                }
                self.locationNLabel.text = name
                let coordinates = i?.first?.location?.coordinate
                self.lat = coordinates?.latitude ?? 0
                self.long = coordinates?.longitude ?? 0
                self.timezone = (i?.first?.timeZone)!
                self.recreateZmanimCalendar()
                self.setSunsetTime()
                if self.defaults.bool(forKey: "zmanWasPicked") {
                    self.selectOpinion.text = self.list[self.defaults.integer(forKey: "currentZman")]
                    self.showZman(row: self.defaults.integer(forKey: "currentZman"))
                    self.time.isHidden = false
                    self.date.isHidden = false
                    self.zmanShown = true
                }
                self.defaults.set(self.lat, forKey: "lat")
                self.defaults.set(self.long, forKey: "long")
                self.defaults.set(name, forKey: "locationName")
                self.defaults.set(true, forKey: "hasRunBefore")
                self.defaults.set(true, forKey: "useZipcode")
                self.defaults.set(self.timezone.identifier, forKey: "timezone")
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { UIAlertAction in
            alert.dismiss(animated: true) {}
        }))
        alert.addAction(UIAlertAction(title: "Use Location", style: .default, handler: { UIAlertAction in
            self.getUserLocation()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didGetNotification(_ notification: Notification) {
        let amount = notification.object as! String
        elevation = NumberFormatter().number(from: amount)!.doubleValue
        defaults.set(elevation, forKey: "elevation")
        currentElevationLabel.text = "Current: " + amount
        recreateZmanimCalendar()
        showZman(row: currentZman)
        setSunsetTime()
    }
    
    public func recreateZmanimCalendar() {
        let geoLocation = KosherCocoa.GeoLocation.init(latitude: self.lat, andLongitude: self.long, elevation: self.elevation, andTimeZone: timezone)
        zmanimCalendar = ComplexZmanimCalendar(location: geoLocation)
    }
    
    func setSunsetTime() {
        let timeFormatter = DateFormatter()
        if GlobalStruct.roundUp {
            timeFormatter.dateFormat = "h:mm aa"
        } else {
            timeFormatter.dateFormat = "h:mm:ss aa"
        }
        var zman = zmanimCalendar.sunset()
        if GlobalStruct.roundUp {
            zman = zman?.advanced(by: 60)
        }
        self.sunset.text = "Sunset: " + timeFormatter.string(from: zman!)
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
        defaults.set(currentZman, forKey: "currentZman")
        defaults.set(true, forKey: "zmanWasPicked")
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
        if GlobalStruct.roundUp {
            timeFormatter.dateFormat = "h:mm aa"
        } else {
            timeFormatter.dateFormat = "h:mm:ss aa"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM y"
        var zman: Date? = nil
        if list[row] == "72 Zmaniyot Minutes" {
            zman = zmanimCalendar.tzait72Zmanit()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "90 Zmaniyot Minutes" {
            zman = zmanimCalendar.tzait90Zmanit()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "96 Zmaniyot Minutes" {
            zman = zmanimCalendar.tzait96Zmanit()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "120 Zmaniyot Minutes" {
            zman = zmanimCalendar.tzait120Zmanit()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "50 Regular Minutes (NY Only)" {
            zman = zmanimCalendar.tzait50()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "60 Regular Minutes" {
            zman = zmanimCalendar.tzait60()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "72 Regular Minutes" {
            zman = zmanimCalendar.tzait72()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "90 Regular Minutes" {
            zman = zmanimCalendar.tzait90()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "96 Regular Minutes" {
            zman = zmanimCalendar.tzait96()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "120 Regular Minutes" {
            zman = zmanimCalendar.tzait120()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "16.1 degrees" {
            zman = zmanimCalendar.tzais16Point1Degrees()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "18 degrees" {
            zman = zmanimCalendar.tzais18Degrees()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "19.8 degrees" {
            zman = zmanimCalendar.tzais19Point8Degrees()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
        if list[row] == "26 degrees" {
            zman = zmanimCalendar.tzais26Degrees()
            if GlobalStruct.roundUp {
                zman = zman?.advanced(by: 60)
            }
            self.time.text = timeFormatter.string(from: zman!)
            self.date.text = dateFormatter.string(from: zman!)
        }
    }
}

struct GlobalStruct {
    static var useElevation = false
    static var roundUp = false
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
    
    override func sunset() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunset()
        }
        return seaLevelSunset()
    }
    
    override func shaahZmanisGra() -> Double {
        if GlobalStruct.useElevation {
            return temporalHour(fromSunrise: sunrise()!, toSunset: sunset()!)
        }
        return temporalHour(fromSunrise: seaLevelSunrise()!, toSunset: seaLevelSunset()!)
    }
}
