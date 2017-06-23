//
//  Url.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 13.06.17.
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

public class Request {
    
    public enum requestType : UInt32 {
        case GET = 1, POST, PUT, DELETE
    }
    
    public static func get(url: String, options: [String: String]? = nil) -> (status: Int, value: String) {
        let result = API.instance.URLRequest(
            method: ngsURLRequestType(requestType.GET.rawValue),
            url: url, options: options)
        
        
        let outStr = String(cString: result.data ?? [0])
        return (result.status, outStr)
    }
    
    public static func getJson(url: String, options: [String: String]? = nil) -> (status: Int, value: [String: Any]?) {
        let result = API.instance.URLRequest(
            method: ngsURLRequestType(requestType.GET.rawValue),
            url: url, options: options)
        
        do {
            let outStr = String(cString: result.data ?? [0])
            if !outStr.isEmpty {
                if let json = try JSONSerialization.jsonObject(with: outStr.data(using: .utf8)!, options: []) as? [String: Any] {
                    return (result.status, json)
                }
            }
        }
        catch {
            print("Error deserializing JSON: \(error)")
        }
        return (543, nil)
    }
    
    public static func postJson(url: String, payload: String, options: [String: String]? = nil) -> (status: Int, value: [String: Any]?) {
        
        var fullOptions = options ?? [:]
        fullOptions["POSTFIELDS"] = payload
        let result = API.instance.URLRequest(
            method: ngsURLRequestType(requestType.POST.rawValue),
            url: url, options: fullOptions)
        
        do {
            let outStr = String(cString: result.data ?? [0])
            if !outStr.isEmpty {
                if let json = try JSONSerialization.jsonObject(with: outStr.data(using: .utf8)!, options: []) as? [String: Any] {
                    return (result.status, json)
                }
            }
        }
        catch {
            print("Error deserializing JSON: \(error)")
        }
        return (543, nil)
    }
    
    
    
    // TODO: get image, get file
}
