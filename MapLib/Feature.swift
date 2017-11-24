//
//  Feature.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 25.11.2017.
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
        if let fc = table as? FeatureClass {
            switch fc.geometryType {
            case .POINT:
                return GeoPoint(handle: ngsFeatureCreateGeometry(handle))
            default: // TODO: Add other types of geometry
                return Geometry(handle: ngsFeatureCreateGeometry(handle))
            }
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


/// Attachment class. File adde to the feature/row
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
    
    /// Is attachment file available on disk.
    ///
    /// - Returns: True of file exists.
    public func isFileAvailable() -> Bool {
        return path.isEmpty
    }
    
    /// Update attachment. Only name and description can be updated. To change attchment file, just delete attachment and create new one.
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
