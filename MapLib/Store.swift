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

public class MemoryStore: Object {
    public static let ext = ".ngmem"
    
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

public class Store: Object {
    public static let ext = ".ngst"
    
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

public enum EditOperationType {
    case NOP, CREATE_FEATURE, CHANGE_FEATURE, DELETE_FEATURE, DELETE_ALL_FEATURES,
    CREATE_ATTACHMENT, CHANGE_ATTACHMENT, DELETE_ATTACHMENT, DELETE_ALL_ATTACHMENTS
}

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

public class Raster: Object {
    
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

public class Table: Object {
    public var fields: [Field] = []

    var batchModeValue = false
    public var batchMode: Bool {
        get {
            return batchModeValue
        }
        set(enable) {
            ngsFeatureClassBatchMode(object, enable ? 1 : 0)
            batchModeValue = enable
        }
    }
    
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
    
    public func createFeature() -> Feature? {
        if let handle = ngsFeatureClassCreateFeature(object) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    public func insertFeature(_ feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassInsertFeature(object, feature.handle, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func updateFeature(_ feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassUpdateFeature(object, feature.handle, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteFeature(id: Int64, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeature(object, id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteFeature(feature: Feature, logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeature(object, feature.id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteFeatures(logEdits: Bool = true) -> Bool {
        return ngsFeatureClassDeleteFeatures(object, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func reset() {
        ngsFeatureClassResetReading(object)
    }
    
    public func nextFeature() -> Feature? {
        if let handle = ngsFeatureClassNextFeature(object) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    public func getFeature(index: Int64) -> Feature? {
        if let handle = ngsFeatureClassGetFeature(object, index) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
    public func getFeature(remoteId: Int64) -> Feature? {
        if let handle = ngsStoreFeatureClassGetFeatureByRemoteId(object, remoteId) {
            return Feature(handle: handle, table: self)
        }
        return nil
    }
    
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
    
    public func delete(editOperation: EditOperation) {
        ngsFeatureClassDeleteEditOperation(object, editOperation.rawOperation)
    }
}

public class FeatureClass: Table {
    public let geometryType: Geometry.GeometryType
    
    override init(copyFrom: Object) {
        geometryType = Geometry.GeometryType(rawValue:
            Int32(ngsFeatureClassGeometryType(copyFrom.object))) ?? .NONE
        
        super.init(copyFrom: copyFrom)
    }
    
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
    
    public func clearFilters() -> Bool {
        let result = ngsFeatureClassSetFilter(object, nil, nil) ==
            Int32(COD_SUCCESS.rawValue)
//        reset()
        return result
    }
    
    public func setSpatialFilter(envelope: Envelope) -> Bool {
        let result = ngsFeatureClassSetSpatialFilter(object,
                                               envelope.minX, envelope.minY,
                                               envelope.maxX, envelope.maxY) ==
            Int32(COD_SUCCESS.rawValue)
//        reset()
        return result
    }
    
    public func setSpatialFilter(geometry: Geometry) -> Bool {
        let result = ngsFeatureClassSetFilter(object, geometry.handle, nil) ==
            Int32(COD_SUCCESS.rawValue)
        return result
    }
    
    public func setAttributeFilter(query: String) -> Bool {
        let result = ngsFeatureClassSetFilter(object, nil, query) ==
            Int32(COD_SUCCESS.rawValue)
//        reset()
        return result
    }
    
    public func setFilters(geometry: Geometry, query: String) -> Bool {
        let result = ngsFeatureClassSetFilter(object, geometry.handle, query) ==
            Int32(COD_SUCCESS.rawValue)
//        reset()
        return result
    }
}

public class Feature {
    let handle: FeatureH!
    public let table: Table?
    public var id: Int64 {
        get {
            return ngsFeatureGetId(handle)
        }
    }
    
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
    
    public func isFieldSet(index: Int32) -> Bool {
        return ngsFeatureIsFieldSet(handle, index) == 1 ? true : false
    }
    
    public func getField(asInteger index: Int32) -> Int32 {
        return ngsFeatureGetFieldAsInteger(handle, index)
    }
    
    public func getField(asDouble index: Int32) -> Double {
        return ngsFeatureGetFieldAsDouble(handle, index)
    }
    
    public func getField(asString index: Int32) -> String {
        return String(cString: ngsFeatureGetFieldAsString(handle, index))
    }
    
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
    
    public func setField(for index: Int32, string value: String) {
        ngsFeatureSetFieldString(handle, index, value)
    }
    
    public func setField(for index: Int32, double value: Double) {
        ngsFeatureSetFieldDouble(handle, index, value)
    }
    
    public func setField(for index: Int32, int value: Int32) {
        ngsFeatureSetFieldInteger(handle, index, value)
    }
    
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
    
    static public func createGeometry(fromJson json: JsonObject) -> Geometry {
        return Geometry(handle: ngsFeatureCreateGeometryFromJson(json.handle))
    }
    
    public func createGeometry() -> Geometry? {
        if table is FeatureClass {
            return Geometry(handle: ngsFeatureCreateGeometry(handle))
        }
        return nil
    }
    
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
    
    public func deleteAttachment(aid: Int64, logEdits: Bool = true) -> Bool {
        return ngsFeatureAttachmentDelete(handle, aid, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteAttachment(attachment: Attachment, logEdits: Bool = true) -> Bool {
        return ngsFeatureAttachmentDelete(handle, attachment.id, logEdits ? 1 : 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func delete() -> Bool {
        return table?.deleteFeature(id: id) ?? false
    }
}

public class CoordinateTransformation {
    let handle: CoordinateTransformationH!
    
    init(handle: CoordinateTransformationH) {
        self.handle = handle
    }
    
    deinit {
        ngsCoordinateTransformationFree(handle)
    }
    
    public static func new(fromEPSG: Int32, toEPSG: Int32) -> CoordinateTransformation {
        return CoordinateTransformation(
            handle: ngsCoordinateTransformationCreate(fromEPSG, toEPSG))
    }
    
    public func transform(_ point: Point) -> Point {
        let coordIn: ngsCoordinate = ngsCoordinate(X: point.x, Y: point.y, Z: 0.0)
        let coordOut = ngsCoordinateTransformationDo(handle, coordIn)
        return Point(x: coordOut.X, y: coordOut.Y)
    }
}

public struct Envelope : Equatable {
    public var minX: Double
    public var maxX: Double
    public var minY: Double
    public var maxY: Double
    
    var extent: ngsExtent {
        get {
            return ngsExtent(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
    }
    
    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
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
    
    public func isInit() -> Bool {
        return minX != 0.0 && minY != 0.0 && maxX != 0.0 && maxY != 0.0
    }
    
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
    
    public static func ==(lhs: Envelope, rhs: Envelope) -> Bool {
        return lhs.maxX == rhs.maxX && lhs.maxY == rhs.maxY &&
                lhs.minX == rhs.minX && lhs.minY == rhs.minY
    }
    
    public var width: Double {
        get {
            return maxX - minX
        }
    }
    
    public var height: Double {
        get {
            return maxY - minY
        }
    }
    
    public var center: Point {
        get {
            let x = minX + width / 2
            let y = minY + height / 2
            return Point(x: x, y: y)
        }
    }
    
    public mutating func increase(by value: Double) {
        let deltaWidth = (width * value - width) / 2.0
        let deltaHeight = (height * value - height) / 2.0
        minX -= deltaWidth
        minY -= deltaHeight
        maxX += deltaWidth
        maxY += deltaHeight
    }
}

public class Geometry {
    let handle: GeometryH!
    
    public enum GeometryType: Int32 {
        case NONE = 0, POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON
    }
    
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
    
    public var envelope: Envelope {
        get {
            return Envelope(envelope: ngsGeometryGetEnvelope(handle))
        }
    }
    
    public var isEmpty: Bool {
        get {
            return ngsGeometryIsEmpty(handle) == 1
        }
    }
    
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
    
    public func transform(to epsg: Int32) -> Bool {
        return ngsGeometryTransformTo(handle, epsg) == Int32(COD_SUCCESS.rawValue)
    }
    
    public func transform(_ transformation: CoordinateTransformation) -> Bool {
        return ngsGeometryTransform(handle, transformation.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func asJson() -> String {
        return String(cString: ngsGeometryToJson(handle))
    }
}

public class Field {
    public let name: String
    public let alias: String
    public let type: FieldType
    public let defaultValue: String?
    
    public enum FieldType: Int32 {
        case UNKNOWN = -1, INTEGER = 0, REAL = 2, STRING = 4, DATE = 11
    }
    
    public init(name: String, alias: String, type: FieldType, defaultValue: String? = nil) {
        self.name = name
        self.alias = alias
        self.type = type
        self.defaultValue = defaultValue
    }
    
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

public class Attachment {
    let id: Int64
    public let name: String
    public let description: String
    public let path: String
    public let size: Int64
    var remoteIdVal: Int64
    let handle: FeatureH!
    
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
    
    public func isFileAvailable() -> Bool {
        return path.isEmpty
    }
    
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
