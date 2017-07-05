//
//  MapLibTests.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Дмитрий Барышников on 13.06.17.
//  Copyright © 2017 NextGIS, info@nextgis.co
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import XCTest
@testable import ngmaplib

class MapLibTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVersion() {
        let version = API.instance.version(component: "self")
        XCTAssertTrue(version > 100, "Invalid version \(version)")
        
        let versionStr = API.instance.versionString(component: "self")
        XCTAssertFalse(versionStr.isEmpty, "Invalid version string")
        
        let formatsStr = API.instance.versionString(component: "formats")
        print(formatsStr)
        XCTAssertFalse(formatsStr.isEmpty, "Invalid formats string")
    }
    
    func testJson() {
        do {
            let data = "{\"nextgisweb_ngwcluster\": \"0.0\", \"nextgisweb_basemap\": \"0.0\", \"nextgisweb\": \"3.0\", \"nextgisweb_qgis\": \"0.0\", \"nextgisweb_mapserver\": \"0.0dev\"}"
            let json = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: []) as? [String: Any]
            XCTAssertFalse((json?.isEmpty)!, "Expected not empty")
        }
        catch {
            XCTAssertFalse(true, error as! String)
        }
    }
    
    func testCatalog() {
        let catalog = API.instance.getCatalog()
        let children = catalog.children()
        XCTAssertFalse(children.isEmpty, "Catalog must have at least one children")
        
        for child in children {
            print("Catalog child name: \(child.name), type: \(child.type)")
        }
        
        if(!children.isEmpty) {
            let subChildren = children[0].children()
            XCTAssertFalse(children.isEmpty, "Child must have at least one children")
        
            for child in subChildren {
                print("Catalog child name: ngc://Local connections/\(child.name), type: \(child.type)")
            }
            
            if(!subChildren.isEmpty) {
                let homeChildren = subChildren[0].children()
                XCTAssertFalse(homeChildren.isEmpty, "Child must have at least one children")
                
                for child in homeChildren {
                    print("Catalog child name: ngc://Local connections/\(subChildren[0].name)/\(child.name), type: \(child.type)")
                }
            }
        }
    }
    
    func testMap() {
        let map = API.instance.getMap("default")
        XCTAssertTrue(map != nil, "Map mast be openned or created")
    }
    
    func testURL() {
        let testUrl = "http://demo.nextgis.com"
        let versionUrl = testUrl + "/api/component/pyramid/pkg_version"
        let options = [
            "MAX_RETRY": "5",
            "RETRY_DELAY": "5",
            "TIMEOUT": "10"
        ]
        let versionRequest = Request.get(url: versionUrl, options: options)
        XCTAssertTrue(versionRequest.status > 100 && versionRequest.status < 400, "Get HTTP Status \(versionRequest.status)")
        XCTAssertFalse(versionRequest.value.isEmpty ||
            versionRequest.value == "", "Request result must be not empty")
        
        let versionJSONRequest = Request.getJson(url: versionUrl, options: options)
        XCTAssertTrue(versionRequest.status > 100 && versionJSONRequest.status < 400, "Get HTTP Status \(versionJSONRequest.status)")
        
        let ngwVersion: Double
        
        let versionJSONRequestValue = versionJSONRequest.value as! [String:Any]
        if let ngwVersionStr = versionJSONRequestValue["nextgisweb"] as? String {
            ngwVersion = Double(ngwVersionStr)!
        }
        else {
            ngwVersion = 0.0
        }
        
        XCTAssertTrue(ngwVersion >= 3.0, "Error parse version number")
        
        let httpsResponse = Request.get(url: "https://nextgis.com", options: options)
        XCTAssertTrue(httpsResponse.status > 100 && httpsResponse.status < 400, "HTTPS Not supported. Return code \(httpsResponse.status)")
        
        let imageRequest = Request.getRaw(url: "http://tile.openstreetmap.org/9/309/160.png", options: options)
        XCTAssertTrue(imageRequest.status > 100 && imageRequest.status < 400, "HTTPS Not supported. Return code \(imageRequest.status)")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
