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
import UIKit
import ngstore

public func getAPI() -> API {
    return API.instance
}

func notifyFunction(uri: UnsafePointer<Int8>?, code: ngsChangeCode) -> Swift.Void {
    switch code {
    case CC_TOKEN_EXPIRED:
        API.instance.onAuthNotify(url: String(cString: uri!))
        return
    case CC_CREATE_FEATURE, CC_CHANGE_FEATURE, CC_DELETE_FEATURE, CC_DELETEALL_FEATURES:
        API.instance.onMapViewNotify(url: String(cString: uri!))
        return
    default:
        return
    }
}

public class API {
    public static let instance = API()
    
    private let catalog: Catalog
    private let cacheDir: String

    private var mapsDir: Object?
    private var geodataDir: Object?
    private var authArray: [Auth] = []
    private var mapViewArray: [MapView] = []
    
    init() {
        // Init library
        let homeDir = NSHomeDirectory()
        cacheDir = homeDir + "/Library/Caches/ngstore"
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
        
        let options = [
            "HOME": homeDir,
            "GDAL_DATA": gdalData,
            "CACHE_DIR": cacheDir,
            "SETTINGS_DIR": settingsDir,
            "SSL_CERT_FILE": certFile,
            "NUM_THREADS": "4", //"ALL_CPUS", // 
            "DEBUG_MODE": Constants.debugMode ? "ON" : "OFF"
        ]
        
        if ngsInit(toArrayOfCStrings(options)) != Int32(COD_SUCCESS.rawValue) {
            printError("Init ngstore failed: " + String(cString: ngsGetLastErrorMessage()))
        }
        catalog = Catalog(catalog: ngsCatalogObjectGet("ngc://"))
        
        printMessage("\n home dir: \(homeDir)\n settings: \(settingsDir)\n cache dir: \(cacheDir)\n GDAL data dir: \(gdalData)")
        
        if let libDir = catalog.childByPath(path: "ngc://Local connections/Home/Library") {
            let appSupportDir = Catalog.getOrCreateFolder(libDir, "Application Support")
            if appSupportDir == nil {
                //thow error
                printError("Application Support directory not found")
                return
            }
            
            let ngstoreDir = Catalog.getOrCreateFolder(appSupportDir, "ngstore")
            if ngstoreDir == nil {
                //thow error
                printError("ngstore directory not found")
                return
            }
            
            mapsDir = Catalog.getOrCreateFolder(ngstoreDir, "maps")
            geodataDir = Catalog.getOrCreateFolder(ngstoreDir, "geodata")
            
        } else {
            mapsDir = nil
            geodataDir = nil
            // thow error
            printError("Library directory not found")
        }
        
        
//        let mapStore = homeDir + "/Library/Application Support/ngstore/maps"
//        let dataStore = homeDir + "/Library/Application Support/ngstore/geodata"
//        let projectionsDir = homeDir + "/Library/Application Support/ngstore/projections"
        
        ngsAddNotifyFunction(notifyFunction, Int32(CC_ALL.rawValue))
    }
    
    deinit {
        // Deinit library
        ngsUnInit()
    }
    
    private static func getOrCreateFolder(_ parent: Object!, _ name: String) -> Object? {
        if let dir = parent.child(name: name) {
            return dir
        }
        
        return parent.createDirectory(name: name)
    }
    
    /// Returns library version as number
    ///
    /// - Parameter component: May be self, gdal, sqlite, tiff, jpeg, png, jsonc, proj, geotiff, expat, iconv, zlib, openssl
    /// - Returns: version number
    public func version(component: String) -> Int {
        return Int(ngsGetVersion(component))
    }
    
    
    /// Returns library version as string
    ///
    /// - Parameter component: May be self, gdal, sqlite, tiff, jpeg, png, jsonc, proj, geotiff, expat, iconv, zlib, openssl
    /// - Returns: version string
    public func versionString(component: String) -> String {
        return String(cString: ngsGetVersionString(component))
    }
    
    public func freeResources(full: Bool) {
        ngsFreeResources(full ? 1 : 0)
    }
    
    
    /// Returns last error message
    ///
    /// - Returns: message string
    public func lastError() -> String {
        return String(cString: ngsGetLastErrorMessage())
    }
    
    
    /// Executes URL request
    ///
    /// - Parameters:
    ///   - method: request type (GET, POST, PUT, DELETE)
    ///   - url: URL to request
    ///   - options: request options (POST payload or etc.)
    /// - Returns: result structure with return code and raw data buffer
    func URLRequest(method: ngsURLRequestType, url: String, options: [String: String]? = nil) ->
        (status: Int, data: [UInt8]?){
            if let requestResultPtr = ngsURLRequest(method, url,
                                                    toArrayOfCStrings(options)) {
            let requestResult = requestResultPtr.pointee
            let status = Int(requestResult.status)
            
            if requestResult.dataLen == 0 {
                return (543, nil)
            }
               
            let buffer = [UInt8](repeating: 0, count: Int(requestResult.dataLen + 1))
            memcpy(UnsafeMutableRawPointer(mutating: buffer), requestResult.data, Int(requestResult.dataLen))
            printMessage("Get \(requestResult.dataLen) data")
                
            ngsURLRequestResultFree(requestResultPtr)
                
                
            return (status, buffer)
        }
        return (543, nil)
    }
    
    public func getCatalog() -> Catalog {
        return catalog
    }
    
    public func getMap(_ name: String) -> Map? {
        if mapsDir == nil {
            printError("Maps dir undefined. Cannot find map.")
            return nil
        }
        
        let mapPath = (mapsDir?.path)! + Catalog.separator + name + Map.ext
        var mapId = ngsMapOpen(mapPath)
        if mapId == 0 {
            printWarning("Map \(mapPath) is not exists. Create it")
            mapId = ngsMapCreate(name, "default map", 3857,
                                 -20037508.34, -20037508.34,
                                 20037508.34, 20037508.34)
            if mapId == 0 { return nil }
        }
        else {
            printMessage("Get map with ID: \(mapId)")
        }
        
        return Map(id: mapId, path: mapPath)
    }
    
    public func getStore(_ name: String) -> Store? {
        if geodataDir == nil {
            printError("GeoData dir undefined. Cannot find store.")
            return nil
        }
        
        var newName = name
        if !newName.hasSuffix(Store.ext) {
            newName += Store.ext
        }
        
        let storePath = (geodataDir?.path)! + Catalog.separator + newName
        var store = geodataDir?.child(name: newName)
        if store == nil {
            printWarning("Store \(storePath) is not exists. Create it")
            let options = [
                "TYPE" : "\(CAT_CONTAINER_NGS.rawValue)",
                "CREATE_UNIQUE": "OFF"
            ]
            store = geodataDir?.create(name: name, options: options)
        }
        
        if store == nil {
            return nil
        }
        
        return Store(copyFrom: store!)
    }
    
    public func getDataDirectory() -> Object? {
        return geodataDir
    }
    
    public func getTmpDirectory() -> Object? {
        return catalog.childByPath(path: "ngc://Local connections/Home/tmp")
    }
    
    public func md5(string: String) -> String {
        return String(cString: ngsMD5(string))
    }
    
    func addAuth(auth: Auth) -> Bool {
        if ngsURLAuthAdd(auth.getURL(), toArrayOfCStrings(auth.options())) ==
            Int32(COD_SUCCESS.rawValue) {
            authArray.append(auth)
            return true
        }
        return false
    }
    
    func removeAuth(auth: Auth) {
        if ngsURLAuthDelete(auth.getURL()) == Int32(COD_SUCCESS.rawValue) {
            if let index = authArray.index(of: auth) {
                authArray.remove(at: index)
            }
        }
    }
    
    func onAuthNotify(url: String) {
        for auth in authArray {
            auth.onRefreshTokenFailed(url: url)
        }
    }
    
    func addMapView(_ view: MapView) {
        mapViewArray.append(view)
    }

    func removeMapView(_ view: MapView) {
        if let index = mapViewArray.index(of: view) {
            mapViewArray.remove(at: index)
        }

    }
    
    func onMapViewNotify(url: String) {
        for view in mapViewArray {
            view.scheduleDraw(drawState: .REFILL)
        }
    }
    
    func createJsonDocument() -> JsonDocumentH {
        return ngsJsonDocumentCreate()
    }
}
