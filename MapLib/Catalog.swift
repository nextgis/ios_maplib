//
//  Catalog.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 22.06.17.
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

import Foundation
import ngstore


public class Object {
    public let type: Int
    public let name: String
    public let path: String
    private let object: CatalogObjectH!
    
    init(name: String, type: Int, path: String, object: CatalogObjectH) {
        self.name = name
        self.type = type
        self.path = path
        self.object = object
    }
    
    public func children() -> [Object] {
        var out: [Object] = []
        
        if let queryResult = ngsCatalogObjectQuery(object, 0) { // TODO: Add filter support
            var count: Int = 0
            while (queryResult[count].name != nil) {
                out.append(Object(name: String(cString: queryResult[count].name),
                                  type: Int(queryResult[count].type),
                                  path: path + Catalog.separator + String(cString: queryResult[count].name),
                                  object: queryResult[count].object))
                count += 1
            }
            
            ngsFree(queryResult)
        }
        
        return out
    }
    
    public func child(name: String) -> Object? {
        let childrenArray = children()
        for childItem in childrenArray {
            if childItem.name == name {
                return childItem
            }
        }
        return nil
    }
    
    public func create(name: String, options: [String:String] = [:]) -> Object? {
        if(ngsCatalogObjectCreate(object, name, options.isEmpty ? nil :
            toArrayOfCStrings(options)) == Int32(COD_SUCCESS.rawValue)) {
            return child(name: name) //TODO: Return catalog handler and create Object in place
        }
        return nil
    }
    
    public func createTMS(name: String, url: String, epsg: Int, z_min: UInt8, z_max: UInt8) -> Object? {
        let options = [
            "TYPE": "\(CAT_RASTER_TMS.rawValue)",
            "CREATE_UNIQUE": "OFF",
            "url": url,
            "epsg": "\(epsg)",
            "z_min": "\(z_min)",
            "z_max": "\(z_max)"
        ]
        return create(name: name, options: options)
    }
    
    public func createDirectory(name: String) -> Object? {
        let options = [
            "TYPE": "\(CAT_CONTAINER_DIR.rawValue)",
            "CREATE_UNIQUE": "OFF"
        ]
        return create(name: name, options: options)
    }
}

public class Catalog: Object {
    static public let separator = "/"
    
    init(catalog: CatalogObjectH!) {
        super.init(name: "Catalog", type: Int(CAT_CONTAINER_ROOT.rawValue),
                   path: "ngc://", object: catalog)
    }
    
    public func getCurrentDirectory() -> String {
        return String(cString: ngsGetCurrentDirectory())
    }
    
    public func childByPath(path: String) -> Object? {
        if let objectHandler = ngsCatalogObjectGet(path) {
            let objectType = Int(ngsCatalogObjectType(objectHandler).rawValue)
            let objectName = String(cString: ngsCatalogObjectName(objectHandler))
            return Object(name: objectName, type: objectType,
                          path: path,
                          object: objectHandler)
        }
        return nil
    }
}
