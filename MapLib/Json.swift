//
//  Json.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 30.07.17.
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

/// Json document class.
public class JsonDocument {
    let handle: JsonDocumentH!
    
    /// Init empty document.
    public init() {
        handle = API.instance.createJsonDocument()
    }
    
    deinit {
        ngsJsonDocumentFree(handle)
    }
    
    /// Load document from url.
    ///
    /// - Parameters:
    ///   - url: Url to fetch Json document.
    ///   - options: Options passed to the http request function. See Request.get for detailes.
    ///   - callback: Callback function to show progress or cancel operation.
    /// - Returns: True on success.
    public func load(url: String, options: [String: String]? = nil,
                     callback: (func: ngstore.ngsProgressFunc,
        data: UnsafeMutableRawPointer)? = nil ) -> Bool {
        return ngsJsonDocumentLoadUrl(handle, url, toArrayOfCStrings(options),
                                      callback == nil ? nil : callback!.func,
                                      callback == nil ? nil : callback!.data) ==
            Int32(COD_SUCCESS.rawValue) ? true : false;
    }
    
    /// Get json document root object.
    ///
    /// - Returns: JsonObject class instance.
    public func getRoot() -> JsonObject {
        let handle = ngsJsonDocumentRoot(self.handle)
        let type = ngsJsonObjectType(handle)
        if type == JsonObject.jsonObjectType.ARRAY.rawValue {
            return JsonArray(handle: handle)
        } else {
            return JsonObject(handle: handle)
        }
    }
}

/// JsonObject class
public class JsonObject {
    let handle: JsonObjectH?
    
    /// Json object type.
    ///
    /// - NULL: Null object.
    /// - OBJECT: Another object.
    /// - ARRAY: Array of json objects.
    /// - BOOLEAN: Boolean object.
    /// - STRING: String object.
    /// - INTEGER: Integer object.
    /// - LONG: Long object.
    /// - DOUBLE: Double object.
    public enum jsonObjectType : Int32 {
        case NULL = 0, OBJECT, ARRAY, BOOLEAN, STRING, INTEGER, LONG, DOUBLE
    }
    
    /// If json object valid the property will be tru. The property is redonly.
    public var valid: Bool {
        get {
            return ngsJsonObjectValid(handle) == 1 ? true : false
        }
    }
    
    init(handle: JsonObjectH?) {
        self.handle = handle
    }
    
    deinit {
        ngsJsonObjectFree(handle)
    }
    
    /// Json object name.
    public var name: String {
        get {
            return String(cString: ngsJsonObjectName(handle))
        }
    }
    
    /// Json object type.
    public var type: jsonObjectType {
        get {
            return jsonObjectType(rawValue: ngsJsonObjectType(handle))!
        }
    }
    
    /// Get string from json object.
    ///
    /// - Parameter defaultValue: Default string value.
    /// - Returns: string.
    public func getString(with defaultValue: String) -> String {
        return String(cString: ngsJsonObjectGetString(handle, defaultValue))
    }
    
    /// Get double from json object.
    ///
    /// - Parameter defaultValue: Default double value.
    /// - Returns: double.
    public func getDouble(with defaultValue: Double) -> Double {
        return ngsJsonObjectGetDouble(handle, defaultValue)
    }
    
    /// Get int from json object.
    ///
    /// - Parameter defaultValue: Default int value.
    /// - Returns: int.
    public func getInteger(with defaultValue: Int32) -> Int32 {
        return ngsJsonObjectGetInteger(handle, defaultValue)
    }
    
    /// Get long from json object.
    ///
    /// - Parameter defaultValue: Default long value.
    /// - Returns: long.
    public func getLong(with defaultValue: Int) -> Int {
        return ngsJsonObjectGetLong(handle, defaultValue)
    }
    
    /// Get bool from json object.
    ///
    /// - Parameter defaultValue: Default bool value.
    /// - Returns: bool.
    public func getBool(with defaultValue: Bool) -> Bool {
        return ngsJsonObjectGetBool(handle, defaultValue ? 1 : 0) == 1 ? true : false
    }
    
    /// Get json object from json object.
    ///
    /// - Parameter defaultValue: Default json object value.
    /// - Returns: json object.
    public func getObject(name: String) -> JsonObject {
        return JsonObject(handle: ngsJsonObjectGetObject(handle, name))
    }

    /// Get string from json object.
    ///
    /// - Parameters:
    ///   - key: Key value.
    ///   - defaultValue: Default value.
    /// - Returns: String value.
    public func getString(for key: String, with defaultValue: String) -> String {
        return String(cString: ngsJsonObjectGetStringForKey(handle, key, defaultValue))
    }
    
    /// Get double from json object.
    ///
    /// - Parameters:
    ///   - key: Key value.
    ///   - defaultValue: Default value.
    /// - Returns: Double value.
    public func getDouble(for key: String, with defaultValue: Double) -> Double {
        return ngsJsonObjectGetDoubleForKey(handle, key, defaultValue)
    }
    
    /// Get integer from json object.
    ///
    /// - Parameters:
    ///   - key: Key value.
    ///   - defaultValue: Default value.
    /// - Returns: Integer value.
    public func getInteger(for key: String, with defaultValue: Int32) -> Int32 {
        return ngsJsonObjectGetIntegerForKey(handle, key, defaultValue)
    }
    
    /// Get long from json object.
    ///
    /// - Parameters:
    ///   - key: Key value.
    ///   - defaultValue: Default value.
    /// - Returns: Long value.
    public func getLong(for key: String, with defaultValue: Int) -> Int {
        return ngsJsonObjectGetLongForKey(handle, key, defaultValue)
    }
    
    /// Get bool from json object.
    ///
    /// - Parameters:
    ///   - key: Key value.
    ///   - defaultValue: Default value.
    /// - Returns: Boolean value.
    public func getBool(for key: String, with defaultValue: Bool) -> Bool {
        return ngsJsonObjectGetBoolForKey(handle, key, defaultValue ? 1 : 0) == 1 ? true : false
    }
    
    /// Set string value.
    ///
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key value.
    /// - Returns: True on success.
    public func set(string value: String, for key: String) -> Bool {
        return ngsJsonObjectSetStringForKey(handle, key, value) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set double value.
    ///
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key value.
    /// - Returns: True on success.
    public func set(double value: Double, for key: String) -> Bool {
        return ngsJsonObjectSetDoubleForKey(handle, key, value) == Int32(COD_SUCCESS.rawValue)
    }

    /// Set integer value.
    ///
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key value.
    /// - Returns: True on success.
    public func set(int value: Int32, for key: String) -> Bool {
        return ngsJsonObjectSetIntegerForKey(handle, key, value) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set long value.
    ///
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key value.
    /// - Returns: True on success.
    public func set(long value: Int, for key: String) -> Bool {
        return ngsJsonObjectSetLongForKey(handle, key, value) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set boolean value.
    ///
    /// - Parameters:
    ///   - value: Value to set.
    ///   - key: Key value.
    /// - Returns: True on success.
    public func set(bool value: Bool, for key: String) -> Bool {
        return ngsJsonObjectSetBoolForKey(handle, key, value ? 1 : 0) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Get json object children.
    ///
    /// - Returns: Array of children.
    public func children() -> [JsonObject] {
        var out: [JsonObject] = []
        if let children = ngsJsonObjectChildren(handle) {
            var count: Int = 0
            while (children[count] != nil) {
                out.append(JsonObject(handle: children[count]))
                count += 1
            }
            ngsFree(children) // Don't free pointers inside list
        }
        return out
    }
    
    /// Get array by name.
    ///
    /// - Parameter name: Array object name.
    /// - Returns: Json array object.
    public func getArray(name: String) -> JsonArray {
        return JsonArray(handle: ngsJsonObjectGetArray(handle, name))
    }
}

/// Json array class.
public class JsonArray : JsonObject {
    
    /// Item count.
    public var size: Int32 {
        get {
            return ngsJsonArraySize(handle)
        }
    }
    
    /// Get item by index. Index mas be between 0 and size.
    ///
    /// - Parameter index: Item index.
    /// - Returns: Json object.
    public func getItem(with index: Int32) -> JsonObject {
        return JsonObject(handle: ngsJsonArrayItem(handle, index))
    }
}
