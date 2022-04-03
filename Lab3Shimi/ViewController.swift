//
//  ViewController.swift
//  Lab3Shimi
//
//  Created by Shimi Joseph on 2022-04-01.
//

import UIKit
import CoreLocation

class ViewController: UIViewController ,UITextFieldDelegate{
    @IBOutlet weak var locationLabela: UILabel!
    @IBOutlet weak var LocationFirst: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var textCode: UILabel!
    let locationManager = CLLocationManager()
//    let locationDelegate = MyLocationDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchText.delegate = self
        locationManager.delegate = self
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue,.systemYellow,.systemMint])
        weatherImage.preferredSymbolConfiguration = config
        weatherImage.image = UIImage(systemName: "cloud.sleet")
  }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.endEditing(true)
        print(textField.text ?? "")
        getWeather(search: textField.text)
        return true
    }

  @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
       }
    private func displayLocation(locations: String){
        labelLocation.text = locations
    }
    @IBAction func onSearchTapped(_ sender: UIButton) {
        searchText.endEditing(true)
        getWeather(search: searchText.text)
       
    }
    private func getWeather(search: String?) {
        guard let search = search else {
            return
        }
        //step 1 : get url
        let url = getUrl(search: search)
        guard let url = url  else{
            print("could not get URL")
            return
        }
        //step 2:Create a UTLSession
        let session = URLSession.shared
        //step 3: Create task for session
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("network call completed")

            guard error == nil else {
                print("received error")
              
                return
            }

            guard let data = data else {
                print("no data found")
                return
            }

            if let weather = self.parseJson(data: data) {
                print(weather.location.name)
                print(weather.current.temp_c)
                print(weather.current.condition.text)
                print(weather.current.condition.code)
                DispatchQueue.main.async {
                    self.locationLabela.text = weather.location.name
                    self.temperatureLabel.text = "\(weather.current.temp_c)C"
                    self.textCode.text = weather.current.condition.text
                   let  code = weather.current.condition.code
                   if (code == 1000) {
                        self.weatherImage.image = UIImage(systemName: "cloud.moon.fill")
                        }
                    else if (code == 1183){
                        self.weatherImage.image = UIImage(systemName: "cloud.drizzle")
                    }
                    else if (code == 1003){
                        self.weatherImage.image = UIImage(systemName: "cloud.moon")
                    }
                    else if(code == 1009){
                        self.weatherImage.image = UIImage(systemName: "cloud.fog")
                    }
}
            }
          
        }

        //step 4 : Start the task
        dataTask.resume()
    }
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        do{
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        }
        catch{
            print("Error parsing weather")
            print(error)
        }
        return weatherResponse
    }
    private func getUrl(search: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "2f3ca681b02f4145a3735054223003"
        let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(search)"
        return URL(string: url)
}
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got location")
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("latlng: (\(latitude),\(longitude))")
           self.getWeather(search: "\(latitude),\(longitude)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}
struct WeatherResponse: Decodable{
    let location : Location
    let current : Weather
}
struct Location: Decodable{
    let name : String
}
struct Weather: Decodable {
    let temp_c : Float
    let condition : WeatherCondition

}

struct WeatherCondition: Decodable {
    let text : String
    let code : Int
  

}



