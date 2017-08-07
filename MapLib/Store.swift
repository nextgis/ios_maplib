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

public class Store: Object {
    public static let ext = ".ngst"
    
    public func createFeatureClass(name: String,
                                   geometryType: FeatureClass.geometryTypeEnum,
                                   fields: [Field],
                                   options: [String: String]? = nil) -> FeatureClass? {
        
        var fullOptions = options ?? [:]
        fullOptions["GEOMETRY_TYPE"] = FeatureClass.geometryTypeToName(geometryType)
        fullOptions["TYPE"] = "\(CAT_FC_GPKG.rawValue)"
        fullOptions["FIELD_COUNT"] = "\(fields.count)"
        for index in 0..<fields.count {
            fullOptions["FIELD_\(index)_TYPE"] = Field.fieldTypeToName(fields[index].type)
            fullOptions["FIELD_\(index)_NAME"] = fields[index].name
            fullOptions["FIELD_\(index)_ALIAS"] = fields[index].alias
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

public class FeatureClass: Object {
    public var fields: [Field] = []
    public let geometryType: geometryTypeEnum
    
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
    
    public enum geometryTypeEnum: Int32 {
        case NONE = 0, POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON
    }
    
    override init(copyFrom: Object) {
        geometryType = geometryTypeEnum(rawValue:
            Int32(ngsFeatureClassGeometryType(copyFrom.object)))!
        
        // Add fields
        if let fieldsList = ngsFeatureClassFields(copyFrom.object) {
            var count: Int = 0
            while (fieldsList[count].name != nil) {
                let fName = String(cString: fieldsList[count].name)
                let fAlias = String(cString: fieldsList[count].alias)
                let fType = Field.fieldType(rawValue: fieldsList[count].type)
                
                printMessage("Add field - name: \(fName), alias: \(fAlias), type: \(fType ?? Field.fieldType.UNKNOWN) to '\(copyFrom.name)'")
                
                let fieldValue = Field(name: fName, alias: fAlias, type: fType!)
                fields.append(fieldValue)
                count += 1
            }
            ngsFree(fieldsList)
        }
        
        super.init(copyFrom: copyFrom)
    }
    
    static func geometryTypeToName(_ geometryType: geometryTypeEnum) -> String {
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
    
    public func createFeature() -> Feature {
        return Feature(handle: ngsFeatureClassCreateFeature(object))
    }
    
    public func createOverviews(force: Bool, zoomLevels: [Int8],
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
            "FORCE" : force ? "ON" : "OFF",
            "ZOOM_LEVELS" : zoomLevelsValue
        ]
        return ngsFeatureClassCreateOverviews(object, toArrayOfCStrings(options),
                                              callback == nil ? nil : callback!.func,
                                              callback == nil ? nil : callback!.data) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func insertFeature(_ feature: Feature) -> Bool {
        return ngsFeatureClassInsertFeature(object, feature.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func updateFeature(_ feature: Feature) -> Bool {
        return ngsFeatureClassUpdateFeature(object, feature.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteFeature(id: Int64) -> Bool {
        return ngsFeatureClassDeleteFeature(object, id) ==
            Int32(COD_SUCCESS.rawValue)
    }

    public func deleteFeature(feature: Feature) -> Bool {
        return ngsFeatureClassDeleteFeature(object, feature.id) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteFeatures() -> Bool {
        return ngsFeatureClassDeleteFeatures(object) == Int32(COD_SUCCESS.rawValue)
    }
    
    public func reset() {
        ngsFeatureClassResetReading(object)
    }
    
    public func nextFeature() -> Feature? {
        return Feature(handle: ngsFeatureClassNextFeature(object))
    }
    
    public func getFeature(index: Int64) -> Feature? {
        return Feature(handle: ngsFeatureClassGetFeature(object, index))
    }
    
    public func getFeature(remoteId: Int64) -> Feature? {
        return Feature(handle: ngsStoreFeatureClassGetFeatureByRemoteId(object, remoteId))
    }
    
    public func fieldIndexAndType(by name: String) -> (index: Int32, type: Field.fieldType) {
        var count: Int32 = 0
        for field in fields {
            if field.name == name {
                return (count, field.type)
            }
            count += 1
        }
        return (-1, Field.fieldType.UNKNOWN)
    }
}

public class Feature {
    let handle: FeatureH!
    public var id: Int64 {
        get {
            return ngsFeatureGetId(handle)
        }
    }
    
    public var geometry: Geometry {
        get {
            return Geometry(handle: ngsFeatureGetGeometry(handle))
        }
        set(value) {
            ngsFeatureSetGeometry(handle, value.handle)
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
    
    init(handle: FeatureH) {
        self.handle = handle
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
        
        return Calendar.current.date(from: dateComponents)!
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
        let calendar = Calendar.current
        
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
    
    public func createGeometry() -> Geometry {
        return Geometry(handle: ngsFeatureCreateGeometry(handle))
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
                              move: Bool, remoteId: Int64 = -1) -> Int64 {
        let options = [
            "MOVE" : move ? "ON" :  "OFF",
            "RID" : "\(remoteId)"
        ]
        
        return ngsFeatureAttachmentAdd(handle, name, description, path,
                                toArrayOfCStrings(options))
    }
    
    public func deleteAttachment(aid: Int64) -> Bool {
        return ngsFeatureAttachmentDelete(handle, aid) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    public func deleteAttachment(attachment: Attachment) -> Bool {
        return ngsFeatureAttachmentDelete(handle, attachment.id) ==
            Int32(COD_SUCCESS.rawValue)
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
}

public class Geometry {
    let handle: GeometryH!
    
    init(handle: GeometryH) {
        self.handle = handle
    }
    
    static func freeGeometry(_ geom: Geometry) {
        ngsGeometryFree(geom.handle)
    }
    
    public func transform(to epsg: Int32) -> Bool {
        return ngsGeometryTransformTo(handle, epsg) == Int32(COD_SUCCESS.rawValue)
    }
    
    public func transform(_ transformation: CoordinateTransformation) -> Bool {
        return ngsGeometryTransform(handle, transformation.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
}

public class Field {
    public let name: String
    public let alias: String
    public let type: fieldType
    
    public enum fieldType: Int32 {
        case UNKNOWN = -1, INTEGER = 0, REAL = 2, STRING = 4, DATE = 11
    }
    
    public init(name: String, alias: String, type: fieldType) {
        self.name = name
        self.alias = alias
        self.type = type
    }
    
    static func fieldTypeToName(_ fieldType: fieldType) -> String {
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
            ngsStoreFeatureSetAttachmentRemoteId(handle, id, rid)
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
    
    public func isFileAvailable() -> Bool {
        return path.isEmpty
    }
    
    public func update(name: String, description: String) -> Bool {
        return ngsFeatureAttachmentUpdate(handle, id, name, description) ==
            Int32(COD_SUCCESS.rawValue)
    }
}

/*
NGS_EXTERNC int ngsFeatureFieldCount(FeatureH feature);
NGS_EXTERNC void ngsGeometrySetPoint(GeometryH geometry, int point, double x, double y, double z, double m);
*/
