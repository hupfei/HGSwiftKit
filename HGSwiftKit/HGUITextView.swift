//
//  HGUITextView.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

public class HGUITextView: UITextView, UITextViewDelegate {
    ///允许输入的最大文字长度
    var maximumTextLength: Int?
    ///是否按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
    ///默认为 NO
    var shouldCountingNonASCIICharacterAsTwo: Bool = false
    ///placeholder文字
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    ///placeholder颜色
    var placeholderColor: UIColor? = UIColor(hexString: "#999999") {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = font
        label.textColor = placeholderColor
        label.textAlignment = textAlignment
        label.text = placeholder
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    public override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    public override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    public override var text: String? {
        didSet {
            handleTextChanged(sender: self)
        }
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            handleTextChanged(sender: self)
        }
    }
    
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChanged), name: UITextView.textDidChangeNotification, object: nil)
        
        contentInsetAdjustmentBehavior = .never
        self.delegate = self
        
        addSubview(placeholderLabel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if placeholder.isNilOrEmpty || frame.size == .zero {
            return
        }
        
        let x = textContainerInset.left + 5
        let y = textContainerInset.top
        let w = frame.size.width - x * 2
        let h = 20.0
        placeholderLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func lengthWithString(_ string: String?) -> Int {
        guard let _string = string else { return 0 }
        return shouldCountingNonASCIICharacterAsTwo ? _string.lengthAdaptToChinese : _string.count
    }
    
    @objc private func handleTextChanged(sender: Any) {
        var textView: HGUITextView?
        if let _sender = sender as? NSNotification, let object = _sender.object as? HGUITextView {
            if object == self {
                textView = object
            }
        } else if let _sender = sender as? HGUITextView {
            textView = _sender
        }
        if textView == nil {
            return
        }
        
        placeholderLabel.isHidden = !textView!.text.isNilOrEmpty
        
        guard let _maximumTextLength = maximumTextLength else { return }
        
        if let undoManager = undoManager, undoManager.isUndoing || undoManager.isRedoing { return }
        
        if let _ = markedTextRange { return }
                
        if let _text = textView!.text, _maximumTextLength < lengthWithString(_text) {
            //超过最大数，裁剪
            var slicingLength = _maximumTextLength
            if shouldCountingNonASCIICharacterAsTwo {
                var l = 0
                for (index, c) in _text.enumerated() {
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
            textView!.text = _text.slicing(from: 0, length: slicingLength)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let _maximumTextLength = maximumTextLength else { return true }

        //中文输入法正在输入拼音的过程中，不应该限制字数
        if let _ = markedTextRange {
            return true
        }

        //允许删除
        if text.isEmpty, range.length > 0 {
            return true
        }

        let rangeLength = (shouldCountingNonASCIICharacterAsTwo ? textView.text?.slicing(from: range.location, length: range.length)?.lengthAdaptToChinese : range.length) ?? 0
        if lengthWithString(textView.text) - rangeLength + lengthWithString(text) > _maximumTextLength {
            //裁剪将要插入的文字
            let substringLength = _maximumTextLength - lengthWithString(textView.text) + rangeLength
            if substringLength > 0 && lengthWithString(text) > substringLength {
                if let allowedText = text.slicing(from: 0, length: substringLength), lengthWithString(allowedText) <= substringLength {
                    textView.text = NSString(string: textView.text ?? "").replacingCharacters(in: range, with: allowedText)
                }
            }
            return false
        }
        return true
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self,
            name: UITextView.textDidChangeNotification,
            object: nil)
    }
}
