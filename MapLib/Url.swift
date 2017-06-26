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

    /// Executes get request
    ///
    /// # Request option values
    ///
    /// Request options are key-value array. The keys may be:
    ///
    /// - "**CONNECTTIMEOUT**": "val", where val is in seconds (possibly with decimals)
    /// - "**TIMEOUT**": "val", where val is in seconds. This is the maximum delay for the whole request to complete before being aborted
    /// - "**LOW_SPEED_TIME**": "val", where val is in seconds. This is the maximum time where the transfer speed should be below the LOW_SPEED_LIMIT (if not specified 1b/s), before the transfer to be considered too slow and aborted
    /// - "**LOW_SPEED_LIMIT**": "val", where val is in bytes/second. See LOW_SPEED_TIME. Has only effect if LOW_SPEED_TIME is specified too
    /// - "**HEADERS**": "val", where val is an extra header to use when getting a web page For example "Accept: application/x-ogcwkt"
    /// - "**COOKIE**": "val", where val is formatted as COOKIE1=VALUE1; COOKIE2=VALUE2;
    /// - "**MAX_RETRY**": "val", where val is the maximum number of retry attempts if a 502, 503 or 504 HTTP error occurs. Default is 0
    /// - "**RETRY_DELAY**": "val", where val is the number of seconds between retry attempts. Default is 30
    ///
    /// - seealso: `Request option values`, for a description of the available options.
    ///
    /// - Parameters:
    ///   - url: URL to execute
    ///   - options: the array of key-value pairs - String:String
    /// - Returns: structure with return status code and String data
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
