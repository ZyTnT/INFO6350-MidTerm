//
//  CityInfo.swift
//  WeatherApp
//
//  Created by Yutong Zhen on 10/28/21.
//
import Foundation
import RealmSwift


class CityInfo : Object {
    @objc dynamic var locationKey: String = ""
    @objc dynamic var cityName: String = ""
    @objc dynamic var countryName: String = ""
    @objc dynamic var stateName: String = ""
    
    override static func primaryKey() -> String? {
        return "locationKey"
    }
    

}
