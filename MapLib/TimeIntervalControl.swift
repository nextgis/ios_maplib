//
//  ColorControl.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 27.09.17.
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

/// Control to set time. For exampe update timeout or fetch timeout.
@IBDesignable open class TimeIntervalControl: UIControl {
    /// Text field.
    public var interval: FormTextField!
    /// Combo box button.
    public var type: ComboBoxControl!
    /// Interval type.
    ///
    /// - SECOND: Second
    /// - MINUTE: Minute
    /// - HOUR: Hour
    public enum IntervalType {
        case SECOND, MINUTE, HOUR
    }
    
    /// Time interval text.
    @IBInspectable open var intervalText: String? {
        get {
            return interval.text
        }
        set {
            interval.text = newValue
        }
    }
    
    /// Time interval text color.
    @IBInspectable open var intervalColor: UIColor? {
        get {
            return interval.textColor
        }
        set {
            interval.textColor = newValue
        }
    }
    
    /// Time interval text size. Default is 17.
    @IBInspectable open var intervalTextSize: CGFloat = 17.0 {
        didSet {
            interval.font = UIFont.systemFont(ofSize: intervalTextSize)
        }
    }
    
    /// Combobox buttom text color.
    @IBInspectable open var typeTextColor: UIColor? {
        get {
            return type.titleColor(for: .normal)
        }
        set {
            type.setTitleColor(newValue, for: .normal)
        }
    }
    
    /// Combobox buttom text size. Default is 17.
    @IBInspectable open var typeTextSize: CGFloat = 17.0 {
        didSet {
            type.titleLabel?.font = UIFont.systemFont(ofSize: intervalTextSize)
        }
    }
    
    /// Combobox buttom drop down image.
    @IBInspectable open var typeImage: UIImage? {
        didSet {
            type.setImage(typeImage, for: .normal) // ?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        }
    }
    
    /// Background color.
    @IBInspectable open var controlsBackgroundColor: UIColor? = UIColor.white {
        didSet {
            type.backgroundColor = controlsBackgroundColor
            interval.backgroundColor = controlsBackgroundColor
        }
    }
    
    /// Border color of input field and combobox button.
    @IBInspectable open var borderColor: UIColor? = UIColor.black {
        didSet {
            type.layer.borderColor = borderColor?.cgColor
            interval.layer.borderColor = borderColor?.cgColor
        }
    }
    
    /// Border radius of input field and combobox button.
    @IBInspectable open var borderRadius: CGFloat = 10.0 {
        didSet {
            type.layer.cornerRadius = borderRadius
            interval.layer.cornerRadius = borderRadius
            type.layer.masksToBounds = borderRadius > 0
            interval.layer.masksToBounds = borderRadius > 0
        }
    }
    
    /// Border width of input field and combobox button.
    @IBInspectable open var borderWidth: CGFloat = 1.0 {
        didSet {
            type.layer.borderWidth = borderWidth
            interval.layer.borderWidth = borderWidth
        }
    }
    
    //MARK: Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControls()
    }
    
    func setupControls() {
        interval = FormTextField()
        interval.translatesAutoresizingMaskIntoConstraints = false
        interval.keyboardType = .numberPad
        
//        interval.backgroundColor = controlsBackgroundColor
//        interval.layer.borderColor = borderColor?.cgColor
//        interval.layer.cornerRadius = borderRadius
//        interval.layer.masksToBounds = borderRadius > 0
//        interval.layer.borderWidth = borderWidth
//        interval.textColor = UIColor.black
        
        addSubview(interval)
        
        type = ComboBoxControl()
        type.translatesAutoresizingMaskIntoConstraints = false
        type.setupControls()
        type.selection = [
            NSLocalizedString("seconds", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""),
            NSLocalizedString("minutes", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""),
            NSLocalizedString("hours", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: "")
        ]
        type.setSelection(value: NSLocalizedString("minutes", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""))
        
//        type.backgroundColor = controlsBackgroundColor
//        type.layer.borderColor = borderColor?.cgColor
//        type.layer.cornerRadius = borderRadius
//        type.layer.masksToBounds = borderRadius > 0
//        type.layer.borderWidth = borderWidth
//        type.setTitleColor(UIColor.black, for: .normal)
        
        addSubview(type)
        
        let labelTopCt = NSLayoutConstraint(item: interval,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let labelLeadingCt = NSLayoutConstraint(item: interval,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: 0.0)
        let labelTrailingCt = NSLayoutConstraint(item: interval,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: type,
                                                 attribute: .leading,
                                                 multiplier: 1.0,
                                                 constant: -16.0)
        
        let labelBottomCt = NSLayoutConstraint(item: interval,
                                                 attribute: .bottom,
                                                 relatedBy: .equal,
                                                 toItem: type,
                                                 attribute: .bottom,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        
        let typeTopCt = NSLayoutConstraint(item: type,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        
        let typeTrailingCt = NSLayoutConstraint(item: type,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .trailing,
                                                multiplier: 1.0,
                                                constant: 0.0)
        
        let typeWidthCt = NSLayoutConstraint(item: type,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 110.0)
        
        NSLayoutConstraint.activate([labelTopCt, labelLeadingCt, labelTrailingCt,
                                     labelBottomCt,
                                     typeTopCt, typeTrailingCt, typeWidthCt])
    }
    
    /// Get time interval value as decimal.
    ///
    /// - Returns: Control value as decimal.
    public func getValueAsDecimal() -> Int {
        return Int(interval.text ?? "0") ?? 0
    }
    
    /// Get time interval value as double.
    ///
    /// - Returns: Control value as double.
    public func getValueAsReal() -> Double {
        return Double(interval.text ?? "0.0") ?? 0.0
    }
    
    /// Set control value as double.
    ///
    /// - Parameter real: Double value.
    public func setValue(real: Double) {
        interval.text = "\(real)"
    }
    
    /// Set control value as decimal.
    ///
    /// - Parameter decimal: Decimal value.
    public func setValue(decimal: Int) {
        interval.text = "\(decimal)"
    }
    
    /// Get time interval type.
    ///
    /// - Returns: Time interval type.
    public func getType() -> IntervalType {
        switch type.currentValue {
        case NSLocalizedString("seconds", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""):
            return .SECOND
        case NSLocalizedString("minutes", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""):
            return .MINUTE
        case NSLocalizedString("hours", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""):
            return .HOUR
        default:
            return .MINUTE
        }
    }
    
    /// Set time interval type.
    ///
    /// - Parameter value: Time interval type.
    public func setType(value: IntervalType) {
        switch value {
        case .SECOND:
            type.setSelection(value: NSLocalizedString("seconds", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""))
        case .MINUTE:
            type.setSelection(value: NSLocalizedString("minutes", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""))
        case .HOUR:
            type.setSelection(value: NSLocalizedString("hours", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""))
//        default:
//            break
        }
    }
}

/// Edit control with text align.
@IBDesignable open class FormTextField: UITextField {
    
    /// Padding left value. Default is 8.
    @IBInspectable var paddingLeft: CGFloat = 8.0
    /// Padding right value. Default is 8.
    @IBInspectable var paddingRight: CGFloat = 8.0
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
