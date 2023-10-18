//
//  detailViewController.swift
//  hw2tj2557
//
//  Created by Tharun Kumar on 9/27/23.
//

import UIKit

class detailViewController: UIViewController {

    @IBOutlet weak var WeatherIcon: UIImageView!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var statusWeather: UILabel!
    @IBOutlet weak var WeatherDegree: UILabel!
    
    var name:String=""
    var stat:String=""
    var pic: UIImage?=nil
    var deg: String=""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.weatherCondition.text=name
        self.WeatherIcon.image=pic
        self.statusWeather.text=stat
        self.WeatherDegree.text=deg
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
