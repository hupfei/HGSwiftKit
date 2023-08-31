//
//  BaseViewModel.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import Foundation

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

open class BaseViewModel {
    public init() {
        
    }
}
