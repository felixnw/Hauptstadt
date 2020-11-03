//
//  ContentView.swift
//  Hauptstadt WatchKit Extension
//
//  Created by Felix on 10/26/20.
//
// 38.946087, -77.064571
let restTest = "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/Transportation_WebMercator/MapServer/5/query?where=1%3D1&outFields=ADDRESS,LATITUDE,LONGITUDE,NUMBER_OF_BIKES,NUMBER_OF_EMPTY_DOCKS&geometry=-77.092%2C38.938&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelContains&distance=500&units=esriSRUnit_Meter&returnGeometry=false&outSR=4326&f=json"

let restPartOne = "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/Transportation_WebMercator/MapServer/5/query?where=1%3D1&outFields=ADDRESS,LATITUDE,LONGITUDE,NUMBER_OF_BIKES,NUMBER_OF_EMPTY_DOCKS&geometry="
var restLong = -77.064
let restPartTwo = "%2C"
var restLat = 38.946
let restPartThree = "&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelContains&distance="
var restDistance = 500;
let restPartFour = "units=esriSRUnit_Meter&returnGeometry=false&outSR=4326&f=json"

import SwiftUI
import CoreLocation

let json = """
{"displayFieldName":"ADDRESS","fieldAliases":{"ADDRESS":"ADDRESS","LATITUDE":"LATITUDE","LONGITUDE":"LONGITUDE","NUMBER_OF_BIKES":"NUMBER_OF_BIKES","NUMBER_OF_EMPTY_DOCKS":"NUMBER_OF_EMPTY_DOCKS"},"fields":[{"name":"ADDRESS","type":"esriFieldTypeString","alias":"ADDRESS","length":100},{"name":"LATITUDE","type":"esriFieldTypeDouble","alias":"LATITUDE"},{"name":"LONGITUDE","type":"esriFieldTypeDouble","alias":"LONGITUDE"},{"name":"NUMBER_OF_BIKES","type":"esriFieldTypeInteger","alias":"NUMBER_OF_BIKES"},{"name":"NUMBER_OF_EMPTY_DOCKS","type":"esriFieldTypeInteger","alias":"NUMBER_OF_EMPTY_DOCKS"}],"features":[{"attributes":{"ADDRESS":"American University East Campus","LATITUDE":38.936298,"LONGITUDE":-77.087128,"NUMBER_OF_BIKES":0,"NUMBER_OF_EMPTY_DOCKS":19}},{"attributes":{"ADDRESS":"Ward Circle / American University","LATITUDE":38.938736,"LONGITUDE":-77.087171,"NUMBER_OF_BIKES":4,"NUMBER_OF_EMPTY_DOCKS":9}}]}
"""

var loc: CLLocation?

class LocationFinder: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    func initiate() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func get() {
            currentLocation=locationManager.location
            loc = currentLocation
    }
}

struct Stations: Codable {
    var features: [Station]
}

struct Station: Codable, Identifiable {
    var id = UUID()
    var address: String
    var lat: Double
    var long: Double
    var bikes: Int
    var docks: Int

    enum CodingKeys: String, CodingKey {
        case address = "ADDRESS"
        case lat = "LATITUDE"
        case long = "LONGITUDE"
        case bikes = "NUMBER_OF_BIKES"
        case docks = "NUMBER_OF_EMPTY_DOCKS"
    }
}

let testData: [Station] = [
    Station(address: "Ward Circle / American University", lat: 38.946087, long: -77.064571, bikes: 4, docks: 9),
    Station(address: "American University East Campus", lat: 38.946087, long: -77.064571, bikes: 0, docks: 19)]
    

var stations = [Station]()

func getAPI() {
    let queryPartOne = restPartOne+String(restLong)+restPartTwo+String(restLat)
    let queryPartTwo = restPartThree+String(restDistance)+restPartFour
    let query = queryPartOne + queryPartTwo

    if let url = URL(string: query) {
        if let data = try? Data(contentsOf: url) {
            parser(json: data)
        }
    }
}

func parser(json: Data) {
    let decoder = JSONDecoder()

    if let jsonStations = try? decoder.decode(Stations.self, from: json) {
        stations = jsonStations.features
        NSLog(stations[0].address)
    }
}

struct detailView: View {
    var body: some View {
        VStack {
            
        }
    }
}

struct ContentView: View {
    var navigationTitle = "Nearby"
    let locationFinder = LocationFinder()
    @State var long:CLLocationDegrees?
    @State var lat: CLLocationDegrees?
    
    var body: some View {
        NavigationView() {
            VStack {
                Button(action: {
                    self.locationFinder.initiate()
                    self.locationFinder.get()
                    self.long = (loc?.coordinate.longitude)!
                    self.lat = (loc?.coordinate.latitude)!
                    restLat = lat!
                    restLong = long!
                    getAPI()
                }) {
                    Text("Refresh")
                }
                
                List(testData) {Station in
                    NavigationLink(destination: Text(Station.address)
                    ) {
                        VStack {
                            Text(Station.address)
                                .font(.footnote)
                            HStack {
                                Text(String(Station.bikes))
                                    .font(.title)
                                Text("|")
                                    .font(.title)
                                Text(String(Station.docks))
                                    .font(.title)
                            }
                            Text("Bikes | Docks")
                                .font(.caption)
                            Text("XXXft")
                                .font(.footnote)
                        }
                    }
                    .listStyle(CarouselListStyle())
                        .navigationBarTitle(navigationTitle)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
