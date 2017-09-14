//
//  AttributesView.swift
//  ngmaplib
//
//  Created by Dmitry Baryshnikov on 10.08.17.
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

class UIButtonWithAttachment: UIButton {
    var attachment: Attachment? = nil
}

public protocol AttachmentDelegate: class {
    func onAttachment(attachment: Attachment?)
    func onAddAttachment()
}

public class AttributesView: UIScrollView {
    
    weak var prevView: UIView? = nil

    public var showUnsetFields: Bool = false
    public var isSectionUppercased = true
    public var labelColor: UIColor = UIColor.black
    public var labelSize: CGFloat = 13.0
    public var textColor: UIColor = UIColor.black
    public var textSize: CGFloat = 16.0
    public var sectionTextColor: UIColor = UIColor.black
    public var sectionTextSize: CGFloat = 13.0
    public var attachmentImage: UIImage? = nil
    public var attachmentRemoteImage: UIImage? = nil
    public var attachmentDelegate: AttachmentDelegate? = nil

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    public func fill(feature: Feature) {
        prevView = nil
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        if let fc = feature.featureClass {
            if isSectionUppercased {
                addSection("Attributes".localized.uppercased())
            }
            else {
                addSection("Attributes".localized)
            }
            let fields = fc.fields
            var count: Int32 = 0
            for field in fields {
                if showUnsetFields {
                    addFieldLabel(feature, field, count)
                } else if feature.isFieldSet(index: count) {
                    addFieldLabel(feature, field, count)
                }
                
                count += 1
            }
            
            addSection("Attachments".localized.uppercased())
            
            for attachment in feature.getAttachments() {
                addAttachment(attachment)
            }
            
            let bottom = NSLayoutConstraint(item: prevView!,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
            NSLayoutConstraint.activate([bottom])
        }
    }
    
    func onAttachmentTap(sender: UIButtonWithAttachment) {
        attachmentDelegate?.onAttachment(attachment: sender.attachment)
    }
    
    public func addAttachment(_ attachment: Attachment) {
        
        let lb = UIButtonWithAttachment()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.setTitle(attachment.name, for: .normal)
        lb.setTitleColor(textColor, for: .normal)
        
        lb.titleLabel?.numberOfLines = 2
        lb.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        lb.backgroundColor = UIColor.clear
        lb.contentHorizontalAlignment = .left
        
        
        if attachment.path.isEmpty ||
            !FileManager.default.fileExists(atPath: attachment.path) {
            // Add download alert
            lb.setImage(attachmentRemoteImage, for: .normal)
        } else {
            // Add preview
            lb.setImage(attachmentImage, for: .normal)
        }
        
        lb.attachment = attachment
        lb.addTarget(self, action: #selector(onAttachmentTap), for: .touchUpInside)
        
        addSubview(lb)
        
        let top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 15.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height, width])
        
        prevView = lb
    }
    
    func addFieldNameLabel(_ field: Field) {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.numberOfLines = 2
        lb.textColor = labelColor
        lb.text = field.alias + "  "
        lb.font = UIFont.systemFont(ofSize: labelSize)
        
        addSubview(lb)
        
        let top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 15.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)

        
        NSLayoutConstraint.activate([leading, trailing, top, height, width])
        
        prevView = lb
    }
    
    public func addFieldLabel(_ feature: Feature, _ field: Field, _ pos: Int32) {
        addFieldNameLabel(field)
        
        let vl: UIView
        
        let value = feature.getField(asString: pos)
        if value.hasPrefix("http") {
            let tv = UITextView()
            tv.isEditable = false;
            tv.dataDetectorTypes = UIDataDetectorTypes.all;
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.textAlignment = .left
            tv.textColor = textColor
            tv.text = value
            tv.font = UIFont.systemFont(ofSize: textSize)
            tv.textContainerInset = UIEdgeInsets.zero
            tv.contentInset = UIEdgeInsets.zero
            tv.textContainer.lineFragmentPadding = 0
            tv.isScrollEnabled = false
            tv.backgroundColor = UIColor.clear
            
            vl = tv
        } else {
            let vl1 = UILabel()
            vl1.translatesAutoresizingMaskIntoConstraints = false
            vl1.textAlignment = .left
            vl1.numberOfLines = 0
            vl1.textColor = textColor
            vl1.text = value
            vl1.font = UIFont.systemFont(ofSize: textSize)
            
            vl = vl1
        }
        
        addSubview(vl)
        
        let top1 = NSLayoutConstraint(item: vl,
                                      attribute: .top,
                                      relatedBy: .equal,
                                      toItem: prevView,
                                      attribute: .bottom,
                                      multiplier: 1.0,
                                      constant: 12.0)
        
        let leading1 = NSLayoutConstraint(item: vl,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let trailing1 = NSLayoutConstraint(item: vl,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .trailing,
                                           multiplier: 1.0,
                                           constant: 8.0)
        
        let height1 = NSLayoutConstraint(item: vl,
                                         attribute: .height,
                                         relatedBy: .greaterThanOrEqual,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: 18.0)
        
        let width = NSLayoutConstraint(item: vl,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading1, trailing1, top1, height1, width])
        
        prevView = vl
        
    }
    
    public func addSection(_ name: String) {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.numberOfLines = 1
        lb.textColor = sectionTextColor
        lb.text = name
        lb.font = UIFont.systemFont(ofSize: sectionTextSize)
        
        addSubview(lb)
        
        var top: NSLayoutConstraint
        if prevView == nil {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 8.0)
        } else {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        }
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 14.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height])
        
        prevView = lb
    }


}

public class AttributesEditView: AttributesView, UITextFieldDelegate {
    
    public var attachmentBtnColor: UIColor = UIColor.blue
    public var attachmentBtnImage: UIImage? = nil
    public var delAttachmentBtnImage: UIImage? = nil
    private var fieldControlMap: [Int32: UITextField] = [:]
    weak var attachments: UIView!
    weak var bottomAttribute: NSLayoutConstraint? = nil
    
    public override func fill(feature: Feature) {
        if let fc = feature.featureClass {
            if isSectionUppercased {
                addSection("Attributes".localized.uppercased())
            }
            else {
                addSection("Attributes".localized)
            }
            let fields = fc.fields
            var count: Int32 = 0
            for field in fields {
                if showUnsetFields {
                    addFieldEdit(feature, field, count)
                } else if feature.isFieldSet(index: count) {
                    addFieldEdit(feature, field, count)
                }
                
                count += 1
            }
            
            addSection("Attachments".localized.uppercased())
            attachments = addSubview()
            for attachment in feature.getAttachments() {
                addAttachmentEdit(attachment)
            }
            addAttachmentBtn()
            
            let bottom = NSLayoutConstraint(item: prevView!,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
            NSLayoutConstraint.activate([bottom])
        }
    }
    
    public func addFieldEdit(_ feature: Feature, _ field: Field, _ pos: Int32) {
        addFieldNameLabel(field)
        
        
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .left
        tv.textColor = textColor
        tv.font = UIFont.systemFont(ofSize: textSize)
        tv.borderStyle = .roundedRect
        
        
        let value = feature.getField(asString: pos)
        switch(field.type) {
        case .STRING, .UNKNOWN:
            tv.text = value
        case .INTEGER:
            tv.text = value
            tv.keyboardType = .numberPad
        case .REAL:
            tv.text = value
            tv.keyboardType = .decimalPad
        case .DATE:
            let dateValue = feature.getField(asDateTime: pos)
            tv.delegate = self
            tv.isUserInteractionEnabled = true
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm".localized
            tv.text = formatter.string(from: dateValue)
        }
        
        fieldControlMap[pos] = tv
        addSubview(tv)
        
        let top = NSLayoutConstraint(item: tv,
                                      attribute: .top,
                                      relatedBy: .equal,
                                      toItem: prevView,
                                      attribute: .bottom,
                                      multiplier: 1.0,
                                      constant: 12.0)
        
        let leading = NSLayoutConstraint(item: tv,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: tv,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .trailing,
                                           multiplier: 1.0,
                                           constant: -8.0)
        
//        let width = NSLayoutConstraint(item: tv,
//                                       attribute: .width,
//                                       relatedBy: .lessThanOrEqual,
//                                       toItem: self,
//                                       attribute: .width,
//                                       multiplier: 1.0,
//                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top/*, width*/])
        
        prevView = tv
    }
    
    public func addAttachmentEdit(_ attachment: Attachment) {
        let lb = AttachmentCell(parent: self, attachment: attachment, textSize: textSize,
                                textColor: textColor, attachRemoteImg: attachmentRemoteImage,
                                attachImg: attachmentImage, delBtnImg: delAttachmentBtnImage)
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        attachments.addSubview(lb)
        
        var top: NSLayoutConstraint
        if attachments.subviews.count == 1 {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: attachments,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        } else {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 0.0)
        }
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: attachments,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: attachments,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 0.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: attachments,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        if bottomAttribute != nil {
            NSLayoutConstraint.deactivate([bottomAttribute!])
        }
        
        
        bottomAttribute = NSLayoutConstraint(item: attachments,
                                             attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: lb,
                                             attribute: .bottom,
                                             multiplier: 1.0,
                                             constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height, width, bottomAttribute!])
        
        prevView = lb
    }
    
    public func addAttachmentBtn() {
        
        let lb = UIButtonWithAttachment()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.setTitle("Add file".localized, for: .normal)
        lb.setTitleColor(attachmentBtnColor, for: .normal)
        
        lb.titleLabel?.numberOfLines = 2
        lb.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        lb.backgroundColor = UIColor.clear
        lb.contentHorizontalAlignment = .left
        lb.setImage(attachmentBtnImage, for: .normal)
        
        lb.addTarget(self, action: #selector(onAddAttachment), for: .touchUpInside)
        
        addSubview(lb)
        
        let top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 15.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height, width])
        
        prevView = lb
    }

    func onAddAttachment(sender: UIButtonWithAttachment) {
        attachmentDelegate?.onAddAttachment()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // user touch field
        let h = 265.0
        var alertHeight: CGFloat = 0.0
        var titleText = "Input date".localized
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
        
        let margin = Constants.Sizes.defaultPopoverMargin
        let rect = CGRect(x: 0, y: margin + 25.0,
                          width: alert.view.bounds.size.width - margin * 4.0,
                          height: alertHeight)
        let customView = UIDatePicker(frame: rect)
        customView.datePickerMode = UIDatePickerMode.dateAndTime
        
        alert.view.addSubview(customView)
        
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Cancel".localized,
                                      style: UIAlertActionStyle.cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Set".localized,
                                      style: UIAlertActionStyle.default,
                                      handler:
            { action in self.onSetValue(
                sender: action, view: customView, textField: textField)}))
        
        // show the alert
        viewController?.present(alert, animated: true, completion: nil)

        return false
    }
    
    func onSetValue(sender: UIAlertAction, view: UIDatePicker, textField: UITextField) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm".localized
        textField.text = formatter.string(from: view.date)
    }
    
    public func save(feature: Feature) -> Bool {
        if let fc = feature.featureClass {
            // Update fields
            
            let fields = fc.fields
            var count: Int32 = 0
            for field in fields {
                let value = fieldControlMap[count]?.text ?? ""
                
                if !value.isEmpty || (value.isEmpty &&
                    feature.isFieldSet(index: count)) {
                    
                    switch field.type {
                    case .STRING, .UNKNOWN:
                        feature.setField(for: count, string: value)
                    case .INTEGER:
                        if let intValue = Int32(value) {
                            feature.setField(for: count, int: intValue)
                        }
                    case .REAL:
                        if let realValue = Double(value) {
                            feature.setField(for: count, double: realValue)
                        }
                    case .DATE:
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy HH:mm".localized
                        if let dateValue = formatter.date(from: value) {
                            feature.setField(for: count, date: dateValue)
                        }
                    }
                }
                
                count += 1
            }
            
            // Add/remove attachments
            for case let cell as AttachmentCell in attachments.subviews {
                if let attachment = cell.label.attachment {
                    if attachment.id != -1 {
                        if cell.markToDelete {
                            _ = feature.deleteAttachment(attachment: attachment)
                        } else {
                            
                        }
                    } else {
                        _ = feature.addAttachment(name: attachment.name,
                                                  description: attachment.description,
                                                  path: attachment.path,
                                                  move: false)
                    }
                }
            }
            
            return fc.updateFeature(feature)
        }
        return false
    }

    public func addAttachment(name: String, path: String) {
        printMessage("Add attachment with name: \(name) and path: \(path)")
        let newAttachment = Attachment(name: name, description: "", path: path)
        addAttachmentEdit(newAttachment)
    }
    
    func addSubview() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        
        var top: NSLayoutConstraint
        if prevView == nil {
            top = NSLayoutConstraint(item: v,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 8.0)
        } else {
            top = NSLayoutConstraint(item: v,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 12.0)
        }
        
        let leading = NSLayoutConstraint(item: v,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: v,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: -8.0)
        
        NSLayoutConstraint.activate([leading, trailing, top])
        
        prevView = v
        return v
    }

}

class AttachmentCell: UIView {
    var parentView: AttributesEditView!
    var label: UIButtonWithAttachment!
    var deleteButton: UIButton!
    var heightY: NSLayoutConstraint!
    var heightD: NSLayoutConstraint!
    var markToDelete = false
    
    
    init(parent: AttributesEditView, attachment: Attachment, textSize: CGFloat,
         textColor: UIColor?, attachRemoteImg: UIImage?, attachImg: UIImage?,
         delBtnImg: UIImage?) {
        
        self.parentView = parent
        
        super.init(frame: CGRect.zero)
        
        label = UIButtonWithAttachment()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle(attachment.name, for: .normal)
        label.setTitleColor(textColor, for: .normal)
        
        label.titleLabel?.numberOfLines = 2
        label.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        label.backgroundColor = UIColor.clear
        label.contentHorizontalAlignment = .left
        
        
        if attachment.path.isEmpty ||
            !FileManager.default.fileExists(atPath: attachment.path) {
            // Add download alert
            label.setImage(attachRemoteImg, for: .normal)
        } else {
            // Add preview
            label.setImage(attachImg, for: .normal)
        }
        
        label.attachment = attachment
        
        addSubview(label)
        
        deleteButton = UIButton()
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = UIColor.clear
        deleteButton.setImage(delBtnImg, for: .normal)
        deleteButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
        
        addSubview(deleteButton)
        
        
        let top = NSLayoutConstraint(item: label,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 8.0)
        
        let bottom = NSLayoutConstraint(item: label,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 8.0)
        
        let leading = NSLayoutConstraint(item: label,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let trailing = NSLayoutConstraint(item: label,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: deleteButton,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: -16.0)
        
        let trailingD = NSLayoutConstraint(item: deleteButton,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .trailing,
                                           multiplier: 1.0,
                                           constant: 0.0)
        
        
        let topD = NSLayoutConstraint(item: deleteButton,
                                      attribute: .top,
                                      relatedBy: .equal,
                                      toItem: self,
                                      attribute: .top,
                                      multiplier: 1.0,
                                      constant: 8.0)
        
        let widthD = NSLayoutConstraint(item: deleteButton,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 28.0)
        
        heightD = NSLayoutConstraint(item: deleteButton,
                                     attribute: .height,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: 28.0)
        
        heightY = NSLayoutConstraint(item: self,
                                     attribute: .height,
                                     relatedBy: .greaterThanOrEqual,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: 40.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, bottom,
                                     trailingD, topD, widthD, heightD,
                                     heightY])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onDelete(sender: UIButton) {
        NSLayoutConstraint.deactivate([heightY])
        markToDelete = true
        
        deleteButton.isEnabled = false
        deleteButton.isHidden = true
        label.isEnabled = false
        label.isHidden = true
        
        heightD.constant = 0.0
        heightY = NSLayoutConstraint(item: self,
                                     attribute: .height,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: 0.0)
        
        NSLayoutConstraint.activate([heightY])
        
        layoutIfNeeded()
        parentView.layoutIfNeeded()
    }
    
}
