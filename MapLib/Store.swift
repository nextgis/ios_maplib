//
//  Store.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 19.07.17.
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

/// In memory spatial data storage. After class instance destruction all data will be loose.
public class MemoryStore: Object {
    
    /// Memory storage description file extension.
    public static let ext = ".ngmem"
    
    /// Create feature class in storage.
    ///
    /// - Parameters:
    ///   - name: Feature class name.
    ///   - geometryType: Geometry type.
    ///   - epsg: Spatial reference EPSG code.
    ///   - fields: Feature class fields.
    ///   - options: Any other create option if form of key-value dictionary.
    /// - Returns: FeatureClass class instance or nil.
    public func createFeatureClass(name: String,
                                   geometryType: Geometry.GeometryType,
                                   epsg: Int32,
                                   fields: [Field],
                                   options: [String: String]) -> FeatureClass? {
        
        var fullOptions = options
        fullOptions["GEOMETRY_TYPE"] = Geometry.geometryTypeToName(geometryType)
        fullOptions["TYPE"] = "\(CAT_FC_MEM.rawValue)"
        fullOptions["EPSG"] = "\(epsg)"
        fullOptions["FIELD_COUNT"] = "\(fields.count)"
        for index in 0..<fields.count {
            fullOptions["FIELD_\(index)_TYPE"] = Field.fieldTypeToName(fields[index].type)
            fullOptions["FIELD_\(index)_NAME"] = fields[index].name
            fullOptions["FIELD_\(index)_ALIAS"] = fields[index].alias
            if fields[index].defaultValue != nil {
                fullOptions["FIELD_\(index)_DEFAULT_VAL"] = fields[index].defaultValue
            }
        }
        
        if ngsCatalogObjectCreate(object, name, toArrayOfCStrings(fullOptions)) ==
            Int32(COD_SUCCESS.rawValue) {
            if let featureClassObject = child(name: name) {
                return FeatureClass(copyFrom: featureClassObject)
            }
        }        
        return nil
    }
}

/// Spatial data storage. This is geopackage file with specific additions.
public class Store: Object {
    
    /// Spatial data storage file extension.
    public static let ext = ".ngst"
    
    /// Create feature class in storage.
    ///
    /// - Parameters:
    ///   - name: Feature class name.
    ///   - geometryType: Geometry type.
    ///   - fields: Feature class fields.
    ///   - options: Any other create option if form of key-value dictionary.
    /// - Returns: FeatureClass class instance or nil.
    public func createFeatureClass(name: String,
                                   geometryType: Geometry.GeometryType,
                                   fields: [Field],
                                   options: [String: String]) -> FeatureClass? {
        
        var fullOptions = options
        fullOptions["GEOMETRY_TYPE"] = Geometry.geometryTypeToName(geometryType)
        fullOptions["TYPE"] = "\(CAT_FC_GPKG.rawValue)"
        fullOptions["FIELD_COUNT"] = "\(fields.count)"
        for index in 0..<fields.count {
            fullOptions["FIELD_\(index)_TYPE"] = Field.fieldTypeToName(fields[index].type)
            fullOptions["FIELD_\(index)_NAME"] = fields[index].name
            fullOptions["FIELD_\(index)_ALIAS"] = fields[index].alias
            if fields[index].defaultValue != nil {
                fullOptions["FIELD_\(index)_DEFAULT_VAL"] = fields[index].defaultValue
            }
        }
        
        if ngsCatalogObjectCreate(object, name, toArrayOfCStrings(fullOptions)) ==
            Int32(COD_SUCCESS.rawValue) {
            if let featureClassObject = child(name: name) {
                return FeatureClass(copyFrom: featureClassObject)
            }
        }
        
        return nil
    }
    
    /// Create table in storage.
    ///
    /// - Parameters:
    ///   - name: Table name.
    ///   - fields: Table fields.
    ///   - options: Any other create option if form of key-value dictionary.
    /// - Returns: Table class instance or nil.
    public func createTable(name: String, fields: [Field],
                            options: [String: String]) -> Table? {
        
        var fullOptions = options
        fullOptions["TYPE"] = "\(CAT_TABLE_GPKG.rawValue)"
        fullOptions["FIELD_COUNT"] = "\(fields.count)"
        for index in 0..<fields.count {
            fullOptions["FIELD_\(index)_TYPE"] = Field.fieldTypeToName(fields[index].type)
            fullOptions["FIELD_\(index)_NAME"] = fields[index].name
            fullOptions["FIELD_\(index)_ALIAS"] = fields[index].alias
        }
        
        if ngsCatalogObjectCreate(object, name, toArrayOfCStrings(fullOptions)) ==
            Int32(COD_SUCCESS.rawValue) {
            if let tableObject = child(name: name) {
                return Table(copyFrom: tableObject)
            }
        }
        
        return nil
    }

}

/// Edit operation type. This is enumerator of edit operation types.
///
/// - NOP: No operation.
/// - CREATE_FEATURE: Create feature/row.
/// - CHANGE_FEATURE: Change feature/row.
/// - DELETE_FEATURE: Delete feature/row.
/// - DELETE_ALL_FEATURES: Delete all features.
/// - CREATE_ATTACHMENT: Create new attachment
/// - CHANGE_ATTACHMENT: Change attachment name and/or description
/// - DELETE_ATTACHMENT: Delete attachment
/// - DELETE_ALL_ATTACHMENTS: Delete all attachmetns
public enum EditOperationType {
    case NOP, CREATE_FEATURE, CHANGE_FEATURE, DELETE_FEATURE, DELETE_ALL_FEATURES, CREATE_ATTACHMENT, CHANGE_ATTACHMENT, DELETE_ATTACHMENT, DELETE_ALL_ATTACHMENTS
}

/// Edit operation for logging properties.
public struct EditOperation {
    public var fid: Int64
    public var aid: Int64
    public var rid: Int64
    public var arid: Int64
    public var operation: EditOperationType
    
    init(operation: ngsEditOperation) {
        printMessage("EditOperation -- fid: \(operation.fid), aid: \(operation.aid), rid: \(operation.rid), arid: \(operation.arid)")
        self.fid = operation.fid
        self.aid = operation.aid
        self.rid = operation.rid
        self.arid = operation.arid
        
        switch operation.code {
        case CC_CREATE_FEATURE:
            self.operation = .CREATE_FEATURE
        case CC_CHANGE_FEATURE:
            self.operation = .CHANGE_FEATURE
        case CC_DELETE_FEATURE:
            self.operation = .DELETE_FEATURE
        case CC_DELETEALL_FEATURES:
            self.operation = .DELETE_ALL_FEATURES
        case CC_CREATE_ATTACHMENT:
            self.operation = .CREATE_ATTACHMENT
        case CC_CHANGE_ATTACHMENT:
            self.operation = .CHANGE_ATTACHMENT
        case CC_DELETE_ATTACHMENT:
            self.operation = .DELETE_ATTACHMENT
        case CC_DELETEALL_ATTACHMENTS:
            self.operation = .DELETE_ALL_ATTACHMENTS
        default:
            self.operation = .NOP
        }
    }
    
    var rawOperation: ngsEditOperation {
        get {
            var rawOperation: ngsChangeCode = CC_NOP
            switch self.operation {
            case .CREATE_FEATURE:
                rawOperation = CC_CREATE_FEATURE
            case .CHANGE_FEATURE:
                rawOperation = CC_CHANGE_FEATURE
            case .DELETE_FEATURE:
                rawOperation = CC_DELETE_FEATURE
            case .DELETE_ALL_FEATURES:
                rawOperation = CC_DELETEALL_FEATURES
            case .CREATE_ATTACHMENT:
                rawOperation = CC_CREATE_ATTACHMENT
            case .CHANGE_ATTACHMENT:
                rawOperation = CC_CHANGE_ATTACHMENT
            case .DELETE_ATTACHMENT:
                rawOperation = CC_DELETE_ATTACHMENT
            case .DELETE_ALL_ATTACHMENTS:
                rawOperation = CC_DELETEALL_ATTACHMENTS
            default:
                rawOperation = CC_NOP
            }
            
            return ngsEditOperation(fid: self.fid, aid: self.aid, code: rawOperation, rid: self.rid, arid: self.arid)
        }
    }
}

/// Spatial referenced raster or image
public class Raster: Object {
    
    var isOpened: Bool {
        get {
            return ngsDatasetIsOpened(object) == Int32(COD_SUCCESS.rawValue)
        }
        set {
            if newValue {
                ngsDatasetOpen(object, 96, nil)
            }
            else {
                ngsDatasetClose(object)
            }
        }
    }
    
    /// Cache tiles for some area for TMS datasource.
    ///
    /// - Parameters:
    ///   - bbox: Area to cache.
    ///   - zoomLevels: Zoom levels to cache.
    ///   - callback: Callback function which executes periodically indicating progress.
    /// - Returns: True on success.
    public func cacheArea(bbox: Envelope, zoomLevels: [Int8],
                          callback: (func: ngstore.ngsProgressFunc,
        data: UnsafeMutableRawPointer)? = nil) -> Bool {
        var zoomLevelsValue = ""
        for zoomLevel in zoomLevels {
            if(!zoomLevelsValue.isEmpty) {
                zoomLevelsValue += ","
            }
            zoomLevelsValue += "\(zoomLevel)"
        }
        let options = [
            "MINX" : "\(bbox.minX)",
            "MINY" : "\(bbox.minY)",
            "MAXX" : "\(bbox.maxX)",
            "MAXY" : "\(bbox.maxY)",
            "ZOOM_LEVELS" : zoomLevelsValue
        ]
        return ngsRasterCacheArea(object, toArrayOfCStrings(options),
                                              callback == nil ? nil : callback!.func,
                                              callback == nil ? nil : callback!.data) ==
            Int32(COD_SUCCESS.rawValue)
    }
}

/// Non spatial table.
public class Table: Object {
    
    /// Fields array
    public var fields: [Field] = []

    var batchModeValue = false
    
    /// Enable/disable batch mode property. The sqlite journal will be swith on/off.
    public var batchMode: Bool {
        get {
            return batchModeValue
        }
        set(enable) {
            ngsFeatureClassBatchMode(object, enable ? 1 : 0)
            batchModeValue = enable
        }
    }
    
    /// Feature/row count readonly property.
    public var count: Int64 {
        get {
            return ngsFeatureClassCount(object)
        }
    }
    
    override init(copyFrom: Object) {
        
        // Add fields
        if let fieldsList = ngsFeatureClassFields(copyFrom.object) {
            var count: Int = 0
            while (fieldsList[count].name != nil) {
                let fName = String(cString: fieldsList[count].name)
                let fAlias = String(cString: fieldsList[count].alias)
                let fType = Field.FieldType(rawValue: fieldsList[count].type)
                
//                printMessage("Add field \(count) - name: \(fName), alias: \(fAlias), type: \(fType ?? Field.FieldType.UNKNOWN) to '\(copyFrom.name)'")
                
                let fieldValue = Field(name: fName, alias: fAlias, type: fType!)
                fields.append(fieldValue)
                count += 1
            }
            ngsFree(fieldsList)
        }
        
        super.init(copyFrom: copyFrom)
    }
    
    /// Create new feature/row in memory.
    ///
    /// - Returns: New feature class instane or nil.
    public func createFeature() -> Feature? {
        if let handle = ngsFeatureClassCreateFeature(object) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    /// Insert feature into table.
    ///
    /// - Parameters:
    ///   - feature: Feature/row to insert.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func insertFeature(_ feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassInsertFeature(object, feature.handle, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Update feature/row.
    ///
    /// - Parameters:
    ///   - feature: Feature/row to update.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func updateFeature(_ feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassUpdateFeature(object, feature.handle, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete feature/row.
    ///
    /// - Parameters:
    ///   - id: Feature/row identificator.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func deleteFeature(id: Int64, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeature(object, id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete feature/row.
    ///
    /// - Parameters:
    ///   - feature: Feature/row to delete.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func deleteFeature(feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeature(object, feature.id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete all features/rows in table.
    ///
    /// - Parameter logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func deleteFeatures(logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeatures(object, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Reset reading features/rows.
    public func reset() {
        ngsFeatureClassResetReading(object)
    }
    
    /// Get next feature/row.
    ///
    /// - Returns: Feature class instance or nil.
    public func nextFeature() -> Feature? {
        if let handle = ngsFeatureClassNextFeature(object) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    /// Get feature/row by identificator.
    ///
    /// - Parameter index: Feature/row
    /// - Returns: Feature class instance or nil.
    public func getFeature(index: Int64) -> Feature? {
        if let handle = ngsFeatureClassGetFeature(object, index) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    /// Get feature/row by remote identificator.
    ///
    /// - Parameter remoteId: remote identificator.
    /// - Returns: Feature class instance or nil.
    public func getFeature(remoteId: Int64) -> Feature? {
        if let handle = ngsStoreFeatureClassGetFeatureByRemoteId(object, remoteId) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    /// Search field index and type by field name.
    ///
    /// - Parameter name: Field name.
    /// - Returns: Tuple with index and type. If field not exists the index will be negative and field type will be UNKNOWN.Get e
    public func fieldIndexAndType(by name: String) -> (index: Int32, type: Field.FieldType) {
        var count: Int32 = 0
        for field in fields {
            if field.name == name {
                return (count, field.type)
            }
            count += 1
        }
        return (-1, Field.FieldType.UNKNOWN)
    }

    /// Get edit operations log.
    ///
    /// - Returns: EditOperation class array. It may be empty.
    public func editOperations() -> [EditOperation] {
        var out: [EditOperation] = []
        if let op = ngsFeatureClassGetEditOperations(object) {
            var count = 0
            while op[count].fid != -1 {
                let opItem = EditOperation(operation: op[count])
                
                count += 1
                if opItem.operation == .NOP {
                    continue
                }
                
                out.append(opItem)
            }
            
            return out
        }
        return out
    }
    
    
    /// Delete edit operation from log.
    ///
    /// - Parameter editOperation: EditOperation to delete.
    public func delete(editOperation: EditOperation) {
        ngsFeatureClassDeleteEditOperation(object, editOperation.rawOperation)
    }
}

/// Spatial table.
public class FeatureClass: Table {
    
    /// Geometry type of feature class.
    public let geometryType: Geometry.GeometryType
    
    override init(copyFrom: Object) {
        geometryType = Geometry.GeometryType(rawValue:
            Int32(ngsFeatureClassGeometryType(copyFrom.object))) ?? .NONE
        
        super.init(copyFrom: copyFrom)
    }
    
    /// Create vector overviews to speedup drawing. This is a synchronous method.
    ///
    /// - Parameters:
    ///   - force: If true the previous overviews will be deleted.
    ///   - zoomLevels: The list of zoom levels to generate.
    ///   - callback: Callback function to show process and cancel creation if needed.
    /// - Returns: True on success.
    public func createOverviews(force: Bool, zoomLevels: [Int8],
                                callback: (func: ngstore.ngsProgressFunc,
        data: UnsafeMutableRawPointer)? = nil) -> Bool {
        
        printMessage("create overviews: \(zoomLevels)")
        
        var zoomLevelsValue = ""
        for zoomLevel in zoomLevels {
            if(!zoomLevelsValue.isEmpty) {
                zoomLevelsValue += ","
            }
            zoomLevelsValue += "\(zoomLevel)"
        }
        let options = [
            "FORCE" : force ? "ON" : "OFF",
            "ZOOM_LEVELS" : zoomLevelsValue
        ]
        return ngsFeatureClassCreateOverviews(object, toArrayOfCStrings(options),
                                              callback == nil ? nil : callback!.func,
                                              callback == nil ? nil : callback!.data) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Clear any filters set on feature class.
    ///
    /// - Returns: True on success.
    public func clearFilters() -> Bool {
        let result = ngsFeatureClassSetFilter(object, nil, nil) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
    
    /// Set spatial filter.
    ///
    /// - Parameter envelope: Features intesect with envelope will be returned via nextFeature.
    /// - Returns: True on success.
    public func setSpatialFilter(envelope: Envelope) -> Bool {
        let result = ngsFeatureClassSetSpatialFilter(object,
                                               envelope.minX, envelope.minY,
                                               envelope.maxX, envelope.maxY) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
    
    /// Set spatial filter.
    ///
    /// - Parameter geometry: Features intesect with geometry will be returned via nextFeature.
    /// - Returns: True on success.
    public func setSpatialFilter(geometry: Geometry) -> Bool {
        let result = ngsFeatureClassSetFilter(object, geometry.handle, nil) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
    
    /// Set attribute filter.
    ///
    /// - Parameter query: SQL WHERE clause.
    /// - Returns: True on success.
    public func setAttributeFilter(query: String) -> Bool {
        let result = ngsFeatureClassSetFilter(object, nil, query) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
    
    /// Set spatial and attribute filtes.
    ///
    /// - Parameters:
    ///   - geometry: Features intesect with geometry will be returned via nextFeature.
    ///   - query: SQL WHERE clause.
    /// - Returns: True on success.
    public func setFilters(geometry: Geometry, query: String) -> Bool {
        let result = ngsFeatureClassSetFilter(object, geometry.handle, query) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
}

/// FeatureClass/Table filed class.
public class Field {
    
    /// Field name.
    public let name: String
    
    /// Field alias.
    public let alias: String
    
    /// Field type.
    public let type: FieldType
    
    /// Field default value.
    public let defaultValue: String?
    
    /// Field type enum.
    ///
    /// - UNKNOWN: Unknown type.
    /// - INTEGER: Integer type.
    /// - REAL: Real type.
    /// - STRING: String type.
    /// - DATE: Date/time type.
    public enum FieldType: Int32 {
        case UNKNOWN = -1, INTEGER = 0, REAL = 2, STRING = 4, DATE = 11
    }
    
    /// Init field with values.
    ///
    /// - Parameters:
    ///   - name: Field name.
    ///   - alias: Field alias.
    ///   - type: Field type.
    ///   - defaultValue: Default value or nil.
    public init(name: String, alias: String, type: FieldType, defaultValue: String? = nil) {
        self.name = name
        self.alias = alias
        self.type = type
        self.defaultValue = defaultValue
    }
    
    /// Field type name string.
    ///
    /// - Parameter fieldType: Field type.
    /// - Returns: Name string.
    static func fieldTypeToName(_ fieldType: FieldType) -> String {
        switch fieldType {
        case .INTEGER:
            return "INTEGER"
        case .REAL:
            return "REAL"
        case .STRING:
            return "STRING"
        case .DATE:
            return "DATE_TIME"
        default:
            return "STRING"
        }
    }
}

