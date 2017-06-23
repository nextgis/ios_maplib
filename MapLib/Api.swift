//
//  Api.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 13.06.17.
//  Copyright © 2017 NextGIS, info@nextgis.com
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
//

import Foundation
import ngstore

public class API {
    static let instance = API()
    private let catalog: Catalog
    
    init() {
        // Init library
        let homeDir = NSHomeDirectory()
        let cacheDir = homeDir + "/Library/Caches/ngstore"
        let settingsDir = homeDir + "/Library/Preferences/ngstore"
        
        var gdalData: String = ""
        var certFile: String = ""
//        let gdalData = homeDir + "/Library/Frameworks/ngstore.framework/Resources/gdal"
//        let certFile = homeDir + "/Library/Frameworks/ngstore.framework/Resources/ssl/certs/cert.pem"        
        for bundle in Bundle.allFrameworks {
            if let gdal = bundle.url(forResource: "gdal", withExtension: "") {
                gdalData = gdal.path
            }
            
            if let ssl = bundle.url(forResource: "cert", withExtension: "pem", subdirectory: "ssl/certs") {
                certFile = ssl.path
            }
        }
        

//        let mapStore = homeDir + "/Library/Application Support/ngstore/maps"
//        let dataStore = homeDir + "/Library/Application Support/ngstore/geodata"
//        let projectionsDir = homeDir + "/Library/Application Support/ngstore/projections"
        
        let options = [
            "HOME": homeDir,
            "GDAL_DATA": gdalData,
            "CACHE_DIR": cacheDir,
            "SETTINGS_DIR": settingsDir,
            "SSL_CERT_FILE": certFile,
            "NUM_THREADS": "ALL_CPUS",
            "DEBUG_MODE": "OFF"
        ]
        
        if ngsInit(toArrayOfCStrings(options)) != Int32(COD_SUCCESS.rawValue) {
            print("Init ngstore failed: " + String(cString: ngsGetLastErrorMessage()))
        }
        catalog = Catalog(catalog: ngsCatalogObjectGet("ngc://"))

    }
    
    deinit {
        // Deinit library
        ngsUnInit()
    }
    
    public func version(component: String) -> Int {
        return Int(ngsGetVersion(component))
    }
    
    
    public func versionString(component: String) -> String {
        return String(cString: ngsGetVersionString(component))
    }
    
    public func freeResources(full: Bool) {
        ngsFreeResources(full ? 1 : 0)
    }
    
    public func lastError() -> String {
        return String(cString: ngsGetLastErrorMessage())
    }
    
    func URLRequest(method: ngsURLRequestType, url: String, options: [String: String]? = nil) ->
        (status: Int, data: [UInt8]?){
            if let requestResultPtr = ngsURLRequest(method, url, options == nil ||
                (options?.isEmpty)! ? nil : toArrayOfCStrings(options)) {
            let requestResult = requestResultPtr.pointee
            let status = Int(requestResult.status)
            
            if requestResult.dataLen == 0 {
                return (543, nil)
            }
               
            let buffer = [UInt8](repeating: 0, count: Int(requestResult.dataLen + 1))
            memcpy(UnsafeMutableRawPointer(mutating: buffer), requestResult.data, Int(requestResult.dataLen))
                
            ngsURLRequestDestroyResult(requestResultPtr)
                
            return (status, buffer)
        }
        return (543, nil)
    }
    
    public func getCatalog() -> Catalog {
        return catalog
    }
    
   
    /*
    func getMap(name: String) -> Map {
     
    }*/
}
