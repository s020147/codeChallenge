//
//  ViewController.swift
//  11health Code Challenge
//
//  Created by dustin on 24/6/2020.
//  Copyright © 2020 Jan. All rights reserved.
//

import UIKit
var vSpinner : UIView?

class ViewController: UIViewController {

    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightLabel: UIView!
    @IBOutlet weak var enterButton: UIButton!
    var timerFlag : Bool = false
    var geoObject : GeoObject?
    var currentInterval : TimeInterval  = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        beginUI()
    }
    @IBAction func enterAction(_ sender: Any) {
        validate()
        updateUI()
    }
    private func validate(){
        guard let zipCode = zipCodeTextField.text, zipCode != "" else{
                showAlert(title: "Empty Zip", message: "")
                return
        }
        if (!zipCode.isNumeric){
            showAlert(title: "Non numeric value for zip", message: "")
            return
        }
        if(!(zipCode.count == 5)){
            showAlert(title: "Zip code needs to be 5 individual numbers", message: "")
            return
        }
    }
    private func updateUI(){
        showSpinner(onView: self.view)
        ServiceSingleton.shared.getGeoInformation(zip: zipCodeTextField.text!, completionHandler: {geoObj,err in
                   if let geoObject = geoObj{
                        self.geoObject = geoObject
                        self.timerFlag = true
                    DispatchQueue.main.async{
                        self.activeUI()
                    }
                   }else{
                    DispatchQueue.main.async{
                        self.showAlert(title: "No zipcode exist in \(self.zipCodeTextField.text!)", message: "")
                    }
            }
               })
    }
    
    
    private func beginUI(){
        timeLabel.text = "00:00:00"
        heightLayoutConstraint.constant = 0.0
        enterButton.alpha = 1
        timeZoneLabel.alpha = 0
    }
    
    private func activeUI(){
        heightLayoutConstraint.constant = 300.0
        enterButton.alpha = 0
        timeZoneLabel.alpha = 1
        updateTimezoneLabel()
        getTimeUntilNewYear()
        self.removeSpinner()
    }
    
    private func updateTimezoneLabel(){
        timeZoneLabel.text = "We are in \(geoObject!.timezone.timezone_identifier) time zone"
    }
    private func updateTimeLabel(timeInterval:TimeInterval){
        DispatchQueue.main.async{
            self.timeLabel.text = timeInterval.stringFromTimeInterval()
        }
    }
    
    private func getTimeUntilNewYear(){
        let currentTime = Date()
        let utcTimeZone = TimeZone(abbreviation: "UTC")!
        let timeZoneAbbreviation = geoObject?.timezone.timezone_abbr
        let currentTimeOfLocale = currentTime.to(timeZone: TimeZone(abbreviation: timeZoneAbbreviation!)!, from: utcTimeZone)
        let time2 = getNewYearsEveDate()
        let differenceBetween = currentTimeOfLocale.distance(to: time2!)
        currentInterval = differenceBetween
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.currentInterval -= 1
            self.updateTimeLabel(timeInterval: self.currentInterval)
            if(!self.timerFlag){
                timer.invalidate()
            }
        }
    }
    
    private func getNewYearsEveDate()->Date?{
        // Get the current year
        let year = Calendar.current.component(.year, from: Date())
        // Get the first day of next year
        if let firstOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1)) {
            // Get the last day of the current year
            let lastSecondOfTheYear = Calendar.current.date(byAdding: .second, value: -1, to: firstOfNextYear)
            return lastSecondOfTheYear!
        }
        return nil
    }

}
extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
            validate()
            updateUI()
           return true
       }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        beginUI()
        timerFlag = false
    }
    
}
extension ViewController{
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
extension Date {
    func to(timeZone outputTimeZone: TimeZone, from inputTimeZone: TimeZone) -> Date {
         let delta = TimeInterval(outputTimeZone.secondsFromGMT(for: self) - inputTimeZone.secondsFromGMT(for: self))
         return addingTimeInterval(delta)
    }
}

extension TimeInterval{
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)

    }
}
