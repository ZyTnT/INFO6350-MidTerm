//
//  ViewController.swift
//  Weather
//
//  Created by Ashish Ashish on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count // You will replace this with arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arr[indexPath.row] // replace this with values from arrCurrentWeather array
        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
//        do{
//            let realm = try Realm()
//            let cities = realm.objects(CityInfo.self)
//            self.arrCityInfo.removeAll()
//            getAllCurrentWeather(Array(cities)).done { currentWeather in
//               self.tblView.reloadData()
//            }
//            .catch { error in
//               print(error)
//            }
//       }catch{
//           print("Error in reading Database \(error)")
//       }
        
        
        
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ... cities.count - 1 {
                promises.append( getCurrentWeather(cities[i].key) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "" // build URL for current weather here
                
                Alamofire.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                  
                    let currentWeather = CurrentWeather()
                    
                    
                    seal.fulfill(currentWeather)
                    
                }
            }
    }

}

