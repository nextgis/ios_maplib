//
//  MapLibTests.swift
//  MapLibTests
//
//  Created by Дмитрий Барышников on 13.06.17.
//  Copyright © 2017 NextGIS. All rights reserved.
//

import XCTest
@testable import MapLib

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
        let version = NGApi.instance.version(component: "self")
        XCTAssertTrue(version > 100, "Invalid version \(version)")
        
        let versionStr = NGApi.instance.versionString(component: "self")
        XCTAssertFalse(versionStr.isEmpty, "Invalid version string")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
