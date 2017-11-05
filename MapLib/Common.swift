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

import UIKit
import ngstore

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

extension UIView {
    
    var viewController: UIViewController? {
        
        var responder: UIResponder? = self
        
        while responder != nil {
            
            if let responder = responder as? UIViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
}

public typealias funcReturnCode = ngstore.ngsCode

public func hexStringToUIColor (hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 8) {
        return UIColor.gray
    }
    
    var rgbaValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbaValue)
    
    return UIColor(
        red:   CGFloat((rgbaValue & 0xFF000000) >> 24) / 255.0,
        green: CGFloat((rgbaValue & 0x00FF0000) >> 16) / 255.0,
        blue:  CGFloat((rgbaValue & 0x0000FF00) >> 8)  / 255.0,
        alpha: CGFloat((rgbaValue & 0x000000FF) >> 0)  / 255.0
    )
}

public func uiColorToHexString(color: UIColor) -> String {
    var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0),
                                     CGFloat(0.0), CGFloat(0.0))
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return String(format: "#%02x%02x%02x%02x",
                  Int(red * 255),
                  Int(green * 255),
                  Int(blue * 255),
                  Int(alpha * 255))
}

public struct returnCodeEnum {
    public static let SUCCESS = COD_SUCCESS
    public static let FINISHED = COD_FINISHED
    public static let IN_PROCESS = COD_IN_PROCESS
    public static let CANCELED = COD_CANCELED
}

struct Constants {
    static let debugMode = true
    static let refreshTime = 0.35
    
    struct Map {
        static let tolerance = 11.0
        static let epsg: Int32 = 3857
    }
    
    struct Sizes {
        static let minPanPix: Double = 4.0
        static let dialogCornerRadius: CGFloat = 10.0
        static let alertWidth: CGFloat = 270.0
        static let defaultPopoverMargin: CGFloat = 8.0
    }
    
    static let bandleId = "com.nextgis.MapLibSwift"
    static let tmpDirCatalogPath = "ngc://Local connections/Home/tmp"
    static let docDirCatalogPath = "ngc://Local connections/Home/Documents"
}
