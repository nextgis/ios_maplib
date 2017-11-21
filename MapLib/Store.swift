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

/// In memory spatial data storage. After destruction all data will be loose.
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

/// Spatial data storage. This is geopackage file with library additions.
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

/// Edit operation type.
///
/// - NOP: No operation.
/// - CREATE_FEATURE: Create feature/row.
/// - CHANGE_FEATURE: Change feature/row.
/// - DELETE_FEATURE: Delete feature/row.
/// - DELETE_ALL_FEATURES: Delete all features.
/// - : This is enumerator of edit operation types.
public enum EditOperationType {
    case NOP, CREATE_FEATURE, CHANGE_FEATURE, DELETE_FEATURE, DELETE_ALL_FEATURES,
    CREATE_ATTACHMENT, CHANGE_ATTACHMENT, DELETE_ATTACHMENT, DELETE_ALL_ATTACHMENTS
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

/// Feature or row from featureclass or table.
public class Feature {
    let handle: FeatureH!
    
    /// FeatureClass or Table class instance.
    public let table: Table?
    
    /// Feature/row identificator.
    public var id: Int64 {
        get {
            return ngsFeatureGetId(handle)
        }
    }
    
    /// Feature/row geometry.
    public var geometry: Geometry? {
        get {
            if let handle = ngsFeatureGetGeometry(handle) {
                return Geometry(handle: handle)
            }
            else {
                return nil
            }
        }
        set(value) {
            if table is FeatureClass && value != nil {
                ngsFeatureSetGeometry(handle, value!.handle)
            }
            else {
                printError("This is not Feature class. Don't add geometry")
            }
        }
    }
    
    /// Feature/row remote identificator or -1.
    public var remoteId: Int64 {
        get {
            return ngsStoreFeatureGetRemoteId(handle)
        }
        set(id) {
            ngsStoreFeatureSetRemoteId(handle, id)
        }
    }
    
    init(handle: FeatureH, table: Table? = nil) {
        self.handle = handle
        self.table = table
    }
    
    deinit {
        ngsFeatureFree(handle)
    }
    
    /// Check if field set.
    ///
    /// - Parameter index: Field index.
    /// - Returns: True if field set.
    public func isFieldSet(index: Int32) -> Bool {
        return ngsFeatureIsFieldSet(handle, index) == 1 ? true : false
    }
    
    /// Get field value.
    ///
    /// - Parameter index: Field index.
    /// - Returns: Field value.
    public func getField(asInteger index: Int32) -> Int32 {
        return ngsFeatureGetFieldAsInteger(handle, index)
    }
    
    /// Get field value.
    ///
    /// - Parameter index: Field index.
    /// - Returns: Field value.
    public func getField(asDouble index: Int32) -> Double {
        return ngsFeatureGetFieldAsDouble(handle, index)
    }
    
    /// Get field value.
    ///
    /// - Parameter index: Field index.
    /// - Returns: Field value.
    public func getField(asString index: Int32) -> String {
        return String(cString: ngsFeatureGetFieldAsString(handle, index))
    }
    
    /// Get field value.
    ///
    /// - Parameter index: Field index.
    /// - Returns: Field value.
    public func getField(asDateTime index: Int32) -> Date {
        if ngsFeatureIsFieldSet(handle, index) == 1 {
            let year = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            let month = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            let day = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            let hour = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            let minute = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            let second = UnsafeMutablePointer<Float>.allocate(capacity: 1)
            let tag = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            ngsFeatureGetFieldAsDateTime(handle, index, year, month, day,
                                         hour, minute, second, tag)
            var dateComponents = DateComponents()
            dateComponents.year = Int(year.pointee)
            dateComponents.month = Int(month.pointee)
            dateComponents.day = Int(day.pointee)
            dateComponents.hour = Int(hour.pointee)
            dateComponents.minute = Int(minute.pointee)
            dateComponents.second = Int(second.pointee)
            
            if tag.pointee > 1 {
                dateComponents.timeZone = TimeZone(secondsFromGMT: Int(tag.pointee - 100) / 4 * 3600)
            }
            else {
                dateComponents.timeZone = TimeZone(secondsFromGMT: 0) // UTC
            }
            
            return Calendar.current.date(from: dateComponents)!
        }
        
        return Date()
    }
    
    /// Set field value.
    ///
    /// - Parameters:
    ///   - index: Fieldd index.
    ///   - value: Value to set.
    public func setField(for index: Int32, string value: String) {
        ngsFeatureSetFieldString(handle, index, value)
    }
    
    /// Set field value.
    ///
    /// - Parameters:
    ///   - index: Fieldd index.
    ///   - value: Value to set.
    public func setField(for index: Int32, double value: Double) {
        ngsFeatureSetFieldDouble(handle, index, value)
    }
    
    /// Set field value.
    ///
    /// - Parameters:
    ///   - index: Fieldd index.
    ///   - value: Value to set.
    public func setField(for index: Int32, int value: Int32) {
        ngsFeatureSetFieldInteger(handle, index, value)
    }
    
    /// Set field value.
    ///
    /// - Parameters:
    ///   - index: Fieldd index.
    ///   - value: Value to set.
    public func setField(for index: Int32, date value: Date) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let year = calendar.component(.year, from: value)
        let month = calendar.component(.month, from: value)
        let day = calendar.component(.day, from: value)
        let hour = calendar.component(.hour, from: value)
        let minute = calendar.component(.minute, from: value)
        let second = calendar.component(.second, from: value)
        
        ngsFeatureSetFieldDateTime(handle, index, Int32(year), Int32(month),
                                   Int32(day), Int32(hour), Int32(minute),
                                   Float(second), 100) // 100 is UTC
    }
    
    /// Create geometry from json object. The GeoJson geomtry part.
    ///
    /// - Parameter json: JsonObject class instance.
    /// - Returns: Geometry or nil.
    static public func createGeometry(fromJson json: JsonObject) -> Geometry? {
        if let handle = ngsFeatureCreateGeometryFromJson(json.handle) {
            return Geometry(handle: handle)
        }
        return nil
    }
    
    /// Create new geometry. The type of geometry will be coresspondent feature class.
    ///
    /// - Returns: Geometry class instance or nil.
    public func createGeometry() -> Geometry? {
        if table is FeatureClass {
            return Geometry(handle: ngsFeatureCreateGeometry(handle))
        }
        return nil
    }
    
    /// Get attachment.
    ///
    /// - Parameter aid: Attachment identificator.
    /// - Returns: Attachment class instance or nil.
    public func getAttachment(aid: Int64) -> Attachment? {
        if let attachments = ngsFeatureAttachmentsGet(handle) {
            var count = 0
            while(attachments[count].name != nil) {
                if attachments[count].id == aid {
                    return Attachment(featureHandle: handle, id: attachments[count].id,
                                      name: String(cString: attachments[count].name),
                                      description: String(cString: attachments[count].description),
                                      path: String(cString: attachments[count].path),
                                      size: attachments[count].size,
                                      remoteId: attachments[count].rid)
                }
                count += 1
            }
        }
        return nil
    }
    
    /// Get all attachments.
    ///
    /// - Returns: Attachment array.
    public func getAttachments() -> [Attachment] {
        var attachmentsArray = [Attachment]()
        if let attachments = ngsFeatureAttachmentsGet(handle) {
            var count = 0
            while(attachments[count].name != nil) {
                attachmentsArray.append(
                    Attachment(featureHandle: handle, id: attachments[count].id,
                               name: String(cString: attachments[count].name),
                               description: String(cString: attachments[count].description),
                               path: String(cString: attachments[count].path),
                               size: attachments[count].size,
                               remoteId: attachments[count].rid))
                count += 1
            }
        }
        
        return attachmentsArray
    }
    
    /// Add new attachment.
    ///
    /// - Parameters:
    ///   - name: Name.
    ///   - description: Description text.
    ///   - path: File system path.
    ///   - move: If true the attachment file will be
    ///   - remoteId: Remote identificator.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: New attachment identificator.
    public func addAttachment(name: String, description: String, path: String,
                              move: Bool, remoteId: Int64 = -1,
                              logEdits: Bool = true) -> Int64 {
        let options = [
            "MOVE" : move ? "ON" :  "OFF",
            "RID" : "\(remoteId)"
        ]
        
        return ngsFeatureAttachmentAdd(handle, name, description, path,
                                       toArrayOfCStrings(options), logEdits ? 1 : 0)
    }
    
    /// Delete attachment.
    ///
    /// - Parameters:
    ///   - aid: Attachment identificator.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func deleteAttachment(aid: Int64, logEdits: Bool = true) -> Bool {
        return ngsFeatureAttachmentDelete(handle, aid, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete attachment.
    ///
    /// - Parameters:
    ///   - attachment: Attachment class instance.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func deleteAttachment(attachment: Attachment, logEdits: Bool = true) -> Bool {
        return ngsFeatureAttachmentDelete(handle, attachment.id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete feature.
    ///
    /// - Returns: True on success.
    public func delete() -> Bool {
        return table?.deleteFeature(id: id) ?? false
    }
}

/// Coordinate transformation class. Helps to transform from one spatial reference to another.
public class CoordinateTransformation {
    let handle: CoordinateTransformationH!
    
    init(handle: CoordinateTransformationH) {
        self.handle = handle
    }
    
    deinit {
        ngsCoordinateTransformationFree(handle)
    }
    
    /// Create new coordinate transformation.
    ///
    /// - Parameters:
    ///   - fromEPSG: Source EPSG spatial reference code.
    ///   - toEPSG: Destination EPSG spatial reference code.
    /// - Returns: CoordinateTransformation class instance.
    public static func new(fromEPSG: Int32, toEPSG: Int32) -> CoordinateTransformation {
        return CoordinateTransformation(
            handle: ngsCoordinateTransformationCreate(fromEPSG, toEPSG))
    }
    
    /// Perform transformation of point from one spatial reference to another.
    ///
    /// - Parameter point: Point to transform.
    /// - Returns: Point with new coordinates.
    public func transform(_ point: Point) -> Point {
        let coordIn: ngsCoordinate = ngsCoordinate(X: point.x, Y: point.y, Z: 0.0)
        let coordOut = ngsCoordinateTransformationDo(handle, coordIn)
        return Point(x: coordOut.X, y: coordOut.Y)
    }
}

/// Spatial envelope.
public struct Envelope : Equatable {
    
    /// Minimum X coordinate.
    public var minX: Double
    
    /// Maximum X coordinate.
    public var maxX: Double
    
    /// Minimum Y coordinate.
    public var minY: Double
    
    /// Maximum Y coordinate.
    public var maxY: Double
    
    var extent: ngsExtent {
        get {
            return ngsExtent(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
    }
    
    /// Init envelope with values.
    ///
    /// - Parameters:
    ///   - minX: Minimum X coordinate.
    ///   - minY: Minimum Y coordinate.
    ///   - maxX: Maximum X coordinate.
    ///   - maxY: Maximum Y coordinate.
    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    /// Init envelope with zeroo coordinates. Envelope will be invalid.
    public init() {
        self.minX = 0.0
        self.maxX = 0.0
        self.minY = 0.0
        self.maxY = 0.0
    }
    
    init(envelope: ngsExtent) {
        self.minX = envelope.minX
        self.maxX = envelope.maxX
        self.minY = envelope.minY
        self.maxY = envelope.maxY
    }
    
    /// Check if envelope is init.
    ///
    /// - Returns: True if envelope is init.
    public func isInit() -> Bool {
        return minX != 0.0 && minY != 0.0 && maxX != 0.0 && maxY != 0.0
    }
    
    /// Merge envelope with other envelope. The result of extent of this and other envelop will be set to this envelope.
    ///
    /// - Parameter other: Other envelope.
    public mutating func merge(other: Envelope) {
        if isInit() {
            self.minX = min(minX, other.minX)
            self.minY = min(minY, other.minY)
            self.maxX = max(maxX, other.maxX)
            self.maxY = max(maxY, other.maxY)
        }
        else {
            self.minX = other.minX
            self.minY = other.minY
            self.maxX = other.maxX
            self.maxY = other.maxY
        }
    }
    
    /// Compare if envelopes are same.
    ///
    /// - Parameters:
    ///   - lhs: Envelope to compare.
    ///   - rhs: Envelope to compare.
    /// - Returns: True if same.
    public static func ==(lhs: Envelope, rhs: Envelope) -> Bool {
        return lhs.maxX == rhs.maxX && lhs.maxY == rhs.maxY &&
                lhs.minX == rhs.minX && lhs.minY == rhs.minY
    }
    
    /// Envelope width.
    public var width: Double {
        get {
            return maxX - minX
        }
    }
    
    /// Envelope height.
    public var height: Double {
        get {
            return maxY - minY
        }
    }
    
    /// Envelope center.
    public var center: Point {
        get {
            let x = minX + width / 2
            let y = minY + height / 2
            return Point(x: x, y: y)
        }
    }
    
    /// Increase envelope by value.
    ///
    /// - Parameter value: Value to increase width and height of envelope. May be negative for decrease sizes.
    public mutating func increase(by value: Double) {
        let deltaWidth = (width * value - width) / 2.0
        let deltaHeight = (height * value - height) / 2.0
        minX -= deltaWidth
        minY -= deltaHeight
        maxX += deltaWidth
        maxY += deltaHeight
    }
    
    /// Transform envelope from one spatial reference to another.
    ///
    /// - Parameters:
    ///   - fromEPSG: Source spatial reference EPSG code.
    ///   - toEPSG: Destination spatial reference EPSD code.
    public mutating func transform(fromEPSG: Int32, toEPSG: Int32) {
        let newTransform = CoordinateTransformation.new(fromEPSG: fromEPSG, toEPSG: toEPSG)
        var points: [Point] = []
        points.append(Point(x: minX, y: minY))
        points.append(Point(x: minX, y: maxY))
        points.append(Point(x: maxX, y: maxY))
        points.append(Point(x: maxX, y: minY))
        
        for index in 0..<4 {
            points[index] = newTransform.transform(points[index])
        }
        
        minX = Constants.bigValue
        minY = Constants.bigValue
        maxX = -Constants.bigValue
        maxY = -Constants.bigValue
        for index in 0..<4 {
            if minX > points[index].x {
                minX = points[index].x
            }
            if minY > points[index].y {
                minY = points[index].y
            }
            if maxX < points[index].x {
                maxX = points[index].x
            }
            if maxY < points[index].y {
                maxY = points[index].y
            }
        }
    }
    
    /// Create strong copy of envelope.
    ///
    /// - Returns: New envelope clas instance.
    public func clone() -> Envelope {
        return Envelope(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }
}

/// Geometry class.
public class Geometry {
    let handle: GeometryH!
    
    /// Geometry type.
    ///
    /// - NONE: No geometry.
    /// - POINT: Point.
    /// - LINESTRING: Linestring.
    /// - POLYGON: Polygon.
    /// - MULTIPOINT: Multipoint.
    /// - MULTILINESTRING: Multilinestring.
    /// - MULTIPOLYGON: Multipolygon.
    public enum GeometryType: Int32 {
        case NONE = 0, POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON
    }
    
    /// Get name from geometry type.
    ///
    /// - Parameter geometryType: Geometry type.
    /// - Returns: Geometry type name string.
    static func geometryTypeToName(_ geometryType: GeometryType) -> String {
        switch geometryType {
        case .NONE:
            return "NONE"
        case .POINT:
            return "POINT"
        case .LINESTRING:
            return "LINESTRING"
        case .POLYGON:
            return "POLYGON"
        case .MULTIPOINT:
            return "MULTIPOINT"
        case .MULTILINESTRING:
            return "MULTILINESTRING"
        case .MULTIPOLYGON:
            return "MULTIPOLYGON"
        }
    }
    
    /// Envelope of geometry.
    public var envelope: Envelope {
        get {
            return Envelope(envelope: ngsGeometryGetEnvelope(handle))
        }
    }
    
    /// Is empty geometry.
    public var isEmpty: Bool {
        get {
            return ngsGeometryIsEmpty(handle) == 1
        }
    }
    
    /// Geometry type.
    public var type: GeometryType {
        get {
            return Geometry.GeometryType(rawValue:
                Int32(ngsGeometryGetType(handle))) ?? .NONE
        }
    }
    
    init(handle: GeometryH) {
        self.handle = handle
    }
    
    deinit {
        ngsGeometryFree(handle)
    }
    
    /// Transform geometry from one spatial reference to another.
    ///
    /// - Parameter epsg: Destination spatial reference.
    /// - Returns: True on success.
    public func transform(to epsg: Int32) -> Bool {
        return ngsGeometryTransformTo(handle, epsg) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Transform geometry from one spatial reference to another.
    ///
    /// - Parameter transformation: CoordinateTransformation class instance.
    /// - Returns: True on success.
    public func transform(_ transformation: CoordinateTransformation) -> Bool {
        return ngsGeometryTransform(handle, transformation.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Transform geometry to GeoJson string.
    ///
    /// - Returns: GeoJson string.
    public func asJson() -> String {
        return String(cString: ngsGeometryToJson(handle))
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

/// Attachment class.
public class Attachment {
    let id: Int64
    
    /// Attachment name.
    public let name: String
    
    /// Attachment description.
    public let description: String
    
    /// File system path to attachmetn if exists.
    public let path: String
    
    /// Attachment file size in bytes.
    public let size: Int64
    var remoteIdVal: Int64
    let handle: FeatureH!
    
    /// Remote identificator read/write property.
    public var remoteId: Int64 {
        get {
            return remoteIdVal
        }
        set(rid) {
            if handle != nil {
                ngsStoreFeatureSetAttachmentRemoteId(handle, id, rid)
            }
            remoteIdVal = rid
        }
    }
    
    init(featureHandle: FeatureH, id: Int64, name: String, description: String,
         path: String, size: Int64, remoteId: Int64) {
        self.handle = featureHandle
        self.id = id
        self.name = name
        self.description = description
        self.path = path
        self.size = size
        self.remoteIdVal = remoteId
    }
    
    init(name: String, description: String, path: String) {
        self.handle = nil
        self.id = -1
        self.name = name
        self.description = description
        self.path = path
        self.size = -1
        self.remoteIdVal = -1
    }
    
    /// If attachment file available.
    ///
    /// - Returns: True of file exists.
    public func isFileAvailable() -> Bool {
        return path.isEmpty
    }
    
    /// Update attachment.
    ///
    /// - Parameters:
    ///   - name: New attachment name.
    ///   - description: New attachment description.
    ///   - logEdits: Log edits in history table. This log can be received using editOperations function.
    /// - Returns: True on success.
    public func update(name: String, description: String, logEdits: Bool = true) -> Bool {
        if handle == nil {
            return false
        }
        return ngsFeatureAttachmentUpdate(handle, id, name, description, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
}

/*
NGS_EXTERNC int ngsFeatureFieldCount(FeatureH feature);
NGS_EXTERNC void ngsGeometrySetPoint(GeometryH geometry, int point, double x, double y, double z, double m);
*/
