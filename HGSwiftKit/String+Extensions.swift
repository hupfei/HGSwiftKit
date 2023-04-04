//
//  String+Extensions.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation

public extension String {
    
    /// 按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
    var lengthAdaptToChinese: Int {
        var length = 0
        Array(self).forEach { c in
            if c.isASCII {
                length += 1
            } else {
                length += 2
            }
        }
        return length
    }
}
