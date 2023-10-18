//
//  firstTableViewController.swift
//  hw2tj2557
//
//  Created by Tharun Kumar on 9/20/23.
//

import UIKit
import CoreLocation
import Foundation

class MyCustomCell: UITableViewCell {
    @IBOutlet weak var WeatherCondition: UILabel!
    @IBOutlet weak var WeatherDegree: UILabel!
    @IBOutlet weak var WeatherIcon: UIImageView!
    @IBOutlet weak var statusWeather: UILabel!
}
    

class firstTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var Locations: [Weather] = []
    let locationManager=CLLocationManager()
    var coords:CLLocation?
    
    //var temps: [String] = ["52°F","48°F","50°F","54°F","49°F","81°F"]
    
   // var ImageWeather: [UIImage] = [UIImage(named: "cloudy")!, UIImage(named: "sunny")!, UIImage(named: "sunny")!, UIImage(named: "cloudy")!, UIImage(named: "rainy")!, UIImage(named: "sunny")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let citiesCoordinates = [
                (name: "Current Location", lat: coords?.coordinate.latitude ?? 0, long: coords?.coordinate.longitude ?? 0),
                (name: "Detroit", lat: 42.3314, long: -83.0458),
                (name: "Chicago", lat: 41.8781, long: -87.6298),
                (name: "Los Angeles", lat: 34.0522, long: -118.2437)
            ]

            for city in citiesCoordinates {
                let lat = city.lat
                let long = city.long
                let cityName = city.name
                reqWeather(latitude: lat, longitude: long, cityName: cityName)
            }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupInitLocation()
    }
    
    //Location
    func setupInitLocation(){
        locationManager.delegate=self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, coords == nil{
            coords=locations.first
            locationManager.stopUpdatingLocation()
            if let latitude = coords?.coordinate.latitude, let longitude = coords?.coordinate.longitude {
                        reqWeather(latitude: latitude, longitude: longitude, cityName: "Current Location")
                    }
        }
    }
    
    func reqWeather(latitude: Double, longitude: Double, cityName: String) {
        let url = "http://api.weatherapi.com/v1/current.json?key=d8f8811a2d294b2db6532203230610&q=\(latitude),\(longitude)&aqi=no"

        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            // Validation
            guard let data = data, error == nil else {
                print("Error with Data for \(cityName)")
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(Weather.self, from: data)

                // Create Location and Current objects
                let location = Location(
                    name: weatherResponse.location.name,
                    region: weatherResponse.location.region,
                    country: weatherResponse.location.country,
                    lat: weatherResponse.location.lat,
                    lon: weatherResponse.location.lon,
                    tz_id: weatherResponse.location.tz_id,
                    localtime_epoch: weatherResponse.location.localtime_epoch,
                    localtime: weatherResponse.location.localtime
                )

                let current = Current(
                    last_updated_epoch: weatherResponse.current.last_updated_epoch,
                    last_updated: weatherResponse.current.last_updated,
                    temp_c: weatherResponse.current.temp_c,
                    temp_f: weatherResponse.current.temp_f,
                    is_day: weatherResponse.current.is_day,
                    condition: Condition(
                        text: weatherResponse.current.condition.text,
                        icon: weatherResponse.current.condition.icon,
                        code: weatherResponse.current.condition.code
                    ),
                    wind_mph: weatherResponse.current.wind_mph,
                    wind_kph: weatherResponse.current.wind_kph,
                    wind_degree: weatherResponse.current.wind_degree,
                    wind_dir: weatherResponse.current.wind_dir,
                    pressure_mb: weatherResponse.current.pressure_mb,
                    pressure_in: weatherResponse.current.pressure_in,
                    precip_mm: weatherResponse.current.precip_mm,
                    precip_in: weatherResponse.current.precip_in,
                    humidity: weatherResponse.current.humidity,
                    cloud: weatherResponse.current.cloud,
                    feelslike_c: weatherResponse.current.feelslike_c,
                    feelslike_f: weatherResponse.current.feelslike_f,
                    vis_km: weatherResponse.current.vis_km,
                    vis_miles: weatherResponse.current.vis_miles,
                    uv: weatherResponse.current.uv,
                    gust_mph: weatherResponse.current.gust_mph,
                    gust_kph: weatherResponse.current.gust_kph
                )

                // Create a Weather object using Location and Current
                let weatherEntry = Weather(
                    location: location,
                    current: current
                )

                // Append the Weather object to Locations
                self.Locations.append(weatherEntry)

                DispatchQueue.main.async {
                    // Reload the table view on the main thread to reflect the updated data
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON for \(cityName): \(error)")
            }
        }).resume()
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Weather"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCustomCell

        // Configure the cell...
        let weather = Locations[indexPath.row]

        cell.WeatherCondition.text = weather.location.name
        cell.statusWeather.text = weather.current.condition.text
        cell.WeatherDegree.text = String(weather.current.temp_f) + "°F"
        // Fetch and set the image
        if let iconURLString = weather.current.condition.icon as? String, let iconURL = URL(string: "https:" + iconURLString) {
            URLSession.shared.dataTask(with: iconURL) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.WeatherIcon.image = UIImage(data: data)
                        // Store the image data in case you need it later
                        //cell.iconImageData = data
                    }
                } else {
                    // Handle error or set a placeholder image
                    DispatchQueue.main.async {
                        cell.WeatherIcon.image = UIImage(named: "placeholderImage")
                    }
                }
            }.resume()
        } else {
            // Handle missing or invalid icon URL
            cell.WeatherIcon.image = UIImage(named: "placeholderImage")
        }

        return cell
    }



    
    struct Weather: Decodable {
        let location: Location
        let current: Current
    }
    
    struct Location: Codable {
        let name: String
        let region: String
        let country: String
        let lat: Double
        let lon: Double
        let tz_id: String
        let localtime_epoch: Int
        let localtime: String
    }

    struct Current: Codable {
        let last_updated_epoch: Int
        let last_updated: String
        let temp_c: Double
        let temp_f: Double
        let is_day: Int
        let condition: Condition
        let wind_mph: Double
        let wind_kph: Double
        let wind_degree: Int
        let wind_dir: String
        let pressure_mb: Double
        let pressure_in: Double
        let precip_mm: Double
        let precip_in: Double
        let humidity: Int
        let cloud: Int
        let feelslike_c: Double
        let feelslike_f: Double
        let vis_km: Double
        let vis_miles: Double
        let uv: Double
        let gust_mph: Double
        let gust_kph: Double
    }

    struct Condition: Codable {
        let text: String
        let icon: String
        let code: Int
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    Locations.remove(at: indexPath.row)
                    //temps.remove(at: indexPath.row)
                    //ImageWeather.remove(at: indexPath.row)
                    
                    // Delete the row from the table view with animation
                    tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Reorder your data source arrays to reflect the new order of rows
        let itemToMove = Locations.remove(at: sourceIndexPath.row)
        //let tempToMove = temps.remove(at: sourceIndexPath.row)
        //let imageToMove = ImageWeather.remove(at: sourceIndexPath.row)

        Locations.insert(itemToMove, at: destinationIndexPath.row)
        //temps.insert(tempToMove, at: destinationIndexPath.row)
        //ImageWeather.insert(imageToMove, at: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false for rows you don't want to be movable
        return indexPath.row != 0
    }
    
    @IBOutlet weak var toolbar: UIToolbar!

    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if isEditing {
                setEditing(false, animated: true)
                sender.title = "Edit"
            } else {
                setEditing(true, animated: true)
                sender.title = "Done"
            }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destVC = segue.destination as! detailViewController
            let selectedWeather = Locations[indexPath.row]

            destVC.name = selectedWeather.location.name
            destVC.stat = selectedWeather.current.condition.text
            destVC.deg = String(selectedWeather.current.temp_f)+"°F"
            // Fetch and set the image asynchronously
        if let iconURLString = selectedWeather.current.condition.icon as? String, let iconURL = URL(string: "https:" + iconURLString) {
                URLSession.shared.dataTask(with: iconURL) { data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            destVC.WeatherIcon.image = UIImage(data: data)
                        }
                    } else {
                        // Handle error or set a placeholder image
                        DispatchQueue.main.async {
                            destVC.WeatherIcon.image = UIImage(named: "placeholderImage")
                        }
                    }
                }.resume()
        } else {
                // Handle missing or invalid icon URL
            destVC.WeatherIcon.image = UIImage(named: "placeholderImage")
            }
        }
    }

}
