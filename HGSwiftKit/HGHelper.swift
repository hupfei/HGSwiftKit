//
//  HGHelper.swift
//  eycCustomerIOS
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

// MARK: - 常量

/// 屏幕宽度
public let kScreenWidth: CGFloat = UIScreen.main.bounds.width
/// 屏幕高度
public let kScreenHeight: CGFloat = UIScreen.main.bounds.height
/// 状态栏高度
public let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
/// 导航栏高度(包括状态栏)
public let kNavigationBarHeight: CGFloat = (kStatusBarHeight + 44)
/// 底部安全区域高度
public let kSafeAreaBottomHeight: CGFloat = kStatusBarHeight > 20 ? 34 : 0
/// tabbarcontroller 子viewcontroller 底部安全距离
public let kTabbarHeight: CGFloat = 49 + kSafeAreaBottomHeight
/// 线条高度
public let kLineHeight = 1.0 / UIScreen.main.scale

// MARK: - methods

public func CGRectSetX(_ rect: CGRect, x: CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: x, y: rect.origin.y), size: rect.size)
}

public func CGRectSetY(_ rect: CGRect, y: CGFloat) -> CGRect {
    return CGRect(origin: CGPoint(x: rect.origin.x, y: y), size: rect.size)
}

public func CGRectSetWidth(_ rect: CGRect, width: CGFloat) -> CGRect {
    if width < 0 { return rect }
    return CGRect(origin: rect.origin, size: CGSize(width: width, height: rect.height))
}

public func CGRectSetHeight(_ rect: CGRect, height: CGFloat) -> CGRect {
    if height < 0 { return rect }
    return CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: height))
}

public func CGFloatGetCenter(parent: CGFloat, child: CGFloat) -> CGFloat {
    return (parent - child) / 2.0
}

public extension Optional where Wrapped == Bool {

    var unwrappedBoolValue: Bool {
        guard let _self = self else { return false }
        return _self
    }
}
