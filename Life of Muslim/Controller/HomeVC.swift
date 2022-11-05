//
//  HomeVC.swift
//  Life of Muslim
//
//  Created by Anon's MacBook Pro on 17/10/22.
//

import UIKit
import Adhan
import Alamofire
import SwiftyJSON
import CoreLocation

class HomeVC: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?appid=3f08f42cc5571fd65dfd661f5ba64f75&units=metric"
    
    let APP_ID = "3f08f42cc5571fd65dfd661f5ba64f75"
    
    @IBOutlet weak var cityLocationLbl: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var NextNamazLbl: UILabel!
    
    @IBOutlet weak var FajorNamazView: UIView!
    @IBOutlet weak var JohorNamazView: UIView!
    @IBOutlet weak var AshorNamazView: UIView!
    @IBOutlet weak var MagribNamazView: UIView!
    @IBOutlet weak var IshaNamazView: UIView!
    
    @IBOutlet weak var IftarTimeLbl: UILabel!
    @IBOutlet weak var SahariTimeLbl: UILabel!
    
    @IBOutlet weak var SunriseLbl: UILabel!
    @IBOutlet weak var SunsetLbl: UILabel!
    
    @IBOutlet weak var NextNamajLbl: UILabel!
    
    @IBOutlet weak var ArabicDateLbl: UILabel!
    @IBOutlet weak var EnglishDateLbl: UILabel!
    
    @IBOutlet weak var FajorLbl: UILabel!
    @IBOutlet weak var JohorLbl: UILabel!
    @IBOutlet weak var AshorLbl: UILabel!
    @IBOutlet weak var MagribLbl: UILabel!
    @IBOutlet weak var IshaLbl: UILabel!
    
    let formatter = DateFormatter()
    let quranVC = QuranVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        AdhanLibrary()
        EngDate()
        ArabicDate()
        NamazView(demoView: FajorNamazView)
        NamazView(demoView: JohorNamazView)
        NamazView(demoView: AshorNamazView)
        NamazView(demoView: MagribNamazView)
        NamazView(demoView: IshaNamazView)
        quranVC.parseJSON()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: Arabic date
    func ArabicDate() {
        let formetter = DateFormatter()
        let islamicCelender: Calendar = Calendar(identifier: .islamicCivil)
        formetter.dateFormat = "d MMMM, yyyy"
        let currentDate: Date = Date()
        formetter.calendar = islamicCelender
        let hijriDate = formetter.string(from: currentDate)
        ArabicDateLbl.text = hijriDate
    }
    
    //MARK: Gegorian date
    func EngDate() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+6")
        EnglishDateLbl.text = "\(dateFormatter.string(from: date))"
    }
    
    //MARK: 'Adhan' pod
    func AdhanLibrary() {
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        let coordinates = Coordinates(latitude: 23.777176, longitude: 90.399452)
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = .hanafi
        
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
        {
            
            formatter.timeStyle = .short
            formatter.timeZone = TimeZone(identifier: "Asia/Dhaka")!
            formatter.locale = Locale(identifier: "bn_IN")
            
            FajorLbl.text = formatter.string(from: prayers.fajr)
            JohorLbl.text = formatter.string(from: prayers.dhuhr)
            AshorLbl.text = formatter.string(from: prayers.asr)
            MagribLbl.text = formatter.string(from: prayers.maghrib)
            IshaLbl.text = formatter.string(from: prayers.isha )
            
            SunriseLbl.text = formatter.string(from: prayers.sunrise)
            SunsetLbl.text = formatter.string(from: prayers.maghrib)
            
            SahariTimeLbl.text = formatter.string(from: prayers.fajr)
            IftarTimeLbl.text = formatter.string(from: prayers.maghrib)
            
            let nyc = Coordinates(latitude: 40.7128, longitude: -74.0059)
            let qiblaDirection = Qibla(coordinates: nyc).direction
            print("\n Qibla: \(qiblaDirection)")
            
            
            let prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
        
            let next = prayerTimes?.nextPrayer()
            if next != nil{
                let countdown = prayerTimes!.time(for: next!)
                NextNamajLbl.text = formatter.string(from: countdown)
            }else{
                NextNamajLbl.isHidden = true
                NextNamazLbl.isHidden = true
            }
        }
    }
    
    func NamazView(demoView: UIView) {
        demoView.layer.borderWidth = 1
        demoView.layer.borderColor = UIColor.white.cgColor
        demoView.layer.cornerRadius = 8
    }
}

//MARK: Location Manager setup
extension HomeVC {
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : lat , "lon" : lon, "appid" : APP_ID]
            print(params)
            getWeatherData(url: WEATHER_URL, parameter: params)
        }
    }
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't find the location ERROR: \(error)")
        cityLocationLbl.text = "Dhaka"
    }
    //MARK: - Change City Delegate methods
    func changeCityName(searchCityName: String) {
        print(searchCityName)
        let params : [String : String] = ["q" : searchCityName, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: params)
    }
    
    //MARK: - Networking with Alamofire
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameter : [String : String]) {
        AF.request(url, method: .get, parameters: parameter).responseJSON {
            response in
//            if response.result.isSuccess {
//                print("Ntetworking Successful")
//                let jsonData : JSON = JSON(response.result.value!)
//                //print("JSON DATA:\(jsonData)")
//                self.weatherData(data: jsonData)
//                self.updateUIView()
//            }
//            else{
//                print("Error Getting JSON response : \(response.result.error!)")
//            }
            
            switch response.result {
            case .success(_):
                print("Ntetworking Successful")
                let jsonData : JSON = JSON(response.value!)
                print("JSON DATA:\(jsonData)")
                self.weatherData(data: jsonData)
                self.updateUIView()
            case .failure(_):
                print("Error Getting JSON response : \(String(describing: response.error))")
            }
        }
    }
    
    //MARK: - JSON Parsing
    func weatherData(data : JSON) {
        let tempResult = data["main"]["temp"].doubleValue
        weatherData.Temperature = Int(tempResult - 273.15)
        weatherData.CityId = data["weather"]["0"]["id"].intValue
        weatherData.CityName = data["name"].stringValue
        weatherData.WeatherIcon = weatherData.updateWeatherIcon(condition: weatherData.CityId)
    }
    //MARK: - UI Updates
    func updateUIView() {
        cityLocationLbl.text = weatherData.CityName
        print(weatherData.CityName)
        temperatureLabel.text = String(weatherData.Temperature)
        //weatherIcon.image = UIImage(named: weatherDataModel.WeatherIcon)
    }

}

