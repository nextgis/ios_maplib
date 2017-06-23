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
    private let object: CatalogObjectH!
    
    init(name: String, type: Int, object: CatalogObjectH) {
        self.name = name
        self.type = type
        self.object = object
    }
    
    public func children() -> [Object] {
        let queryResult = ngsCatalogObjectQuery(object, 0)
        var out: [Object] = []
        if (queryResult != nil) {
            var count: Int = 0
            while (queryResult![count].name != nil) {
                out.append(Object(name: String(cString: queryResult![count].name),
                                  type: Int(queryResult![count].type),
                                  object: queryResult![count].object))
                count += 1
            }
            
            ngsFree(queryResult)
        }
        
        return out
    }
}

public class Catalog {
    private let catalog: CatalogObjectH
    public let separator = "/"
    
    init(catalog: CatalogObjectH!) {
        self.catalog = catalog
    }
    
    public func getCurrentDirectory() -> String {
        return String(cString: ngsGetCurrentDirectory())
    }
    
    public func children() -> [Object] {
        let queryResult = ngsCatalogObjectQuery(catalog, 0) // TODO: Add filter support
        var out: [Object] = []
        if (queryResult != nil) {
            var count: Int = 0
            while (queryResult![count].name != nil) {
                out.append(Object(name: String(cString: queryResult![count].name),
                                  type: Int(queryResult![count].type),
                                  object: queryResult![count].object))
                count += 1
            }
            
            ngsFree(queryResult)
        }
        
        return out
    }
    
    
}
