//
//  SizeControl.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 19.08.17.
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

/// Size control class. Control consist of slider and input field. Slider change input field value. If input field changes, slider changed too.
@IBDesignable open class SizeControl: UIControl {
    
    /// Label near slider.
    public var label: UILabel!
    
    /// Slider.
    public var slider: UISlider!
    
    /// Input field.
    public var value: UITextField!
    
    var labelTopCt: NSLayoutConstraint?
    var labelLeadingCt: NSLayoutConstraint?
    var labelTrailingCt: NSLayoutConstraint?
    
    var sliderTopCt: NSLayoutConstraint?
    var sliderLeadingCt: NSLayoutConstraint?
    var sliderTrailingCt: NSLayoutConstraint?
    
    var valueTopCt: NSLayoutConstraint?
    var valueLeadingCt: NSLayoutConstraint?
    var valueTrailingCt: NSLayoutConstraint?
    var valueWidth: NSLayoutConstraint?
    
    /// Label text read/write property.
    @IBInspectable open var labelText: String? {
        get {
            return label.text
        }
        set {
            if newValue != nil {
                label.text = NSLocalizedString(newValue!, comment: "")
            }
            else {
                label.text = newValue
            }
        }
    }
    
    /// Label color read/write property.
    @IBInspectable open var labelColor: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    /// Label text size. Default value is 17.
    @IBInspectable open var labelTextSize: CGFloat = 17.0 {
        didSet {
            label.font = UIFont.systemFont(ofSize: labelTextSize)
        }
    }
    
    /// Slider thumb tint color.
    @IBInspectable open var sliderColor: UIColor? {
        get {
            return slider.thumbTintColor
        }
        set {
            slider.thumbTintColor = newValue
        }
    }
    
    /// Slider minimum track tint color.
    @IBInspectable open var sliderMinColor: UIColor? {
        get {
            return slider.minimumTrackTintColor
        }
        set {
            slider.minimumTrackTintColor = newValue
        }
    }
    
    /// Slider maximum track tint color.
    @IBInspectable open var sliderMaxColor: UIColor? {
        get {
            return slider.maximumTrackTintColor
        }
        set {
            slider.maximumTrackTintColor = newValue
        }
    }
    
    /// Slider minimum value.
    @IBInspectable open var sliderMinValue: Float {
        get {
            return slider.minimumValue
        }
        set {
            slider.minimumValue = newValue
        }
    }
    
    /// Slider maximum value.
    @IBInspectable open var sliderMaxValue: Float {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }
    
    /// Slider value.
    @IBInspectable open var sliderValue: String = "0" {
        didSet {
            slider.value = Float(sliderValue) ?? 0.0
            value.text = sliderValue
        }
    }
    
    /// Input text control text ize. Default value is 17.
    @IBInspectable open var valueTextSize: CGFloat = 17.0 {
        didSet {
            value.font = UIFont.systemFont(ofSize: valueTextSize)
        }
    }
    
    /// The slider, label and input filed are in one or two lines.
    @IBInspectable open var oneLine: Bool = false {
        didSet {
            setConstraints(oneLine)
        }
    }
    
    //MARK: Initialization
    public init(oneLine: Bool) {
        super.init(frame: CGRect.zero)
        self.oneLine = oneLine
        setupControls()
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControls()
    }
    
    func onValueChanged(sender: UISlider) {
        value.text = "\(Int(slider.value))"
        sendActions(for: .valueChanged)
    }
    
    func onTextChanged(sender: UITextField) {
        slider.value = Float(value.text!) ?? 0.0
        sendActions(for: .valueChanged)
    }
    
    /// Set control value.
    ///
    /// - Parameter size: Value to set.
    public func setSizeValue(_ size: String) {
        slider.value = Float(size) ?? 0.0
        value.text = size
    }
    
    /// Get control value.
    ///
    /// - Returns: Float value.
    public func getSizeValue() -> Float {
        return Float(value.text!) ?? 0.0
    }
    
    func setupControls() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
        
        addSubview(slider)
        
        value = UITextField()
        value.keyboardType = UIKeyboardType.decimalPad
        value.borderStyle = UITextBorderStyle.roundedRect
        value.translatesAutoresizingMaskIntoConstraints = false
        value.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
        
        addSubview(value)
        
        setConstraints(oneLine)
    }
    
    func setConstraints(_ oneLine: Bool) {
        // Remove old
        if labelTopCt != nil && labelLeadingCt != nil && labelTrailingCt != nil &&
            sliderTopCt != nil && sliderLeadingCt != nil && sliderTrailingCt != nil &&
            valueTopCt != nil && valueTrailingCt != nil && valueWidth != nil {
            NSLayoutConstraint.deactivate([labelTopCt!, labelLeadingCt!, labelTrailingCt!,
                                           sliderTopCt!, sliderLeadingCt!, sliderTrailingCt!,
                                           valueTopCt!, valueTrailingCt!, valueWidth!])
        }
        // Add new
        labelLeadingCt = NSLayoutConstraint(item: label,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .leading,
                                            multiplier: 1.0,
                                            constant: 0.0)
        
        if oneLine {
            labelTopCt = NSLayoutConstraint(item: label,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: slider,
                                            attribute: .centerY,
                                            multiplier: 1.0,
                                            constant: 0.0)
            
            labelTrailingCt = NSLayoutConstraint(item: label,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: slider,
                                                 attribute: .leading,
                                                 multiplier: 1.0,
                                                 constant: -16.0)
            sliderTopCt = NSLayoutConstraint(item: slider,
                                             attribute: .top,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .top,
                                             multiplier: 1.0,
                                             constant: 0.0)
            
            sliderLeadingCt = NSLayoutConstraint(item: slider,
                                                 attribute: .leading,
                                                 relatedBy: .equal,
                                                 toItem: label,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: -16.0)
            
        } else {
            labelTopCt = NSLayoutConstraint(item: label,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
            
            labelTrailingCt = NSLayoutConstraint(item: label,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
            
            sliderTopCt = NSLayoutConstraint(item: slider,
                                             attribute: .top,
                                             relatedBy: .equal,
                                             toItem: label,
                                             attribute: .bottom,
                                             multiplier: 1.0,
                                             constant: 8.0)
            
            sliderLeadingCt = NSLayoutConstraint(item: slider,
                                                 attribute: .leading,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .leading,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
            
        }
        
        
        sliderTrailingCt = NSLayoutConstraint(item: slider,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: value,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: -16.0)
        
        if oneLine {
            valueTopCt = NSLayoutConstraint(item: value,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        } else {
            valueTopCt = NSLayoutConstraint(item: value,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: label,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
        }
        
        
        valueTrailingCt = NSLayoutConstraint(item: value,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .trailing,
                                             multiplier: 1.0,
                                             constant: 0.0)
        
        valueWidth = NSLayoutConstraint(item: value,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 50.0)
        
        NSLayoutConstraint.activate([labelTopCt!, labelLeadingCt!, labelTrailingCt!,
                                     sliderTopCt!, sliderLeadingCt!, sliderTrailingCt!,
                                     valueTopCt!, valueTrailingCt!, valueWidth!])
        
        layoutIfNeeded()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

