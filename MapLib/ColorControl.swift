//
//  ColorControl.swift
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

extension UIColor {
    
    var redValue: Int {
        let out = Int(CIColor(color: self).red * 255.0)
        if out > 255 {
            return 255
        }
        if out < 0 {
            return 0
        }
        return out
    }
    
    var greenValue: Int {
        let out = Int(CIColor(color: self).green * 255.0)
        if out > 255 {
            return 255
        }
        if out < 0 {
            return 0
        }
        return out
        
    }
    
    var blueValue: Int {
        let out = Int(CIColor(color: self).blue * 255.0)
        if out > 255 {
            return 255
        }
        if out < 0 {
            return 0
        }
        return out
    }
}

@IBDesignable open class ColorControl: UIControl {
    
    public var label: UILabel!
    public var imageView: UIImageView!
    public var text: UILabel!
    public var value: UITextField!
    
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
    
    @IBInspectable open var labelColor: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    @IBInspectable open var labelTextSize: CGFloat = 17.0 {
        didSet {
            label.font = UIFont.systemFont(ofSize: labelTextSize)
        }
    }
    
    @IBInspectable open var textColor: UIColor? {
        get {
            return text.textColor
        }
        set {
            text.textColor = newValue
        }
    }
    
    @IBInspectable open var textTextSize: CGFloat = 17.0 {
        didSet {
            text.font = UIFont.systemFont(ofSize: textTextSize)
        }
    }
    
    @IBInspectable open var valueTextSize: CGFloat = 17.0 {
        didSet {
            value.font = UIFont.systemFont(ofSize: valueTextSize)
        }
    }
    
    
    @IBInspectable open var image: UIImage? {
        didSet {
            imageView.image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            imageView.tintColor = color
        }
    }
    
    @IBInspectable open var color: UIColor = UIColor.red {
        didSet {
            imageView.tintColor = color
            value.text = "\(color.redValue) \(color.greenValue) \(color.blueValue)"
        }
    }
    
    @IBInspectable open var sliderColor: UIColor = UIColor.white
    @IBInspectable open var sliderMinColor: UIColor = UIColor.blue
    @IBInspectable open var sliderMaxColor: UIColor = UIColor.gray
    
    //MARK: Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControls()
    }
    
    func onTextChanged(sender: UITextField) {
        let rgb = value.text?.components(separatedBy: " ")
        if rgb?.count == 3 {
            imageView.tintColor = UIColor(red: CGFloat(Float(rgb![0]) ?? 0.0) / 255.0,
                                          green: CGFloat(Float(rgb![1]) ?? 0.0) / 255.0,
                                          blue: CGFloat(Float(rgb![2]) ?? 0.0) / 255.0,
                                          alpha: 1.0)
        }
    }
    
    func onImageViewTapped(sender: UITapGestureRecognizer) {
        let h = 420.0
        var alertHeight: CGFloat = 0.0
        var titleText = ""
        for _ in stride(from: 0.0, through: h, by: 28.0) {
            titleText += "\n"
            alertHeight += 25.0
        }
        
        let alert = UIAlertController(title: titleText,
                                      message: "",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let subView = alert.view.subviews.first!
        let alertContentView = subView.subviews.first!
        alertContentView.backgroundColor = UIColor.white
        alertContentView.layer.cornerRadius = Constants.Sizes.dialogCornerRadius
        
        let rect = CGRect(x: 0.0, y: 0.0, width: Constants.Sizes.alertWidth, height: alertHeight)
        let customView = SelectColorView(color: imageView.tintColor, frame: rect,
                                         textSize: labelTextSize,
                                         sliderMinColor: sliderMinColor,
                                         sliderMaxColor: sliderMaxColor,
                                         sliderColor: sliderColor)
        
        alert.view.addSubview(customView)
        
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""),
                                      style: UIAlertActionStyle.cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Create", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""),
                                      style: UIAlertActionStyle.default,
                                      handler:
            { action in self.onUpdateColor(sender: action, view: customView)}))
        
        // show the alert
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func onUpdateColor(sender: UIAlertAction, view: SelectColorView) {
        color = UIColor(red: CGFloat(view.red.getSizeValue() / 255.0),
                        green: CGFloat(view.green.getSizeValue() / 255.0),
                        blue: CGFloat(view.blue.getSizeValue() / 255.0),
                        alpha: 1.0)
    }
    
    func setupControls() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        addSubview(imageView)
        
        text = UILabel()
        text.text = "RGB:"
        text.textAlignment = .right
        text.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(text)
        
        value = UITextField()
        value.keyboardType = UIKeyboardType.decimalPad
        value.borderStyle = UITextBorderStyle.roundedRect
        value.translatesAutoresizingMaskIntoConstraints = false
        value.addTarget(self, action: #selector(onTextChanged), for: .editingDidEnd)
        
        addSubview(value)
        
        let labelTopCt = NSLayoutConstraint(item: label,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let labelLeadingCt = NSLayoutConstraint(item: label,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: 0.0)
        let labelTrailingCt = NSLayoutConstraint(item: label,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        
        let imageTopCt = NSLayoutConstraint(item: imageView,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: label,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
        
        let imageLeadingCt = NSLayoutConstraint(item: imageView,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: 0.0)
        
        let imageWidthCt = NSLayoutConstraint(item: imageView,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 28.0)
        
        let imageHeightCt = NSLayoutConstraint(item: imageView,
                                               attribute: .height,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1.0,
                                               constant: 28.0)
        
        let valueYCt = NSLayoutConstraint(item: value,
                                          attribute: .centerY,
                                          relatedBy: .equal,
                                          toItem: imageView,
                                          attribute: .centerY,
                                          multiplier: 1.0,
                                          constant: 0.0)
        
        let valueWidthCt = NSLayoutConstraint(item: value,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 124.0)
        
        let valueTrailingCt = NSLayoutConstraint(item: value,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        
        let textLeadingCt = NSLayoutConstraint(item: text,
                                               attribute: .leading,
                                               relatedBy: .equal,
                                               toItem: imageView,
                                               attribute: .trailing,
                                               multiplier: 1.0,
                                               constant: 16.0)
        let textTrailingCt = NSLayoutConstraint(item: text,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: value,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: -16.0)
        
        let textYCt = NSLayoutConstraint(item: text,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: imageView,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        NSLayoutConstraint.activate([labelTopCt, labelLeadingCt, labelTrailingCt,
                                     imageTopCt, imageLeadingCt, imageWidthCt,
                                     imageHeightCt, valueYCt, valueWidthCt,
                                     valueTrailingCt, textLeadingCt, textTrailingCt,
                                     textYCt])
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

class ColorView: UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topLeft, .topRight], radius: 10)
    }
}

class SelectColorView: UIView {
    
    var preview: ColorView!
    var red: SizeControl!
    var green: SizeControl!
    var blue: SizeControl!
    
    init(color: UIColor, frame: CGRect, textSize: CGFloat, sliderMinColor: UIColor, sliderMaxColor: UIColor, sliderColor: UIColor) {
        super.init(frame: frame)
        setupControls(color: color, textSize: textSize, sliderMinColor: sliderMinColor, sliderMaxColor: sliderMaxColor, sliderColor: sliderColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onChangeEvent(sender: Any) {
        if let sizeControl = sender as? SizeControl {
            if let currentColor = preview.backgroundColor {
                var red = Float(currentColor.redValue)
                var green = Float(currentColor.greenValue)
                var blue = Float(currentColor.blueValue)
                
                switch sizeControl.tag {
                case 0:
                    red = sizeControl.getSizeValue()
                case 1:
                    green = sizeControl.getSizeValue()
                case 2:
                    blue = sizeControl.getSizeValue()
                default:
                    break
                }
                
                preview.backgroundColor = UIColor(red: CGFloat(red / 255.0),
                                                  green: CGFloat(green / 255.0),
                                                  blue: CGFloat(blue / 255.0),
                                                  alpha: 1.0)
            }
        }
    }
    
    func setupControls(color: UIColor, textSize: CGFloat, sliderMinColor: UIColor, sliderMaxColor: UIColor, sliderColor: UIColor) {
        preview = ColorView()
        preview.backgroundColor = color
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(preview)
        
        red = SizeControl(oneLine: true)
        red.labelText = "R: "
        red.labelTextSize = textSize
        red.valueTextSize = textSize
        red.sliderMinColor = sliderMinColor
        red.sliderMaxColor = sliderMaxColor
        red.sliderColor = sliderColor
        red.sliderMinValue = 0.0
        red.sliderMaxValue = 255.0
        red.translatesAutoresizingMaskIntoConstraints = false
        red.sliderValue = "\(color.redValue)"
        red.tag = 0
        red.addTarget(self, action: #selector(onChangeEvent), for: .valueChanged)
        
        addSubview(red)
        
        green = SizeControl(oneLine: true)
        green.labelText = "G: "
        green.labelTextSize = textSize
        green.valueTextSize = textSize
        green.sliderMinColor = sliderMinColor
        green.sliderMaxColor = sliderMaxColor
        green.sliderColor = sliderColor
        green.sliderMinValue = 0.0
        green.sliderMaxValue = 255.0
        green.translatesAutoresizingMaskIntoConstraints = false
        green.sliderValue = "\(color.greenValue)"
        green.tag = 1
        green.addTarget(self, action: #selector(onChangeEvent), for: .valueChanged)
        
        addSubview(green)
        
        blue = SizeControl(oneLine: true)
        blue.labelText = "B: "
        blue.labelTextSize = textSize
        blue.valueTextSize = textSize
        blue.sliderMinColor = sliderMinColor
        blue.sliderMaxColor = sliderMaxColor
        blue.sliderColor = sliderColor
        blue.sliderMinValue = 0.0
        blue.sliderMaxValue = 255.0
        blue.translatesAutoresizingMaskIntoConstraints = false
        blue.sliderValue = "\(color.blueValue)"
        blue.tag = 2
        blue.addTarget(self, action: #selector(onChangeEvent), for: .valueChanged)
        
        addSubview(blue)
        
        let previewTopCt = NSLayoutConstraint(item: preview,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0.0)
        
        let previewLeadingCt = NSLayoutConstraint(item: preview,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .leading,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        
        let previewTrailingCt = NSLayoutConstraint(item: preview,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .trailing,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        let previewHeightCt = NSLayoutConstraint(item: preview,
                                                 attribute: .height,
                                                 relatedBy: .greaterThanOrEqual,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: 256.0)
        
        let redTop = NSLayoutConstraint(item: red,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: preview,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 16.0)
        
        let redLeadingCt = NSLayoutConstraint(item: red,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 16.0)
        
        let redTrailingCt = NSLayoutConstraint(item: red,
                                               attribute: .trailing,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .trailing,
                                               multiplier: 1.0,
                                               constant: -16.0)
        
        let redHeightCt = NSLayoutConstraint(item: red,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1.0,
                                             constant: 28.0)
        
        let greenTop = NSLayoutConstraint(item: green,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: red,
                                          attribute: .bottom,
                                          multiplier: 1.0,
                                          constant: 12.0)
        
        let greenLeadingCt = NSLayoutConstraint(item: green,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: 16.0)
        
        let greenTrailingCt = NSLayoutConstraint(item: green,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: -16.0)
        
        let greenHeightCt = NSLayoutConstraint(item: green,
                                               attribute: .height,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1.0,
                                               constant: 28.0)
        
        let blueTop = NSLayoutConstraint(item: blue,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: green,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 12.0)
        
        let blueLeadingCt = NSLayoutConstraint(item: blue,
                                               attribute: .leading,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .leading,
                                               multiplier: 1.0,
                                               constant: 16.0)
        
        let blueTrailingCt = NSLayoutConstraint(item: blue,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .trailing,
                                                multiplier: 1.0,
                                                constant: -16.0)
        
        let blueHeightCt = NSLayoutConstraint(item: blue,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: 28.0)
        
        NSLayoutConstraint.activate([previewTopCt, previewLeadingCt,
                                     previewTrailingCt, previewHeightCt,
                                     redTop, redLeadingCt,
                                     redTrailingCt, redHeightCt,
                                     greenTop, greenLeadingCt,
                                     greenTrailingCt, greenHeightCt,
                                     blueTop, blueLeadingCt,
                                     blueTrailingCt, blueHeightCt
            ])
    }
}
