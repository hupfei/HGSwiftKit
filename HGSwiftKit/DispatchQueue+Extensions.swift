//
//  DispatchQueue+Extensions.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

public extension DispatchQueue {
    
    static func MainThread(execute work: @escaping @convention(block) () -> Void) {
        if Thread.isMainThread {
            work()
            return
        }
        
        DispatchQueue.main.async {
            work()
        }
    }
}
