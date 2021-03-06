//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Yutong Zhen on 10/28/21.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftSpinner
import SwiftyJSON
import RealmSwift

class SearchCityViewController: UIViewController  {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblView: UITableView!
    
    var arr = [CityInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        searchBar.delegate = self
    }
}


//MARK: Table view handlers

extension SearchCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(arr[indexPath.row].cityName), \(arr[indexPath.row].stateName), \(arr[indexPath.row].countryName)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addCityToDB(for: indexPath.row)
    }
    
    func addCityToDB(for row: Int){
        let city = arr[row].cityName
        let alert = UIAlertController(title: "Add City", message: "Get weather for \(city)", preferredStyle:.alert)
        
        let OK = UIAlertAction(title: "OK", style: .default) { action in
            print(row)
            self.addCity(for: row)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }
        alert.addAction(OK)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addCity(for index: Int){
        
        if isCityAlreadyAdded(for: index){
            arr.removeAll()
            tblView.reloadData()
            return
        }
        
        // add city in DB
        let loc = arr[index]
        do {
            let realm = try Realm()
            try realm.write{
                realm.add(loc, update: Realm.UpdatePolicy.all)
            }
        }catch{
            print("Unable to add city in the database")
        }
        
        // clear table and searchbar and reload data
        arr.removeAll()
        searchBar.text = ""
        tblView.reloadData()
        
    }
    
    func isCityAlreadyAdded(for index: Int) -> Bool{
        
        let loc = arr[index]
        
        let realm = try! Realm()
        if realm.object(ofType: CityInfo.self, forPrimaryKey: loc.locationKey) != nil {
            return true
        }
        return false
    }
    
}

extension SearchCityViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if search text is less than 2 dont do anything
        guard searchBar.text!.count > 2 else {
            // if empty delete everything
            if searchBar.text!.isEmpty {
                arr.removeAll()
                tblView.reloadData()
            }
            return;
        }
        
        // get values for the search string
        getAutocomplete(for: searchBar.text!)
    }
    
    func getAutocompleteURL(_ cityStr: String) -> String{
    
        return "\(Key.autocompleteURL)?q=\(cityStr)&apikey=\(Key.apiKey)"
    }
    
    func getAutocomplete(for cityStr: String){
        
        // get url
        let autCompleteURL = getAutocompleteURL(cityStr)
        
        // call API and get data
        AF.request(autCompleteURL).responseJSON { response in
            
            if response.error != nil {
                print("Error in getting Autocomplete Error: \(response.error?.localizedDescription)")
                return
            }
            
            let autoCompleteJSON : [JSON] = JSON(response.value).arrayValue
            
            self.arr.removeAll()
            for city in autoCompleteJSON {
                let citydata = CityInfo()
                citydata.locationKey = city["Key"].stringValue
                citydata.cityName    = city["LocalizedName"].stringValue
                citydata.countryName = city["Country"]["LocalizedName"].stringValue
                citydata.stateName   = city["AdministrativeArea"]["ID"].stringValue
                self.arr.append(citydata)
                print(city)
            }
            self.tblView.reloadData()
            
        }
    }
}
