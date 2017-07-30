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
    private let document: JsonDocumentH!
    
    init() {
        document = API.instance.createJsonDocument()
    }
    
    deinit {
        ngsJsonDocumentFree(document)
    }
    
    public func load(url: String, options: [String: String]? = nil,
                     callback: ngstore.ngsProgressFunc!,
                     _ callbackData: UnsafeMutableRawPointer!) -> Bool {
        return ngsJsonDocumentLoadUrl(document, url, toArrayOfCStrings(options),
                                      callback, callbackData) ==
            Int32(COD_SUCCESS.rawValue) ? true : false;
    }
    
    func getRoot() -> JsonObject {
        return JsonObject(object: ngsJsonDocumentRoot(document))
    }
}

public class JsonObject {
    fileprivate let object: JsonObjectH!
    
    public enum jsonObjectType : Int32 {
        case NULL = 0, OBJECT, ARRAY, BOOLEAN, STRING, INTEGER, LONG, DOUBLE
    }
    
    init(object: JsonObjectH!) {
        self.object = object
    }
    
    deinit {
        ngsJsonObjectFree(object)
    }
    
    public var name: String {
        get {
            return String(cString: ngsJsonObjectName(object))
        }
    }
    
    public var type: jsonObjectType {
        get {
            return jsonObjectType(rawValue: ngsJsonObjectType(object))!
        }
    }
    
    public func getString(with defaultValue: String) -> String {
        return String(cString: ngsJsonObjectGetString(object, defaultValue))
    }
    
    public func getDouble(with defaultValue: Double) -> Double {
        return ngsJsonObjectGetDouble(object, defaultValue)
    }
    
    public func getInteger(with defaultValue: Int32) -> Int32 {
        return ngsJsonObjectGetInteger(object, defaultValue)
    }
    
    public func getLong(with defaultValue: Int) -> Int {
        return ngsJsonObjectGetLong(object, defaultValue)
    }
    
    public func getBool(with defaultValue: Bool) -> Bool {
        return ngsJsonObjectGetBool(object, defaultValue ? 1 : 0) == 1 ? true : false
    }
    
    public func getObject(name: String) -> JsonObject {
        return JsonObject(object: ngsJsonObjectGetObject(object, name))
    }
    
    public func children() -> [JsonObject] {
        var out: [JsonObject] = []
        if let children = ngsJsonObjectChildren(object) {
            var count: Int = 0
            while (children[count] != nil) {
                out.append(JsonObject(object: children[count]))
                count += 1
            }
            ngsJsonObjectChildrenListFree(children)
        }
        return out
    }
    
    public func getArray(name: String) -> JsonArray {
        return JsonArray(object: ngsJsonObjectGetArray(object, name))
    }
    
}

public class JsonArray : JsonObject {
    
    public var size: Int32 {
        get {
            return ngsJsonArraySize(object)
        }
    }
    
    public func getItem(with index: Int32) -> JsonObject {
        return JsonObject(object: ngsJsonArrayItem(object, index))
    }    
}
