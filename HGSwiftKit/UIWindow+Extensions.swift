//
//  UIWindow+Extensions.swift
//  HGSwiftKit_Example
//
//  Created by hupengfei on 2023/4/1.
//  Copyright © 2023 hupfei. All rights reserved.
//

import UIKit

public extension UIWindow {
    
    class var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive && $0 is UIWindowScene })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .last?.windows
                .filter({ $0.isKeyWindow })
                .last
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    /// 当前控制器
    class var topViewController: UIViewController? {
        var window = UIWindow.keyWindow
        if window?.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            window = windows.filter({ $0.windowLevel == .normal }).first
        }
        let vc = window?.rootViewController
        return topViewController(vc)
    }
    
    // MARK: - private func
    class private func topViewController(_ vc :UIViewController?) -> UIViewController? {
        if vc == nil {
            return nil
        }
        
        if let presentVC = vc?.presentedViewController {
            return topViewController(presentVC)
        }
        
        if let tabVC = vc as? UITabBarController {
            if let selectVC = tabVC.selectedViewController {
                return topViewController(selectVC)
            }
            return nil
        }
        
        if let navC = vc as? UINavigationController {
            return topViewController(navC.visibleViewController)
        }
        
        return vc
    }
}
