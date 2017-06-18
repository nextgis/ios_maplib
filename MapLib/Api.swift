//
//  Api.swift
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
//

import Foundation
import ngstore

public class HTTPResponse {
    
}

public class NGApi {
    static let instance = NGApi()
    
    init() {
        // Init library
        let cacheDir = NSHomeDirectory() + "/Library/Caches"
        let settingsDir = NSHomeDirectory() + "/Library/Preferences"
        let gdalData = NSHomeDirectory() + "/Library/Frameworks/ngstore.framework/Resources/gdal"
//        let mapStore = NSHomeDirectory() + "/Library/Application Support/maps"
//        let dataStore = NSHomeDirectory() + "/Library/Application Support/geodata"
//        let projectionsDir = NSHomeDirectory() + "/Library/Application Support/projections"
        
        let options = [
            "GDAL_DATA=" + gdalData,
            "CACHE_DIR=" + cacheDir,
            "SETTINGS_DIR=" + settingsDir,
            "NUM_THREADS=ALL_CPUS",
            "DEBUG_MODE=OFF"
        ]
        
        ngsInit(toArrayOfCStrings(options))
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
    
    // https://stackoverflow.com/a/40189217/2901140
    private func toArrayOfCStrings(_ values: [String]) -> UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> {
        let buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: values.count + 1)
        for (index, value) in values.enumerated() {
            buffer[index] = UnsafeMutablePointer<Int8>(mutating: (value as NSString).utf8String!)
        }
        buffer[values.count] = nil
        return buffer

    }
    
    /*
    func HTTPGet(url: String) -> HTTPResponse {
        
    }

    func HTTPDelete(url: String) -> HTTPResponse {
        
    }
    
    func HTTPPost(url: String, payload: String) -> HTTPResponse {
        
    }
    
    func HTTPPut(url: String, payload: String) -> HTTPResponse {
        
    }
    
    func getMap(name: String) -> Map {
        
    }*/
}
