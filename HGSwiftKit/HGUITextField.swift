//
//  HGUITextField.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

open class HGUITextField: UITextField, UITextFieldDelegate {
    ///修改 placeholder 的颜色
    public var placeholderColor: UIColor? = UIColor(hexString: "C4C8D0") {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    ///文字在输入框内的 padding
    public var textInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    ///clearButton 在默认位置上的偏移
    public var clearButtonPositionAdjustment: UIOffset = .zero
    ///允许输入的最大文字长度
    public var maximumTextLength: Int?
    ///是否按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
    ///默认为 NO
    public var shouldCountingNonASCIICharacterAsTwo: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialize()
    }
    
    private func didInitialize() {
        self.delegate = self
        addTarget(self, action: #selector(handleTextChangeEvent(textField:)), for: UIControl.Event.editingChanged)
    }
    
    public override var text: String? {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let _maximumTextLength = maximumTextLength else { return true }

        //中文输入法正在输入拼音的过程中，不应该限制字数
        if let _ = markedTextRange {
            return true
        }

        //允许删除
        if string.isEmpty, range.length > 0 {
            return true
        }

        let rangeLength = (shouldCountingNonASCIICharacterAsTwo ? text?.slicing(from: range.location, length: range.length)?.lengthAdaptToChinese : range.length) ?? 0
        if lengthWithString(text) - rangeLength + lengthWithString(string) > _maximumTextLength {
            //裁剪将要插入的文字
            let substringLength = _maximumTextLength - lengthWithString(text) + rangeLength
            if substringLength > 0 && lengthWithString(string) > substringLength {
                if let allowedText = string.slicing(from: 0, length: substringLength), lengthWithString(allowedText) <= substringLength {
                    text = NSString(string: text ?? "").replacingCharacters(in: range, with: allowedText)
                }
            }
            return false
        }
        return true
    }
    
    public override var placeholder: String? {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.inset(by: textInsets)
        return super.textRect(forBounds: newBounds)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.inset(by: textInsets)
        return super.editingRect(forBounds: newBounds)
    }
    
    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.clearButtonRect(forBounds: bounds)
        result = result.offsetBy(dx: clearButtonPositionAdjustment.horizontal, dy: clearButtonPositionAdjustment.vertical)
        return result
    }
        
    private func lengthWithString(_ string: String?) -> Int {
        guard let _string = string else { return 0 }
        return shouldCountingNonASCIICharacterAsTwo ? _string.lengthAdaptToChinese : _string.count
    }
    
    private func updateAttributedPlaceholderIfNeeded() {
        if let _placeholder = placeholder, let _placeholderColor = placeholderColor {
            attributedPlaceholder = NSAttributedString(string: _placeholder, attributes: [.foregroundColor: _placeholderColor])
        }
    }
    
    @objc private func handleTextChangeEvent(textField: HGUITextField) {
        guard let _maximumTextLength = maximumTextLength else { return }
        
        if let undoManager = textField.undoManager, undoManager.isUndoing || undoManager.isRedoing { return }
        
        if let _ = markedTextRange { return }
                
        if let text = textField.text, _maximumTextLength < lengthWithString(textField.text) {
            //超过最大数，裁剪
            var slicingLength = _maximumTextLength
            if shouldCountingNonASCIICharacterAsTwo {
                var l = 0
                for (index, c) in text.enumerated() {
                    if c.isASCII {
                        l += 1
                        if l == _maximumTextLength {
                            slicingLength = index
                            break
                        }
                    } else {
                        l += 2
                        if l - 1 == _maximumTextLength {
                            slicingLength = index
                            break
                        }
                    }
                }
            }
            textField.text = text.slicing(from: 0, length: slicingLength)
        }
    }
}
