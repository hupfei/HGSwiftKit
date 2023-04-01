//
//  HGCountdown.swift
//  eycCustomerIOS
//
//  Created by hupengfei on 2022/3/3.
//  Copyright © 2022 EVT. All rights reserved.
//

import Foundation

class HGCountdown {
    
    typealias TimeChangedBlock = (Int) -> Void
        
    static let shard = HGCountdown()

    /// key: identifier, value: remainingTime
    private var remainingTimes: [String: Int] = [:]
    private var timer: DispatchSourceTimer?
    private let lock = NSLock()

    /// 开启定时器
    /// - Parameters:
    ///   - identifier: 定时器唯一标识符
    func startTimer(identifier: String,
                    duration: Int = 60,
                    timeChangedHandler: @escaping TimeChangedBlock) {
        if !remainingTimes.contains(where: { $0.key == identifier }) {
            remainingTimes[identifier] = duration
        }
        if timer != nil {
            //定时器已启动
            return
        }
        
        func timeChanged() {
            lock.lock()
            defer { lock.unlock() }
            
            let times = self.remainingTimes
            for (identifier, time) in times {
                let remainingTime = time - 1
                self.remainingTimes[identifier] = remainingTime
                //倒计时回调
                timeChangedHandler(remainingTime)
                
                if remainingTime <= 0 {
                    //当前类型倒计时结束
                    self.remainingTimes.removeValue(forKey: identifier)
                }
            }
            
            closeTimerIfNedded()
        }
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                timeChanged()
            }
        })
        timer?.resume()
    }
    
    func removeTimer(identifier: String) {
        remainingTimes.removeValue(forKey: identifier)
        closeTimerIfNedded()
    }
    
    // 所有的场景倒计时都结束后关闭定时器
    private func closeTimerIfNedded() {
        let isFinished = remainingTimes.values.filter { $0 > 0 }.isEmpty
        if isFinished, timer != nil {
            timer?.cancel()
            timer = nil
        }
    }
}
