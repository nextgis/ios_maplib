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
        // TODO: init library
    }
    
    deinit {
        // Deinit library
        ngsUnInit()
    }
    
    func version(component: String) -> Int {
        return Int(ngsGetVersion(component))
    }
    
    
    func versionString(component: String) -> String {
        return String(cString: ngsGetVersionString(component))
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
