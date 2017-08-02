//
//  Common.swift
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

// https://stackoverflow.com/a/40189217/2901140
func toArrayOfCStrings(_ values: [String:String]?) -> UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> {
    var buffer: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>
    if values == nil {
        buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1)
        buffer[0] = nil
    }
    else {
        buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: values!.count + 1)
    
        for (index, value) in values!.enumerated() {
            let keyValue = value.key + "=" + value.value
            buffer[index] = UnsafeMutablePointer<Int8>(mutating: (keyValue as NSString).utf8String!)
        }
        buffer[values!.count] = nil
    }
    return buffer
}

public func bridge<T: AnyObject>(obj: T) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(obj).toOpaque()
    // return unsafeAddressOf(obj) // ***
}

public func bridge<T: AnyObject>(ptr: UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    // return unsafeBitCast(ptr, T.self) // ***
}

func printError(_ message: String) {
    print("ngmobile error: \(message)")
}

func printMessage(_ message: String) {
    if Constants.debugMode {
        print("ngmobile: \(message)")
    }
}

func printWarning(_ message: String) {
    if Constants.debugMode {
        print("ngmobile warning: \(message)")
    }
}

struct Constants {
    static let debugMode = true
    static let refreshTime = 0.35
}
