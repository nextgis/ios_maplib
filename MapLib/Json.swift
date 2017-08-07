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

public class JsonDocument {
    let handle: JsonDocumentH!
    
    public init() {
        handle = API.instance.createJsonDocument()
    }
    
    deinit {
        ngsJsonDocumentFree(handle)
    }
    
    public func load(url: String, options: [String: String]? = nil,
                     callback: (func: ngstore.ngsProgressFunc,
        data: UnsafeMutableRawPointer)? = nil ) -> Bool {
        return ngsJsonDocumentLoadUrl(handle, url, toArrayOfCStrings(options),
                                      callback == nil ? nil : callback!.func,
                                      callback == nil ? nil : callback!.data) ==
            Int32(COD_SUCCESS.rawValue) ? true : false;
    }
    
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

public class JsonObject {
    let handle: JsonObjectH?
    
    public enum jsonObjectType : Int32 {
        case NULL = 0, OBJECT, ARRAY, BOOLEAN, STRING, INTEGER, LONG, DOUBLE
    }
    
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
    
    public var name: String {
        get {
            return String(cString: ngsJsonObjectName(handle))
        }
    }
    
    public var type: jsonObjectType {
        get {
            return jsonObjectType(rawValue: ngsJsonObjectType(handle))!
        }
    }
    
    public func getString(with defaultValue: String) -> String {
        return String(cString: ngsJsonObjectGetString(handle, defaultValue))
    }
    
    public func getDouble(with defaultValue: Double) -> Double {
        return ngsJsonObjectGetDouble(handle, defaultValue)
    }
    
    public func getInteger(with defaultValue: Int32) -> Int32 {
        return ngsJsonObjectGetInteger(handle, defaultValue)
    }
    
    public func getLong(with defaultValue: Int) -> Int {
        return ngsJsonObjectGetLong(handle, defaultValue)
    }
    
    public func getBool(with defaultValue: Bool) -> Bool {
        return ngsJsonObjectGetBool(handle, defaultValue ? 1 : 0) == 1 ? true : false
    }
    
    public func getObject(name: String) -> JsonObject {
        return JsonObject(handle: ngsJsonObjectGetObject(handle, name))
    }
    
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
    
    public func getArray(name: String) -> JsonArray {
        return JsonArray(handle: ngsJsonObjectGetArray(handle, name))
    }
}

public class JsonArray : JsonObject {
    
    public var size: Int32 {
        get {
            return ngsJsonArraySize(handle)
        }
    }
    
    public func getItem(with index: Int32) -> JsonObject {
        return JsonObject(handle: ngsJsonArrayItem(handle, index))
    }
}
