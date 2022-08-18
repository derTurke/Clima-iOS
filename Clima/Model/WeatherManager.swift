import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
  


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?APPID=ef013e4bbd751a4cad67b9983848e680&units=metric"
    
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let url = "\(weatherURL)&q=\(cityName)"
        performRequest(with: url)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longiutde: CLLocationDegrees){
        let url = "\(weatherURL)&lat=\(latitude)&lon=\(longiutde)"
        performRequest(with: url)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJson(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
