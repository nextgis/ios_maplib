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
                print("Catalog child name: ngc://\(child.name), type: \(child.type)")
            }
            
            if(!subChildren.isEmpty) {
                let homeChildren = subChildren[0].children()
                XCTAssertFalse(homeChildren.isEmpty, "Child must have at least one children")
                
                for child in homeChildren {
                    print("Catalog child name: ngc://\(subChildren[0].name)/\(child.name), type: \(child.type)")
                }
            }
        }
        
//        CatalogObjectH catalog = ngsCatalogObjectGet("ngc://");
//        ngsCatalogObjectInfo* pathInfo = ngsCatalogObjectQuery(catalog, 0);
//        ASSERT_NE(pathInfo, nullptr);
//        size_t count = 0;
//        while(pathInfo[count].name) {
//            count++;
//        }
//        ASSERT_GE(count, 1);
//        CPLString path2test = CPLSPrintf("ngc://%s", pathInfo[0].name);
//        ngsFree(pathInfo);
//        
//        CatalogObjectH path2testObject = ngsCatalogObjectGet(path2test);
//        pathInfo = ngsCatalogObjectQuery(path2testObject, 0);
//        ASSERT_NE(pathInfo, nullptr);
//        count = 0;
//        while(pathInfo[count].name) {
//            std::cout << count << ". " << path2test << "/" <<  pathInfo[count].name << '\n';
//            count++;
//        }
//        EXPECT_GE(count, 1);
//        path2test = CPLSPrintf("%s/%s", path2test.c_str(), pathInfo[0].name);
//        ngsFree(pathInfo);
    }
    
    func testURL() {
        let testUrl = "http://demo.nextgis.com"
        let versionUrl = testUrl + "/api/component/pyramid/pkg_version"
        let versionRequest = Request.get(url: versionUrl)
        XCTAssertTrue(versionRequest.status > 100 && versionRequest.status < 400, "Get HTTP Status \(versionRequest.status)")
        XCTAssertFalse(versionRequest.value.isEmpty ||
            versionRequest.value == "", "Request result must be not empty")
        
        let versionJSONRequest = Request.getJson(url: versionUrl)
        XCTAssertTrue(versionRequest.status > 100 && versionJSONRequest.status < 400, "Get HTTP Status \(versionJSONRequest.status)")
        
        let ngwVersion: Double
        if let ngwVersionStr = versionJSONRequest.value?["nextgisweb"] as? String {
            ngwVersion = Double(ngwVersionStr)!
        }
        else {
            ngwVersion = 0.0
        }
        
        XCTAssertTrue(ngwVersion >= 3.0, "Error parse version number")
        
        let options: [String: String] = [
            //"UNSAFESSL": "ON"
        :]
        let httpsResponse = Request.get(url: "https://nextgis.com", options: options)
        XCTAssertTrue(httpsResponse.status > 100 && httpsResponse.status < 400, "HTTPS Not supported. Return code \(httpsResponse.status)")
        
        let httpsResponse2 = Request.get(url: "https://nextgis.com", options: options)
        XCTAssertTrue(httpsResponse2.status > 100 && httpsResponse2.status < 400, "HTTPS Not supported. Return code \(httpsResponse2.status)")   
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
