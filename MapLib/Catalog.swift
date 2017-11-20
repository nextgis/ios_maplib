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


/// Catalog object class. This is base class for all catalog objects.
public class Object {
    public let type: Int
    public let name: String
    public let path: String
    let object: CatalogObjectH!
    
    
    /// Catalog object type
    public enum ObjectType: UInt32 {
        case UNKNOWN
        case FOLDER
        case GEOJSON
        case TMS
        case FEATURE_CLASS
        
        public var rawValue: UInt32 {
            switch self {
            case .UNKNOWN:
                return 0
            case .FOLDER:
                return CAT_CONTAINER_DIR.rawValue
            case .GEOJSON:
                return CAT_FC_GEOJSON.rawValue
            case .TMS:
                return CAT_RASTER_TMS.rawValue
            case .FEATURE_CLASS:
                return CAT_FC_GPKG.rawValue
            }
        }
    }
    
    /// Get catalog object metadata.
    ///
    /// - Parameter domain: Domain to search metadata. May  be empty srting.
    /// - Returns: Dictionary of key-value.
    public func getMetadata(for domain: String) -> [String: String] {
        if let rawArray = ngsCatalogObjectMetadata(object, domain) {
            var count = 0
            var out: [String: String] = [:]
            while(rawArray[count] != nil) {
                let metadataItem = String(cString: rawArray[count]!)
                if let splitIndex = metadataItem.range(of: "=") {
                    let key = metadataItem.substring(to: splitIndex.lowerBound)
                    let value = metadataItem.substring(from: metadataItem.index(splitIndex.lowerBound, offsetBy: 1))
                    out[key] = value
                }
                count += 1
            }
            return out
        }
        return [:]
    }
    
    /// Set catalog object metadata.
    ///
    /// - Parameters:
    ///   - name: Key name.
    ///   - value: Key value.
    ///   - domain: Domain name.
    /// - Returns: True on success.
    public func setMetadata(item name: String, value: String, domain: String) -> Bool {
        return ngsCatalogObjectSetMetadataItem(object, name, value, domain) == Int32(COD_SUCCESS.rawValue)
    }
    
    init(name: String, type: Int, path: String, object: CatalogObjectH) {
        self.name = name
        self.type = type
        self.path = path
        self.object = object
    }
    
    init(object: CatalogObjectH) {
        self.object = object
        self.name = String(cString: ngsCatalogObjectName(object))
        self.type = Int(ngsCatalogObjectType(object).rawValue)
        self.path = "" // TODO: Do we need path?
    }
    
    init(copyFrom: Object) {
        self.name = copyFrom.name
        self.type = copyFrom.type
        self.path = copyFrom.path
        self.object = copyFrom.object
    }
    
    /// Compare current catalog object with other.
    ///
    /// - Parameter object: Catalog object to compare.
    /// - Returns: True if equal.
    public func isSame(_ object: Object) -> Bool {
        return self.object == object.object
    }
    
    /// Get catalog object children.
    ///
    /// - Returns: Array of catalog object class instances.
    public func children() -> [Object] {
        var out: [Object] = []
        
        if let queryResult = ngsCatalogObjectQuery(object, 0) { // TODO: Add filter support
            var count: Int = 0
            while (queryResult[count].name != nil) {
//                printMessage("Name \(String(cString: queryResult[count].name)) in folder \(name)")
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
    
    /// Get child by name.
    ///
    /// - Parameter name: Catalog object child name.
    /// - Returns: Catalog object child instance or nil.
    public func child(name: String) -> Object? {
        for childItem in children() {
            if childItem.name == name {
                return childItem
            }
        }
        return nil
    }
    
    /// Refresh catalog object. Rerad children.
    public func refresh() {
        ngsCatalogObjectRefresh(object)
    }
    
    /// Create new catalog object.
    ///
    /// - Parameters:
    ///   - name: New object name.
    ///   - options: Dictionary describing new catalog objec. The keys are created object dependent. The mandatory key is:
    ///     - TYPE - this is string value of type ObjectType
    /// - Returns: Created catalog object instance or nil.
    public func create(name: String, options: [String:String] = [:]) -> Object? {
        if(ngsCatalogObjectCreate(object, name, toArrayOfCStrings(options)) ==
            Int32(COD_SUCCESS.rawValue)) {
            return child(name: name)
        }
        return nil
    }   
    
    /// Create TMS datasource
    ///
    /// - Parameters:
    ///   - name: TMS connection name
    ///   - url: TMS url. {x}, {y} and {z} must be present in url string
    ///   - epsg: EPSG code of TMS
    ///   - z_min: Minimum zoom. Default is 0
    ///   - z_max: Maximum zoom. Default is 18
    ///   - fullExtent: Full extent of TMS datasource. Depends on tile schema and projection
    ///   - limitExtent: Data extent. Maybe equal or less of fullExtent
    ///   - cacheExpires: Time in seconds to remove cahced tiles
    ///   - options: Addtional options as key: value array
    /// - Returns: Catalog object or nil
    public func createTMS(name: String, url: String, epsg: Int32,
                          z_min: UInt8, z_max: UInt8, fullExtent: Envelope,
                          limitExtent: Envelope, cacheExpires: Int,
                          options: [String: String] = [:]) -> Object? {
        var createOptions = [
            "TYPE": "\(ObjectType.TMS.rawValue)",
            "CREATE_UNIQUE": "OFF",
            "url": url,
            "epsg": "\(epsg)",
            "z_min": "\(z_min)",
            "z_max": "\(z_max)",
            "x_min": "\(fullExtent.minX)",
            "y_min": "\(fullExtent.minY)",
            "x_max": "\(fullExtent.maxX)",
            "y_max": "\(fullExtent.maxY)",
            "cache_expires": "\(cacheExpires)",
            "limit_x_min": "\(limitExtent.minX)",
            "limit_y_min": "\(limitExtent.minY)",
            "limit_x_max": "\(limitExtent.maxX)",
            "limit_y_max": "\(limitExtent.maxY)"
        ]
        
        for option in options {
            createOptions[option.key] = option.value
        }
        
        return create(name: name, options: createOptions)
    }
    
    /// Create new directory.
    ///
    /// - Parameter name: Directory name.
    /// - Returns: Created directory or nil.
    public func createDirectory(name: String) -> Object? {
        let options = [
            "TYPE": "\(ObjectType.FOLDER.rawValue)",
            "CREATE_UNIQUE": "OFF"
        ]
        return create(name: name, options: options)
    }
    
    /// Delete catalog object.
    ///
    /// - Returns: True on success.
    public func delete() -> Bool {
        return ngsCatalogObjectDelete(object) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete catalog object with name.
    ///
    /// - Parameter name: Object name to delete.
    /// - Returns: True on success.
    public func delete(name: String) -> Bool {
        if let deleteObject = child(name: name) {
            return deleteObject.delete()
        }
        return false
    }
    
    /// Copy current catalog object to destination object.
    ///
    /// - Parameters:
    ///   - type: Output catalog object type.
    ///   - destination: Destination catalog object.
    ///   - move: Move object. This object will be deleted.
    ///   - options: Key-value dictionary. This will affect how the copy will be performed.
    /// - Returns: True on success.
    public func copy(as type: ObjectType, in destination: Object, move: Bool,
                     with options: [String: String] = [:]) -> Bool {
        
        var createOptions = [
            "TYPE": "\(type.rawValue)",
            "MOVE": move ? "ON" : "OFF"
        ]
        
        for option in options {
            createOptions[option.key] = option.value
        }

        return ngsCatalogObjectCopy(object, destination.object,
                                    toArrayOfCStrings(createOptions), nil, nil) ==
        Int32(COD_SUCCESS.rawValue)
    }

    /// Check if type is non spatial table.
    ///
    /// - Parameter type: Type to check.
    /// - Returns: True if this type belongs to table types.
    public static func isTable(_ type: Int) -> Bool {
        return type >= 1500 && type <= 1999
    }
    
    /// Check if type is raster.
    ///
    /// - Parameter type: Type to check.
    /// - Returns: True if this type belongs to raster types.
    public static func isRaster(_ type: Int) -> Bool {
        return type >= 1000 && type <= 1499
    }
    
    /// Check if type is featureclass.
    ///
    /// - Parameter type: Type to check.
    /// - Returns: True if this type belongs to featureclass types.
    public static func isFeatureClass(_ type: Int) -> Bool {
        return type >= 500 && type <= 999
    }
    
    /// Check if type is container (catalog object which can hold other objects).
    ///
    /// - Parameter type: Type to check.
    /// - Returns: True if this type belongs to container types.
    public static func isContainer(_ type: Int) -> Bool {
        return type >= 50 && type <= 499
    }
    
    /// Force catalog object instance to table.
    ///
    /// - Parameter table: Catalog object instance.
    /// - Returns: Table class instance or nil.
    public static func forceChildTo(table: Object) -> Table? {
        if isTable(table.type) {
            return Table(copyFrom: table)
        }
        return nil
    }
    
    /// Force catalog object instance to featureclass.
    ///
    /// - Parameter featureClass: Catalog object instance.
    /// - Returns: FeatureClass class instance or nil.
    public static func forceChildTo(featureClass: Object) -> FeatureClass? {
        if isFeatureClass(featureClass.type) {
            return FeatureClass(copyFrom: featureClass)
        }
        return nil
    }
    
    /// Force catalog object instance to raster.
    ///
    /// - Parameter raster: Catalog object instance.
    /// - Returns: Raster class instance or nil.
    public static func forceChildTo(raster: Object) -> Raster? {
        if isRaster(raster.type) {
            return Raster(copyFrom: raster)
        }
        return nil
    }
    
    /// Force catalog object instance to memory store.
    ///
    /// - Parameter memoryStore: Catalog object instance.
    /// - Returns: MemoryStore class instance or nil.
    public static func forceChildTo(memoryStore: Object) -> MemoryStore? {
        if memoryStore.type == 71 {
            return MemoryStore(copyFrom: memoryStore)
        }
        return nil
    }
}

/// The catalog root object class.
public class Catalog: Object {
    
    /// The separator in catalog paths
    static public let separator = "/"
    
    init(catalog: CatalogObjectH!) {
        super.init(name: "Catalog", type: Int(CAT_CONTAINER_ROOT.rawValue),
                   path: "ngc://", object: catalog)
    }
    
    
    /// Get current directory
    ///
    /// - Returns: Get current directory. This is file system path
    public func getCurrentDirectory() -> String {
        return String(cString: ngsGetCurrentDirectory())
    }
    
    /// Get catalog child by file system path.
    ///
    /// - Parameter path: File system path.
    /// - Returns: Catalog object class instance or nil.
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
    
    static func getOrCreateFolder(_ parent: Object!, _ name: String) -> Object? {
        if let dir = parent.child(name: name) {
            return dir
        }
        
        return parent.createDirectory(name: name)
    }
}
